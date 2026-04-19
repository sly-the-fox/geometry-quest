extends Node

# Autoload registered as "AudioManager". No class_name on autoloads in 4.6.
# M0 stubs. Full implementation lands in M20.


func play_music(path: String, crossfade_s: float = 0.0) -> void:
	pass


func play_sfx(path: String, world_pos: Vector3 = Vector3.ZERO, positional: bool = false) -> void:
	pass


func play_world_drone() -> void:
	pass


func stop_music(fade_s: float = 0.0) -> void:
	pass
