shader_type canvas_item;
// Neige / parasites d'écran (caméras, game over). Purement procédural.
uniform float intensity : hint_range(0.0, 1.0) = 0.25;
uniform float line_strength : hint_range(0.0, 1.0) = 0.15;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 px = floor(FRAGCOORD.xy / 2.0);
	float n = rand(px + vec2(floor(TIME * 30.0) * 1.37, floor(TIME * 30.0) * 2.11));
	float line = step(0.97, fract(UV.y * 3.0 - TIME * 0.6)) * line_strength;
	COLOR = vec4(vec3(n), intensity * (0.6 + 0.4 * n) + line);
}
