"""Author Serotonin meshes in Blender; run with --background --python this_file.
Only clears the disposable Blender process scene, never opens an existing user .blend.
"""
import argparse
import json
import math
import sys
from pathlib import Path

import bpy
import bmesh
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'art' / 'source'
PREVIEW = ROOT / 'art' / 'previews'
RUNTIME = ROOT / 'godot' / 'assets' / 'models'
for folder in (SOURCE, PREVIEW, RUNTIME):
    folder.mkdir(parents=True, exist_ok=True)

args = argparse.ArgumentParser()
selection = args.add_mutually_exclusive_group()
selection.add_argument('--hero-only', action='store_true')
args.add_argument('--skip-render', action='store_true')
selection.add_argument('--asset', choices=['ilmek', 'nefes', 'kiskac', 'garden'])
opts = args.parse_args(sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else [])
bpy.context.preferences.filepaths.file_preview_type = 'NONE'


def linear_channel(value):
    return value / 12.92 if value <= .04045 else ((value + .055) / 1.055) ** 2.4


def material(name, hex_color, roughness=.42, emission=0):
    rgb = tuple(linear_channel(int(hex_color[i:i+2], 16) / 255) for i in (0, 2, 4))
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    mat.diffuse_color = (*rgb, 1)
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*rgb, 1)
    bsdf.inputs['Roughness'].default_value = roughness
    bsdf.inputs['Metallic'].default_value = .05
    if emission:
        bsdf.inputs['Emission Color'].default_value = (*rgb, 1)
        bsdf.inputs['Emission Strength'].default_value = emission
    return mat


def reset():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    return {
        'pearl': material('Pearl_E8E1D5', 'E8E1D5'),
        'ink': material('Ink_102E34', '102E34', .35),
        'gold': material('Gold_E8BD64', 'E8BD64', .32, .12),
        'coral': material('Coral_D99689', 'D99689', .5),
        'teal': material('Petrol_244B50', '244B50', .62),
    }


def finish(obj, name, mat):
    obj.name = name
    obj.data.materials.append(mat)
    if obj.type == 'MESH':
        for poly in obj.data.polygons:
            poly.use_smooth = True
    return obj


def sphere(name, loc, scale, mat, segments=24, rings=12):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, location=loc)
    obj = bpy.context.object
    obj.scale = scale
    return finish(obj, name, mat)


def tube(name, points, radius, mat):
    curve = bpy.data.curves.new(name, 'CURVE')
    curve.dimensions = '3D'
    curve.resolution_u = 5
    curve.bevel_depth = radius
    curve.bevel_resolution = 2
    curve.use_fill_caps = True
    spline = curve.splines.new('BEZIER')
    spline.bezier_points.add(len(points) - 1)
    for p, co in zip(spline.bezier_points, points):
        p.co = co
        p.handle_left_type = 'AUTO'
        p.handle_right_type = 'AUTO'
    obj = bpy.data.objects.new(name, curve)
    bpy.context.collection.objects.link(obj)
    return finish(obj, name, mat)


def hero(ctx):
    m = ctx['materials']
    objects = []
    body = sphere('Ilmek_body', (0, .025, .62), (.165, .14, .40), m['pearl'], 24, 12)
    # Seed taper, preserving closed UV sphere topology.
    for vertex in body.data.vertices:
        if vertex.co.z > 0:
            vertex.co.x *= 1 - .32 * vertex.co.z
            vertex.co.y *= 1 - .22 * vertex.co.z
    objects.append(body)
    objects.append(sphere('Ilmek_head', (0, -.01, 1.065), (.22, .18, .255), m['pearl'], 24, 12))
    objects.append(sphere('Face_mask', (0, -.17, 1.07), (.156, .045, .14), m['ink'], 20, 10))
    for sign in (-1, 1):
        objects.append(sphere('Eye_L' if sign < 0 else 'Eye_R',
                              (sign*.058, -.213, 1.09), (.018, .012, .027), m['pearl'], 12, 8))
        wing = sphere('Wing_L' if sign < 0 else 'Wing_R',
                      (sign*.20, .21, .64), (.20, .022, .47), m['pearl'], 20, 12)
        # Thin closed membrane, gently cupped towards the tip (opaque for mobile).
        for vertex in wing.data.vertices:
            vertex.co.x *= .65 + .35 * vertex.co.z
            vertex.co.y += .22 * (1 - vertex.co.z) ** 2
        wing.rotation_euler[0] = .48
        wing.rotation_euler[1] = sign * -.22
        objects.append(wing)
        objects.append(sphere('Foot_L' if sign < 0 else 'Foot_R',
                              (sign*.075, -.015, .16), (.055, .075, .16), m['ink'], 16, 8))
    objects.append(tube('Golden_crown_stem', [(0, .015, 1.30), (.07, .02, 1.36),
                                             (.18, -.005, 1.40)], .018, m['gold']))
    objects.append(sphere('Crown_seed', (.18, -.005, 1.40), (.055, .04, .045), m['gold'], 12, 8))
    objects.append(tube('Ribbon_source', [(0, .25, .49), (.40, .36, .40),
                                         (.70, .36, .30), (.86, .35, .55),
                                         (1.05, .15, .66)], .019, m['gold']))
    objects.append(sphere('Ribbon_tip', (1.05, .15, .66), (.036,.036,.036), m['gold'], 12, 8))
    return objects


