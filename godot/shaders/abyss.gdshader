shader_type spatial;
render_mode unshaded;
varying vec3 surface_position;
void vertex() { surface_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
    float pool = exp(-length(surface_position.xz - vec2(-3.0, -5.0)) * 0.085);
    ALBEDO = mix(vec3(0.018, 0.048, 0.060), vec3(0.040, 0.130, 0.150), pool);
}
