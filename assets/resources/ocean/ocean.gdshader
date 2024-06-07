shader_type spatial;

group_uniforms PlanetAndPlayerData;
uniform float planet_radius = 1000.;
uniform vec3 target_world_position;
uniform vec3 target_up;
uniform vec3 target_right;
uniform vec3 target_fwd;
uniform float cpu_time;
uniform vec3 movement_offset;
uniform float plane_size;

group_uniforms WaveData;
uniform float speed = 1.;
uniform vec4 wave_1 = vec4(.2, 10., 1., 0.);
uniform vec4 wave_2 = vec4(.2, 10., 1., 0.);
uniform vec4 wave_3 = vec4(.2, 10., 1., 0.);
uniform vec4 wave_4 = vec4(.2, 10., 1., 0.);
uniform vec4 wave_5 = vec4(.2, 10., 1., 0.);

group_uniforms VisualData;
uniform sampler2D water_tex : filter_nearest;
uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform float metallic : hint_range(0.0, 1.0, 0.001) = 0.;
uniform float roughness : hint_range(0.0, 1.0, 0.001) = 0.02;
uniform float movement_offset_scale;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;

group_uniforms EdgeData;
uniform float edge_scale : hint_range(0.0, 1.0, 0.001) = .1;
uniform float near = 1.;
uniform float far = 100.;
uniform vec3 edge_color : source_color;
uniform float edge_noise_scale = 1.;
uniform sampler2D edge_noise_texture;

group_uniforms LightData;
uniform sampler2D color_ramp;

uniform sampler2D depth_texture : source_color, hint_depth_texture;

vec3 gerstner_wave (vec4 wave, vec3 vertex, inout vec3 tangent, inout vec3 binormal) {
	float steepness = wave.x;
	float wavelength = wave.y;
	vec2 direction = wave.zw;
	
	float k = 2. * PI / wavelength;
	float c = sqrt(9.8 / k);
	vec2 d = normalize(direction);
	float f = k * (dot(d, vertex.xz) - (cpu_time * c * speed));
	float a = steepness / k;
	
	tangent += vec3(
		- d.x * d.x * (steepness * sin(f)),
		d.x * (steepness * cos(f)), 
		- d.x * d.y * (steepness * sin(f))
	);
	
	binormal += vec3(
		- d.x * d.y * (steepness * sin(f)),
		d.y * (steepness * cos(f)),
		- d.y * d.y * (steepness * sin(f))
	);
	
	return vec3(
		d.x * (a * cos(f)),
		a * sin(f),
		d.y * (a * cos(f))
	);
}

void vertex() {
	// Calculate the player vector and position
	vec3 player_dir = normalize(target_world_position);
	vec3 player_pos = (player_dir * planet_radius);
	
	// Calculate basis from the three provided vectors
	mat3 player_basis = mat3(
		target_right, target_up, target_fwd
	);
	
	// ===== Gerstner wave calculation ===== 
	vec3 init_vertex = movement_offset + VERTEX;
	
	vec3 tangent = vec3(1., 0., 0.);
	vec3 binormal = vec3(0., 0., 1.);
	vec3 vertex = init_vertex;
	
	vertex += gerstner_wave(wave_1, init_vertex, tangent, binormal);
	vertex += gerstner_wave(wave_2, init_vertex, tangent, binormal);
	vertex += gerstner_wave(wave_3, init_vertex, tangent, binormal);
	vertex += gerstner_wave(wave_4, init_vertex, tangent, binormal);
	vertex += gerstner_wave(wave_5, init_vertex, tangent, binormal);
	
	vertex -= movement_offset;
	
	vec3 normal = normalize(cross(binormal, tangent));
	
	// Find the new vertex adjusted to the player basis
	float height = vertex.y;
	float adjusted_height = planet_radius + height;
	vec3 adjusted_vert = player_basis * vertex;
	vec3 adjusted_normal = player_basis * normal;
	
	// Apply the new position and put it on the sphere surface
	vec3 final_vert = player_pos + adjusted_vert;
	final_vert = normalize(final_vert) * adjusted_height;
	
	VERTEX = final_vert;
	NORMAL = adjusted_normal;
}


float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1. - clamp(dot(normalize(normal), normalize(view)), 0., 1.)), amount);
}

float edge(float depth) {
	depth = 2. * depth - 1.;
	return near * far / (far + depth * (near - far));
}

float linear_depth(float value, vec2 screen_uv, mat4 inv_pro_mat) {
	vec3 ndc = vec3(screen_uv * 2. - 1., value);
	vec4 view = inv_pro_mat * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}

void fragment() {
	// === SETUP
	vec2 scaled_uv = UV + (movement_offset.xz / (plane_size * movement_offset_scale));
	vec3 normal = mix(
		texture(texture_normal, scaled_uv).rgb,
		texture(texture_normal2, scaled_uv).rgb,
		.5
	);
	
	// === EDGE
	float z_depth = linear_depth(texture(depth_texture, SCREEN_UV).x, SCREEN_UV, INV_PROJECTION_MATRIX);
	float z_pos = linear_depth(FRAGCOORD.z, SCREEN_UV, INV_PROJECTION_MATRIX);
	float z_dif = z_depth - z_pos;
	
	z_dif = smoothstep(0., 1., 1. - z_dif);
	float final_z_dif = smoothstep(0., 1., z_dif);
	final_z_dif = step(final_z_dif, edge_scale);
	
	// === COLOR
	float fresnel_val = fresnel(5., NORMAL, VIEW);
	float color_mask = texture(water_tex, scaled_uv * 15.).x;
	vec3 surface_color = mix(albedo, albedo2, fresnel_val);
	
	ALBEDO = mix(edge_color, surface_color, final_z_dif);
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal;
}

void light() {
	float dotnl = clamp(dot(NORMAL, LIGHT), -0.95, 0.95);
	float sample_position = clamp((dotnl + 1.0) * ATTENUATION / 2.1, 0.05, 0.95);
	vec4 ramp_light = texture(color_ramp, vec2(sample_position, 0.0));
	vec3 diffuse_light = ramp_light.rgb * clamp(LIGHT_COLOR * ATTENUATION, vec3(0,0,0), vec3(1,1,1));
	DIFFUSE_LIGHT += max(diffuse_light, DIFFUSE_LIGHT);
}