shader_type canvas_item;

uniform sampler2D main_tex;

// Blurs the screen in the Y-direction.
void fragment() {
	vec2 pixel_size = 1. / vec2(textureSize(main_tex, 0));
	vec3 col = texture(main_tex, UV).xyz * 0.16;
	col += texture(main_tex, UV + vec2(0.0, pixel_size.y)).xyz * 0.15;
	col += texture(main_tex, UV + vec2(0.0, -pixel_size.y)).xyz * 0.15;
	col += texture(main_tex, UV + vec2(0.0, 2.0 * pixel_size.y)).xyz * 0.12;
	col += texture(main_tex, UV + vec2(0.0, 2.0 * -pixel_size.y)).xyz * 0.12;
	col += texture(main_tex, UV + vec2(0.0, 3.0 * pixel_size.y)).xyz * 0.09;
	col += texture(main_tex, UV + vec2(0.0, 3.0 * -pixel_size.y)).xyz * 0.09;
	col += texture(main_tex, UV + vec2(0.0, 4.0 * pixel_size.y)).xyz * 0.05;
	col += texture(main_tex, UV + vec2(0.0, 4.0 * -pixel_size.y)).xyz * 0.05;
	COLOR.xyz = col;
}