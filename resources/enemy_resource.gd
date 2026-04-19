class_name EnemyResource extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export var scene: PackedScene
@export var stats: Stats
@export var contact_damage: int = 1
@export var detection_radius: float = 8.0
@export var leash_radius: float = 14.0
@export var move_speed: float = 3.0
@export var weak_to: Array[StringName] = []
@export var pattern_locked: bool = false
