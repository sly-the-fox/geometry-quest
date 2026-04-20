shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform vec4 tint : source_color = vec4(1.0);
uniform float rim_power : hint_range(0.5, 8.0) = 2.5;
uniform float pulse_hz : hint_range(0.0, 4.0) = 0.5;
uniform float phase_offset = 0.0;
uniform float emission_base : hint_range(0.0, 4.0) = 1.0;

void fragment() {
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
	float pulse = 0.5 + 0.5 * sin(TIME * pulse_hz * 6.283185 + phase_offset);
	ALBEDO = tint.rgb * 0.15;
	EMISSION = tint.rgb * (emission_base + rim * 2.0) * (0.6 + 0.4 * pulse);
	ROUGHNESS = 0.4;
}
