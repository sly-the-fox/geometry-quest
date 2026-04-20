class_name Room extends Node3D

# Base class for region rooms. Full behavior lands in M13.
# M1: exists so scenes/test_room.tscn can have a script hook.

@export var room_id: StringName = &""
@export var region_id: StringName = &""
