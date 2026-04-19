class_name RegionResource extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export var entry_room_scene_path: String = ""
@export var rooms: Array[PackedScene] = []
@export var palette_primary: Color = Color.WHITE
@export var palette_secondary: Color = Color.WHITE
@export var palette_accent: Color = Color.WHITE
@export var sky_shader_path: String = ""
@export var fog_density: float = 0.015
@export var fog_color: Color = Color(0.1, 0.12, 0.16)
@export var music_path: String = ""
@export var ambient_drone_path: String = ""
@export var boss_id: StringName = &""
