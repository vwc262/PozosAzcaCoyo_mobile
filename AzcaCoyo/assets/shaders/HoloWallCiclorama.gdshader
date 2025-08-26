shader_type spatial;

uniform sampler2D base_texture;
uniform sampler2D noise_texture;
uniform vec4 tint: source_color = vec4(1.0);
uniform vec2 Speeds = vec2(1.0,1.0);
uniform float tiling = 7.0;
uniform float tiling_noise = 1.0;

void vertex() {
	UV2= (UV) + fract(Speeds*TIME);
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 baseColor = texture(base_texture, UV*tiling).rgb;
	vec3 noiseMask = texture(noise_texture, UV2*tiling_noise).rgb;
	ALBEDO = tint.rgb;
	EMISSION = tint.rgb*noiseMask;
	ALPHA= baseColor.r+pow(noiseMask.r,3.0);
	
	
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
