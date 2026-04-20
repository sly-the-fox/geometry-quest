extends Node

# M2 dev-only. Press Tab to deal 3 damage to the player — used to manually
# verify HitState + i-frames during F5 smoke. Delete this script and the
# DebugDamager node before M5 lands real enemies (or before M13 when the
# default scene swaps back to main.tscn).

@export var player: NodePath


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"ui_focus_next"):  # Tab
		return
	var p: Player = get_node_or_null(player) as Player
	if p == null or p.health_component == null:
		return
	var info: DamageInfo = DamageInfo.new()
	info.amount = 3
	info.type = &"debug"
	info.knockback = -p.global_transform.basis.z * -4.0  # push player backward
	info.stagger_seconds = 0.2
	p.health_component.apply_damage(info)
