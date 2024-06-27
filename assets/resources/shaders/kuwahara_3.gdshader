shader_type canvas_item;

uniform sampler2D main_tex;
uniform sampler2D channel_1;
uniform float kuwahara_level : hint_range(0., 1.);
uniform float radius = 15.0;
uniform float q  = 12.0;
uniform float alpha = 5.0;

void fragment() {
	vec2 resolution = vec2(textureSize(main_tex, 0));
	
	vec4 m[4];
	vec3 s[4];
	for (int k = 0; k < 4; ++k) {
		m[k] = vec4(0.0);
		s[k] = vec3(0.0);
	}
	
	float piN = 2.0 * PI / float(4);
	mat2 X = mat2(vec2(cos(piN), sin(piN)), vec2(-sin(piN), cos(piN)));
	
	vec4 t = texture(channel_1, UV);
	float a = radius * clamp((alpha + t.w) / alpha, 0.1, 2.0); 
	float b = radius * clamp(alpha / (alpha + t.w), 0.1, 2.0);
	float cos_phi = cos(t.z);
	float sin_phi = sin(t.z);
	
	mat2 SR = mat2(vec2(cos_phi/a, -sin_phi/b), vec2(sin_phi/a, cos_phi/b)); 
	int max_x = int(sqrt(a*a * cos_phi*cos_phi +
	                        b*b * sin_phi*sin_phi));
	int max_y = int(sqrt(a*a * sin_phi*sin_phi +
	                        b*b * cos_phi*cos_phi));
	
	for (int j = 0; j <= max_y; ++j)  {
		for (int i = -max_x; i <= max_x; ++i) {
			if ((j !=0) || (i > 0)) {
				vec2 v = SR * vec2(float(i),float(j));
				float dot_v = dot(v,v);
				if (dot_v <= 0.99 - (0.98 * kuwahara_level)) {
					vec4 c0_fix = texture(main_tex, UV + (vec2(float(i), float(j)) / resolution.xy));
					vec3 c0 = c0_fix.rgb;
					vec4 c1_fix = texture(main_tex, UV - (vec2(float(i), float(j)) / resolution.xy));
					vec3 c1 = c1_fix.rgb;

					vec3 cc0 = c0 * c0;
					vec3 cc1 = c1 * c1;

					float n = 0.0;
					float wx[4];
					
					{
						float z;
						float xx = 0.33 - 0.84 * v.x * v.x;
						float yy = 0.33 - 0.84 * v.y * v.y;

						z = max(0.0, v.y + xx);
						n += wx[0] = z * z;

						z = max(0.0, -v.x + yy);
						n += wx[1] = z * z;

						z = max(0.0, -v.y + xx);
						n += wx[2] = z * z;

						z = max(0.0, v.x + yy);
						n += wx[3] = z * z;
					}

					float g = exp(-3.125 * dot_v) / n;

					for (int k = 0; k < 4; ++k) {
						float w = wx[k] * g;
						m[k] += vec4(c0 * w, w);
						s[k] += cc0 * w;
						m[(k+2)&3] += vec4(c1 * w, w);
						s[(k+2)&3] += cc1 * w;
					}
				}
			}
		}
	}
	
	vec4 o = vec4(0.0);
	for (int k = 0; k < 4; ++k) {
		m[k].rgb /= m[k].w;
		s[k] = abs(s[k] / m[k].w - m[k].rgb * m[k].rgb);

		float sigma2 = sqrt(s[k].r) + sqrt(s[k].g) + sqrt(s[k].b);
		float w = 1.0 / (1.0 + pow(255.0 * sigma2, q));
		o += vec4(m[k].rgb * w, w);
	}
	
	COLOR = vec4(o.rgb / o.w, 1.0);
}
