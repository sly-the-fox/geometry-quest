extends Node

# Autoload registered as "GameState". No class_name on autoloads in 4.6.
# Runtime mirror of SPEC §18 save schema. Persistence lives in SaveManager.

var current_region: StringName = &"hub"
var current_room: StringName = &"room_nexus_main"
var spawn_point: StringName = &"start"

var field_integrity: int = 12
var field_integrity_max: int = 12

var stats: Stats
var lens_energy: float = 3.0
var inverter_energy: float = 2.0

var equipped_weapon_id: StringName = &""
var inventory_weapon_ids: Array[StringName] = []

var flags: Dictionary = {
	"nexus_tutorial_completed": false,
	"met_alchemist": false,
	"defeated_alchemist": false,
	"has_octagon_harmonizer": false,
	"met_observer": false,
	"defeated_observer": false,
	"region_02_unlocked": true,
	"region_07_unlocked": false,
}

var puzzles_solved: Array[StringName] = []
var process_order_log: Array[StringName] = []


func _ready() -> void:
	stats = Stats.new()
