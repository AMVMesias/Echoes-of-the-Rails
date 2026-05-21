shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back, diffuse_lambert, specular_disabled;

uniform vec4 albedo_color : source_color = vec4(0.42, 0.46, 0.48, 1.0);
uniform vec4 fog_color : source_color = vec4(0.66, 0.70, 0.74, 1.0);
uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform float edge_softness : hint_range(0.01, 0.35) = 0.12;
uniform float noise_scale : hint_range(0.5, 12.0) = 4.0;

float hash(vec3 p) {
	return fract(sin(dot(p, vec3(12.9898, 78.233, 37.719))) * 43758.5453);
}

void fragment() {
	float noise_value = hash(floor((VERTEX + NODE_POSITION_WORLD) * noise_scale));
	float mask = smoothstep(dissolve_amount - edge_softness, dissolve_amount + edge_softness, noise_value);
	ALBEDO = mix(fog_color.rgb, albedo_color.rgb, mask);
	ALPHA = mask * albedo_color.a;
	ROUGHNESS = 1.0;
}
