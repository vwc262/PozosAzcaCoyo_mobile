shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;

// Parámetros ajustables
uniform float max_distance = 1.0; // Distancia máxima a la que el objeto es completamente visible
uniform float min_distance = 0.0;  // Distancia mínima a la que el objeto comienza a desvanecerse
uniform float dither_scale = 1.0;  // Escala del patrón de dithering

// Función de dithering (patrón Bayer 8x8)
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
    // Calcular distancia a la cámara usando VIEW_MATRIX
    float distance = length((VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz);

    // Calcular factor de transparencia basado en la distancia
    float alpha = 1.0 - smoothstep(min_distance, max_distance, distance);

    // Aplicar dithering
    vec2 screen_pos = FRAGCOORD.xy * dither_scale;
    float dithered_alpha = dither8x8(screen_pos, alpha);

    // Si el alpha ditherado es menor que 0, descartar el píxel
    if (dithered_alpha < 0.0) {
        discard;
    }

    // Usar el vertex color en lugar de un color uniforme
    ALBEDO = COLOR.rgb;
    ALPHA = COLOR.a * alpha;
	EMISSION = COLOR.rgb * 0.7;
}