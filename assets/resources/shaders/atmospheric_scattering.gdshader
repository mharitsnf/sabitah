shader_type spatial;
render_mode unshaded;

group_uniforms CameraData;
uniform float fov = 0.;

group_uniforms ObjectLocations;
uniform vec3 planet_center;
uniform vec3 sun_center;

group_uniforms ObjectRadiuses;
uniform float planet_radius;
uniform float atmosphere_radius;

group_uniforms SampleSizes;
uniform int optical_depth_sample_size = 10;
uniform int in_scattering_sample_size = 10;

group_uniforms Rayleigh;
uniform vec3 r_scattering_coefficients;
uniform float r_density_falloff;

group_uniforms Mie;
uniform vec3 m_scattering_coefficients;
uniform float m_density_falloff;

group_uniforms OpticalDepthAndLight;
uniform float density_falloff_strength;
uniform float optical_depth_strength;
uniform bool is_accelerated;
uniform sampler2D optical_depth_texture;

group_uniforms HDR;
uniform float f_exposure;

uniform sampler2D depth_texture : hint_depth_texture;
uniform sampler2D screen_texture : hint_screen_texture;


void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}


vec2 ray_sphere_intersect(
	vec3 start, // starting position of the ray
	vec3 dir, // the direction of the ray
	vec3 center, // center of sphere
	float radius // and the sphere radius
) {
	// ray-sphere intersection that assumes
	// the sphere is centered at the origin.
	// No intersection when result.x > result.y
	vec3 offset = start - center;
	float a = dot(dir, dir);
	float b = 2.0 * dot(offset, dir);
	float c = dot(offset, offset) - (radius * radius);
	float d = (b*b) - 4.0*a*c;
	
	// if there is no intersection, return some invalid number
	if (d < 0.0) return vec2(1e5,-1e5);
	
	float s = sqrt(d);
	// point near is 0 if point is on camera.
	float start_intersect = max(0., (-b - s) / (2. * a));
	float end_intersect = (-b + s) / (2. * a);
	
	// dist to the atmosphere and dist through the atmosphere
	return vec2(start_intersect, end_intersect - start_intersect);
}


// For calculating camera direction in world space
vec3 get_camera_direction(vec2 uv, vec2 viewport_size, mat4 inv_view_matrix) {
	// so the original UV is typically in screen space, which is the final space there is.
	// refresher on spaces: object -> world -> camera/view -> clip/ndc -> screen
	// the ray direction is on the world space, so we need to transform this UV into world space.
	// to do that, we first change it to NDC space which normalizes the UV to [-1,1] range
	vec2 normalized_uv = uv * 2. - 1.;
	vec3 dir_ndc = vec3(normalized_uv.x, normalized_uv.y, 1.);
	
	vec2 resolution = 1. / viewport_size;
	float aspect_ratio = resolution.y / resolution.x;
	float tan_half_fov = tan(radians(fov) * .5);
	
	// we then construct the camera/view space by taking into account the aspect ratio and FOV.
	vec3 dir_view = normalize(vec3(normalized_uv.x * aspect_ratio * tan_half_fov, normalized_uv.y * tan_half_fov, -1.0));
	
	// once we do that, we can transform further to world space usingn the inverse view matrix.
	vec4 dir_world = inv_view_matrix * vec4(dir_view, 0.0);
	
	// return the normalized version of it
	return normalize(dir_world.xyz);
}


float get_linear_depth(sampler2D depth_tex, vec2 screen_uv, mat4 inv_pro_mat) {
	float depth = texture(depth_tex, screen_uv).x;
	vec3 ndc = vec3(screen_uv * 2. - 1., depth);
	vec4 view = inv_pro_mat * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}


float height01(vec3 point) {
	float height = length(planet_center - point) - planet_radius;
    return height / (atmosphere_radius - planet_radius);
}


vec2 local_density(vec3 point) {
	float height01 = height01(point);
	
	return vec2(
		exp(-height01 * r_density_falloff) * density_falloff_strength, // rayleigh
		exp(-height01 * m_density_falloff) * density_falloff_strength // mie
	);
}


