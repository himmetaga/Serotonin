"""Deterministic procedural membrane-room source and GLB exporter for Serotonin."""
import bpy
import bmesh
import json
import math
import os
from mathutils import Vector

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SOURCE = os.path.join(ROOT, "art", "source", "membrane_room.blend")
GLB = os.path.join(ROOT, "godot", "assets", "models", "membrane_room.glb")
MANIFEST = os.path.join(ROOT, "art", "membrane_room_manifest.json")
MAX_TRIANGLES = 22000

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
for datablocks in (bpy.data.meshes, bpy.data.curves, bpy.data.materials):
    for block in list(datablocks):
        if block.users == 0:
            datablocks.remove(block)

def material(name, color, roughness):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1.0)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    return m

pearl = material("Pearl_Coral_Satin", (0.72, 0.38, 0.31), 0.43)
warm = material("Warm_Pearl_Satin", (0.91, 0.68, 0.55), 0.48)
teal = material("Deep_Teal_Satin", (0.045, 0.20, 0.22), 0.52)
parts = []

def make_mesh(name, verts, faces, mat):
    mesh = bpy.data.meshes.new(name + "Mesh")
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(mesh)
    bm.free()
    mesh.update()
    # A coherent planar UV set is retained for later material work.
    uv = mesh.uv_layers.new(name="MembraneUV")
    xs = [v.co.x for v in mesh.vertices]
    ys = [v.co.y for v in mesh.vertices]
    xspan, yspan = max(max(xs)-min(xs), 1e-5), max(max(ys)-min(ys), 1e-5)
    for poly in mesh.polygons:
        for li in poly.loop_indices:
            co = mesh.vertices[mesh.loops[li].vertex_index].co
            uv.data[li].uv = ((co.x-min(xs))/xspan, (co.y-min(ys))/yspan)
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat)
    parts.append(obj)
    return obj

def grid_shell(name, nu, nv, point, thickness, mat):
    """Closed thick sheet with sampled top/bottom and a welded perimeter boundary."""
    verts, faces = [], []
    for layer in range(2):
        for j in range(nv + 1):
            v = j / nv
            for i in range(nu + 1):
                u = i / nu
                x, y, z = point(u, v)
                verts.append((x, y, z - (thickness if layer else 0.0)))
    row = nu + 1
    layer_size = row * (nv + 1)
    for j in range(nv):
        for i in range(nu):
            a = j*row+i; b=a+1; c=a+row+1; d=a+row
            faces.extend(((a,b,c),(a,c,d)))
            A,B,C,D = (a+layer_size,b+layer_size,c+layer_size,d+layer_size)
            faces.extend(((A,C,B),(A,D,C)))
    boundary = list(range(nu+1))
    boundary += [j*row+nu for j in range(1,nv+1)]
    boundary += [nv*row+i for i in range(nu-1,-1,-1)]
    boundary += [j*row for j in range(nv-1,0,-1)]
    for k, a in enumerate(boundary):
        b = boundary[(k+1) % len(boundary)]
        faces.append((a,b,b+layer_size,a+layer_size))
    obj=make_mesh(name, verts, faces, mat)
    for poly in obj.data.polygons:
        poly.use_smooth=True
    return obj

def coast_point(theta):
    """A lobed coast outside an explicitly protected, flat gameplay rectangle."""
    cs, sn = math.cos(theta), math.sin(theta)
    direction = Vector((9.0*math.copysign(abs(cs)**.5, cs),
                        4.8*math.copysign(abs(sn)**.5, sn), 0)).normalized()
    protected = min(7.35/max(abs(direction.x), 1e-9),
                    3.85/max(abs(direction.y), 1e-9))
    lobe = (.5 + .5*math.sin(5*theta+.6))**2
    extension = .22 + .68*lobe + .18*math.sin(3*theta-1.2)**2
    return direction, protected, extension


