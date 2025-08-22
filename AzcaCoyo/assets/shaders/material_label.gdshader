shader_type spatial;

uniform sampler2D numeros_texture : source_color, repeat_disable, filter_nearest;
uniform vec4 color_texto : source_color = vec4(1.0);
uniform float escala_numeros = 1.0;
uniform float espaciado = 0.1; // Controla el espacio entre dígitos (0.0 a 0.5)

varying flat int numero_entero;

void vertex() {
    numero_entero = int(INSTANCE_CUSTOM.r * 255.0);
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