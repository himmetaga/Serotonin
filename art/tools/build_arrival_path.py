"""Small editable entrance passage, Blender Y=-1 -> Godot Z=+1."""
import bpy
import bmesh
import json
import math
import os
from mathutils import Vector

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
groups = {name: ([], []) for name in ("Arrival_Causeway", "Arrival_Ribs", "Arrival_Tissue")}


def append(name, verts, faces):
    target, polygons = groups[name]
    offset = len(target)
    target.extend(verts)
    polygons.extend(tuple(offset+i for i in face) for face in faces)


def tube(path, radii):
    verts, faces, sides = [], [], 8
    for i, point in enumerate(path):
        direction = (Vector(path[min(i+1,len(path)-1)]) - Vector(path[max(0,i-1)])).normalized()
        ref = Vector((0,1,0)) if abs(direction.z) > .9 else Vector((0,0,1))
        side = direction.cross(ref).normalized()
        up = direction.cross(side).normalized()
        for k in range(sides):
            angle = math.tau*k/sides
            verts.append(tuple(Vector(point)+radii[i]*(side*math.cos(angle)+up*math.sin(angle))))
    for i in range(len(path)-1):
        for k in range(sides):
            a, b = i*sides+k, i*sides+(k+1)%sides
            faces.append((a,b,b+sides,a+sides))
    faces.extend((tuple(range(sides-1,-1,-1)), tuple((len(path)-1)*sides+k for k in range(sides))))
    append("Arrival_Ribs", verts, faces)


# Flat floor supports the full movement strip; only its exterior silhouette varies.
verts, faces, rows = [], [], 25
for layer in range(2):
    for i in range(rows):
        t = i/(rows-1)
        width = 1.40 + .13*math.sin(t*math.tau+.6)
        for side in (-1,1):
            # End at the room's flat core boundary, not on top of its flat faces.
            verts.append((-14.5+7.15*t, -1+side*width, -.18*layer))
offset = rows*2
for i in range(rows-1):
    a = i*2
    faces.extend(((a,a+1,a+3,a+2),(a+offset,a+2+offset,a+3+offset,a+1+offset),
                  (a,a+2,a+2+offset,a+offset),(a+1,a+1+offset,a+3+offset,a+3)))
faces.extend(((0,offset,offset+1,1),(offset-2,offset-1,2*offset-1,2*offset-2)))
append("Arrival_Causeway", verts, faces)
def curve(a,b,c,d,count):
    return [(1-t)**3*a+3*(1-t)**2*t*b+3*(1-t)*t*t*c+t**3*d
            for t in (i/(count-1) for i in range(count))]


# Large folded sheets carry the body-interior silhouette, not dry tree branches.
# They sit beyond the protected arena and entrance; windows are real openings.
def tissue_point(u,v,side):
    x = -16.0 + 26.0*v
    fold = .48*math.sin(v*math.tau*2.1+side*.7)
    y = -1 + side*(5.1 + 2.0*math.sin(math.pi*u) + fold*(.25+.75*u))
    z = -2.8 + 12.0*u + .65*math.sin(v*math.pi*1.4+side)*math.sin(math.pi*u)
    return Vector((x,y,z))


