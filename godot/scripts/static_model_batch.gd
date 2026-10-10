extends RefCounted

# Only rigid, opaque models. Caller must explicitly authorize any opaque shaders.
static func combine(root: Node3D, opaque_shaders: Array[Shader] = [], excluded_names: Array[String] = [], included_names: Array[String] = []) -> Dictionary:
	var meshes: Array[MeshInstance3D] = []
	if not _collect_safe(root, meshes):
		return {"skipped": true}
	var selected: Array[MeshInstance3D] = []
	for instance: MeshInstance3D in meshes:
		var excluded := false
		var included := included_names.is_empty()
		for fragment: String in included_names:
			if String(instance.name).contains(fragment):
				included = true
		for fragment: String in excluded_names:
			if String(instance.name).contains(fragment):
				excluded = true
		if included and not excluded:
			selected.append(instance)
	meshes = selected
	var groups: Dictionary = {}
	var input_triangles := 0
	for instance: MeshInstance3D in meshes:
		for surface: int in instance.mesh.get_surface_count():
			var material := instance.get_active_material(surface)
			var opaque_standard := material is StandardMaterial3D and (material as StandardMaterial3D).transparency == BaseMaterial3D.TRANSPARENCY_DISABLED
			var opaque_custom := material is ShaderMaterial and (material as ShaderMaterial).shader in opaque_shaders
			if not opaque_standard and not opaque_custom:
				return {"skipped": true}
			if instance.mesh.surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES:
				return {"skipped": true}
			var format: int = instance.mesh.surface_get_format(surface)
			if format & (Mesh.ARRAY_FORMAT_BONES | Mesh.ARRAY_FORMAT_WEIGHTS):
				return {"skipped": true}
			# Imported local-to-scene materials can have different IDs but identical shading.
			# Storage/LOD flags are not vertex attributes; do not split batches on them.
			var attributes: int = format & ((1 << Mesh.ARRAY_MAX) - 1)
			var key := "%s/%d/%d/%d" % [_material_key(material), instance.layers, instance.cast_shadow, attributes]
			if not groups.has(key):
				var tool := SurfaceTool.new()
				tool.begin(Mesh.PRIMITIVE_TRIANGLES)
				tool.set_material(material)
				groups[key] = {"tool": tool, "source": instance}
			(groups[key]["tool"] as SurfaceTool).append_from(instance.mesh, surface,
				root.global_transform.affine_inverse() * instance.global_transform)
			input_triangles += _triangles(instance.mesh, surface)
	if groups.size() >= meshes.size():
		return {"skipped": true, "reason": "already_batched"}
	var batch := Node3D.new()
	batch.name = "StaticBatch"
	var output_triangles := 0
	for key: String in groups:
		var source: MeshInstance3D = groups[key]["source"]
		var output := MeshInstance3D.new()
		output.mesh = (groups[key]["tool"] as SurfaceTool).commit()
		output.layers = source.layers
		output.cast_shadow = source.cast_shadow
		batch.add_child(output)
		output_triangles += _triangles(output.mesh, 0)
	if input_triangles != output_triangles:
		batch.free()
		return {"skipped": true, "error": "triangle_count_mismatch"}
	root.add_child(batch)
	for instance: MeshInstance3D in meshes:
		instance.visible = false
	var report := {"skipped": false, "source_meshes": meshes.size(),
		"batch_meshes": groups.size(), "input_triangles": input_triangles,
		"output_triangles": output_triangles}
	root.set_meta("static_batch_report", report)
	return report


static func _material_key(material: Material) -> String:
	var properties: Dictionary = {}
	for property: Dictionary in material.get_property_list():
		var property_name: String = property["name"]
		if not (int(property["usage"]) & PROPERTY_USAGE_STORAGE) or property_name.begins_with("resource_"):
			continue
		var value: Variant = material.get(property_name)
		# Resource identity is retained for textures, passes, and other shading dependencies.
		properties[property_name] = value.get_instance_id() if value is Resource else value
	if material is ShaderMaterial:
		var shader_material := material as ShaderMaterial
		for uniform: Dictionary in shader_material.shader.get_shader_uniform_list():
			properties["uniform/" + String(uniform["name"])] = shader_material.get_shader_parameter(uniform["name"])
	return var_to_str(properties)


static func _collect_safe(node: Node, result: Array[MeshInstance3D]) -> bool:
	if node is AnimationPlayer or node is Skeleton3D or node.get_script() != null:
		return false
	if node is MeshInstance3D:
		var instance := node as MeshInstance3D
		if instance.skin != null or instance.material_overlay != null:
			return false
		if not instance.skeleton.is_empty() and instance.get_node_or_null(instance.skeleton) is Skeleton3D:
			return false
		if instance.mesh is ArrayMesh and (instance.mesh as ArrayMesh).get_blend_shape_count() > 0:
			return false
		if instance.mesh and instance.visible:
			result.append(instance)
	for child: Node in node.get_children():
		if not _collect_safe(child, result):
			return false
	return true


static func _triangles(mesh: Mesh, surface: int) -> int:
	var arrays := mesh.surface_get_arrays(surface)
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	return indices.size() / 3 if not indices.is_empty() else vertices.size() / 3
