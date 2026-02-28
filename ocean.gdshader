shader_type canvas_item;

uniform float wave_speed : hint_range(0.0, 5.0) = 1.0;
uniform float wave_strength : hint_range(0.0, 0.1) = 0.02;
uniform float wave_frequency : hint_range(0.0, 20.0) = 8.0;
uniform vec4 shallow_color : source_color = vec4(0.0, 0.5, 0.8, 1.0);
uniform vec4 deep_color : source_color = vec4(0.0, 0.1, 0.4, 1.0);
uniform float foam_threshold : hint_range(0.0, 1.0) = 0.7;
uniform vec4 foam_color : source_color = vec4(0.9, 0.95, 1.0, 1.0);
uniform vec4 overlay_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float overlay_strength : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec2 uv = UV;
	
	// layered waves
	float time = TIME * wave_speed;
	uv.x += sin(uv.y * wave_frequency + time) * wave_strength;
	uv.x += sin(uv.y * wave_frequency * 0.5 + time * 1.3) * wave_strength * 0.5;
	uv.y += cos(uv.x * wave_frequency + time * 0.8) * wave_strength * 0.3;
	
	// depth gradient top to bottom
	vec4 water = mix(shallow_color, deep_color, uv.y);
	
	// foam on wave peaks
	// foam as horizontal streaks instead of circles
	float foam = sin(uv.x * wave_frequency * 3.0 + time + sin(uv.y * 5.0) * 0.5) * 0.5 + 0.5;
	foam = pow(foam, 2.0); // sharpen it so only peaks show
	water = mix(water, foam_color, foam * 0.4);
	
	// subtle shimmer
	float shimmer = sin(uv.x * 30.0 + time * 3.0) * sin(uv.y * 20.0 + time * 2.0);
	water.rgb += shimmer * 0.03;
	
	water.rgb = mix(water.rgb, overlay_color.rgb, overlay_strength);

	COLOR = water;	
}