class_name Hurtbox extends Area3D

# Damage-receiving Area3D. Collision masks enforce team routing at the
# physics layer; the `team` field is defense-in-depth and drives the
# (M11) block-cone check. Hurtbox is otherwise a dumb router — all
# signal emission lives in HealthComponent so mitigation + i-frame +
# signal stay atomic.

# ─── Config ────────────────────────────────────────────────────────────
@export var team: HealthComponent.Team = HealthComponent.Team.ENEMY
@export var health_component: NodePath

# M11 Hexagonal Shield hook. In M2 these fields are declared but unread;
# the pre-mitigation hurtbox_hit signal is the place block/parry logic
# will veto damage before HealthComponent.apply_damage runs.
@export var is_blocking: bool = false
@export var block_cone_degrees: float = 60.0

# ─── Runtime ───────────────────────────────────────────────────────────
var _hc: HealthComponent = null


func _ready() -> void:
	if health_component != NodePath():
		_hc = get_node_or_null(health_component) as HealthComponent


signal hit(info: DamageInfo)


func receive(info: DamageInfo) -> int:
	# Per-node pre-mitigation signal. Owners (shield M11) bridge this to
	# SignalBus.hurtbox_hit so Hurtbox itself stays free of autoload refs
	# (same rationale as HealthComponent — see combat/health_component.gd).
	hit.emit(info)
	if _hc == null:
		return 0
	return _hc.apply_damage(info)
