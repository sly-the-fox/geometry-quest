class_name StateMachine extends Node

# Simple state machine dispatcher. Children must extend PlayerState and be
# named with the StringName that change_state() will look up — e.g. `idle`,
# `move`, `jump`. Godot 4 Node.name is StringName, which lets us key _states
# by c.name directly and match StringName lookups exactly.

var current: PlayerState = null
var _states: Dictionary = {}


func _ready() -> void:
	for c in get_children():
		if c is PlayerState:
			_states[c.name] = c


func change_state(state_name: StringName, msg: Dictionary = {}) -> void:
	if current != null:
		current.exit()
	current = _states.get(state_name, null)
	if current != null:
		current.enter(msg)


func _physics_process(delta: float) -> void:
	if current != null:
		current.physics_process(delta)


func _process(delta: float) -> void:
	if current != null:
		current.process(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current != null:
		current.handle_input(event)
