class_name HealthComponent extends Node

# HP + i-frames + stability mitigation + team-aware SignalBus emission.
# Mitigation formula (SPEC §10.1): dealt = max(1, amount - floor(stability/5)).
# This is intentionally NOT Stats.corruption_resistance_percent() — that helper
# returns a percent used for other corruption effects; damage mitigation uses
# the integer floor directly.

enum Team { PLAYER, ENEMY, BOSS }

# ─── Config ────────────────────────────────────────────────────────────
@export var max_hp: int = 12
@export var team: Team = Team.ENEMY
# Stability source. Enemies wire local_stats via their scene file or M5's
# EnemyResource. Player assigns GameState.stats in Player._ready to avoid
# referencing the autoload identifier from this script (pure-function
# tests can't resolve autoloads at compile time).
@export var local_stats: Stats = null
@export var invulnerable_after_hit_s: float = 0.6

# Per-node damage/death signals for listeners that don't want SignalBus
# (flash tweens, local FX). SignalBus is the cross-system channel.
signal damaged(info: DamageInfo, dealt: int)
signal released()

# ─── Runtime ───────────────────────────────────────────────────────────
var hp: int = 0
var _iframe_timer: float = 0.0


func _ready() -> void:
	hp = max_hp


func _physics_process(delta: float) -> void:
	# TODO M9: for ENEMY/BOSS, multiply delta by SlowmoAgent.scale so
	# i-frames slow under the Lens. Player stays at real time.
	if _iframe_timer > 0.0:
		_iframe_timer = max(0.0, _iframe_timer - delta)


# Returns the damage actually dealt (0 if i-framed or dead).
func apply_damage(info: DamageInfo) -> int:
	if hp <= 0:
		return 0
	if _iframe_timer > 0.0:
		return 0

	var s: int = _get_stability()
	var dealt: int = max(1, info.amount - int(floor(float(s) / 5.0)))

	# Pattern-break ×2 (SPEC §10.1). M2 only honors info.breaks_pattern.
	# TODO M3/M10: also ×2 when target.pattern_locked AND source weapon
	# has the "inversion" tag OR is Tetrahedron Blade. Requires
	# DamageInfo.source_tags + Enemy.pattern_locked to land first.
	if info.breaks_pattern:
		dealt *= 2

	dealt = min(dealt, hp)
	hp -= dealt
	_iframe_timer = invulnerable_after_hit_s

	# Per-node signals only. Owners (player.gd, enemy.gd) forward these
	# to SignalBus so HealthComponent stays free of autoload references
	# and can be unit-tested under --headless -s (pure-function mode).
	damaged.emit(info, dealt)
	if hp <= 0:
		released.emit()

	return dealt


func heal(amount: int) -> void:
	hp = clampi(hp + amount, 0, max_hp)


func is_alive() -> bool:
	return hp > 0


func is_invulnerable() -> bool:
	return _iframe_timer > 0.0


# ─── Internals ─────────────────────────────────────────────────────────

func _get_stability() -> int:
	if local_stats != null:
		return local_stats.stability
	return 0
