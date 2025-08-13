shader_type spatial;
render_mode cull_disabled,depth_draw_always;

uniform vec4 gradient_color1 : source_color;
uniform vec4 gradient_color2 : source_color;
uniform float alpha_value: hint_range(0.0, 1.0) = 0.5;
uniform sampler2D gradient_Texture : repeat_enable,filter_linear;
uniform vec4 primary_color : source_color;
uniform vec4 secondary_color : source_color;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D gotas : repeat_enable,filter_linear;
uniform sampler2D normalmap_a : hint_normal,repeat_enable,filter_linear_mipmap;
uniform sampler2D normalmap_b : hint_normal,repeat_enable,filter_linear_mipmap;
uniform float normalmap_a_strg : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float normalmap_b_strg : hint_range(0.0, 1.0, 0.01) = 0.25;
uniform vec2 movement_direction_a = vec2(0.1,0.1);
uniform float movement_strg_a = 0.5;
uniform float uv_scale_a = 1.0;
uniform vec2 movement_direction_b = vec2(0.1,0.1);
uniform float movement_strg_b = 0.5;
uniform float uv_scale_b = 1.0;
uniform sampler2D screen_texture : hint_screen_texture,repeat_enable,filter_linear;
uniform sampler2D depth_texture : hint_depth_texture,repeat_enable,filter_linear;
uniform float depth_distance : hint_range(0.0, 20.0, 0.1) = 4.0;
uniform float beers_law : hint_range(0.0, 20.0, 0.1) = 12.0;
uniform float water_transparency : hint_range(0.0, 1.0, 0.1) = 0.05;
uniform float speed = 0.0;
uniform float wave_count = 20.0;
uniform float wave_spread = 0.5; // Variación en la posición inicial

group_uniforms Goteo;
uniform float intens : hint_range(0.0, 1.0, 0.01) = 0.55;
uniform float amplitud : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float frecuencia : hint_range(0.0, 20.0, 0.01) = 20.0;

// Función de hash para pseudo-aleatoriedad
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow ((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0 , 1.0)), amount);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 base_uv = UV;

        // Usa coordenadas basadas en posición mundial para consistencia
        vec2 worldUV = vec2(FRAGCOORD.x / SCREEN_UV.x, FRAGCOORD.y / SCREEN_UV.y);
	    base_uv = mix(UV, worldUV, 0.3);


	float basic_fresnel = smoothstep(0.4,1.0,fresnel (3.0, NORMAL, VIEW));

	//Normal
	vec2 uv_a = base_uv * uv_scale_a;
	vec2 uv_movement_a = movement_direction_a * TIME * movement_strg_a;
	vec2 uv_b = base_uv * uv_scale_b;
	vec2 uv_movement_b = movement_direction_b * TIME * movement_strg_b;
	vec3 normalmap = texture(normalmap_a, uv_a + uv_movement_a,1.0).rgb * normalmap_a_strg;
	normalmap += texture(normalmap_b, uv_b + uv_movement_b,1.0).rgb * normalmap_b_strg;

	// Get Depth and Screen Textures
	float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec3 screen = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;

    // Muestrear la textura de gotas
    vec4 gotasTex = texture(gotas, uv_a * wave_count);

    // Generar un offset único para cada "gota" basado en su posición
    float time_offset = hash(floor(uv_a * wave_count));
    float freq_variation = hash(floor(uv_a * wave_count + 0.5)) * 0.5 + 0.75; // 0.75-1.25

    // Tiempo modificado por offset y variación de frecuencia
    float modified_time = TIME * speed * freq_variation + time_offset * 10.0;
    float fr = fract(modified_time * 0.75); // Velocidad base más lenta

    // Cálculo de la onda con variación
    float ad = (fr - 1.0) + gotasTex.r;
    float mul = ad * (frecuencia + sin(TIME * 0.5 + time_offset) * amplitud); // Variación adicional
    float clam = clamp(mul, 0.0, 1.0) * PI;

	vec3 gotasWave = vec3(sin(clam) * intens);

	vec3 ndc = vec3 (SCREEN_UV * 2.0 -1.0, depth);
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4 (ndc, 1.0);
	float depth_texture_y = world.y / world.w;
	float vertex_y = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).y;

	float depth_blend = clamp((vertex_y - depth_texture_y) / depth_distance, 0.0, 1.0);
	depth_blend = exp(-depth_blend * beers_law);

	vec3 depth_color = mix(secondary_color, primary_color, depth_blend).rgb;
	vec3 final_color = mix(depth_color.rgb, screen, water_transparency);
	vec3 gradCol = mix(gradient_color1,gradient_color2,(texture(gradient_Texture,UV+vec2(1,-TIME * speed)).r)).rgb;

	//ALBEDO = mix(final_color, screen, depth_blend * (0.5 * basic_fresnel)) + (isRaining ? gotasWave:vec3(0.0));
	ALBEDO = mix(final_color, screen, depth_blend * (0.5 * basic_fresnel))+gradCol*(alpha_value+0.2);
	ROUGHNESS = roughness * (1.0 - basic_fresnel);
	NORMAL_MAP = normalmap;
	METALLIC = metallic;
	ALPHA = 1.0;
	EMISSION = gradCol * 2.0 * alpha_value;
	//EMISSION = gotasWave;
}