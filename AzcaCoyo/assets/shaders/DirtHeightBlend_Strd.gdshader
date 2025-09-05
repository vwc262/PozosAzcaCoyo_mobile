shader_type spatial;
//render_mode world_vertex_coords; 
uniform sampler2D base_texture;
uniform sampler2D dirt_texture;
uniform sampler2D gradient;
uniform float metalness;
uniform float rough = 1.0;
uniform float model_height = 2.0;
uniform float tile = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 frag_world_pos = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	float height = (frag_world_pos.y + model_height / 10.0) / model_height;
	vec4 gradientHeight= texture(gradient,vec2(height,0.5));
	//ALBEDO = texture(dirt_texture,UV2).rgb*COLOR.rgb;
	ALBEDO = mix((texture(dirt_texture,UV2*tile).rgb),texture(base_texture,UV2*tile).rgb*COLOR.rgb,gradientHeight.r);
	METALLIC = metalness;
	ROUGHNESS = rough;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
