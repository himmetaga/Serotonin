"""One third-person visual target: graded cellular ribs, not a Voronoi texture.

Blender coordinates: the +X destination sits beyond the existing playable arena.
No packages or external geometry. Editable source and runtime GLB stay separate.
"""
import bpy
import bmesh
import json
import math
import os
import random
from mathutils import Vector

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
rng = random.Random(1701)
groups = {key: [[], []] for key in ("Ivory_Ribs", "Peach_Web", "Thin_Membrane")}


def append_geometry(group, vertices, faces):
    target_v, target_f = groups[group]
    offset = len(target_v)
    target_v.extend(vertices)
    target_f.extend(tuple(offset + i for i in face) for face in faces)


def sweep(group, path, radii, sides=8):
    vertices, faces = [], []
    for i, center in enumerate(path):
        center = Vector(center)
        tangent = (Vector(path[min(i + 1, len(path) - 1)]) -
                   Vector(path[max(0, i - 1)])).normalized()
        side = tangent.cross(Vector((1, 0, 0))).normalized()
        up = tangent.cross(side).normalized()
        for k in range(sides):
            angle = math.tau * k / sides
            vertices.append(tuple(center + radii[i] *
                                  (math.cos(angle) * side + math.sin(angle) * up)))
    for i in range(len(path) - 1):
        for k in range(sides):
            a, b = i * sides + k, i * sides + (k + 1) % sides
            faces.append((a, b, b + sides, a + sides))
    faces.append(tuple(range(sides - 1, -1, -1)))
    start = (len(path) - 1) * sides
    faces.append(tuple(start + k for k in range(sides)))
    append_geometry(group, vertices, faces)


def surface(u, v):
    """An asymmetric arch shell; u is angle, v is graded shell width."""
    angle = .10 + (math.pi - .20) * u
    width = 4.9 + 2.5 * v
    height = 5.3 + 2.4 * v
    y = width * math.cos(angle) + .35 * math.sin(2 * angle)
    z = -.9 + height * math.sin(angle)
    x = 8.3 + 1.1 * v + .55 * math.sin(angle * 2.0 + .4) + .22 * math.sin(angle * 5)
    return Vector((x, y, z))


# Two load-bearing contours taper into roots; the intervening web is visibly finer.
for width in (0.0, 1.0):
    path = [surface(i / 52, width) for i in range(53)]
    radii = [.17 + .13 * (1 - math.sin(math.pi * i / 52)) for i in range(53)]
    sweep("Ivory_Ribs", path, radii, 10)

# Feet grow back into the platform edge instead of hanging in an empty backdrop.
for u in (0.0, 1.0):
    for v in (0.0, 1.0):
        start = surface(u, v)
        end = Vector((7.85, (1 if u == 0 else -1) * 3.95, -.22))
        path = [start.lerp(end, t / 10) + Vector((0, 0, -.4 * math.sin(math.pi * t / 10)))
                for t in range(11)]
        sweep("Ivory_Ribs", path, [.26 - .13 * t / 10 for t in range(11)], 8)

# Irregular triangulation and its face dual: shared edges form genuine open cells.
# This is a surface dual, not a volumetric Voronoi or physical bone simulation.
cols, rows = 20, 5
uvs = []
for j in range(rows + 1):
    for i in range(cols + 1):
        u = i / cols + (rng.uniform(-.016, .016) if 0 < i < cols else 0)
        v = j / rows + (rng.uniform(-.055, .055) if 0 < j < rows else 0)
        uvs.append(Vector((u, v)))
triangles = []
for j in range(rows):
    for i in range(cols):
        a = j * (cols + 1) + i
        b, c, d = a + 1, a + cols + 2, a + cols + 1
        triangles.extend(((a, b, c), (a, c, d)) if (i + j) % 2 else
                         ((a, b, d), (b, c, d)))
centers = [sum((uvs[i] for i in tri), Vector((0, 0))) / 3 for tri in triangles]
incident = [[] for _ in uvs]
for face_index, triangle in enumerate(triangles):
    for vertex in triangle:
        incident[vertex].append(face_index)
cells, edges = [], set()
for j in range(1, rows):
    for i in range(1, cols):
        index = j * (cols + 1) + i
        origin = uvs[index]
        cycle = sorted(incident[index], key=lambda face:
                       math.atan2(centers[face].y - origin.y, centers[face].x - origin.x))
        cells.append((origin, cycle))
        for a, b in zip(cycle, cycle[1:] + cycle[:1]):
            edges.add(tuple(sorted((a, b))))
