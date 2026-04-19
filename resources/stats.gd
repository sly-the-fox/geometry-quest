class_name Stats extends Resource

@export var field_integrity_max: int = 12
@export var coherence: int = 10
@export var resonance: int = 10
@export var stability: int = 10
@export var flow: int = 10


func hit_chance() -> float:
	return clampf(0.70 + float(coherence) * 0.003, 0.0, 1.0)


func corruption_resistance_percent() -> float:
	return float(stability) * 0.5


func move_speed_mult() -> float:
	return 1.0 + float(flow) * 0.01


func accessible_pyramids() -> Array[int]:
	var access: Array[int] = [3]
	if resonance >= 10:
		access.append_array([5, 6])
	if resonance >= 30:
		access.append_array([7, 8])
	return access
