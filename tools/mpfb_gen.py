# Gera personagens realistas (MakeHuman/MPFB2, CC0) já ligados ao esqueleto da
# Universal Animation Library (Quaternius, CC0) usada no jogo, e exporta .glb.
# Corre dentro do Blender:  blender -b --python tools/mpfb_gen.py -- <ual.gltf> <saida_dir> <specs.json>
import bpy, json, math, os, sys, traceback
from mathutils import Vector

argv = sys.argv[sys.argv.index("--") + 1:]
UAL, OUT, SPECS = argv[0], argv[1], argv[2]
os.makedirs(OUT, exist_ok=True)

mods = {k: v for k, v in sys.modules.items() if "mpfb" in k}
def svc(name, cls):
    for k, v in mods.items():
        if k.endswith("services." + name):
            return getattr(v, cls)
    raise RuntimeError("sem " + name)

HumanService = svc("humanservice", "HumanService")
AssetService = svc("assetservice", "AssetService")


def log(*a):
    print("GEN", *a, flush=True)


def asset_list(sub, typ):
    try:
        return AssetService.get_asset_list(sub, typ)
    except Exception as e:
        log("lista falhou", sub, e)
        return {}


CLOTHES = asset_list("clothes", "mhclo")
SKINS = asset_list("skins", "mhmat")
HAIR = asset_list("hair", "mhclo")
EYES = asset_list("eyes", "mhclo")
BROWS = asset_list("eyebrows", "mhclo")
LASH = asset_list("eyelashes", "mhclo")
log("roupa", len(CLOTHES), sorted(CLOTHES.keys())[:200])
log("peles", sorted(SKINS.keys())[:60])
log("cabelo", sorted(HAIR.keys())[:60])


def find(dct, words):
    for w in words:
        for k, v in dct.items():
            if w.lower() in k.lower():
                return v.get("full_path") or v.get("path") or v.get("fragment")
    return None


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()
    for b in (bpy.data.meshes, bpy.data.armatures, bpy.data.materials, bpy.data.images):
        for x in list(b):
            if x.users == 0:
                b.remove(x)


def bake_mesh(obj):
    ## aplica shape keys e todos os modificadores (máscaras, armadura) ao objeto
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    if obj.data.shape_keys:
        bpy.ops.object.shape_key_remove(all=True, apply_mix=True)
    for m in list(obj.modifiers):
        try:
            bpy.ops.object.modifier_apply(modifier=m.name)
        except Exception as e:
            log("modificador", m.name, e)
            obj.modifiers.remove(m)


def tpose(rig):
    ## braços na horizontal (como a pose de descanso da biblioteca de animações)
    bpy.context.view_layer.objects.active = rig
    bpy.ops.object.mode_set(mode="POSE")
    for pb in rig.pose.bones:
        n = pb.name.lower()
        if ("upperarm" in n or "upper_arm" in n) and (n.endswith(".l") or n.endswith(".r")):
            b = pb.bone
            d = (b.tail_local - b.head_local).normalized()
            side = 1.0 if (b.head_local.x > 0) else -1.0
            q = d.rotation_difference(Vector((side, 0.0, 0.0)))
            ml = b.matrix_local.to_3x3()
            pb.rotation_mode = "QUATERNION"
            pb.rotation_quaternion = (ml.inverted() @ q.to_matrix() @ ml).to_quaternion()
    bpy.ops.object.mode_set(mode="OBJECT")


def make(spec):
    clear_scene()
    macro = spec.get("macro", {})
    try:
        base = HumanService.create_human(mask_helpers=False, detailed_helpers=False, extra_vertex_groups=True, feet_on_ground=True, scale=0.1, macro_detail_dict=macro or None)
    except Exception as e:
        log("create_human com macro falhou", e)
        base = HumanService.create_human()
    sk = find(SKINS, spec.get("skin", ["young caucasian male", "male", "default"]))
    if sk:
        for st in ("GAMEENGINE", "MAKESKIN"):
            try:
                HumanService.set_character_skin(sk, base, skin_type=st)
                break
            except Exception as e:
                log("pele", st, e)
    for dct, words, typ in ((EYES, ["brown", "blue", "eye"], "Eyes"), (BROWS, ["eyebrow"], "Eyebrows"), (LASH, ["eyelash"], "Eyelashes"), (HAIR, spec.get("hair", []), "Hair")):
        p = find(dct, words) if words else None
        if p:
            try:
                HumanService.add_mhclo_asset(p, base, asset_type=typ, subdiv_levels=0, material_type="MAKESKIN")
            except Exception as e:
                log("parte", typ, e)
    for words in spec.get("clothes", []):
        p = find(CLOTHES, words)
        log("roupa", words, "->", p)
        if p:
            try:
                HumanService.add_mhclo_asset(p, base, asset_type="Clothes", subdiv_levels=0, material_type="MAKESKIN")
            except Exception as e:
                log("roupa falhou", e)
    HumanService.add_builtin_rig(base, "default")
    rig = [o for o in bpy.data.objects if o.type == "ARMATURE"][0]
    tpose(rig)
    meshes = [o for o in bpy.data.objects if o.type == "MESH"]
    for o in meshes:
        bake_mesh(o)
        o.parent = None
    bpy.data.objects.remove(rig)
    # altura igual ao manequim da biblioteca (1.75 m)
    zmax = max((o.matrix_world @ Vector(c)).z for o in meshes for c in o.bound_box)
    zmin = min((o.matrix_world @ Vector(c)).z for o in meshes for c in o.bound_box)
    k = 1.75 / max(0.1, zmax - zmin)
    for o in meshes:
        o.scale = o.scale * k
        o.location = o.location * k
        o.location.z -= zmin * k
        bpy.ops.object.select_all(action="DESELECT")
        o.select_set(True)
        bpy.context.view_layer.objects.active = o
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    # esqueleto da biblioteca de animações
    bpy.ops.import_scene.gltf(filepath=UAL)
    ual_rig = [o for o in bpy.data.objects if o.type == "ARMATURE"][0]
    for o in [o for o in bpy.data.objects if o.type == "MESH" and o not in meshes]:
        bpy.data.objects.remove(o)
    ual_rig.animation_data_clear()
    for a in list(bpy.data.actions):
        bpy.data.actions.remove(a)
    # o gltf importa com Y-up convertido; o MakeHuman olha para -Y, a biblioteca para +Z do Godot (= -Y Blender)
    bpy.ops.object.select_all(action="DESELECT")
    for o in meshes:
        o.select_set(True)
    ual_rig.select_set(True)
    bpy.context.view_layer.objects.active = ual_rig
    bpy.ops.object.parent_set(type="ARMATURE_AUTO")
    tris = 0
    for o in meshes:
        o.data.calc_loop_triangles()
        tris += len(o.data.loop_triangles)
    for img in bpy.data.images:
        if img.size[0] > 1024:
            img.scale(1024, 1024)
    path = os.path.join(OUT, spec["id"] + ".glb")
    bpy.ops.object.select_all(action="DESELECT")
    for o in meshes:
        o.select_set(True)
    ual_rig.select_set(True)
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", use_selection=True, export_animations=False, export_apply=False, export_image_format="JPEG", export_jpeg_quality=85)
    log("OK", spec["id"], "triângulos", tris, "tamanho", os.path.getsize(path) // 1024, "KB", "ossos", len(ual_rig.data.bones))


specs = json.load(open(SPECS))
for sp in specs:
    try:
        make(sp)
    except Exception:
        log("FALHOU", sp["id"])
        traceback.print_exc()
