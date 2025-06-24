shader_type canvas_item;

// Noise
uniform sampler2D noise_texture: filter_nearest, repeat_enable;
// Strength
uniform float distortion = 0.01;
// How fast slime should move
uniform vec2 speed = vec2(1.0, 0.5);
// Wave strength
uniform vec2 wave_strength = vec2(1.0, 1.0);
// Noise/texture blend
uniform float noise_blend:hint_range(0.0, 1.0, 0.01) = 0.2;

// Modulate colors
varying vec4 modulate;

// Called for every vertex the material is visible on.
void vertex() {
	if (VERTEX.x > 0.0) {
		VERTEX.y += sin(TIME * 2.0) * wave_strength.y;
		VERTEX.x += cos(TIME * 1.0) * wave_strength.x;
	}
	else {
		VERTEX.y += cos(TIME * 3.0) * wave_strength.y;
		VERTEX.x += sin(TIME * 0.7) * wave_strength.x;
	}
	modulate = COLOR;
}

// Called for every pixel the material is visible on.
void fragment() {
	vec2 move = speed;
	vec2 better_move = vec2(move.x * sin(TIME), move.y * cos(TIME));
	//COLOR = texture(TEXTURE, UV);
	//COLOR.rgb *= texture(noise_texture, UV + real_move).rgb;
	vec3 new_tex = mix(texture(TEXTURE,UV).rgb,
			texture(noise_texture, UV + better_move).rgb, noise_blend);
	COLOR.rgb = new_tex;
	COLOR *= modulate;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
