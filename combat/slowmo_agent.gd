class_name SlowmoAgent extends Node

# Per-node time scale stub. M9 activates this for enemies/projectiles under
# the Heptagon Lens; M2 only declares the hook so HealthComponent + future
# AI nodes can multiply their delta by `scale` without another refactor.
# Player's SlowmoAgent stays at 1.0 — global time_scale is forbidden by
# SPEC §24.11.

var scale: float = 1.0


func _ready() -> void:
	SignalBus.slowmo_broadcast.connect(_on_slowmo)


func _on_slowmo(new_scale: float) -> void:
	scale = new_scale
