shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, depth_prepass_alpha;

uniform sampler2D albedo_texture : source_color;
uniform vec4 tint_color : source_color = vec4(1.0);

// escala
uniform float escala_minima = 0.5;
uniform float escala_maxima = 1.0;
uniform float distancia_minima = 1.0;
uniform float distancia_maxima = 10.0;

varying vec4 instance_custom_data;
varying float factor_escala;
varying float distancia_camara;

void vertex() {

    // Calcular posición mundial de la instancia
    vec4 world_pos = MODEL_MATRIX * vec4(VERTEX, 1.0);
    vec3 camera_pos = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    distancia_camara = distance(world_pos.xyz, camera_pos);

    // Calcular factor de escala basado en distancia AJUSTADA
    factor_escala = 1.0 - smoothstep(distancia_minima, distancia_maxima, distancia_camara);
    factor_escala = escala_minima + factor_escala * (escala_maxima - escala_minima);

    VERTEX = VERTEX * factor_escala;
    NORMAL = normalize(NORMAL / factor_escala);
    instance_custom_data = INSTANCE_CUSTOM;
}

float fresnel(float amount, vec3 normal, vec3 view) {
    return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void fragment() {    
    // Muestrear la textura de albedo
    vec4 texture_color = texture(albedo_texture, UV);
    
    // Multiplicar el color de la textura por el color de tinte
    ALBEDO = texture_color.rgb * tint_color.rgb;
    
    // También multiplicar el alpha si es necesario
    ALPHA = texture_color.a * tint_color.a;
}