class_name JumpState extends PlayerState


func enter(_msg: Dictionary = {}) -> void:
	parent.velocity.y = parent.jump_speed
	parent.coyote_timer = 0.0
	parent._suppress_coyote_refill = true


func physics_process(delta: float) -> void:
	parent.apply_gravity(delta)
	var input_vec: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	parent.apply_air_move(input_vec, delta)
	parent.move_and_slide()
	parent.face_move_direction(delta)
	if parent.is_on_floor():
		# _suppress_coyote_refill is cleared by Player on landing tick.
		if input_vec.length() < 0.05:
			machine.change_state(&"idle")
		else:
			machine.change_state(&"move")
