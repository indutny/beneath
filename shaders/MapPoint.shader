shader_type spatial;
render_mode shadows_disabled, ambient_light_disabled, depth_test_disable,
	cull_disabled, skip_vertex_transform;

uniform sampler2D hud;
uniform float emission: hint_range(0.0, 10.0) = 1.0;
uniform float rescale: hint_range(0.01, 4.0) = 1.0;
uniform float width: hint_range(0.25, 4.0) = 1.0;

void vertex() {
	vec3 center = (MODELVIEW_MATRIX * vec4(vec3(0.0), 1.0)).xyz;
	
	VERTEX = (WORLD_MATRIX * vec4(VERTEX, 0.0)).xyz;
	VERTEX = VERTEX * length(center);
	VERTEX += center;
	
	NORMAL = (WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz;
}

void fragment() {
	vec2 rescaled_uv = (UV - 0.5) / rescale + 0.5;
	
	EMISSION = texture(hud, rescaled_uv).rgb * emission;
	ALPHA = texture(hud, rescaled_uv).a;
}