def normalize(objects):
    bpy.ops.object.select_all(action='DESELECT')
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.object.convert(target='MESH')
    objects = list(bpy.context.selected_objects)
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    for obj in objects:
        mesh = obj.data
        bm = bmesh.new()
        bm.from_mesh(mesh)
        # Curve cap rings may be coincident but disconnected after conversion.
        bmesh.ops.remove_doubles(bm, verts=list(bm.verts), dist=0.00001)
        bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
        bm.to_mesh(mesh)
        bm.free()
    return objects


def geometry_report(objects):
    triangles = 0
    degenerate = 0
    nonmanifold = 0
    materials = set()
    low = Vector((math.inf, math.inf, math.inf))
    high = Vector((-math.inf, -math.inf, -math.inf))
    for obj in objects:
        obj.data.calc_loop_triangles()
        triangles += len(obj.data.loop_triangles)
        degenerate += sum(1 for p in obj.data.polygons if p.area < 1e-10)
        materials.update(mat.name for mat in obj.data.materials if mat)
        bm = bmesh.new()
        bm.from_mesh(obj.data)
        nonmanifold += sum(1 for edge in bm.edges if not edge.is_manifold)
        bm.free()
        for vertex in obj.data.vertices:
            p = obj.matrix_world @ vertex.co
            for index in range(3):
                low[index] = min(low[index], p[index])
                high[index] = max(high[index], p[index])
    return {'triangles': triangles, 'degenerate_faces': degenerate,
            'nonmanifold_edges': nonmanifold, 'materials': sorted(materials),
            'dimensions_blender': [round(v, 4) for v in high-low],
            'uv_meshes': sum(bool(o.data.uv_layers) for o in objects),
            'mesh_parts': len(objects), 'rig': False, 'lod': False,
            'overlap_policy': 'Separate closed parts may overlap intentionally; not a boolean-unioned printable mesh.'}


def export(name, objects):
    bpy.ops.object.select_all(action='DESELECT')
    # Export a merged copy for few draw calls; retain editable parts in the .blend.
    copies = []
    semantic_parts = []
    shell_parts = []
    for obj in objects:
        clone = obj.copy()
        clone.data = obj.data.copy()
        bpy.context.collection.objects.link(clone)
        if name == 'kiskac' and obj.name.startswith('Guardian_Shell_'):
            clone.name = obj.name + '_Runtime'
            clone.select_set(False)
            shell_parts.append(clone)
        elif name == 'kiskac' and obj.name.startswith('Guardian_Exposed_'):
            # Keep the authored thread independently controllable at runtime.
            clone.name = 'Guardian_Seam_Runtime'
            clone.select_set(False)
            semantic_parts.append(clone)
        else:
            clone.select_set(True)
            copies.append(clone)
    bpy.context.view_layer.objects.active = copies[0]
    bpy.ops.object.join()
    merged = bpy.context.object
    bpy.context.scene.cursor.location = (0,0,0)
    bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
    merged.name = name
    if semantic_parts:
        bpy.ops.object.select_all(action='DESELECT')
        for part in semantic_parts:
            part.select_set(True)
        bpy.context.view_layer.objects.active = semantic_parts[0]
        bpy.ops.object.join()
        seam = bpy.context.object
        seam.name = 'Guardian_Seam_Runtime'
        bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
        semantic_parts = [seam]
        merged.select_set(True)
    for part in semantic_parts + shell_parts:
        part.select_set(True)
    bpy.ops.export_scene.gltf(filepath=str(RUNTIME / f'{name}.glb'),
                              export_format='GLB', use_selection=True,
                              export_yup=True, export_animations=False)
    bpy.data.objects.remove(merged, do_unlink=True)
    for part in semantic_parts + shell_parts:
        bpy.data.objects.remove(part, do_unlink=True)


