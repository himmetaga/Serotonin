shader_type spatial;
render_mode diffuse_burley;

uniform vec4 base_color : source_color = vec4(0.72, 0.57, 0.53, 1.0);
uniform float fiber_strength = 0.035;
varying vec3 surface_position;

float hash(vec3 p) {
    p = fract(p * 0.1031);
    p += dot(p, p.yzx + 33.33);
    return fract((p.x + p.y) * p.z);
}

float soft_noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix(hash(i), hash(i + vec3(1,0,0)), f.x),
                   mix(hash(i + vec3(0,1,0)), hash(i + vec3(1,1,0)), f.x), f.y),
               mix(mix(hash(i + vec3(0,0,1)), hash(i + vec3(1,0,1)), f.x),
                   mix(hash(i + vec3(0,1,1)), hash(i + vec3(1,1,1)), f.x), f.y), f.z);
}

void vertex() {
    surface_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec3 p = surface_position;
    float cloud = soft_noise(p * 0.65);
    float fibers = sin(p.x * 10.0 + p.z * 2.7 + cloud * 9.0);
    float grain = soft_noise(p * 18.0);
    float variation = 0.95 + cloud * 0.07 + fibers * fiber_strength + (grain - 0.5) * 0.015;
    ALBEDO = base_color.rgb * variation;
    ROUGHNESS = 0.78;
    SPECULAR = 0.22;
    RIM = 0.08;
    RIM_TINT = 0.7;
    // Opaque rim response avoids layering transparent tissue on a mobile screen.
    float edge = pow(1.0 - max(dot(normalize(NORMAL), normalize(VIEW)), 0.0), 3.0);
    EMISSION = base_color.rgb * edge * 0.018;
}
