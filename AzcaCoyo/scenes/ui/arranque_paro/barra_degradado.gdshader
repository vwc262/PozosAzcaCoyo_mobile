shader_type canvas_item;

uniform float fill_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 fill_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float edge_smoothness : hint_range(0.0, 0.1) = 0.01;

void fragment() {
    vec2 uv = UV;
    
    // Calcula la transición suave en el borde
    float alpha = smoothstep(fill_amount - edge_smoothness, fill_amount + edge_smoothness, uv.x);
    
    // Mezcla entre el color de relleno y el texture original
    vec4 original_color = vec4(0.0);
    COLOR = mix(fill_color, original_color, alpha);
}