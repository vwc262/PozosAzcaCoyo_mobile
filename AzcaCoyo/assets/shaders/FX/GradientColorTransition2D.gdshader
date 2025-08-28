shader_type canvas_item;

uniform sampler2D base_texture;
uniform sampler2D gradient: repeat_disable; 
uniform float percentage: hint_range(-1.0, 1.0, 0.1);

void fragment() {
	vec2 uv_offset = UV + vec2(1.0,percentage);
	vec4 texture_bomba = texture(base_texture, UV);
	COLOR = texture(gradient, uv_offset) * texture_bomba;
	COLOR.a = texture_bomba.a;
}

