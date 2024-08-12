shader_type spatial;

uniform sampler2D albedo_tex : filter_nearest;
uniform sampler2D color_ramp;
uniform float _roughness: hint_range(0.0, 1.0, 0.01) = 1.;
uniform float _metallic: hint_range(0.0, 1.0, 0.01);
uniform float posterize_levels = 10.;

void fragment() {
	ALBEDO = texture(albedo_tex, UV).rgb;
	ROUGHNESS = _roughness;
	METALLIC = _metallic;
}

vec3 posterize(vec3 color) {
	float grayscale = max(color.r, max(color.g, color.b));
	
	float lower = floor(grayscale * posterize_levels) / posterize_levels;
	float lower_diff = abs(grayscale - lower);

	float upper = ceil(grayscale * posterize_levels) / posterize_levels;
	float upper_diff = abs(upper - grayscale);
	
	float level = lower_diff <= upper_diff ? lower : upper;
	float adjustment = level / grayscale;
	
	return color.rgb * adjustment;
}

void light() {
	float dotnl = clamp(dot(NORMAL, LIGHT), -0.95, 0.95);
	float sample_position = clamp((dotnl + 1.0) * ATTENUATION / 2.1, 0.05, 0.95);
	vec4 ramp_light = texture(color_ramp, vec2(sample_position, 0.0));
	vec3 diffuse_light = ramp_light.rgb * clamp(LIGHT_COLOR * ATTENUATION, vec3(0,0,0), vec3(1,1,1));
	DIFFUSE_LIGHT += diffuse_light;
}