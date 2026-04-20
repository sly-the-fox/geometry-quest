class_name PlayerState extends Node

# Base class for each PlayerState. Under Player/StateMachine/<state>.
# StateMachine sets `parent` and `machine` on Player._ready before any
# state's first tick.

var parent: CharacterBody3D   # concrete: Player
var machine: Node             # concrete: StateMachine


func enter(_msg: Dictionary = {}) -> void:
	pass


func exit() -> void:
	pass


func process(_delta: float) -> void:
	pass


func physics_process(_delta: float) -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass
