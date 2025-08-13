// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_disabled, diffuse_burley, specular_schlick_ggx,unshaded;

uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D base_texture;
uniform sampler2D light_texture;



group_uniforms UniqueVariables;
uniform int index;
uniform vec3 uvScale =  vec3(1.0,1.0,1.0);
uniform bool useAlpha = true;

void vertex() {
	UV = UV * uvScale.xy ;
	//UV2
}

void fragment() {
	vec2 base_uv = UV;
	//vec2 color_uv = UV2;

	vec3 b_tex = texture(base_texture, UV).rgb;
	vec3 light_tex = texture(light_texture, UV).rgb;
	float alphaTex = texture(base_texture, UV).r;
	ALBEDO = albedo.rgb * b_tex* light_tex * COLOR.rgb;
    ALPHA= alphaTex;
}
