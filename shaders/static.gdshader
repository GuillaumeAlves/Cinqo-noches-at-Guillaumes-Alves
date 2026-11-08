shader_type canvas_item;
// Neige / parasites VHS (caméras, game over). Purement procédural.
//
// IMPORTANT : TIME grandit sans fin. Avant, il entrait directement dans un sin(),
// ce qui faisait perdre toute précision au GPU après quelques minutes (surtout en
// WebGL) : la neige se figeait / disparaissait. Le temps est maintenant ramené
// dans une petite plage (mod) et le hasard n'utilise plus sin() → stable à l'infini.
uniform float intensity : hint_range(0.0, 1.0) = 0.25;
uniform float line_strength : hint_range(0.0, 1.0) = 0.15;

// Hash sans sin() (Dave Hoskins), précis même en mediump.
float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
	// Numéro d'image de neige (30 / s), qui reboucle tous les 512 tirages.
	float frame = mod(floor(TIME * 30.0), 512.0);
	vec2 px = floor(FRAGCOORD.xy / 2.0);
	float n = hash(px + vec2(frame * 13.0, frame * 7.0));
	// Bande de « tracking » qui descend lentement (temps rebouclé toutes les 100 s).
	float t = mod(TIME, 100.0);
	float line = step(0.97, fract(UV.y * 3.0 - t * 0.6)) * line_strength;
	COLOR = vec4(vec3(n), intensity * (0.6 + 0.4 * n) + line);
}
