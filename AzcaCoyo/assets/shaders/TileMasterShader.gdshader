// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx,unshaded;

uniform vec4 albedo : source_color = vec4(1.0);
uniform vec4 albedoAdd : source_color;
uniform sampler2D common_texutres;
uniform sampler2D Overlaytexture;
uniform float tile2 = 0.001 ;




uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);


//uniform vec3 uv1_scale;
//uniform vec3 uv1_offset;
//uniform vec3 uv2_scale;
//uniform vec3 uv2_offset;

group_uniforms UniqueVariables;
uniform int index;
uniform vec3 uvScale =  vec3(1.0,1.0,1.0);
uniform bool useAlpha = false;

void vertex() {
	UV = UV * uvScale.xy ;
}

void fragment() {
	vec2 base_uv = UV;
	vec2 ao_uv = UV2;

	vec3 color_tex = texture(common_texutres, UV).rgb;
	vec3 color_tex2 = texture(common_texutres,UV*tile2).rgb;
	vec3 ao_tex = texture(Overlaytexture, ao_uv).rgb;
	ALBEDO = pow(((albedo.rgb * mix(color_tex.rgb,color_tex2, .4) * ao_tex * COLOR.rgb)+albedoAdd.rgb),vec3(2.2));

    ALPHA= 1.0 * (useAlpha ? ALBEDO.x : 1.0);
	//AO_LIGHT_AFFECT = 0.0;
	//vec3 normal_tex = texture(normal_map,UV).rgb;
	//normal_tex = normal_tex *2.0-1.0;
	//NORMAL = normalize(normal_tex);
}
