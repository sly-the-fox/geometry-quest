extends SceneTree

# Run: godot --headless -s res://tests/test_damage.gd
# Pure-function — autoloads are NOT loaded. HealthComponent is instantiated
# via .new() and kept out of the scene tree; its emit helpers guard with
# is_inside_tree() so SignalBus references never execute here.

func _init() -> void:
	var failures: Array[String] = []
	var checks: int = 0

	# ── Setup: enemy-style HC with local Stats(stability=10) ───────────
	var stats: Stats = Stats.new()
	stats.stability = 10
	var hc: HealthComponent = HealthComponent.new()
	hc.max_hp = 12
	hc.hp = 12
	hc.team = HealthComponent.Team.ENEMY
	hc.local_stats = stats

	# Helper: build DamageInfo with amount + optional breaks_pattern.
	var make_info: Callable = func(amount: int, breaks_pattern: bool = false) -> DamageInfo:
		var i: DamageInfo = DamageInfo.new()
		i.amount = amount
		i.breaks_pattern = breaks_pattern
		return i

	# 1. Stability mitigation: 5 - floor(10/5) = 3 dealt, HP 12 → 9.
	checks += 2
	var dealt_1: int = hc.apply_damage(make_info.call(5))
	if dealt_1 != 3:
		failures.append("assert 1: dealt expected 3, got %d" % dealt_1)
	if hc.hp != 9:
		failures.append("assert 1: hp expected 9, got %d" % hc.hp)

	# 2. I-frame window active → second hit deals 0, HP stays 9.
	checks += 2
	var dealt_2: int = hc.apply_damage(make_info.call(5))
	if dealt_2 != 0:
		failures.append("assert 2: i-framed hit expected 0, got %d" % dealt_2)
	if hc.hp != 9:
		failures.append("assert 2: hp expected 9 (unchanged), got %d" % hc.hp)

	# 3. is_invulnerable() reports true during window, false after reset.
	checks += 2
	if not hc.is_invulnerable():
		failures.append("assert 3a: is_invulnerable() expected true during i-frame")
	hc._iframe_timer = 0.0
	if hc.is_invulnerable():
		failures.append("assert 3b: is_invulnerable() expected false after reset")

	# 4. After reset: same 5-damage hit deals 3, HP 9 → 6.
	checks += 2
	var dealt_4: int = hc.apply_damage(make_info.call(5))
	if dealt_4 != 3:
		failures.append("assert 4: post-reset hit expected 3, got %d" % dealt_4)
	if hc.hp != 6:
		failures.append("assert 4: hp expected 6, got %d" % hc.hp)

	# 5. Pattern-break x2: amount 1 mitigated to max(1, 1-2)=1, doubled=2.
	checks += 2
	hc._iframe_timer = 0.0
	var dealt_5: int = hc.apply_damage(make_info.call(1, true))
	if dealt_5 != 2:
		failures.append("assert 5: pattern-break dealt expected 2, got %d" % dealt_5)
	if hc.hp != 4:
		failures.append("assert 5: hp expected 4, got %d" % hc.hp)

	# 6. Overkill caps to remaining HP (kills the target).
	checks += 3
	hc._iframe_timer = 0.0
	var dealt_6: int = hc.apply_damage(make_info.call(100))
	if dealt_6 != 4:
		failures.append("assert 6: overkill dealt expected 4 (capped to hp), got %d" % dealt_6)
	if hc.hp != 0:
		failures.append("assert 6: hp expected 0, got %d" % hc.hp)
	if hc.is_alive():
		failures.append("assert 6: is_alive() expected false")

	# 7. apply_damage on a dead HC is a no-op.
	checks += 2
	hc._iframe_timer = 0.0
	var dealt_7: int = hc.apply_damage(make_info.call(5))
	if dealt_7 != 0:
		failures.append("assert 7: dead HC apply_damage expected 0, got %d" % dealt_7)
	if hc.hp != 0:
		failures.append("assert 7: hp expected 0, got %d" % hc.hp)

	# 8. Mitigation floor: amount 1 vs stability 10 → max(1, 1-2)=1 dealt.
	checks += 2
	var hc2: HealthComponent = HealthComponent.new()
	hc2.max_hp = 12
	hc2.hp = 12
	hc2.team = HealthComponent.Team.ENEMY
	hc2.local_stats = stats
	var dealt_8: int = hc2.apply_damage(make_info.call(1))
	if dealt_8 != 1:
		failures.append("assert 8: floor damage expected 1, got %d" % dealt_8)
	if hc2.hp != 11:
		failures.append("assert 8: hp expected 11, got %d" % hc2.hp)

	if failures.size() > 0:
		for f in failures:
			printerr("FAIL: %s" % f)
		printerr("test_damage: %d/%d failures" % [failures.size(), checks])
		quit(1)
	else:
		print("test_damage: %d assertions passed" % checks)
		quit(0)
