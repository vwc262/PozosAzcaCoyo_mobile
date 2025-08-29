shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, depth_prepass_alpha, unshaded;

uniform sampler2D curve_0 : source_color;
uniform sampler2D curve_1 : source_color;
uniform sampler2D curve_y : source_color;
uniform float distancia_transicion = 4.5;
uniform float suavizado_transicion = 1.0;

uniform sampler2D albedo_texture : source_color;
uniform sampler2D brillo_texture : source_color;
uniform vec2 atlas_position = vec2(0.0, 0.0); // Posición en el atlas (0-1)
uniform vec2 atlas_size = vec2(1.0, 1.0); 
uniform vec2 resolution = vec2(1.0, 1.0); 

// escala
uniform float escala_minima = 0.5;
uniform float escala_maxima = 1.0;
uniform float distancia_minima = 1.0;
uniform float distancia_maxima = 10.0;

// Parámetros de movimiento en Y
uniform float altura_minima : hint_range(0.0, 1.0) = 0.0;
uniform float altura_maxima : hint_range(0.0, 1.0) = 1.0;

varying vec4 instance_custom_data;
varying float factor_escala;
varying float distancia_camara;

float remap(float value, float in_min, float in_max, float out_min, float out_max) {
    return out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min);
}

void vertex() {

    // Calcular posición mundial de la instancia
	vec3 centro_objeto = MODEL_MATRIX[3].xyz;
	vec3 camera_pos = INV_VIEW_MATRIX[3].xyz;
	distancia_camara = distance(centro_objeto, camera_pos);
	
	// Normalizar la distancia al rango [0, 1]
    float distancia_normalizada = clamp(
       	(distancia_camara - distancia_minima) / (distancia_maxima - distancia_minima),
       	0.0, 1.0
    );
		
    vec4 muestra_curva_0 = texture(curve_0, vec2(distancia_normalizada));
    vec4 muestra_curva_1 = texture(curve_1, vec2(distancia_normalizada));
	
	float factor_0 = escala_minima + muestra_curva_0.r * (escala_maxima - escala_minima);
    float factor_1 = escala_minima + muestra_curva_1.r * (escala_maxima - escala_minima);
    
    // Aplicar divisores específicos
    factor_0 /= 10.0;
    factor_1 /= 5.0;
    
    // Calcular peso de interpolación con smoothstep
    float peso = smoothstep(
        distancia_transicion - suavizado_transicion,
        distancia_transicion + suavizado_transicion,
        distancia_camara
    );
	
	factor_escala = mix(factor_0, factor_1, peso);
	
	vec4 muestra_curva_y = texture(curve_y, vec2(distancia_normalizada));
	float peso_y = muestra_curva_y.r;
	
	// Calcular desplazamiento en Y basado en el peso
	float desplazamiento_y = mix(altura_minima, altura_maxima, peso_y);
	desplazamiento_y /= 10.0;
    
    VERTEX = VERTEX * factor_escala;
	VERTEX.y += desplazamiento_y;
    NORMAL = NORMAL * factor_escala;
    instance_custom_data = INSTANCE_CUSTOM;
	//instance_custom_data = CUSTOM1;
}

void fragment() {    
    // Calcular UVs dentro de la región del atlas
    vec2 atlas_uv = atlas_position + UV * atlas_size;
	atlas_uv /= resolution;
    
	vec4 albedo = texture(albedo_texture, atlas_uv);
    vec4 brillo = instance_custom_data.a == 1.0 ? texture(brillo_texture, atlas_uv) : vec4(0.0);
	
    ALBEDO = (albedo.rgb * instance_custom_data.rgb) + brillo.rgb;
    ALPHA = albedo.a + brillo.a; //texture_color.a * instance_custom_data.a;
}