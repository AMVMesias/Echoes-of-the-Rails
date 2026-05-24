shader_type spatial;
render_mode specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.32, 0.25, 0.18, 1.0);
uniform vec4 wear_color : source_color = vec4(0.64, 0.51, 0.33, 1.0);
uniform vec4 grime_color : source_color = vec4(0.05, 0.04, 0.035, 1.0);
uniform float noise_scale = 18.0;
uniform float wear_strength = 0.38;
uniform float grime_strength = 0.28;
uniform float streak_strength = 0.16;
uniform float scratch_strength = 0.12;
uniform float metallic = 0.1;
uniform float roughness = 0.88;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
		u.y
	);
}

void fragment() {
	vec2 uv = UV * noise_scale;
	float n1 = noise(uv);
	float n2 = noise(uv * 2.7 + vec2(8.3, 1.7));
	float vertical_streaks = smoothstep(0.72, 1.0, noise(vec2(uv.x * 0.45, uv.y * 3.5)));
	float scratches = smoothstep(0.82, 1.0, noise(vec2(uv.y * 8.5, uv.x * 0.38) + vec2(2.0, 11.0))) * scratch_strength;
	float edge_wear = smoothstep(0.0, 0.08, UV.y) * smoothstep(1.0, 0.92, UV.y);
	float wear = clamp(n2 * wear_strength + edge_wear * 0.18 + scratches, 0.0, 1.0);
	float grime = clamp((1.0 - n1) * grime_strength + vertical_streaks * streak_strength, 0.0, 1.0);
	vec3 color = mix(base_color.rgb, wear_color.rgb, wear);
	color = mix(color, grime_color.rgb, grime);
	ALBEDO = color;
	METALLIC = metallic;
	ROUGHNESS = clamp(roughness + grime * 0.08 - wear * 0.05, 0.34, 1.0);
	AO = clamp(1.0 - grime * 0.45, 0.35, 1.0);
}
