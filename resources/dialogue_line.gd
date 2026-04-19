class_name DialogueLine extends Resource

@export var speaker: String = ""
@export_multiline var text: String = ""
@export_multiline var portrait_description: String = ""
@export var portrait_texture: Texture2D
@export var next: DialogueLine = null
@export var choices: Array[DialogueChoice] = []
@export var flag_to_set_on_show: StringName = &""
