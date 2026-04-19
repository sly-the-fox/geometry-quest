class_name WeaponResource extends Resource

@export var id: StringName = &""
@export var pyramid_sides: int = 3
@export var display_name: String = ""
@export var icon: Texture2D
@export var scene: PackedScene
@export var frequency_hz: float = 432.0
@export var color_hex: String = "#E0F6FF"
@export var damage: int = 1
@export var damage_type: StringName = &"physical"
@export var attack_windup_s: float = 0.08
@export var attack_active_s: float = 0.18
@export var attack_recovery_s: float = 0.24
@export var resonance_required: int = 10
@export var tags: Array[StringName] = []
