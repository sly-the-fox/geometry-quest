class_name BossResource extends EnemyResource

@export var core_wound: StringName = &""
@export var stuck_geometry_sides: int = 4
@export var required_intervention_weapon: StringName = &""
@export var required_integration_weapon: StringName = &"octagon_harmonizer"
@export var observation_duration_s: float = 4.0
@export var vulnerability_window_s: float = 6.0
@export var difficulty_on_violence: float = 0.25
@export var intro_dialogue: DialogueLine
@export var phase3_warning_dialogue: DialogueLine
@export var integration_dialogue: DialogueLine
@export var nexus_npc_dialogue: DialogueLine
