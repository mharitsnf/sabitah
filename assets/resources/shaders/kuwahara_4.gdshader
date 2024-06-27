shader_type canvas_item;

uniform sampler2D kuwahara_2;
uniform sampler2D kuwahara_3;

uniform float sigma = 2.;

struct lic_t { 
	vec2 p; 
	vec2 t;
	float w;
	float dw;
};

void step2(inout lic_t s, vec2 resolution) {
	vec2 t = texture(kuwahara_2, s.p).xy;
	if (dot(t, s.t) < 0.0) t = -t;
	s.t = t;

	s.dw = (abs(t.x) > abs(t.y))? 
	    abs((fract(s.p.x) - 0.5 - sign(t.x)) / t.x) : 
	    abs((fract(s.p.y) - 0.5 - sign(t.y)) / t.y);

	s.p += t * s.dw / resolution;
	s.w += s.dw;
}

void fragment() {
	vec2 resolution = vec2(textureSize(kuwahara_2, 0));
	float twoSigma2 = 2.0 * sigma * sigma;
    float halfWidth = 2.0 * sigma;
	
	vec3 c = texture( kuwahara_3, UV ).xyz;
	float w = 1.0;
	
	lic_t a, b;
	a.p = b.p = UV;
	a.t = texture( kuwahara_2, UV ).xy / resolution;
	b.t = -a.t;
	a.w = b.w = 0.0;
	
	while (a.w < halfWidth) {
		step2(a, resolution);
		float k = a.dw * exp(-a.w * a.w / twoSigma2);
		c += k * texture(kuwahara_3, a.p).xyz;
		w += k;
	}
	while (b.w < halfWidth) {
		step2(b, resolution);
		float k = b.dw * exp(-b.w * b.w / twoSigma2);
		c += k * texture(kuwahara_3, b.p).xyz;
		w += k;
	}
	c /= w;
	
	COLOR = 1.05 * vec4(c, 1.);
}
