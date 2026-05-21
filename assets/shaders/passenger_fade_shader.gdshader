shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back, diffuse_lambert;

uniform vec4 albedo_color : source_color = vec4(0.34, 0.30, 0.27, 1.0);
uniform vec4 fog_color : source_color = vec4(0.65, 0.69, 0.73, 1.0);
uniform float fade_amount : hint_range(0.0, 1.0) = 0.0;
uniform float vertical_bias : hint_range(0.0, 1.0) = 0.4;

void fragment() {
	float height_fade = smoothstep(vertical_bias, 1.0, UV.y);
	float alpha = clamp(1.0 - fade_amount - height_fade * fade_amount * 0.5, 0.0, 1.0);
	ALBEDO = mix(albedo_color.rgb, fog_color.rgb, fade_amount);
	ALPHA = alpha;
	ROUGHNESS = 0.95;
}
