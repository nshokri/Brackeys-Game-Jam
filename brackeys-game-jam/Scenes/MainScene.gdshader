shader_type spatial;

uniform vec3 albedo : source_color;
uniform sampler2D normalmap;

uniform float alpha : hint_range(0.0, 1.0, 0.01) = 0.8;
uniform float refraction_strength : hint_range(0.0, 8.0, 0.001) = 0.5;
uniform sampler2D screen_texture : hint_screen_texture;

uniform sampler2D depth_texture : hint_depth_texture;

uniform bool is_depth_based = false;

uniform vec2 testdirection;
uniform float speeed;
uniform float steeepness : hint_range(0.0, 1.0, 0.05) = 1.0;
uniform float aamplitude = 1.0;
uniform float waavelength = 1.0;

// direction.y represents z axis (since it is 2D vec)
vec3 gerstner(vec3 vertex, vec2 direction, float time, float speed, float steepness, float amplitude, float wavelength){
	float displaced_x = vertex.x + (steepness/wavelength) * direction.x * cos(wavelength * dot(direction, vertex.xz) + speed * time);
	float displaced_z = vertex.z + (steepness/wavelength) * direction.y * cos(wavelength * dot(direction, vertex.xz) + speed * time);
	float displaced_y = vertex.y + amplitude * sin(wavelength * dot(direction, vertex.xz) + speed * time);
	return vec3(displaced_x, displaced_y, displaced_z);
}

vec3 gerstner_normal(vec3 vertex, vec2 direction, float time, float speed, float steepness, float amplitude, float wavelength) {
    float cosfactor = cos(wavelength * dot(direction, vertex.xz + speed * time));
	float sinfactor = sin(wavelength * dot(direction, vertex.xz + speed * time));
	float x_normal = -direction.x * wavelength * amplitude * cosfactor;
	float z_normal = -direction.y * wavelength * amplitude * cosfactor;
	float y_normal = 1.0 - (steepness/wavelength) * wavelength * amplitude * sinfactor;
	return vec3(x_normal, y_normal, z_normal);
}

vec2 refract_uv(vec2 uv, float strength, vec3 normal){
	float strength1 = strength * (is_depth_based ? pow(uv.y, 4.0) * 5.0 : 1.0);
	uv += strength1 * length(normal) - strength1 * 1.2;
	return uv;
}

void fragment() {
	vec3 nmap = texture(normalmap, UV).rgb;
	ALBEDO = mix(albedo, texture(screen_texture, refract_uv(SCREEN_UV, refraction_strength, nmap)).rgb, 1.0 - alpha);
}

void vertex(){
	VERTEX = gerstner(VERTEX, normalize(testdirection), TIME, speeed, steeepness, aamplitude, waavelength);
	NORMAL = gerstner_normal(VERTEX, normalize(testdirection), TIME, speeed, steeepness, aamplitude, waavelength);
}