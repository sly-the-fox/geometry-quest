class_name MoveState extends PlayerState


func physics_process(delta: float) -> void:
	parent.apply_gravity(delta)
	var input_vec: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if input_vec.length() < 0.05:
		machine.change_state(&"idle")
		return
	parent.apply_ground_move(input_vec, delta)
	parent.move_and_slide()
	parent.face_move_direction(delta)
	if parent.try_consume_jump():
		machine.change_state(&"jump")
