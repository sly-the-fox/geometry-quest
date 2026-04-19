extends SceneTree

# Run: godot --headless -s res://tests/test_scaffolding.gd
# Prerequisite: godot --headless --quit must have run at least once on a
# fresh checkout to prime .godot/global_script_class_cache.cfg.

func _init() -> void:
	var failures: Array[String] = []
	var checks: int = 0

	# 1. Resource classes registered via class_name
	var expected: Array[String] = [
		"DamageInfo",
		"Stats",
		"WeaponResource",
		"EnemyResource",
		"BossResource",
		"BossPhaseResource",
		"RegionResource",
		"DialogueLine",
		"DialogueChoice",
	]
	var registered: Dictionary = {}
	for c in ProjectSettings.get_global_class_list():
		registered[c["class"]] = true
	for cls in expected:
		checks += 1
		if not registered.has(cls):
			failures.append("missing class_name: %s" % cls)

	# 2. Stats formulas at defaults
	var s: Stats = Stats.new()
	checks += 4
	if not is_equal_approx(s.hit_chance(), 0.73):
		failures.append("Stats.hit_chance() expected ~0.73, got %f" % s.hit_chance())
	if not is_equal_approx(s.move_speed_mult(), 1.10):
		failures.append("Stats.move_speed_mult() expected ~1.10, got %f" % s.move_speed_mult())
	if not is_equal_approx(s.corruption_resistance_percent(), 5.0):
		failures.append("Stats.corruption_resistance_percent() expected 5.0, got %f" % s.corruption_resistance_percent())
	if s.accessible_pyramids() != [3, 5, 6]:
		failures.append("Stats.accessible_pyramids() expected [3,5,6], got %s" % str(s.accessible_pyramids()))

	# 3. DamageInfo defaults
	var d: DamageInfo = DamageInfo.new()
	checks += 3
	if d.amount != 0:
		failures.append("DamageInfo.amount default expected 0, got %d" % d.amount)
	if d.type != &"physical":
		failures.append("DamageInfo.type default expected &\"physical\", got %s" % str(d.type))
	if d.breaks_pattern:
		failures.append("DamageInfo.breaks_pattern default expected false")

	if failures.size() > 0:
		for f in failures:
			printerr("FAIL: %s" % f)
		printerr("test_scaffolding: %d/%d failures" % [failures.size(), checks])
		quit(1)
	else:
		print("test_scaffolding: %d assertions passed" % checks)
		quit(0)
