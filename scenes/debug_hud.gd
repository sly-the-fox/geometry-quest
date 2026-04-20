class_name DebugHUD extends CanvasLayer

# On-screen telemetry for M1 vibes-based acceptance. Default-on during M1
# development; press F1 to toggle.

@export var player: CharacterBody3D
@export var camera_rig: CameraRig
@export var readout: Label


func _ready() -> void:
	if readout == null:
		readout = get_node_or_null("Readout")
	set_process(true)


func _process(_delta: float) -> void:
	if readout == null or player == null:
		return
	var v: Vector3 = player.velocity
	var mag: float = v.length()
	var floor_str: String = "true " if player.is_on_floor() else "false"
	var coyote: float = 0.0
	var buffer: float = 0.0
	if "coyote_timer" in player:
		coyote = player.coyote_timer
	if "jump_buffer" in player:
		buffer = player.jump_buffer
	var yaw_deg: float = 0.0
	var pitch_deg: float = 0.0
	var fs: float = 0.0
	if camera_rig != null:
		yaw_deg = rad_to_deg(camera_rig.get_yaw())
		pitch_deg = rad_to_deg(camera_rig.get_pitch())
		fs = -v.dot(player.basis.z)
	var fps: int = int(Engine.get_frames_per_second())
	readout.text = "vel=(%.2f, %.2f, %.2f)  |mag %.2f|\nfloor=%s  coyote=%.2f  buffer=%.2f\ncam yaw=%.1f°  pitch=%.1f°  fwd_speed=%.2f\nfps=%d" % [
		v.x, v.y, v.z, mag, floor_str, coyote, buffer, yaw_deg, pitch_deg, fs, fps
	]


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).pressed and not event.is_echo():
		var k: int = (event as InputEventKey).keycode
		if k == KEY_F1:
			visible = not visible