def rounded_platform():
    """Flat protected core, scalloped thinning coast; no sloped gameplay surface."""
    segments, radial_rings = 96, 7
    thickness = .35
    verts, faces = [(0.0, 0.0, 0.0)], []
    for layer in range(2):
        for ring in range(1, radial_rings+1):
            for k in range(segments):
                theta=math.tau*k/segments
                direction, protected, extension = coast_point(theta)
                fringe = max(0.0, (ring-4)/3)
                radius = protected*ring/4 if ring <= 4 else protected + extension*fringe
                x, y = direction.x*radius, direction.y*radius
                z = -.28*fringe**2
                local_thickness = thickness*(1-fringe) + .10*fringe
                verts.append((x,y,z-(local_thickness if layer else 0.0)))
    layer_size=radial_rings*segments
    bottom_center=len(verts)
    verts.append((0.0,0.0,-thickness))
    for k in range(segments):
        nxt=(k+1)%segments
        faces.extend(((0,1+k,1+nxt),(bottom_center,1+layer_size+nxt,1+layer_size+k)))
    for ring in range(radial_rings-1):
        inner=1+ring*segments; outer=inner+segments
        inner_b=inner+layer_size; outer_b=outer+layer_size
        for k in range(segments):
            nxt=(k+1)%segments
            faces.extend(((inner+k,outer+k,outer+nxt),(inner+k,outer+nxt,inner+nxt),
                          (inner_b+k,outer_b+nxt,outer_b+k),(inner_b+k,inner_b+nxt,outer_b+nxt)))
    top_edge=1+(radial_rings-1)*segments
    bottom_edge=top_edge+layer_size
    for k in range(segments):
        nxt=(k+1)%segments
        faces.extend(((top_edge+k,bottom_edge+k,bottom_edge+nxt),(top_edge+k,bottom_edge+nxt,top_edge+nxt)))
    obj=make_mesh("Continuous_Playable_Membrane",verts,faces,pearl)
    for poly in obj.data.polygons:
        poly.use_smooth=True

rounded_platform()

def tube(name, path, radii, mat, sides=8):
    # Smooth swept tapered rib, closed by end fans; separate closed intersections are intentional.
    verts, faces = [], []
    for i, p in enumerate(path):
        center = Vector(p)
        tangent = Vector(path[min(i+1,len(path)-1)]) - Vector(path[max(i-1,0)])
        tangent.normalize()
        ref = Vector((0,1,0)) if abs(tangent.dot(Vector((0,0,1)))) > .92 else Vector((0,0,1))
        side = tangent.cross(ref).normalized()
        up = tangent.cross(side).normalized()
        for k in range(sides):
            ang = math.tau*k/sides
            q = center + radii[i]*(math.cos(ang)*side + math.sin(ang)*up)
            verts.append(tuple(q))
    for i in range(len(path)-1):
        for k in range(sides):
            a=i*sides+k; b=i*sides+(k+1)%sides
            faces.append((a,b,b+sides,a+sides))
    faces.append(tuple(range(sides-1,-1,-1)))
    base=(len(path)-1)*sides
    faces.append(tuple(base+k for k in range(sides)))
    obj=make_mesh(name, verts, faces, mat)
    for poly in obj.data.polygons:
        poly.use_smooth=True
    return obj

# Curving, tapered roots emerge from the thinning coast. No regular outer rail.
fascia_parts = []
def edge_point(theta):
    direction, protected, extension = coast_point(theta)
    point = direction*(protected+extension)
    point.z = -.28
    return point


def bezier_path(a, b, c, d, samples):
    return [tuple((1-t)**3*a + 3*(1-t)**2*t*b + 3*(1-t)*t*t*c + t**3*d)
            for t in (i/(samples-1) for i in range(samples))]