vec2 optical_depth(vec3 origin, vec3 dir, float ray_length) {
	vec3 sample_point = origin;
	float dist_to_edge = ray_sphere_intersect(origin, dir, planet_center, atmosphere_radius).y;
	float step_size = dist_to_edge / (float(optical_depth_sample_size - 1));
	vec2 od = vec2(0.);
	
	for (int i = 0; i < optical_depth_sample_size; ++i) {
		od += local_density(sample_point);
		sample_point += dir * step_size;
	}
	
	float real_step_size = ray_length / (float(optical_depth_sample_size - 1));
	return 4. * PI * od * real_step_size * optical_depth_strength;
}


float phase_function(float g, float mu) {
	float g2 = g*g;
	float mu2 = mu*mu;
	
	float left = (3. * (1. - g2)) / (2. * (2. + g2));
	float right = (1. + mu2) / pow(1. + g2 - 2. * g * mu, 1.5);
	
	return left * right;
}


vec2 accelerated_optical_depth(vec3 origin, vec3 dir, float ray_length) {
	ivec2 tex_size = textureSize(optical_depth_texture, 0);
	float step_size = ray_length / 99.;
	
	float height01 = clamp(height01(origin), 0., 1.);
	int x = int(height01 * float(tex_size.x));
	
	float angle01 = dot(normalize(planet_center - origin), dir) * .5 + .5;
	int y = int(angle01 * float(tex_size.y));
	
	vec2 od = texelFetch(optical_depth_texture, ivec2(x, y), 0).rg;
	
	return 4. * PI * od * step_size * optical_depth_strength;
}


vec3 in_scattering(vec3 origin, vec3 dir, float ray_length, vec3 original_col) {
	vec3 sample_point = origin;
	float step_size = ray_length / (float(in_scattering_sample_size - 1));
	
	vec3 rayleigh_sum = vec3(0.);
	vec3 mie_sum = vec3(0.);
	
	for (int i = 0; i < in_scattering_sample_size; ++i) {
		// Find local density
		vec2 local_density = local_density(sample_point);
		
		// Optical depth calculation
		vec2 viewray_od = is_accelerated ? 
			accelerated_optical_depth(sample_point, -dir, step_size * float(i)) :
			optical_depth(sample_point, -dir, step_size * float(i));
			
		vec3 to_sun = sun_center - sample_point;
		vec2 sunray_od = is_accelerated ? 
			accelerated_optical_depth(sample_point, normalize(to_sun), length(to_sun)) :
			optical_depth(sample_point, normalize(to_sun), length(to_sun));
		
		// Rayleigh
		vec3 r_atten = exp(-r_scattering_coefficients * (sunray_od.x + viewray_od.x));
		rayleigh_sum += local_density.x * r_atten * r_scattering_coefficients * step_size;
		
		// Mie
		vec3 m_atten = exp(-m_scattering_coefficients * (sunray_od.y + viewray_od.y));
		mie_sum += local_density.y * m_atten * m_scattering_coefficients * step_size;
		
		// Update sample point
		sample_point += dir * step_size;
	}
	
	float mu = dot(dir, normalize(sun_center - origin));	
	vec3 res = (.8 * (rayleigh_sum * phase_function(0., mu)) + (mie_sum * phase_function(.75, mu)));
	return original_col + (1. - exp(-f_exposure * res));
}


void fragment() {
	vec4 original_color = texture(screen_texture, SCREEN_UV);
	
	vec3 cam_pos_world = CAMERA_POSITION_WORLD;
	vec3 cam_dir_world = get_camera_direction(UV, VIEWPORT_SIZE, INV_VIEW_MATRIX);
	
	float depth = get_linear_depth(depth_texture, SCREEN_UV, INV_PROJECTION_MATRIX);
	
	vec2 intersection_pts = ray_sphere_intersect(cam_pos_world, cam_dir_world, planet_center, atmosphere_radius);
	float dst_to = intersection_pts.x;
	float dst_through = min(intersection_pts.y, depth - intersection_pts.x);
	
	vec3 final_light;
	
	if (dst_through > 0.) {
		const float epsilon = .0001;
		vec3 point_in_atmosphere = cam_pos_world + cam_dir_world * (dst_to + epsilon);
		vec3 light = in_scattering(point_in_atmosphere, cam_dir_world, dst_through - epsilon * 2., original_color.rgb);
		final_light = light;
		
	} else {
		final_light = original_color.rgb;
	}
	
	ALBEDO = final_light;
}