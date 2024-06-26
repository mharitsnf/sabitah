shader_type canvas_item;

uniform sampler2D channel_0;

void fragment() {
	vec4 c = texture(channel_0, UV);
	vec2 resolution = vec2(textureSize(channel_0, 0));
	vec2 d = 1.0 / resolution;
	
	vec4 u = (
				-1.0 * texture(channel_0, UV + vec2(-d.x, -d.y)) +
				-2.0 * texture(channel_0, UV + vec2(-d.x,  0.0)) + 
				-1.0 * texture(channel_0, UV + vec2(-d.x,  d.y)) +
				+1.0 * texture(channel_0, UV + vec2( d.x, -d.y)) +
				+2.0 * texture(channel_0, UV + vec2( d.x,  0.0)) + 
				+1.0 * texture(channel_0, UV + vec2( d.x,  d.y))
			) / 4.0;

    vec4 v = (
				-1.0 * texture(channel_0, UV + vec2(-d.x, -d.y)) + 
				-2.0 * texture(channel_0, UV + vec2( 0.0, -d.y)) + 
				-1.0 * texture(channel_0, UV + vec2( d.x, -d.y)) +
				+1.0 * texture(channel_0, UV + vec2(-d.x,  d.y)) +
				+2.0 * texture(channel_0, UV + vec2( 0.0,  d.y)) + 
				+1.0 * texture(channel_0, UV + vec2( d.x,  d.y))
			) / 4.0;
	
	COLOR = vec4(vec3(dot(u.xyz, u.xyz), 
					  dot(v.xyz, v.xyz), 
					  dot(u.xyz, v.xyz)),
				 1.0);
}