for bay in range(20):
    theta = math.tau*(bay+.12*math.sin(bay*1.9))/20
    outward, _, _ = coast_point(theta)
    tangent = Vector((-outward.y, outward.x, 0))
    a = edge_point(theta)
    reach = 1.25 + .65*(.5+.5*math.sin(bay*2.1))
    d = a + outward*reach + tangent*.35*math.sin(bay*1.4)
    d.z = -1.15 - .35*(.5+.5*math.sin(bay*.9))
    b = a + outward*.50 + Vector((0,0,.22))
    c = d - outward*.45 + Vector((0,0,.65))
    trunk = bezier_path(a,b,c,d,9)
    fascia_parts.append(tube("Coastal_Primary_Root", trunk,
                             [.25*(1-i/8)**1.3+.025 for i in range(9)], warm, 8))
    # Neighboring roots converge into the trunk instead of making straight diagonals.
    e = edge_point(theta + math.tau/20*.72)
    join = Vector(trunk[5])
    branch = bezier_path(e, e+outward*.45+Vector((0,0,.12)),
                        join+tangent*.35+Vector((0,0,.20)), join, 7)
    fascia_parts.append(tube("Coastal_Secondary_Root", branch,
                             [.11,.10,.08,.06,.055,.065,.085], warm, 7))
bpy.ops.object.select_all(action="DESELECT")
for obj in fascia_parts:
    obj.select_set(True)
bpy.context.view_layer.objects.active=fascia_parts[0]
bpy.ops.object.join()
fascia = bpy.context.object
fascia.name = "Growing_Costal_Roots"
parts = [obj for obj in parts if obj not in fascia_parts] + [fascia]

# Branching, hollow-space framing ribs below the platform (no detail intrudes on the walkable top).
rib_specs = [
    [(-6.6,-3.25,-.34),(-5.0,-2.8,-1.0),(-3.0,-2.4,-1.8),(-1.0,-1.7,-2.6),(1.2,-1.2,-3.3)],
    [(-5.5,3.25,-.35),(-4.0,2.6,-1.0),(-2.7,1.6,-1.9),(-1.0,.4,-2.7),(1.5,-.5,-3.5)],
    [(5.8,-3.2,-.35),(4.5,-2.4,-1.1),(3.1,-1.2,-2.0),(1.5,.2,-2.9),(.4,1.8,-3.7)],
    [(6.5,3.0,-.35),(5.1,2.4,-1.2),(3.9,2.0,-2.2),(2.1,2.2,-3.1),(.5,2.6,-3.8)],
    [(-3.3,-3.1,-.35),(-2.3,-2.3,-1.25),(-1.7,-1.1,-2.0),(-1.5,.2,-2.6),(-1.2,1.2,-3.0)],
    [(3.7,3.15,-.35),(2.7,2.5,-1.2),(2.2,1.4,-2.1),(2.8,.2,-3.0),(3.0,-1.1,-3.6)],
]
for idx, path in enumerate(rib_specs):
    radii=[.36,.30,.22,.15,.09]
    tube("Branching_Underside_Rib_%02d"%idx, path, radii, teal if idx%2 else warm, 9)

# Cellular leaf vaults: irregular planar Voronoi cells mapped onto a bowed
# anatomical surface. This is authored geometry, not a volumetric growth model.
def clip_cell(poly, nx, ny, limit):
    result = []
    for a, b in zip(poly, poly[1:] + poly[:1]):
        da, db = nx*a[0]+ny*a[1]-limit, nx*b[0]+ny*b[1]-limit
        if da <= 1e-9:
            result.append(a)
        if (da < 0) != (db < 0):
            t = da/(da-db)
            result.append((a[0]+t*(b[0]-a[0]), a[1]+t*(b[1]-a[1])))
    return result


