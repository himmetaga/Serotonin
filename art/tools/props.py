"""Small, reusable Blender prop family for Serotonin's first arena.

Coordinates are Blender Z-up; the authored front faces -Y (Godot +Z after
the project's axis conversion). Materials are supplied by the parent builder.
"""

from math import cos, pi, sin

import bpy
import bmesh


def _mesh_object(name, vertices, faces, material, smooth=False):
    mesh = bpy.data.meshes.new(f"{name}_Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    if material is not None:
        mesh.materials.append(material)
    for polygon in mesh.polygons:
        polygon.use_smooth = smooth
    return obj


def _torus(name, center, major_radius, minor_radius, material,
           major_segments=24, minor_segments=8):
    """Closed low-poly torus whose opening reads clearly at gameplay scale."""
    cx, cy, cz = center
    vertices = []
    faces = []
    for i in range(major_segments):
        u = 2.0 * pi * i / major_segments
        for j in range(minor_segments):
            v = 2.0 * pi * j / minor_segments
            ring = major_radius + minor_radius * cos(v)
            vertices.append((cx + ring * cos(u), cy + ring * sin(u),
                             cz + minor_radius * sin(v)))
    for i in range(major_segments):
        for j in range(minor_segments):
            a = i * minor_segments + j
            b = ((i + 1) % major_segments) * minor_segments + j
            c = ((i + 1) % major_segments) * minor_segments + (j + 1) % minor_segments
            d = i * minor_segments + (j + 1) % minor_segments
            faces.append((a, b, c, d))
    return _mesh_object(name, vertices, faces, material, smooth=True)


def _lobed_membrane(name, center, material):
    """Closed three-lobed torus with an open center and tall soft profile."""
    cx, cy, cz = center
    major_segments, minor_segments = 36, 8
    vertices = []
    faces = []
    for i in range(major_segments):
        u = 2.0 * pi * i / major_segments
        centerline_radius = 0.24 + 0.055 * cos(3.0 * u)
        for j in range(minor_segments):
            v = 2.0 * pi * j / minor_segments
            radius = centerline_radius + 0.085 * cos(v)
            vertices.append((cx + radius * cos(u), cy + radius * sin(u),
                             cz + 0.325 * sin(v)))
    for i in range(major_segments):
        for j in range(minor_segments):
            a = i * minor_segments + j
            b = ((i + 1) % major_segments) * minor_segments + j
            c = ((i + 1) % major_segments) * minor_segments + (j + 1) % minor_segments
            d = i * minor_segments + (j + 1) % minor_segments
            faces.append((a, b, c, d))
    return _mesh_object(name, vertices, faces, material, smooth=True)


def _organic_island(name, material):
    """Closed shallow island spanning 18 x 11 units, with its top at z=0."""
    count = 40
    vertices = []
    faces = []
    bottom_z, top_z = -0.28, 0.0
    for z in (bottom_z, top_z):
        for i in range(count):
            angle = 2.0 * pi * i / count
            wobble = 0.97 + 0.02 * sin(3.0 * angle + 0.4) + 0.01 * cos(5.0 * angle)
            vertices.append((9.0 * wobble * cos(angle),
                             5.5 * wobble * sin(angle), z))
    bottom_center = len(vertices)
    vertices.append((0.0, 0.0, bottom_z))
    top_center = len(vertices)
    vertices.append((0.0, 0.0, top_z))
    for i in range(count):
        nxt = (i + 1) % count
        faces.append((bottom_center, nxt, i))
        faces.append((top_center, count + i, count + nxt))
        faces.append((i, nxt, count + nxt, count + i))
    return _mesh_object(name, vertices, faces, material, smooth=False)


def build_nefes(ctx):
    """One closed three-lobed membrane with a physical central opening; height .65."""
    return [_lobed_membrane("Nefes_Three_Lobed_Membrane", (0.0, 0.0, 0.325),
                            ctx["materials"]["pearl"])]


def _guardian_shell_half(name, side, coral, ink):
    """Closed ellipsoid half, with a flat dark interior on the split plane."""
    segments, rings = 32, 12
    vertices = [(side * 1.1, 0.0, 0.65)]
    for ring in range(1, rings + 1):
        theta = (pi * 0.5) * ring / rings
        for j in range(segments):
            phi = 2.0 * pi * j / segments
            vertices.append((side * 1.1 * cos(theta),
                             0.48 * sin(theta) * cos(phi),
                             0.65 + 0.65 * sin(theta) * sin(phi)))
    faces = [(0, 1 + j, 1 + (j + 1) % segments) for j in range(segments)]
    for ring in range(rings - 1):
        a = 1 + ring * segments
        b = a + segments
        for j in range(segments):
            nxt = (j + 1) % segments
            faces.append((a + j, b + j, b + nxt, a + nxt))
    cap_start = len(faces)
    center = len(vertices)
    vertices.append((0.0, 0.0, 0.65))
    edge = 1 + (rings - 1) * segments
    faces.extend((center, edge + j, edge + (j + 1) % segments)
                 for j in range(segments))
    obj = _mesh_object(name, vertices, faces, coral, smooth=True)
    obj.data.materials.append(ink)
    for face in list(obj.data.polygons)[cap_start:]:
        face.material_index = 1
        face.use_smooth = False
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(obj.data)
    bm.free()
    return obj


def build_guardian(ctx):
    """Friendly shell guardian, rooted at z=0 and facing Blender -Y."""
    pieces = []
    coral = ctx["materials"]["coral"]
    ink = ctx["materials"]["ink"]
    gold = ctx["materials"]["gold"]

    for side, suffix in [(-1, 'L'), (1, 'R')]:
        pieces.append(_guardian_shell_half(f"Guardian_Shell_{suffix}", side, coral, ink))
    # A smaller protected body remains connected when the carapace parts slide apart.
    pieces.append(ctx["sphere"]("Guardian_Inner_Body", (0.0, 0.0, 0.65),
                                 (0.30, 0.32, 0.38), ink, segments=16, rings=8))
    # A shallow inset face and two tiny warm highlights make the front legible.
    pieces.append(ctx["sphere"]("Guardian_Inset_Face", (0.0, -0.455, 0.67),
                                 (0.265, 0.075, 0.17), ink, segments=16, rings=8))
    for side in (-1, 1):
        pieces.append(ctx["sphere"](
            f"Guardian_Eye_Glint_{'L' if side < 0 else 'R'}",
            (side * 0.095, -0.526, 0.705), (0.035, 0.018, 0.035), gold,
            segments=12, rings=8))

    # Paired, open C arcs wrap the sides without obscuring the face.
    left = [(-0.52, -0.39, 0.48), (-0.69, -0.49, 0.31),
            (-0.87, -0.50, 0.31), (-1.00, -0.50, 0.48),
            (-0.99, -0.50, 0.70), (-0.86, -0.49, 0.91),
            (-0.69, -0.42, 0.89), (-0.58, -0.37, 0.78)]
    for side in (-1, 1):
        points = left if side < 0 else [(-x, y, z) for x, y, z in left]
        pieces.append(ctx["tube"](
            f"Guardian_C_CLaw_{'L' if side < 0 else 'R'}", points, 0.105, coral))

    # A dark cleft keeps the gold thread legible without relying on hue.
    seam_points = [(0.0, -0.26, 0.90), (0.0, -0.13, 1.00),
                   (0.0, 0.0, 1.04), (0.0, 0.13, 1.00), (0.0, 0.26, 0.90)]
    pieces.append(ctx["tube"](
        "Guardian_Exposed_Ink_Cleft", seam_points, 0.09, ctx["materials"]["ink"]))
    pieces.append(ctx["tube"](
        "Guardian_Exposed_Gold_Seam",
        [(x, y - 0.035, z + 0.075) for x, y, z in seam_points], 0.035, gold))
    return pieces


def build_garden(ctx):
    """18 x 11 organic floor island with membrane growth kept at its rim."""
    pieces = [_organic_island("Garden_Teal_Island", ctx["materials"]["teal"])]
    coral = ctx["materials"]["coral"]
    gold = ctx["materials"]["gold"]

    # Cluster only outside the playable arena bounds, preserving the center lane.
    clusters = [
        (-7.85, -3.95, 0.48), (-8.05, -0.55, 0.55), (-7.88, 3.95, 0.50),
        (7.85, -3.85, 0.52), (8.0, 0.35, 0.48), (7.85, 3.95, 0.55),
        (-4.8, -4.62, 0.42), (0.0, -4.70, 0.50), (4.75, -4.60, 0.44),
        (-4.9, 4.62, 0.48), (0.15, 4.72, 0.42), (4.9, 4.58, 0.50),
    ]
    for index, (x, y, size) in enumerate(clusters):
        pieces.append(ctx["sphere"](
            f"Garden_Perimeter_Membrane_{index + 1}", (x, y, 0.27),
            (size, size * 0.78, 0.24), coral, segments=16, rings=8))

    bulb_positions = [(-7.35, -2.2), (-7.35, 2.35), (7.35, -2.1),
                      (7.35, 2.25), (-2.6, -4.35), (2.7, 4.32)]
    for index, (x, y) in enumerate(bulb_positions):
        pieces.append(ctx["sphere"](
            f"Garden_Gold_Bulb_{index + 1}", (x, y, 0.32),
            (0.16, 0.16, 0.20), gold, segments=16, rings=8))
    return pieces
