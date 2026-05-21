shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled, depth_prepass_alpha;

uniform vec4 steam_color : source_color = vec4(0.72, 0.75, 0.78, 0.38);
uniform float noise_scale : hint_range(0.5, 10.0) = 3.0;
uniform float drift_speed : hint_range(0.0, 3.0) = 0.55;
uniform float fade_top : hint_range(0.0, 1.0) = 0.75;

float hash(vec3 p) {
	return fract(sin(dot(p, vec3(17.17, 31.13, 47.77))) * 19341.19);
}

void vertex() {
	float drift = sin(TIME * drift_speed + VERTEX.y * 2.0) * 0.08;
	VERTEX.x += drift;
	VERTEX.z += cos(TIME * drift_speed + VERTEX.x) * 0.05;
}

void fragment() {
	float n = hash(floor((VERTEX + vec3(TIME * 0.1, TIME * 0.25, 0.0)) * noise_scale));
	float vertical_fade = smoothstep(0.0, fade_top, UV.y);
	ALBEDO = steam_color.rgb;
	ALPHA = steam_color.a * n * (1.0 - vertical_fade);
}