for a, b in sorted(edges):
    start, end = centers[a], centers[b]
    path = [surface(*(start.lerp(end, t / 3))) for t in range(4)]
    radii = [.025 + .035 * (1 - start.lerp(end, t / 3).y) for t in range(4)]
    sweep("Peach_Web", path, radii, 6)

# Selected cells carry stretched, closed thin sheets; most cells remain open.
sheet_count = 0
for origin, cycle in cells:
    if not (.23 < origin.y < .77 and int(origin.x * cols) in (3, 7, 12, 16)):
        continue
    ring = [surface(*centers[index]) for index in cycle]
    center = surface(*origin) + Vector((.09, 0, 0))
    vertices = [tuple(center)] + [tuple(p) for p in ring]
    layer = len(vertices)
    vertices += [tuple(Vector(p) + Vector((.018, 0, 0))) for p in vertices[:]]
    faces = []
    for i in range(len(ring)):
        a, b = i + 1, (i + 1) % len(ring) + 1
        faces.extend(((0, a, b), (layer, layer + b, layer + a),
                      (a, a + layer, b + layer, b)))
    append_geometry("Thin_Membrane", vertices, faces)
    sheet_count += 1

# Branches join shell and columns; restrained veins only where structure needs them.
for u in (.06, .18, .34, .60, .79, .94):
    path = [surface(u + .022 * math.sin(t * math.pi / 12), t / 12) for t in range(13)]
    radii = [.075 + .04 * math.sin(t * math.pi / 12) for t in range(13)]
    sweep("Ivory_Ribs", path, radii, 8)

objects = []
audit = []
for name, (vertices, faces) in groups.items():
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    failures = sum(not edge.is_manifold for edge in bm.edges)
    degenerate = sum(face.calc_area() < 1e-10 for face in bm.faces)
    bm.to_mesh(mesh)
    bm.free()
    if failures or degenerate:
        raise RuntimeError(f"{name}: nonmanifold={failures}, degenerate={degenerate}")
    uv = mesh.uv_layers.new(name="GateUV")
    for polygon in mesh.polygons:
        polygon.use_smooth = True
        for li in polygon.loop_indices:
            co = mesh.vertices[mesh.loops[li].vertex_index].co
            uv.data[li].uv = (co.y / 16 + .5, co.z / 10)
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    color = {"Ivory_Ribs": (.73, .60, .48), "Peach_Web": (.52, .29, .24),
             "Thin_Membrane": (.80, .43, .29)}[name]
    mat.diffuse_color = (*color, 1)
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Roughness"].default_value = .65
    mesh.materials.append(mat)
    objects.append(obj)
    audit.append({"part": name, "triangles": sum(len(p.vertices) - 2 for p in mesh.polygons),
                  "nonmanifold_edges": failures, "degenerate_faces": degenerate})

triangle_count = sum(item["triangles"] for item in audit)
assert triangle_count <= 18000, triangle_count
assert min(v.co.x for obj in objects for v in obj.data.vertices) > 7.0
bpy.ops.object.select_all(action="SELECT")
bpy.context.view_layer.objects.active = objects[0]
bpy.context.preferences.filepaths.file_preview_type = 'NONE'
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(ROOT, "art/source/cellular_gate.blend"))
bpy.ops.export_scene.gltf(filepath=os.path.join(ROOT, "godot/assets/models/cellular_gate.glb"),
                         export_format="GLB", use_selection=True, export_apply=True,
                         export_yup=True, export_cameras=False, export_lights=False)
report = {"id": "cellular_gate", "status": "visual_target_not_final_art",
          "path": "godot/assets/models/cellular_gate.glb",
          "technical": {"triangles": triangle_count, "triangle_budget": 18000,
                        "nonmanifold_edges": 0, "degenerate_faces": 0},
          "triangles": triangle_count, "triangle_budget": 18000, "parts": audit,
          "open_cells": len(cells) - sheet_count, "closed_membrane_cells": sheet_count,
          "materials": 3, "texture_bytes": 0, "intersections": "Closed swept ribs overlap at junctions; not boolean-unioned.",
          "source": "art/source/cellular_gate.blend", "runtime": "godot/assets/models/cellular_gate.glb",
          "recipe": "art/tools/build_cellular_gate.py", "tool": bpy.app.version_string,
          "provenance": "Project-authored bpy geometry; no external assets.",
          "verification": {"source_topology": True, "export_reviewed": False, "runtime_reviewed": False}}
with open(os.path.join(ROOT, "art/cellular_gate_manifest.json"), "w", encoding="utf-8") as handle:
    json.dump(report, handle, indent=2)
print("CELLULAR_GATE=" + json.dumps(report))
