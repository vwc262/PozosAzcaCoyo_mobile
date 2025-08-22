shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, depth_prepass_alpha;

uniform float speed = 0.0;
uniform vec2 uvDirection = vec2(1.0,1.0);
uniform sampler2D gradient: filter_nearest_mipmap;
uniform sampler2D noise;

// dither - Ahora con valores relativos a la escala
uniform float max_distance = 10.0;
uniform float min_distance = 1.0;
uniform float dither_scale = 1.0;
uniform bool inverse_dither = false;
uniform float escala_relativa = 1.0; // ← NUEVO: ajuste por escala del modelo

// escala
uniform float escala_minima = 0.5;
uniform float escala_maxima = 1.0;
uniform float distancia_minima = 1.0;
uniform float distancia_maxima = 10.0;

varying vec4 instance_custom_data;
varying float factor_escala;
varying float distancia_camara;

void vertex() {
    UV2 = UV + (uvDirection * speed * TIME);

    // Calcular posición mundial de la instancia
    vec4 world_pos = MODEL_MATRIX * vec4(VERTEX, 1.0);
    vec3 camera_pos = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    distancia_camara = distance(world_pos.xyz, camera_pos);

    // AJUSTAR distancia por escala relativa del modelo ← CLAVE
    float distancia_ajustada = distancia_camara / escala_relativa;

    // Calcular factor de escala basado en distancia AJUSTADA
    factor_escala = 1.0 - smoothstep(distancia_minima, distancia_maxima, distancia_ajustada);
    factor_escala = escala_minima + factor_escala * (escala_maxima - escala_minima);

    VERTEX = VERTEX * factor_escala;
    NORMAL = normalize(NORMAL / factor_escala);
    instance_custom_data = INSTANCE_CUSTOM;
}

float fresnel(float amount, vec3 normal, vec3 view) {
    return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

float dither8x8(vec2 position, float brightness) {
    const float dither_threshold_map[64] = float[64](
        0.0/64.0, 32.0/64.0, 8.0/64.0, 40.0/64.0, 2.0/64.0, 34.0/64.0, 10.0/64.0, 42.0/64.0,
        48.0/64.0, 16.0/64.0, 56.0/64.0, 24.0/64.0, 50.0/64.0, 18.0/64.0, 58.0/64.0, 26.0/64.0,
        12.0/64.0, 44.0/64.0, 4.0/64.0, 36.0/64.0, 14.0/64.0, 46.0/64.0, 6.0/64.0, 38.0/64.0,
        60.0/64.0, 28.0/64.0, 52.0/64.0, 20.0/64.0, 62.0/64.0, 30.0/64.0, 54.0/64.0, 22.0/64.0,
        3.0/64.0, 35.0/64.0, 11.0/64.0, 43.0/64.0, 1.0/64.0, 33.0/64.0, 9.0/64.0, 41.0/64.0,
        51.0/64.0, 19.0/64.0, 59.0/64.0, 27.0/64.0, 49.0/64.0, 17.0/64.0, 57.0/64.0, 25.0/64.0,
        15.0/64.0, 47.0/64.0, 7.0/64.0, 39.0/64.0, 13.0/64.0, 45.0/64.0, 5.0/64.0, 37.0/64.0,
        63.0/64.0, 31.0/64.0, 55.0/64.0, 23.0/64.0, 61.0/64.0, 29.0/64.0, 53.0/64.0, 21.0/64.0
    );

    vec2 pixel = mod(position, 8.0);
    int index = int(pixel.x) + int(pixel.y) * 8;
    return brightness - dither_threshold_map[index];
}

void fragment() {
    // 1. Calcular alpha PRIMERO
    float distancia_ajustada = distancia_camara / escala_relativa;
    float alpha = 0.0;
    
    if (inverse_dither) {
        alpha = 1.0 - smoothstep(min_distance, max_distance, distancia_ajustada);
    } else {
        alpha = smoothstep(min_distance, max_distance, distancia_ajustada);
    }

    // 2. DEBUG: Forzar comportamiento consistente
    // Remover temporalmente para diagnóstico
    alpha = clamp(alpha, 0.0, 1.0);

    // 3. Manejo EXPLÍCITO de transparencia completa
    if (alpha < 0.001) {
        discard;
        ALBEDO = vec3(0.0);
        EMISSION = vec3(0.0);
        ALPHA = 0.0;
        
    } else {

    // 4. Dithering
    vec2 screen_pos = FRAGCOORD.xy * dither_scale;
    float dithered_alpha = dither8x8(screen_pos, alpha);
    
    if (dithered_alpha < 0.0) {
	        discard;
        	ALBEDO = vec3(0.0);
        	EMISSION = vec3(0.0);
        	ALPHA = 0.0;
    	}
	}

    // 5. SOLO si pasa todo lo anterior, calcular colores
    // Pero APLICAR el alpha para prevenir blanco
    vec3 normal = normalize(TANGENT);
    vec3 view = normalize(VIEW);
    float fresnel = fresnel(3.0, NORMAL, VIEW);
    
    vec3 albedo_color = mix(
        instance_custom_data.rgb,
        (instance_custom_data.rgb * texture(gradient, UV + (uvDirection * speed * TIME)).rgb),
        1.0 - texture(noise, UV + vec2(.1 * TIME, 1.0)).r
    );
    
    // APLICAR ALPHA a todos los componentes
    ALBEDO = albedo_color * alpha;  // ← Multiplicar por alpha
    EMISSION = (fresnel * instance_custom_data.rgb * 0.65) * alpha;  // ← Multiplicar por alpha
    ALPHA = alpha;
}