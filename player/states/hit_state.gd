extends PlayerState

# Stagger + knockback impulse reaction. Entered from Player.gd when the
# player's HealthComponent emits `damaged`. One-tick velocity impulse
# then natural friction during the stagger window — no explicit curve.
# HealthComponent's 0.6s i-frame and this state's 0.15s min stagger are
# deliberately decoupled: i-frames are damage gating, stagger is behavior.
# M11 parry grants i-frames WITHOUT entering this state.

const MIN_STAGGER_S: float = 0.15

var _stagger_timer: float = 0.0


func enter(msg: Dictionary = {}) -> void:
	var info: DamageInfo = msg.get("info", null)
	if info != null:
		parent.velocity = info.knockback
		_stagger_timer = max(info.stagger_seconds, MIN_STAGGER_S)
	else:
		_stagger_timer = MIN_STAGGER_S


func physics_process(delta: float) -> void:
	parent.apply_gravity(delta)
	parent.apply_horizontal_decel(delta)
	parent.move_and_slide()

	_stagger_timer -= delta
	if _stagger_timer <= 0.0:
		machine.change_state(&"idle")
