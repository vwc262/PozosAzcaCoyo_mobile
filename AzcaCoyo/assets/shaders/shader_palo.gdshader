shader_type spatial;

// Parámetros configurables
uniform vec4 base_color : source_color = vec4(0.5, 0.5, 0.8, 0.3);
uniform vec4 stripe_color : source_color = vec4(1.0, 0.5, 0.2, 0.8);
uniform float stripe_width : hint_range(0.01, 0.5) = 0.1;
uniform float stripe_speed : hint_range(-5.0, 5.0) = 0.55;
uniform bool use_world_coords = false;

// escala
uniform float escala_minima = 0.5;
uniform float escala_maxima = 1.0;
uniform float distancia_minima = 1.0;
uniform float distancia_maxima = 10.0;

// Parámetros de movimiento en Y
uniform float altura_minima : hint_range(0.0, 1.0) = 0.0;
uniform float altura_maxima : hint_range(0.0, 1.0) = 1.0;

varying float factor_escala;
varying float distancia_camara;

float remap(float value, float in_min, float in_max, float out_min, float out_max) {
    return out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min);
}

void vertex() {

    // Calcular posición mundial de la instancia
    vec4 world_pos = MODEL_MATRIX * vec4(VERTEX, 1.0);
    vec3 camera_pos = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    distancia_camara = distance(world_pos.xyz, camera_pos);

    // Calcular factor de escala basado en distancia AJUSTADA
    factor_escala = smoothstep(distancia_minima, distancia_maxima, distancia_camara);
    factor_escala = escala_minima + factor_escala * (escala_maxima - escala_minima);
	
	// Calcular desplazamiento en Y basado en factor_escala
	float peso = 1.0 - remap(distancia_camara, distancia_minima, distancia_maxima, 0.0, 1.0);
	float desplazamiento_y = mix(altura_minima, altura_maxima, peso) / 100.0;
    
    VERTEX = VERTEX * factor_escala * vec3(0.2, 1.0, 0.2);
	VERTEX.y += desplazamiento_y;
    NORMAL = normalize(NORMAL / factor_escala);
}

void fragment() {
    // Calcular la posición Y para el efecto de franja
    float y_pos;
    if (use_world_coords) {
        // Usar coordenadas del mundo (posición global)
        y_pos = FRAGCOORD.y / FRAGCOORD.w;
    } else {
        // Usar coordenadas UV (locales al objeto)
        y_pos = UV.y;
    }
    
    // Animación de la franja con el tiempo
    float moving_stripe = mod(y_pos + TIME * stripe_speed, 1.0);
    
    // Crear el patrón de franja
    float stripe_pattern = step(stripe_width, moving_stripe);
    
    // Mezclar entre el color base y el color de la franja
    vec4 final_color = mix(stripe_color, base_color, stripe_pattern);
    
    // Aplicar al material
    ALBEDO = final_color.rgb;
    ALPHA = final_color.a;
}