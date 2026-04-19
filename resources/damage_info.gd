class_name DamageInfo extends RefCounted

var amount: int = 0
var type: StringName = &"physical"
var source: Node3D = null
var knockback: Vector3 = Vector3.ZERO
var stagger_seconds: float = 0.0
var breaks_pattern: bool = false
var completes_pattern: bool = false