for side in (-1,1):
    nu,nv = 10,18
    vertices,polygons,edges = [],[],{}
    for layer in range(2):
        for j in range(nv+1):
            for i in range(nu+1):
                p = tissue_point(i/nu,j/nv,side)
                p.y += side*.09*layer
                vertices.append(tuple(p))
    count = (nu+1)*(nv+1)
    for j in range(nv):
        for i in range(nu):
            u,v = (i+.5)/nu,(j+.5)/nv
            # Elongated chamber windows, rather than an all-over lattice.
            hole = any(((u-.52)/.19)**2+((v-center)/.095)**2 < 1
                       for center in (.30,.67))
            if hole:
                continue
            a=j*(nu+1)+i
            face=(a,a+1,a+nu+2,a+nu+1)
            polygons.append(face)
            polygons.append(tuple(k+count for k in reversed(face)))
            for a,b in zip(face,face[1:]+face[:1]):
                key=tuple(sorted((a,b)))
                edges.setdefault(key,[]).append((a,b))
    for uses in edges.values():
        if len(uses)==1:
            a,b=uses[0]
            polygons.append((a,a+count,b+count,b))
    # Project the interior boundary onto the intended ellipse. Grid deletion
    # alone makes staircase holes and falsely reads as cut cardboard.
    interior = set()
    for uses in edges.values():
        if len(uses)!=1:
            continue
        for k in uses[0]:
            i,j=k%(nu+1),k//(nu+1)
            if i not in (0,nu) and j not in (0,nv):
                interior.add(k)
    for k in interior:
        u,v=(k%(nu+1))/nu,(k//(nu+1))/nv
        center=min((.30,.67),key=lambda c:abs(v-c))
        du,dv=(u-.52)/.19,(v-center)/.095
        length=math.hypot(du,dv)
        u,v=.52+.19*du/length,center+.095*dv/length
        for layer in range(2):
            p=tissue_point(u,v,side)
            p.y+=side*.09*layer
            vertices[k+layer*count]=tuple(p)
    append("Arrival_Tissue",vertices,polygons)
    # One embedded boundary fibre per wall; the tissue supplies the main volume.
    path = [tissue_point(.18+.035*math.sin(i/16*math.pi),i/16,side)
            -Vector((0,side*.025,0)) for i in range(17)]
    tube(path,[.055+.018*math.sin(i/16*math.pi) for i in range(17)])
for side in (-1,1):
    path = [(-14.2+7.35*i/32,-1+side*(1.52+.12*math.sin(i/32*math.tau)),
             -.28-.28*math.sin(i/32*math.pi)) for i in range(33)]
    tube(path,[.14-.045*math.sin(i/32*math.pi) for i in range(33)])

objects, nonmanifold, degenerate, triangles = [], 0, 0, 0
for name, (vertices, polygons) in groups.items():
    mesh = bpy.data.meshes.new(name+"Mesh")
    mesh.from_pydata(vertices, [], polygons)
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm,faces=bm.faces)
    nonmanifold += sum(not edge.is_manifold for edge in bm.edges)
    degenerate += sum(face.calc_area()<1e-10 for face in bm.faces)
    bm.to_mesh(mesh)
    bm.free()
    uv = mesh.uv_layers.new(name="ArrivalUV")
    for poly in mesh.polygons:
        poly.use_smooth = name != "Arrival_Causeway"
        triangles += len(poly.vertices)-2
        for loop in poly.loop_indices:
            co = mesh.vertices[mesh.loops[loop].vertex_index].co
            uv.data[loop].uv = ((co.x+14.5)/7.15,(co.y+3)/4)
    material = bpy.data.materials.new("Arrival_Tissue_Coral" if name.endswith("Tissue") else
                                    "Arrival_Coral" if name.endswith("Causeway") else "Arrival_Warm_Pearl")
    material.diffuse_color = (.78,.43,.38,1) if name.endswith("Tissue") else (.72,.42,.35,1) if name.endswith("Causeway") else (.91,.71,.59,1)
    material.use_nodes = True
    bsdf = material.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = material.diffuse_color
    bsdf.inputs["Roughness"].default_value = .7
    mesh.materials.append(material)
    obj = bpy.data.objects.new(name,mesh)
    bpy.context.collection.objects.link(obj)
    objects.append(obj)
    if name == "Arrival_Tissue":
        bpy.context.view_layer.objects.active=obj
        modifier=obj.modifiers.new("Smooth_living_sheet","SUBSURF")
        modifier.levels=1
        bpy.ops.object.modifier_apply(modifier=modifier.name)
# Audit the actual smoothed runtime geometry, not the coarse control cage.
nonmanifold=degenerate=triangles=0
for obj in objects:
    obj.data.calc_loop_triangles()
    triangles+=len(obj.data.loop_triangles)
    bm=bmesh.new()
    bm.from_mesh(obj.data)
    nonmanifold+=sum(not edge.is_manifold for edge in bm.edges)
    degenerate+=sum(face.calc_area()<1e-10 for face in bm.faces)
    bm.free()
if nonmanifold or degenerate or triangles > 9000:
    raise RuntimeError(f"Arrival audit failed: {triangles=} {nonmanifold=} {degenerate=}")
bpy.ops.object.select_all(action="DESELECT")
for obj in objects: obj.select_set(True)
bpy.context.view_layer.objects.active=objects[0]
bpy.context.preferences.filepaths.file_preview_type='NONE'
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(ROOT,"art/source/arrival_path.blend"))
bpy.ops.export_scene.gltf(filepath=os.path.join(ROOT,"godot/assets/models/arrival_path.glb"),
                         export_format="GLB",use_selection=True,export_apply=True,export_yup=True,
                         export_cameras=False,export_lights=False)
report = {"schema_version":1,"id":"arrival_path","status":"authored_blockout",
          "path":"godot/assets/models/arrival_path.glb","source_path":"art/source/arrival_path.blend",
          "technical":{"triangles":triangles,"triangle_budget":9000,"materials":3,"mesh_parts":3,
                       "nonmanifold_edges":nonmanifold,"degenerate_faces":degenerate,"uv_meshes":3},
          "source":{"kind":"authored_procedural_mesh","tool":bpy.app.version_string,
                    "recipe":"art/tools/build_arrival_path.py","external_assets":False,
                    "license":"Project-authored; no third-party assets."}}
with open(os.path.join(ROOT,"art/arrival_path_manifest.json"),"w",encoding="utf-8") as file:
    json.dump(report,file,ensure_ascii=False,indent=2)
print("ARRIVAL_REPORT="+json.dumps(report))
