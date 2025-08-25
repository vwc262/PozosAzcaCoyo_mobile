shader_type canvas_item;

uniform sampler2D texture_input;
uniform float speed : hint_range(0.1, 10.0) = 2.0;
uniform float smoothness : hint_range(0.0, 1.0) = 0.3;
uniform vec4 albedo: source_color;

void fragment() {
    vec4 original_color = texture(texture_input, UV);

    float blink = sin(TIME * speed);
    blink = smoothstep(-smoothness, smoothness, blink);

	if(speed == 0.0){
		COLOR = original_color * albedo;
	}else{
	    COLOR = original_color * blink * albedo;
	}
}