// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_disabled, diffuse_burley, specular_schlick_ggx,unshaded;

uniform vec4 albedo : source_color = vec4(1,1,1,1);
uniform float alphaboost = 0.0;
uniform sampler2D base_texture;



group_uniforms UniqueVariables;
uniform int index;
uniform vec3 uvScale =  vec3(1.0,1.0,1.0);
uniform bool useAlpha = true;

void vertex() {
	UV = UV * uvScale.xy ;
	//UV2
}

void fragment() {
	//vec2 base_uv = UV;
	//vec2 color_uv = UV2;

	vec3 b_tex = texture(base_texture, UV).rgb;
	//vec3 light_tex = texture(light_texture, UV).rgb;
	//float alphaTex = ((b_tex.r)>0.06f) ? 1.0 : 0.0;
	//float grayscale = b_tex.r * .36 +  b_tex.r * .59  + b_tex.r * .11 ; 
	//float alphaTex =step(0.06f, b_tex.r); // ((b_tex.r)>0.06f) ? 1.0 : 0.0;
	
	if(step(0.06f, b_tex.r) < 1.0)
		discard;
	
	ALBEDO = albedo.rgb * b_tex * COLOR.rgb;
    ALPHA= 1.0-alphaboost;
}
