shader_type canvas_item;

uniform sampler2D noise_tex;
uniform sampler2D main_tex;
uniform float noise_amount = 1.;
uniform float blend_opacity = .5;
uniform bool enabled = true;

float rand(vec2 co){
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float random_float(float x) {
    // Use a simple hash function to generate randomness
    return fract(sin(x) * 43758.5453123);
}

vec3 blend_softlight(vec3 base, vec3 blend) {
	return mix(
		sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend), 
		2.0 * base * blend + base * base * (1.0 - 2.0 * blend), 
		step(base, vec3(0.5))
	);
}

float f_blend_screen(float base, float blend) {
	return 1.0-((1.0-base)*(1.0-blend));
}

vec3 v3_blend_screen(vec3 base, vec3 blend) {
	return vec3(f_blend_screen(base.r,blend.r),f_blend_screen(base.g,blend.g),f_blend_screen(base.b,blend.b));
}

vec3 blend_screen(vec3 base, vec3 blend, float opacity) {
	return (v3_blend_screen(base, blend) * opacity + base * (1.0 - opacity));
}

float f_blend_overlay(float base, float blend) {
	return base<0.5?(2.0*base*blend):(1.0-2.0*(1.0-base)*(1.0-blend));
}

vec3 v3_blend_overlay(vec3 base, vec3 blend) {
	return vec3(f_blend_overlay(base.r,blend.r),f_blend_overlay(base.g,blend.g),f_blend_overlay(base.b,blend.b));
}

vec3 blend_overlay(vec3 base, vec3 blend, float opacity) {
	return (v3_blend_overlay(base, blend) * opacity + base * (1.0 - opacity));
}

void fragment() {
	vec2 uv = vec2(rand(UV + vec2(TIME)), rand(UV - vec2(TIME)));
	float amount = noise_amount * texture(noise_tex, uv).x;
	vec4 col = texture(main_tex, UV);
	COLOR = vec4(blend_overlay(col.rgb, vec3(amount), blend_opacity), 1.);
}
