class_name Hitbox extends Area3D

# Damage-dealing Area3D. Disabled (monitoring=false) by default — the
# attacker (AttackState or enemy AI) calls enable() during active frames
# and disable() on recovery. `team` is defense-in-depth against mask
# misconfiguration; `area_entered` additionally filters by area.team.

enum KnockbackMode {
	RADIAL,          # target - self (default for M2 PlaceholderHitbox)
	ATTACKER_FORWARD,  # parent's -Z axis
	UP,                # Vector3.UP
}

# ─── Config ────────────────────────────────────────────────────────────
@export var damage: int = 3
@export var damage_type: StringName = &"physical"
@export var knockback_speed: float = 6.0
@export var knockback_mode: KnockbackMode = KnockbackMode.RADIAL
@export var stagger_seconds: float = 0.25
@export var breaks_pattern: bool = false
@export var team: HealthComponent.Team = HealthComponent.Team.PLAYER


func _ready() -> void:
	monitoring = false
	area_entered.connect(_on_area_entered)


func enable() -> void:
	monitoring = true


func disable() -> void:
	monitoring = false


# ─── Internal ──────────────────────────────────────────────────────────

func _on_area_entered(area: Area3D) -> void:
	if not area is Hurtbox:
		return
	var hurtbox: Hurtbox = area
	if hurtbox.team == team:
		return
	hurtbox.receive(_build_info(hurtbox))


func _build_info(target: Hurtbox) -> DamageInfo:
	var info: DamageInfo = DamageInfo.new()
	info.amount = damage
	info.type = damage_type
	info.source = get_parent() as Node3D
	info.stagger_seconds = stagger_seconds
	info.breaks_pattern = breaks_pattern
	info.knockback = _knockback_vector(target)
	return info


func _knockback_vector(target: Hurtbox) -> Vector3:
	if knockback_speed <= 0.0:
		return Vector3.ZERO
	match knockback_mode:
		KnockbackMode.ATTACKER_FORWARD:
			var parent_node: Node3D = get_parent() as Node3D
			if parent_node != null:
				return -parent_node.global_transform.basis.z * knockback_speed
		KnockbackMode.UP:
			return Vector3.UP * knockback_speed
	# RADIAL fallback. Horizontal only — Y knockback goes through UP mode.
	var delta: Vector3 = target.global_position - global_position
	delta.y = 0.0
	if delta.length() < 0.001:
		return Vector3.ZERO
	return delta.normalized() * knockback_speed
