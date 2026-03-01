shader_type canvas_item;

// ---- Colors ----
uniform vec4 color_shallow : source_color = vec4(0.05, 0.4, 0.6, 1.0);
uniform vec4 color_deep    : source_color = vec4(0.01, 0.08, 0.2, 1.0);
uniform vec4 caustic_color : source_color = vec4(0.2, 0.9, 1.0, 1.0);
uniform vec4 bubble_color  : source_color = vec4(0.6, 0.9, 1.0, 0.4);
uniform vec4 fog_color     : source_color = vec4(0.0, 0.15, 0.3, 1.0);

// ---- Settings ----
uniform float depth         : hint_range(0.0, 1.0) = 0.6;   // how deep (dark) the water looks
uniform float wave_speed    : hint_range(0.0, 5.0) = 1.0;
uniform float caustic_scale : hint_range(1.0, 40.0) = 12.0;
uniform float caustic_strength : hint_range(0.0, 1.0) = 0.18;
uniform float fog_density   : hint_range(0.0, 1.0) = 0.35;
uniform float parallax_scale: hint_range(0.0, 0.5) = 0.08;  // subtle parallax shift amount

// Camera scroll position — set this from GDScript each frame
uniform vec2 scroll = vec2(0.0, 0.0);

// ─────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Smooth value noise
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i + vec2(0,0)), hash(i + vec2(1,0)), u.x),
		mix(hash(i + vec2(0,1)), hash(i + vec2(1,1)), u.x),
		u.y
	);
}

// Fractional Brownian Motion — layered noise
float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 5; i++) {
		v += a * noise(p);
		p  = p * 2.1 + vec2(1.3, 0.7);
		a *= 0.5;
	}
	return v;
}

// Cheap caustic pattern using two fbm layers offset against each other
float caustics(vec2 uv, float time) {
	vec2 t = vec2(time * 0.3, time * 0.2);
	float a = fbm(uv + t);
	float b = fbm(uv - t + vec2(1.7, 2.3));
	return pow(1.0 - abs(a - b), 6.0);
}

// ─────────────────────────────────────────────
// Parallax layers
// ─────────────────────────────────────────────

// Returns a soft blob/streak for distant particles (bubbles, debris)
float particle(vec2 uv, vec2 pos, float r) {
	float d = length(uv - pos);
	return smoothstep(r, r * 0.2, d);
}

// A single parallax depth layer of drifting bubbles/particles
float bubble_layer(vec2 uv, float layer, float time) {
	// Each layer scrolls at a different speed (parallax)
	vec2 scroll_offset = scroll * parallax_scale * layer;
	vec2 p = uv + scroll_offset + vec2(0.0, -time * 0.04 * layer);
	p = fract(p * vec2(3.0 + layer, 2.5 + layer * 0.5));

	float b = 0.0;
	// A few particles per tile
	b += particle(p, vec2(0.25, 0.5),  0.015 / layer);
	b += particle(p, vec2(0.7,  0.2),  0.010 / layer);
	b += particle(p, vec2(0.55, 0.75), 0.012 / layer);
	return b * (0.5 / layer);
}

// ─────────────────────────────────────────────
// Main
// ─────────────────────────────────────────────

void fragment() {
	float time = TIME * wave_speed;
	vec2  uv   = UV;

	// --- Depth gradient (top = shallow, bottom = deep) ---
	vec4 base = mix(color_shallow, color_deep, pow(uv.y, 0.8) * depth + (1.0 - depth) * 0.1);

	// --- Background water turbulence (slowest layer) ---
	vec2 bg_uv = uv + scroll * parallax_scale * 0.2;
	float turb = fbm(bg_uv * 3.5 + vec2(time * 0.12, time * 0.08));
	base.rgb  += turb * 0.04 * (1.0 - uv.y); // subtle shimmer near surface

	// --- Caustic light shafts (mid layer) ---
	vec2 caustic_uv = uv * caustic_scale + scroll * parallax_scale * 0.5
	                  + vec2(time * 0.15, time * 0.1);
	float c = caustics(caustic_uv, time);
	// Caustics fade with depth and are strongest near the top
	float caustic_depth_fade = 1.0 - smoothstep(0.0, 0.85, uv.y);
	base.rgb += caustic_color.rgb * c * caustic_strength * caustic_depth_fade;

	// --- Light ray streaks from surface ---
	float ray_x    = uv.x + sin(uv.x * 8.0 + time * 0.5) * 0.015
	                       + scroll.x * parallax_scale * 0.3;
	float ray      = pow(max(0.0, 1.0 - abs(fract(ray_x * 5.0 + 0.5) - 0.5) * 14.0), 2.0);
	float ray_fade = (1.0 - uv.y) * (1.0 - uv.y);
	base.rgb      += caustic_color.rgb * ray * ray_fade * 0.08;

	// --- Parallax bubble / particle layers (3 depths) ---
	float bubbles = 0.0;
	bubbles += bubble_layer(uv, 1.0, time);  // far
	bubbles += bubble_layer(uv, 2.0, time);  // mid
	bubbles += bubble_layer(uv, 3.5, time);  // near
	base.rgb = mix(base.rgb, bubble_color.rgb, clamp(bubbles, 0.0, 1.0));

	// --- Distance fog (gets heavier toward bottom) ---
	float fog = smoothstep(0.0, 1.0, uv.y) * fog_density;
	base.rgb  = mix(base.rgb, fog_color.rgb, fog);

	COLOR = base;
}