def aim(obj, target):
    obj.rotation_euler = (Vector(target) - obj.location).to_track_quat('-Z', 'Y').to_euler()


def setup_render(name, mats):
    scene = bpy.context.scene
    scene.render.engine = 'CYCLES'
    scene.cycles.device = 'CPU'
    scene.cycles.samples = 24
    scene.cycles.use_denoising = True
    scene.render.resolution_x = 1120
    scene.render.resolution_y = 840
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'PNG'
    scene.render.filepath = str(PREVIEW / f'{name}.png')
    scene.world.use_nodes = True
    scene.world.node_tree.nodes['Background'].inputs[0].default_value = (.045,.07,.075,1)
    scene.world.node_tree.nodes['Background'].inputs[1].default_value = .5
    scene.view_settings.view_transform = 'AgX'
    if name == 'garden':
        target, cam, size = (0,0,0), (11,-17,18), 22
    elif name == 'kiskac':
        target, cam, size = (0,0,.6), (3.4,-5.6,3.1), 4.3
    elif name == 'nefes':
        target, cam, size = (0,0,.325), (2,-3,3.2), 1.75
    else:
        target, cam, size = (0,0,.65), (3,-5.6,3.2), 3.2 if name == 'ilmek' else 1.65
    bpy.ops.object.camera_add(location=cam)
    scene.camera = bpy.context.object
    scene.camera.data.type = 'ORTHO'
    scene.camera.data.ortho_scale = size
    aim(scene.camera, target)
    for label, loc, energy, color, area in [
        ('Warm_key', (-3,-4,6), 650, (1,.85,.70), 4),
        ('Cool_fill', (4,-1,4), 400, (.65,.86,1), 3),
        ('Rim', (1,4,5), 900, (1,.77,.47), 3),
    ]:
        bpy.ops.object.light_add(type='AREA', location=loc)
        lamp = bpy.context.object
        lamp.name = label
        lamp.data.energy = energy * (4 if name == 'garden' else 1)
        lamp.data.color = color
        lamp.data.shape = 'DISK'
        lamp.data.size = area
        aim(lamp, target)
    bpy.ops.mesh.primitive_plane_add(size=200, location=(0,0,-.065 if name != 'garden' else -.5))
    finish(bpy.context.object, 'Studio_floor_not_exported', mats['teal'])


builders = {'ilmek': hero}
if not opts.hero_only:
    sys.path.insert(0, str(Path(__file__).parent))
    from props import build_nefes, build_guardian, build_garden
    builders.update(nefes=build_nefes, kiskac=build_guardian, garden=build_garden)
if opts.asset:
    builders = {opts.asset: builders[opts.asset]}

records = []
budgets = {'ilmek':6000, 'nefes':2000, 'kiskac':8000, 'garden':12000}
for name, build in builders.items():
    mats = reset()
    objects = normalize(build({'materials':mats, 'sphere':sphere, 'tube':tube}))
    report = geometry_report(objects)
    report['export_mesh_groups'] = 4 if name == 'kiskac' else 1
    report['budget'] = budgets[name]
    report['within_budget'] = report['triangles'] <= budgets[name]
    if not report['within_budget'] or report['degenerate_faces'] or report['nonmanifold_edges']:
        raise RuntimeError(f'{name}: geometry gate failed: {report}')
    export(name, objects)
    setup_render(name, mats)
    bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE / f'{name}.blend'))
    if not opts.skip_render:
        bpy.ops.render.render(write_still=True)
    records.append({'id':name, 'path':f'godot/assets/models/{name}.glb',
                    'source_path':f'art/source/{name}.blend', 'status':'authored_first_pass',
                    'technical':report,
                    'source':{'kind':'authored_procedural_mesh','tool':bpy.app.version_string,
                              'creator':'Serotonin project / Blender Python',
                              'external_assets':False,'license':'Project-authored; no third-party model or texture content.',
                              'recipe':'art/tools/build_assets.py + art/tools/props.py'},
                    'verification':{'native_scale_reviewed':False,'in_engine_reviewed':False,
                                    'technical_checks_passed':report['within_budget'] and report['nonmanifold_edges']==0,
                                    'approved_by':''}})

manifest = {'schema_version':1,'art_direction_brief':'art/ART_DIRECTION.md','assets':records}
outname = f'{opts.asset}_manifest.json' if opts.asset else ('hero_manifest.json' if opts.hero_only else 'asset_manifest.json')
(ROOT / 'art' / outname).write_text(json.dumps(manifest, indent=2, ensure_ascii=False), encoding='utf-8')
print('SEROTONIN_ASSETS_COMPLETE ' + json.dumps({r['id']:r['technical']['triangles'] for r in records}))
