shader_type canvas_item;

uniform bool check_corners = false;
uniform vec3 border_color: source_color = vec3(1,1,1);
uniform float width = 1.0;

void fragment() {
	vec2 pixel_size = 1.0 / vec2(textureSize(TEXTURE, 0)) * width;
	bool alpha_check = false;
	float new_a = 1.0;
	for (int i = -1; i <= 1; i++){
		for (int j = -1; j <= 1; j++){
			if (abs(i) == abs(j) && !check_corners){
				continue;
			}
			vec2 new_UV = UV + vec2(float(i), float(j)) * pixel_size;
			new_a = min(texture(TEXTURE, new_UV).a, new_a);
			if (new_a == 0.0){
				alpha_check = true;
			}
			// Border checks
			if (new_UV.r >= 1.0 || new_UV.r <= 0.0 || new_UV.g >= 1.0 || new_UV.g <= 0.0){
				alpha_check = true;
			}
		}
	}
	if (alpha_check){
		COLOR.rgb = border_color;
	}
}
