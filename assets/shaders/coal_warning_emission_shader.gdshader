shader_type spatial;
render_mode diffuse_lambert;

uniform vec4 base_color : source_color = vec4(0.18, 0.03, 0.02, 1.0);
uniform vec4 warning_color : source_color = vec4(1.0, 0.08, 0.02, 1.0);
uniform float warning_active : hint_range(0.0, 1.0) = 0.0;
uniform float pulse_speed : hint_range(0.0, 8.0) = 2.2;

void fragment() {
	float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);
	float warning = warning_active * mix(0.25, 1.0, pulse);
	ALBEDO = mix(base_color.rgb, warning_color.rgb, warning * 0.7);
	EMISSION = warning_color.rgb * warning * 0.55;
	ROUGHNESS = 0.65;
}
