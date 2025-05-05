shader_type canvas_item;

void vertex() {
	if (UV.y <= 0.5){
		COLOR = vec4(0,0,0,1);
	}
	else {
		COLOR = vec4(0,0,0,0);
	}
}

void fragment() {
	// Called for every pixel the material is visible on.
}

