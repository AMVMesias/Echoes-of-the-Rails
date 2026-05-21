shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_disabled;

uniform vec4 glass_tint : source_color = vec4(0.42, 0.50, 0.52, 0.28);
uniform vec4 grime_color : source_color = vec4(0.12, 0.10, 0.08, 0.22);
uniform float grime_amount : hint_range(0.0, 1.0) = 0.35;
uniform float noise_scale : hint_range(1.0, 24.0) = 12.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
	float grime = hash(floor(UV * noise_scale));
	vec3 color = mix(glass_tint.rgb, grime_color.rgb, step(1.0 - grime_amount, grime));
	ALBEDO = color;
	ALPHA = glass_tint.a + grime * grime_amount * 0.12;
	ROUGHNESS = 0.2;
}
