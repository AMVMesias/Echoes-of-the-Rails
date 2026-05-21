shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform vec4 albedo_color : source_color = vec4(0.48, 0.43, 0.35, 1.0);
uniform float vertex_snap_strength : hint_range(0.0, 1.0) = 0.12;
uniform float color_steps : hint_range(4.0, 64.0) = 24.0;

void vertex() {
	float grid = mix(256.0, 32.0, vertex_snap_strength);
	VERTEX = floor(VERTEX * grid + 0.5) / grid;
}

void fragment() {
	vec3 stepped = floor(albedo_color.rgb * color_steps) / color_steps;
	ALBEDO = stepped;
	ROUGHNESS = 0.92;
}
