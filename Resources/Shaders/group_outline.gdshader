shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec4 outline_color: source_color;
uniform float width: hint_range(0.0, 10.0, 0.1) = 1.0;

void fragment() {
	vec2 size = SCREEN_PIXEL_SIZE * width;
	float outline = 0.0;
	for (int i = -1; i <= 1; i++){
		for (int j = -1; j <= 1; j++){
			if (abs(i) == abs(j)){
				continue;
			}
			outline += texture(screen_texture, SCREEN_UV + vec2(float(i), float(j)) * size).a;
		}
	}
	outline = min(outline, 1.0);
	
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}
	
	COLOR = mix(c, outline_color, outline - c.a);
}