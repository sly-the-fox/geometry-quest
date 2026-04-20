extends PlayerState

# Placeholder attack with three phases: windup → active → recovery.
# Toggles `Player/WeaponSlot/AttackHitbox` during the active phase.
# M3 (Tetrahedron Blade) replaces the AttackHitbox with the Blade's own
# hitbox under `WeaponSlot/TetrahedronBlade/Hitbox` — this state script
# keeps working as long as that hitbox lives at `_hitbox_path`.
#
# Timings (SPEC §11.3 Blade, M2 placeholder defaults):
#   windup   0.08s — no damage, no cancel
#   active   0.18s — hitbox enabled
#   recovery 0.24s — hitbox off, can't re-attack until exit
# Total: 0.50s.
#
# Input buffering: intentionally absent. If post-v1 polish adds an 80ms
# attack buffer, it plugs into Player._unhandled_input alongside jump.

const WINDUP_S: float = 0.08
const ACTIVE_S: float = 0.18
const RECOVERY_S: float = 0.24

const PH_WINDUP: int = 0
const PH_ACTIVE: int = 1
const PH_RECOVERY: int = 2

const HITBOX_PATH: NodePath = ^"WeaponSlot/AttackHitbox"

var _phase: int = PH_WINDUP
var _phase_timer: float = 0.0
var _hitbox: Hitbox = null


func enter(_msg: Dictionary = {}) -> void:
	_phase = PH_WINDUP
	_phase_timer = WINDUP_S
	_hitbox = parent.get_node_or_null(HITBOX_PATH) as Hitbox
	if _hitbox != null:
		_hitbox.disable()


func exit() -> void:
	if _hitbox != null:
		_hitbox.disable()


func physics_process(delta: float) -> void:
	parent.apply_gravity(delta)
	parent.apply_horizontal_decel(delta)
	parent.move_and_slide()

	_phase_timer -= delta
	if _phase_timer > 0.0:
		return

	match _phase:
		PH_WINDUP:
			_phase = PH_ACTIVE
			_phase_timer = ACTIVE_S
			if _hitbox != null:
				_hitbox.enable()
		PH_ACTIVE:
			_phase = PH_RECOVERY
			_phase_timer = RECOVERY_S
			if _hitbox != null:
				_hitbox.disable()
		PH_RECOVERY:
			machine.change_state(&"idle")
