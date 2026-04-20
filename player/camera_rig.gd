class_name CameraRig extends Node3D

# OoT-style 3rd-person camera rig.
# Tree: CameraRig > YawPivot > PitchPivot > SpringArm3D > Camera3D.
# Rotation read in _process (fresh input every frame, independent of physics).
# Position follow in _physics_process (reads post-integration player pos).

@export var follow_lerp: float = 8.0
@export var mouse_sensitivity: float = 0.0025
@export var stick_sensitivity: float = 2.5
@export var pitch_min_deg: float = -60.0
@export var pitch_max_deg: float = 45.0
@export var realign_delay: float = 1.5
@export var realign_speed_threshold: float = 1.0
@export var realign_rate: float = 4.0
@export var spring_length: float = 4.5

@onready var yaw_pivot: Node3D = $YawPivot
@onready var pitch_pivot: Node3D = $YawPivot/PitchPivot
@onready var spring: SpringArm3D = $YawPivot/PitchPivot/SpringArm3D

var _yaw: float = 0.0
var _pitch: float = -0.15   # small downward default
var _time_since_cam_input: float = 0.0
var _target: Node3D = null
var _lock_on_active: bool = false


func set_target(t: Node3D) -> void:
	_target = t


func set_world_up(_v: Vector3) -> void:
	# Reserved for R2 inverted-gravity room. No-op in M1.
	pass


func set_lock_on(active: bool) -> void:
	_lock_on_active = active


func get_yaw() -> float:
	return _yaw


func get_pitch() -> float:
	return _pitch


func _ready() -> void:
	top_level = true
	spring.spring_length = spring_length
	spring.margin = 0.2
	spring.collision_mask = 1   # world layer only
	if _target != null:
		global_position = _target.global_position
	if DisplayServer.get_name() == "headless":
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event
		_yaw -= mm.relative.x * mouse_sensitivity
		_pitch -= mm.relative.y * mouse_sensitivity
		_time_since_cam_input = 0.0
	elif event.is_action_pressed(&"ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _process(delta: float) -> void:
	# Gamepad stick input.
	var stick: Vector2 = Input.get_vector(&"cam_left", &"cam_right", &"cam_up", &"cam_down")
	if stick.length() > 0.05:
		_yaw -= stick.x * stick_sensitivity * delta
		_pitch -= stick.y * stick_sensitivity * delta
		_time_since_cam_input = 0.0
	else:
		_time_since_cam_input += delta

	# Auto-realign behind player: triggered by idle camera + forward motion.
	# Using -velocity.dot(basis.z) for forward speed handles backpedal naturally.
	if not _lock_on_active and _time_since_cam_input >= realign_delay and _target is CharacterBody3D:
		var cbody: CharacterBody3D = _target
		var fs: float = -cbody.velocity.dot(cbody.basis.z)
		if fs > realign_speed_threshold:
			var desired_yaw: float = cbody.rotation.y + PI  # behind player
			_yaw = lerp_angle(_yaw, desired_yaw, clampf(realign_rate * delta, 0.0, 1.0))

	_pitch = clampf(_pitch, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))
	yaw_pivot.rotation.y = _yaw
	pitch_pivot.rotation.x = _pitch


func _physics_process(delta: float) -> void:
	# Position follow runs after the Player's own _physics_process integrates
	# velocity; reading global_position here avoids one-frame lag.
	if _target != null:
		global_position = global_position.lerp(
			_target.global_position,
			clampf(follow_lerp * delta, 0.0, 1.0)
		)
