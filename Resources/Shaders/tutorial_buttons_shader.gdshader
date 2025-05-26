shader_type canvas_item;

varying vec4 modulate;

void vertex() {
	if(UV.x > 0.5){
		COLOR.rgb = vec3(0, 0, 1);
	}
	else{
		COLOR.rgb = vec3(1, 0, 0);
	}
	modulate = COLOR;
}

void fragment() {
	COLOR *= modulate;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
