extends Node3D

const CAMERA_LAYER := 1 << 7
const ARM_LENGTH := 7.0
var yaw: float = PI * 0.5
var _arm: SpringArm3D
var _idle_time: float = 0.0
var _manual_time: float = 0.0


func setup(camera: Camera3D) -> void:
	name = "ThirdPersonCamera"
	_arm = SpringArm3D.new()
	_arm.name = "CameraArm"
	_arm.spring_length = ARM_LENGTH
	_arm.margin = 0.22
	_arm.collision_mask = CAMERA_LAYER
	add_child(_arm)
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.fov = 58.0
	camera.near = 0.12
	camera.far = 90.0
	camera.current = true
	_arm.add_child(camera)
	_set_arm_rotation()


func forward_direction() -> Vector3:
	return Vector3(sin(yaw), 0.0, cos(yaw))


func screen_to_world(input: Vector2) -> Vector3:
	var forward := forward_direction()
	var right := forward.cross(Vector3.UP)
	return (right * input.x - forward * input.y).limit_length(1.0)


func snap(player: Vector3, facing: Vector3) -> void:
	yaw = atan2(facing.x, facing.z)
	_idle_time = 0.0
	_manual_time = 0.0
	position = player + Vector3.UP * 1.1 + forward_direction() * 1.0
	_set_arm_rotation()


func orbit(radians: float) -> void:
	yaw = wrapf(yaw + radians, -PI, PI)
	_manual_time = 1.2
	_set_arm_rotation()


func advance(delta: float, player: Vector3, facing: Vector3, input_active: bool,
		reduced_motion: bool, combat_target: Vector3 = Vector3.INF) -> void:
	_manual_time = maxf(0.0, _manual_time - delta)
	_idle_time = 0.0 if input_active else _idle_time + delta
	# Keep orientation stable throughout movement/drag, preventing circular strafing.
	if not reduced_motion and _idle_time > 0.35 and _manual_time <= 0.0:
		var desired_direction := facing
		if combat_target.is_finite() and player.distance_to(combat_target) < 7.0:
			desired_direction = combat_target - player
		if desired_direction.length_squared() > 0.01:
			yaw = lerp_angle(yaw, atan2(desired_direction.x, desired_direction.z), 1.0 - exp(-2.8 * delta))
	var focus := player + forward_direction() * 1.0
	if not reduced_motion and combat_target.is_finite() and player.distance_to(combat_target) < 7.0:
		focus = player.lerp(combat_target, 0.20) + forward_direction() * 0.65
	var weight := 1.0 - exp(-(24.0 if reduced_motion else 18.0) * delta)
	position = position.lerp(focus + Vector3.UP * 1.1, weight)
	_set_arm_rotation()


func _set_arm_rotation() -> void:
	_arm.rotation = Vector3(deg_to_rad(-23.0), yaw + PI, 0.0)


func add_room_collisions(node: Node) -> void:
	if node is MeshInstance3D and not node.name.contains("Growing_Costal_Roots"):
		var instance := node as MeshInstance3D
		if instance.mesh and not instance.has_node("CameraOnlyCollision"):
			var body := StaticBody3D.new()
			body.name = "CameraOnlyCollision"
			body.collision_layer = CAMERA_LAYER
			body.collision_mask = 0
			var shape := CollisionShape3D.new()
			shape.shape = instance.mesh.create_trimesh_shape()
			body.add_child(shape)
			instance.add_child(body)
	for child: Node in node.get_children():
		add_room_collisions(child)
