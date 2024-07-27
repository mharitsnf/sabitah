shader_type canvas_item;

uniform float strength = 16.;
uniform sampler2D color_tex;

void fragment() {
	vec4 col = texture(color_tex, UV);
	float x = (UV.x + 4.0 ) * (UV.y + 4.0 ) * (TIME * 10.0);
	vec4 grain = vec4(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01)-0.005) * strength;
	
	grain = 1.0 - grain;
	COLOR = col * grain;
}

