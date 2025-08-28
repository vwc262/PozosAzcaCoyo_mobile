shader_type spatial;

uniform sampler2D base_texture;
uniform sampler2D gradient: repeat_disable;
uniform float percentage: hint_range(-1.0, 1.0, 0.1);
uniform float fresnel_power : hint_range(0.1, 10.0, 0.1) = 3.0;
uniform vec3 fresnel_color : source_color = vec3(1.0, 1.0, 1.0);

void vertex() {
	UV2 = UV + vec2(1.0,percentage);
	// Called for every vertex the material is visible on.
}

void fragment() {

	//UV2 = UV + vec2(gradient.r,0);
	    float fresnel_factor = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), fresnel_power);

	ALBEDO = texture(gradient,UV2).rgb;
	ALPHA = float(1);
	EMISSION = texture(gradient,UV2).rgb * 0.05+ (fresnel_color * fresnel_factor);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
