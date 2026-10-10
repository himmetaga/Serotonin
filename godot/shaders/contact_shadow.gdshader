shader_type spatial;
render_mode unshaded, depth_draw_never;
void fragment() {
    float distance_from_center = length(UV * 2.0 - 1.0);
    ALBEDO = vec3(0.08, 0.07, 0.09);
    ALPHA = (1.0 - smoothstep(0.1, 0.95, distance_from_center)) * 0.23;
}
