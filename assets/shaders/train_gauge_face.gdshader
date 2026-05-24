shader_type spatial;
render_mode cull_disabled, specular_schlick_ggx;

uniform vec4 paper_color : source_color = vec4(0.92, 0.80, 0.55, 1.0);
uniform vec4 aged_color : source_color = vec4(0.42, 0.31, 0.17, 1.0);
uniform vec4 ink_color : source_color = vec4(0.05, 0.035, 0.025, 1.0);
uniform vec4 warning_color : source_color = vec4(0.82, 0.10, 0.06, 1.0);
uniform float stain_strength = 0.24;
uniform float metallic = 0.0;
uniform float roughness = 0.78;

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

float radial_ticks(float angle, float radius, float count, float width, float inner, float outer) {
	float sector = abs(fract(angle / 6.2831853 * count) - 0.5);
	float angular = smoothstep(width, 0.0, sector);
	float band = smoothstep(inner, inner + 0.015, radius) * smoothstep(outer, outer - 0.018, radius);
	return angular * band;
}

void fragment() {
	vec2 p = UV * 2.0 - vec2(1.0);
	float radius = length(p);
	float angle = atan(p.y, p.x);
	if (angle < 0.0) {
		angle += 6.2831853;
	}

	float stain = noise(UV * 18.0) * stain_strength;
	float vignette = smoothstep(0.25, 1.05, radius) * 0.24;
	vec3 color = mix(paper_color.rgb, aged_color.rgb, stain + vignette);

	float minor_ticks = radial_ticks(angle, radius, 60.0, 0.018, 0.74, 0.90) * 0.45;
	float major_ticks = radial_ticks(angle, radius, 12.0, 0.040, 0.66, 0.91);
	float warning_arc = smoothstep(0.68, 0.72, radius) * smoothstep(0.91, 0.88, radius) * smoothstep(4.80, 5.05, angle) * smoothstep(6.05, 5.70, angle);

	color = mix(color, warning_color.rgb, warning_arc * 0.78);
	color = mix(color, ink_color.rgb, clamp(minor_ticks + major_ticks, 0.0, 1.0));

	ALBEDO = color;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	AO = 0.82;
}
