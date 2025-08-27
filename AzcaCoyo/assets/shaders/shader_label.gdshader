shader_type spatial;

uniform sampler2D numeros_texture : source_color, repeat_disable, filter_nearest;
uniform vec4 color_texto : source_color = vec4(1.0);
uniform float escala_numeros = 1.0;
uniform float espaciado = 0.1; // Controla el espacio entre dígitos (0.0 a 0.5)

// escala
uniform float escala_minima = 0.5;
uniform float escala_maxima = 1.0;
uniform float distancia_minima = 1.0;
uniform float distancia_maxima = 10.0;

// Parámetros de movimiento en Y
uniform float altura_minima : hint_range(0.0, 1.0) = 0.0;
uniform float altura_maxima : hint_range(0.0, 1.0) = 1.0;

varying flat int numero_entero;
varying float factor_escala;
varying float distancia_camara;

float remap(float value, float in_min, float in_max, float out_min, float out_max) {
    return out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min);
}

void vertex() {
    numero_entero = int(INSTANCE_CUSTOM.r * 255.0);
	
	
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

    VERTEX = VERTEX * factor_escala;
	VERTEX.y += desplazamiento_y;
    NORMAL = normalize(NORMAL / factor_escala);
}

void fragment() {
    int digito_decenas = numero_entero / 10;
    int digito_unidades = numero_entero % 10;
    
    // Calcular el ancho de cada dígito (mitad del espacio menos espaciado)
    float ancho_digito = 0.5 - espaciado;
    
    int digito;
    vec2 uv_ajustado = UV;
    
    if (UV.x < 0.5) {
        digito = digito_decenas;
        // Escalar UV para el primer dígito
        uv_ajustado.x = UV.x / 0.5 * ancho_digito;
    } else {
        digito = digito_unidades;
        // Escalar UV para el segundo dígito
        uv_ajustado.x = (UV.x - 0.5) / 0.5 * ancho_digito + (0.5 + espaciado);
    }
    
    float offset_x = float(digito) / 10.0;
    vec2 uv_atlas = vec2(uv_ajustado.x / 10.0 + offset_x, uv_ajustado.y);
    
    uv_atlas = (uv_atlas - 0.5) / escala_numeros + 0.5;
    
    vec4 muestra = texture(numeros_texture, uv_atlas);
    
    ALBEDO = muestra.rgb * color_texto.rgb;
    ALPHA = muestra.a * color_texto.a;
}