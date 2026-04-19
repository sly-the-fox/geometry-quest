class_name Fade extends ColorRect

# Full-screen fade overlay.
# Tree-membership requirement: create_tween() needs this node in the active
# scene tree at call time. M13 is responsible for parenting Fade under a
# CanvasLayer before the first transition.


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color = Color(0.0, 0.0, 0.0, 0.0)
	anchor_right = 1.0
	anchor_bottom = 1.0


func fade_out(duration: float = 0.3) -> Signal:
	var tween: Tween = create_tween()
	tween.tween_property(self, "color:a", 1.0, duration)
	return tween.finished


func fade_in(duration: float = 0.3) -> Signal:
	var tween: Tween = create_tween()
	tween.tween_property(self, "color:a", 0.0, duration)
	return tween.finished
