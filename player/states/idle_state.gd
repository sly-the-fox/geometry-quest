class_name IdleState extends PlayerState

# Hysteresis: Idle exits to Move at |input| > 0.10.
# Move exits to Idle at |input| < 0.05. The 0.05–0.10 band is intentional
# anti-chatter — do not unify the thresholds.


func physics_process(delta: float) -> void:
	parent.apply_gravity(delta)
	parent.apply_horizontal_decel(delta)
	parent.move_and_slide()

	var input_vec: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if input_vec.length() > 0.10:
		machine.change_state(&"move")
		return
	if parent.try_consume_jump():
		machine.change_state(&"jump")