def cellular_vault(index, cx, width, height, phase):
    def point(u, v):
        span = .12 + .88*math.sin(math.pi*v)**.72
        return Vector((cx + width*u*span + .65*v*v,
                       5.9 + .8*(1-u*u)*math.sin(math.pi*v) + .28*math.sin(v*4+phase),
                       .05 + height*v))

    seeds = []
    for row in range(5):
        for col in range(5):
            u = -1 + (col+.5)*.4 + .075*math.sin(row*3.7+col*2.9+phase)
            v = (row+.5)/5 + .028*math.sin(col*4.1+row*1.7+phase)
            seeds.append((u,v))
    cells, edges = [], {}
    for sx, sy in seeds:
        poly = [(-1,0),(1,0),(1,1),(-1,1)]
        for tx, ty in seeds:
            if (sx,sy) == (tx,ty):
                continue
            poly = clip_cell(poly, 2*(tx-sx), 2*(ty-sy), tx*tx+ty*ty-sx*sx-sy*sy)
            if not poly:
                break
        cells.append(poly)
        for a, b in zip(poly,poly[1:]+poly[:1]):
            key = tuple(sorted((tuple(round(n,6) for n in a),tuple(round(n,6) for n in b))))
            edges[key] = (a,b)

    components = []
    # Main perimeter grows from thick feet into a delicate crown, rather than
    # forming a fat torus. Cell edges remain a different scale of structure.
    for side in (-1,1):
        path = [point(side, i/32) for i in range(33)]
        components.append(tube("Vault_Primary", path,
                               [.055+.16*(1-i/32)**1.7 for i in range(33)], warm, 8))
    for a,b in edges.values():
        if abs(a[0]-b[0]) < 1e-5 and abs(a[0]) > .999:
            continue # Boundary already has its primary rib.
        path = [point(a[0]+(b[0]-a[0])*t, a[1]+(b[1]-a[1])*t) for t in (0,.5,1)]
        mid_v = (a[1]+b[1])*.5
        radius = .018 + .026*(1-mid_v)
        components.append(tube("Vault_Cellular_Fiber",path,[radius*1.15,radius,radius*1.15],warm,6))
    # Selected closed, thin sheets: mostly real openings, not a solid painted net.
    for cell_index, poly in enumerate(cells):
        if cell_index % 7 != 3 or len(poly) < 3:
            continue
        top = [point(u,v) for u,v in poly]
        n = len(top)
        verts = [tuple(p) for p in top] + [tuple(p+Vector((0,.025,0))) for p in top]
        faces = [tuple(range(n)),tuple(range(2*n-1,n-1,-1))]
        faces += [(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
        panel = make_mesh("Vault_Stretched_Membrane",verts,faces,pearl)
        for face in panel.data.polygons:
            face.use_smooth = True
        components.append(panel)
    bpy.ops.object.select_all(action="DESELECT")
    for obj in components:
        obj.select_set(True)
    bpy.context.view_layer.objects.active=components[0]
    bpy.ops.object.join()
    vault = bpy.context.object
    vault.name = "Rear_Folded_Vault_%02d" % index
    # Joined source components are separately closed and overlap at junctions;
    # no claim that they are welded into one continuous manifold solid.
    global parts
    parts = [obj for obj in parts if obj not in components] + [vault]


vaults = [(-7.2, 3.4, 1.3, 4.5, 0.0), (-1.0, 3.0, 1.5, 5.3, 1.7), (6.4, 3.2, 1.3, 4.7, 3.2)]
for index, (cx, width, depth, height, phase) in enumerate(vaults):
    cellular_vault(index,cx,width,height*1.75,phase)

# Wide, low causeway carries the eye and player from the arena into the rear anatomy.
def causeway_point(u,v):
    width=1.7+0.7*v
    center_x=1.0+0.7*math.sin(v*3.0)
    x=center_x+(u-.5)*2*width
    y=3.3+5.2*v
    rise=v*v*(3.0-2.0*v)
    z=.4*rise
    return x,y,z
grid_shell("Rear_Meandering_Causeway",12,22,causeway_point,.18,warm)

# Two substantial corner roots sweep from the platform into the front feet of the side vaults.
vault_branches=[
    [(-6.2,3.15,-.02),(-6.8,3.75,.22),(-7.35,4.25,.38),(-7.7,4.7,.28),(-7.55,5.05,-.12)],
    [(6.2,3.15,-.02),(6.75,3.75,.20),(7.25,4.25,.35),(7.55,4.7,.24),(7.45,5.05,-.12)],
]
for idx,path in enumerate(vault_branches):
    tube("Rear_Vault_Connecting_Root_%02d"%idx,path,[.23,.21,.17,.12,.08],warm,10)

# Narrow side folds outside the play rectangle create a framing silhouette and keep center sightlines clear.
for side in (-1,1):
    def side_fold(u,v,side=side):
        x = side*(8.65 + .85*u + .38*math.sin(v*math.pi*1.3+u*2.1))
        y = -3.4 + 8.8*v
        z = .15 + 4.7*u + 1.0*math.sin(v*math.pi*1.4+side)*math.sin(u*math.pi)
        return x,y,z
    grid_shell("Side_Fold_%s"%("L" if side<0 else "R"), 12, 20, side_fold, .14, pearl)

# Deterministic audit of exported geometry.
triangles = sum(sum(max(0, len(poly.vertices)-2) for poly in obj.data.polygons) for obj in parts)
if triangles > MAX_TRIANGLES:
    raise RuntimeError("Triangle budget exceeded: %d > %d" % (triangles, MAX_TRIANGLES))
nonmanifold = degenerate = 0
for obj in parts:
    bm=bmesh.new(); bm.from_mesh(obj.data)
    nonmanifold += sum(1 for e in bm.edges if not e.is_manifold)
    degenerate += sum(1 for f in bm.faces if f.calc_area() < 1e-10)
    bm.free()
coords=[obj.matrix_world @ v.co for obj in parts for v in obj.data.vertices]
bounds=[[round(min(getattr(v,axis) for v in coords),4),round(max(getattr(v,axis) for v in coords),4)] for axis in "xyz"]
if nonmanifold or degenerate:
    raise RuntimeError("Topology audit failed: nonmanifold=%d degenerate=%d"%(nonmanifold,degenerate))

bpy.ops.object.select_all(action="DESELECT")
for obj in parts:
    obj.select_set(True)
bpy.context.view_layer.objects.active=parts[0]
bpy.context.preferences.filepaths.file_preview_type='NONE'
bpy.ops.wm.save_as_mainfile(filepath=SOURCE)
bpy.ops.export_scene.gltf(filepath=GLB, export_format="GLB", use_selection=True,
                         export_apply=True, export_yup=True, export_cameras=False,
                         export_lights=False, export_materials="EXPORT", export_image_format="AUTO")
report={
    "schema_version":1,"id":"membrane_room","status":"authored_first_pass",
    "path":"godot/assets/models/membrane_room.glb","source_path":"art/source/membrane_room.blend",
    "technical":{"triangles":triangles,"triangle_budget":MAX_TRIANGLES,"within_budget":triangles<=MAX_TRIANGLES,
      "nonmanifold_edges":nonmanifold,"degenerate_faces":degenerate,"materials":[m.name for m in (pearl,warm,teal)],
      "blender_bounds_xyz":bounds,"uv_meshes":sum(1 for o in parts if o.data.uv_layers),"mesh_parts":len(parts),
      "playable_top_blender_z":0.0,"playable_footprint_xy_m":[[-7.0,7.0],[-3.5,3.5]],
      "godot_axis_conversion":"Blender Z-up/front -Y to glTF/Godot Y-up/front +Z"},
    "source":{"kind":"authored_procedural_mesh","tool":bpy.app.version_string,"creator":"Serotonin project / Blender Python",
      "external_assets":False,"license":"Project-authored; no third-party model or texture content.",
      "concept_reference":"art/concepts/nefes-v2.png","recipe":"art/tools/build_membrane_room.py"},
    "verification":{"source_and_glb_written":True,"technical_checks_passed":True,"rendered":False,"godot_import_reviewed":False}
}
with open(MANIFEST,"w",encoding="utf-8") as f:
    json.dump(report,f,ensure_ascii=False,indent=2)
    f.write("\n")
print("MEMBRANE_ROOM_REPORT="+json.dumps(report,ensure_ascii=False))
