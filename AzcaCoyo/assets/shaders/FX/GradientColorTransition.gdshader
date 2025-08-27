shader_type spatial;

uniform sampler2D base_texture;
uniform sampler2D gradient: repeat_disable; 
uniform float percentage: hint_range(-1.0, 1.0, 0.1);

void vertex() {
	UV2 = UV + vec2(1.0,percentage);
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	//UV2 = UV + vec2(gradient.r,0);
	ALBEDO = texture(gradient,UV2).rgb;
	ALPHA = float(.9);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
