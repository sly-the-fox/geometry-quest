class_name Player extends CharacterBody3D

# Analog 3D character controller. State-driven movement with buffered jump
# and coyote time. Input → camera-relative motion via camera_rig.get_yaw().

# ─── Tuning ────────────────────────────────────────────────────────────
@export var base_move_speed: float = 5.5
@export var gravity_accel: float = -24.0
@export var terminal_fall: float = -40.0
@export var ground_accel: float = 30.0
@export var ground_decel: float = 45.0
@export var air_control: float = 0.5
@export var jump_speed: float = 8.5
@export var coyote_duration: float = 0.12
@export var jump_buffer_duration: float = 0.1
@export var yaw_lerp_rate: float = 12.0

# ─── Internal ──────────────────────────────────────────────────────────
var coyote_timer: float = 0.0
var jump_buffer: float = 0.0
var _suppress_coyote_refill: bool = false
var _was_on_floor: bool = false

@onready var body: MeshInstance3D = $Body
@onready var camera_rig: CameraRig = $CameraRig
@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	floor_snap_length = 0.0
	body.mesh = Polyhedra.merkaba(0.6)
	camera_rig.set_target(self)
	for s in state_machine.get_children():
		if s is PlayerState:
			s.parent = self
			s.machine = state_machine
	state_machine.call_deferred("change_state", &"idle")


func _physics_process(delta: float) -> void:
	_tick_timers(delta)
	# Suppress-coyote-refill flag cleared on landing tick.
	if not _was_on_floor and is_on_floor():
		_suppress_coyote_refill = false
	_was_on_floor = is_on_floor()
	_rotate_idle_body(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"jump"):
		jump_buffer = jump_buffer_duration


# ─── Called by states ──────────────────────────────────────────────────

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = max(terminal_fall, velocity.y + gravity_accel * delta)
	elif velocity.y < 0.0:
		velocity.y = 0.0


func apply_horizontal_decel(delta: float) -> void:
	var h: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	h = h.move_toward(Vector3.ZERO, ground_decel * delta)
	velocity.x = h.x
	velocity.z = h.z


func apply_ground_move(input_vec: Vector2, delta: float) -> void:
	var target: Vector3 = _camera_relative(input_vec) * _speed()
	var cur: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	cur = cur.move_toward(target, ground_accel * delta)
	velocity.x = cur.x
	velocity.z = cur.z


func apply_air_move(input_vec: Vector2, delta: float) -> void:
	var target: Vector3 = _camera_relative(input_vec) * _speed()
	var cur: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	cur = cur.move_toward(target, ground_accel * air_control * delta)
	velocity.x = cur.x
	velocity.z = cur.z


func face_move_direction(delta: float) -> void:
	var h: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	if h.length() < 0.5:
		return
	var desired_yaw: float = atan2(-h.x, -h.z)  # rotation.y=0 faces -Z
	rotation.y = lerp_angle(rotation.y, desired_yaw, clampf(yaw_lerp_rate * delta, 0.0, 1.0))


func try_consume_jump() -> bool:
	if jump_buffer > 0.0 and coyote_timer > 0.0:
		jump_buffer = 0.0
		return true
	return false


# ─── Internals ─────────────────────────────────────────────────────────

func _tick_timers(delta: float) -> void:
	# Coyote timer refills only when firmly grounded (velocity.y <= 0) and
	# not in the immediate post-jump suppression window. This prevents the
	# first airborne tick from refilling coyote and allowing double-jump.
	if is_on_floor() and velocity.y <= 0.0 and not _suppress_coyote_refill:
		coyote_timer = coyote_duration
	else:
		coyote_timer = max(0.0, coyote_timer - delta)
	jump_buffer = max(0.0, jump_buffer - delta)


func _speed() -> float:
	return base_move_speed * GameState.stats.move_speed_mult()


func _camera_relative(input_vec: Vector2) -> Vector3:
	# Input.get_vector("move_left","move_right","move_up","move_down"):
	#   W (move_up)   → y = -1
	#   S (move_down) → y = +1
	# Godot 3D forward is -Z. We want W to move toward camera forward.
	# Negate input.y so W produces +forward.
	var yaw: float = camera_rig.get_yaw()
	var forward: Vector3 = Vector3(-sin(yaw), 0.0, -cos(yaw))
	var right: Vector3 = Vector3(cos(yaw), 0.0, -sin(yaw))
	var dir: Vector3 = (forward * -input_vec.y) + (right * input_vec.x)
	if dir.length() > 1.0:
		dir = dir.normalized()
	return dir * input_vec.length()


func _rotate_idle_body(delta: float) -> void:
	# Slow Y-spin on the merkaba Body mesh when nearly still (SPEC M1 note).
	var h: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	if h.length() < 0.5:
		body.rotate_y(0.35 * delta)
