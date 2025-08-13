shader_type canvas_item;

// Parámetros ajustables desde el inspector
uniform vec4 edge_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Color en los bordes
uniform float base_radius : hint_range(0.1, 5.0) = 1.0;  // Radio base
uniform float pulse_speed : hint_range(0.1, 10.0) = 1.0; // Velocidad de pulsación
uniform float pulse_range : hint_range(0.0, 2.0) = 0.5;  // Rango de variación

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);

    // Calculamos radio oscilante usando función seno con el tiempo
    float oscillating_radius = base_radius + sin(TIME * pulse_speed) * pulse_range;

    // Aplicamos el radio oscilante
    dist = dist * 2.0 / oscillating_radius;

    float alpha = smoothstep(0.0, 1.0, dist);
    COLOR = vec4(edge_color.rgb, alpha);
}