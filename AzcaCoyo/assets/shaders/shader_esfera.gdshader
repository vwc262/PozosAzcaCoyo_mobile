shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, depth_prepass_alpha;

uniform sampler2D albedo_texture : source_color;
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
    instance_custom_data = INSTANCE_CUSTOM;
}

void fragment() {    
    // Calcular UVs dentro de la región del atlas
    vec2 atlas_uv = atlas_position + UV * atlas_size;
	atlas_uv /= resolution;
    
    vec4 texture_color = texture(albedo_texture, atlas_uv);
    ALBEDO = texture_color.rgb * instance_custom_data.rgb;
    ALPHA = texture_color.a * instance_custom_data.a;
}