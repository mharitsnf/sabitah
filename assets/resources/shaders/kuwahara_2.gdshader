shader_type canvas_item;

uniform sampler2D blurred_tex; // blurred tex
uniform sampler2D kuwahara_1;
uniform int blur_amount = 16;
uniform int blur_iterations = 16;
uniform int blur_quality = 4;


float normpdf(in float x, in float sigma) {
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

void fragment() {
	vec3 c = texture(kuwahara_1, UV).rgb;
	vec3 sum = texture(blurred_tex, UV).rgb;
	//vec3 sum = texture_xorgaussian(kuwahara_1, UV, SCREEN_PIXEL_SIZE, float(blur_amount), blur_iterations, blur_quality).rgb;
	
	float lambda1 = 0.5 * (sum.y + sum.x + sqrt(sum.y*sum.y - 2.0*sum.x*sum.y + sum.x*sum.x + 4.0*sum.z*sum.z));
	float lambda2 = 0.5 * (sum.y + sum.x - sqrt(sum.y*sum.y - 2.0*sum.x*sum.y + sum.x*sum.x + 4.0*sum.z*sum.z));
	
	vec2 v = vec2(lambda1 - sum.x, -sum.z);
	vec2 t;
	if (length(v) > 0.0) { 
		t = normalize(v);
	} else {
		t = vec2(0.0, 1.0);
	}
	
	float phi = atan(t.y, t.x);
	float A = (lambda1 + lambda2 > 0.0) ? (lambda1 - lambda2) / (lambda1 + lambda2) : 0.0;
	
	COLOR = vec4(t,phi,A);
}
