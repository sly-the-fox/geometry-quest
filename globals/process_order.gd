extends Node

# Autoload registered as "ProcessOrder". No class_name on autoloads in 4.6.
# Tracks the canonical observe → disrupt → stabilize → complete → integrate
# sequence. Used by puzzles (post-slice) and by the canonical 4-phase boss
# framework (M15+) to enforce bible §4 process-order semantics.

var _log: Array[Dictionary] = []


func record(step: StringName) -> void:
	_log.append({
		"step": step,
		"time": float(Time.get_ticks_msec()) / 1000.0,
	})


func query(step: StringName) -> float:
	# Seconds since the last record of this step, or -1.0 if never recorded.
	for i in range(_log.size() - 1, -1, -1):
		if _log[i]["step"] == step:
			return float(Time.get_ticks_msec()) / 1000.0 - _log[i]["time"]
	return -1.0


func clear() -> void:
	_log.clear()
