# Corre dentro do Blender: mostra a API do MPFB e os recursos instalados (para escrever o gerador).
import bpy, inspect, os, sys
try:
    import addon_utils
    for m in addon_utils.modules():
        if "mpfb" in m.__name__.lower():
            print("ADDON", m.__name__, m.__file__)
            addon_utils.enable(m.__name__, default_set=True)
except Exception as e:
    print("addon_utils", e)
mods = [k for k in sys.modules if "mpfb" in k.lower()]
print("MODS", len(mods), sorted(mods)[:30])
root = [k for k in mods if k.endswith("services.humanservice")]
for r in root:
    hs = sys.modules[r].HumanService
    for n, f in inspect.getmembers(hs, predicate=inspect.isfunction):
        try:
            print("HS", n, inspect.signature(f))
        except Exception:
            print("HS", n)
for r in [k for k in mods if k.endswith("services.locationservice")]:
    ls = sys.modules[r].LocationService
    for n in dir(ls):
        if n.startswith("get_"):
            try:
                print("LOC", n, getattr(ls, n)())
            except Exception as e:
                pass
for r in [k for k in mods if k.endswith("services.assetservice")]:
    a = sys.modules[r].AssetService
    for n, f in inspect.getmembers(a, predicate=inspect.isfunction):
        try:
            print("AS", n, inspect.signature(f))
        except Exception:
            print("AS", n)
