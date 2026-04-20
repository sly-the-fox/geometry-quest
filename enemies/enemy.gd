class_name Enemy extends CharacterBody3D

# M2 dummy: gravity + hurtbox + health + red flash. No AI yet — M5 adds
# the state machine. CharacterBody3D (not StaticBody3D) so M5 reuses this
# scene directly. StandardMaterial3D.albedo_color tween drives the flash;
# M5 may promote to a shader uniform.

@export var gravity_accel: float = -24.0
@export var terminal_fall: float = -40.0
# M5 sets this from EnemyResource.pattern_locked. HealthComponent will
# (M3/M10) check this for the pattern-break ×2 multiplier.
@export var pattern_locked: bool = false

@onready var body: MeshInstance3D = $Body
@onready var health_component: HealthComponent = $HealthComponent

var _flash_tween: Tween = null
var _base_albedo: Color = Color.WHITE


func _ready() -> void:
	floor_snap_length = 0.0
	if body != null and body.material_override is StandardMaterial3D:
		var src: StandardMaterial3D = body.material_override
		var mat: StandardMaterial3D = src.duplicate()
		body.material_override = mat
		_base_albedo = mat.albedo_color
	health_component.damaged.connect(_on_damaged)
	health_component.released.connect(_on_released)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y = max(terminal_fall, velocity.y + gravity_accel * delta)
	elif velocity.y < 0.0:
		velocity.y = 0.0
	move_and_slide()


func _on_damaged(info: DamageInfo, _dealt: int) -> void:
	# Bridge HealthComponent → SignalBus (HC stays autoload-free for -s tests).
	SignalBus.enemy_damaged.emit(self, info)
	var mat: StandardMaterial3D = body.material_override as StandardMaterial3D
	if mat == null:
		return
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash_tween = create_tween()
	_flash_tween.tween_property(mat, ^"albedo_color", Color(1.0, 0.25, 0.25, 1.0), 0.08)
	_flash_tween.tween_property(mat, ^"albedo_color", _base_albedo, 0.08)


func _on_released() -> void:
	# Bible terminology: enemies are "released," not "killed."
	SignalBus.enemy_released.emit(self)
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	queue_free()
