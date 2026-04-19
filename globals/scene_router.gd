extends Node

# Autoload registered as "SceneRouter". No class_name on autoloads in 4.6.
# M0 stubs. Full threaded-preload + fade routing lands in M13.


func change_region(region_id: StringName, room_id: StringName, spawn_name: StringName) -> void:
	push_warning("SceneRouter.change_region stubbed: %s/%s/%s" % [region_id, room_id, spawn_name])


func change_room(region_id: StringName, room_id: StringName, spawn_name: StringName) -> void:
	push_warning("SceneRouter.change_room stubbed: %s/%s/%s" % [region_id, room_id, spawn_name])


func fade_out(duration: float = 0.3) -> Signal:
	push_warning("SceneRouter.fade_out stubbed (duration=%f)" % duration)
	return _finished_signal()


func fade_in(duration: float = 0.3) -> Signal:
	push_warning("SceneRouter.fade_in stubbed (duration=%f)" % duration)
	return _finished_signal()


func _finished_signal() -> Signal:
	# A tween that finishes immediately, giving callers a valid Signal to await.
	var tween := create_tween()
	tween.tween_interval(0.0)
	return tween.finished
