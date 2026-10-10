shader_type spatial;
render_mode diffuse_burley;

uniform vec4 base_color : source_color = vec4(0.64, 0.49, 0.40, 1.0);
varying vec3 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// Screen-space smoothing keeps fine fibers from flickering as the camera moves.
float vein(float distance_to_curve, float width) {
    float aa = max(fwidth(distance_to_curve), 0.002);
    return 1.0 - smoothstep(width, width + aa, abs(distance_to_curve));
}

void fragment() {
    vec2 p = world_position.xz;
    float flow = 0.42 * sin(p.x * 0.48) + 0.20 * sin(p.x * 1.10 + 0.7);
    float trunk = vein(p.y - flow, 0.018);
    float branches = 0.0;
    for (int i = 0; i < 5; i++) {
        float offset = float(i) * 0.68 + float(i * i) * 0.065 - 1.64;
        float curve = flow + offset + 0.26 * sin(p.x * (0.8 + float(i) * 0.17) + float(i) * 1.9);
        branches = max(branches, vein(p.y - curve, 0.009));
    }
    // Decoration follows the route; it never emits light or impersonates an objective sign.
    float fine_phase = (p.y - flow) * 27.0 + 0.6 * sin(p.x * 2.0);
    float fine = sin(fine_phase) * (1.0 - smoothstep(0.6, 1.8, fwidth(fine_phase)));
    float mottling = sin(p.x * 0.85 + p.y * 1.7) * sin(p.y * 0.6 - p.x * 0.2);
    ALBEDO = base_color.rgb * (0.97 + 0.03 * mottling + 0.003 * fine);
    float quiet_arena = mix(0.45, 1.0, smoothstep(0.8, 2.8, length(p - vec2(2.0, 0.0))));
    ALBEDO = mix(ALBEDO, base_color.rgb * vec3(1.06, 1.09, 1.10),
                 (trunk * 0.4 + branches * 0.3) * quiet_arena);
    ROUGHNESS = 0.83;
    SPECULAR = 0.18;
}
