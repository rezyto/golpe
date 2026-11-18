#!/usr/bin/env python3
"""Descarrega recursos CC0 para o GOLPE (corre no GitHub Actions, que tem internet).

- Texturas PBR e HDRIs do Poly Haven (API pública, CC0), reduzidas para telemóvel.
- Adereços 3D do Poly Haven (glTF 1k).
- Sons CC0 do OpenGameArt (biblioteca de armas + Kenney).
Escreve tudo em jogo/assets/ext/ e um LICENSES.md com a origem de cada ficheiro.
"""
import io, json, os, re, subprocess, sys, urllib.request, zipfile

OUT = sys.argv[1] if len(sys.argv) > 1 else "jogo/assets/ext"
UA = {"User-Agent": "GOLPE-asset-fetch/1.0 (github.com/rezyto/golpe)"}
LIC = []


def get(url, binary=True):
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=180) as r:
        data = r.read()
    return data if binary else data.decode("utf-8", "replace")


def jget(url):
    return json.loads(get(url, False))


def save(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as f:
        f.write(data)


# ---------------------------------------------------------------- Poly Haven
PH = "https://api.polyhaven.com"
TEX_ROLES = {
    "asfalto": ["asphalt"],
    "calcada": ["cobblestone", "pavement", "paving"],
    "passeio": ["concrete_floor", "concrete_pavement", "concrete_tiles"],
    "reboco": ["plaster", "stucco"],
    "tijolo": ["brick_wall", "red_brick"],
    "marmore": ["marble"],
    "azulejo": ["tiles"],
    "metal": ["metal_plate", "rusty_metal", "corrugated"],
    "madeira": ["wood_floor", "wood_planks", "laminate"],
    "telhado": ["roof_tiles"],
    "relva": ["grass", "aerial_grass"],
    "areia": ["sand", "coast_sand"],
}
HDRI_ROLES = {
    "dia": (["urban"], ["clear", "partly cloudy", "sunny", "high contrast"]),
    "tarde": (["urban"], ["sunrise-sunset"]),
    "noite": (["urban"], ["night"]),
}
MODEL_WORDS = ["bench", "lamp", "street", "bin", "trash", "barrel", "crate", "potted", "plant", "planter",
               "chair", "table", "shelf", "sofa", "cabinet", "fire_hydrant", "mailbox", "cone", "pallet", "box"]


def pick(assets, words, cats=None, used=()):
    best = None
    for aid, a in assets.items():
        if aid in used:
            continue
        name = aid.lower()
        if not any(w in name for w in words):
            continue
        if cats:
            c = [x.lower() for x in a.get("categories", [])]
            if not any(k in c for k in cats):
                continue
        if best is None or a.get("download_count", 0) > assets[best].get("download_count", 0):
            best = aid
    return best


def credit(kind, aid, src, lic="CC0"):
    LIC.append(f"| {kind} | {aid} | {src} | {lic} |")


def fetch_textures():
    assets = jget(PH + "/assets?t=textures")
    used = set()
    for role, words in TEX_ROLES.items():
        aid = pick(assets, words, used=used)
        if not aid:
            print("sem textura para", role)
            continue
        used.add(aid)
        files = jget(f"{PH}/files/{aid}")
        maps = {"Diffuse": "albedo", "nor_gl": "normal", "Rough": "rough", "AO": "ao"}
        got = 0
        for k, short in maps.items():
            try:
                url = files[k]["1k"]["jpg"]["url"]
            except KeyError:
                continue
            save(f"{OUT}/tex/{role}_{short}.jpg", get(url))
            got += 1
        credit("textura " + role, aid, f"https://polyhaven.com/a/{aid}")
        print("textura", role, "=", aid, got, "mapas")


def fetch_hdris():
    assets = jget(PH + "/assets?t=hdris")
    used = set()
    for role, (cats, tags) in HDRI_ROLES.items():
        pref = {"dia": ["kloofendal_48d_partly_cloudy_puresky", "kloofendal_43d_clear_puresky", "kloofendal_48d_partly_cloudy"],
                "tarde": ["qwantani_dusk_2_puresky", "kloofendal_misty_morning_puresky", "venice_sunset"],
                "noite": ["kloppenheim_02_puresky", "satara_night", "moonless_golf"]}[role]
        aid = next((x for x in pref if x in assets and x not in used), None)
        if not aid:
            cand = {k: v for k, v in assets.items() if k not in used and any(c in [x.lower() for x in v.get("categories", [])] for c in cats)}
            aid = pick(cand, [""], [t for t in tags]) or pick(cand, [""])
        if not aid:
            continue
        used.add(aid)
        files = jget(f"{PH}/files/{aid}")
        url = files["hdri"]["1k"]["hdr"]["url"]
        save(f"{OUT}/hdri/{role}.hdr", get(url))
        credit("céu " + role, aid, f"https://polyhaven.com/a/{aid}")
        print("hdri", role, "=", aid)


def fetch_models(limit=24):
    assets = jget(PH + "/assets?t=models")
    n = 0
    ranked = sorted(assets.items(), key=lambda kv: -kv[1].get("download_count", 0))
    for aid, a in ranked:
        if n >= limit:
            break
        if not any(w in aid.lower() for w in MODEL_WORDS):
            continue
        try:
            files = jget(f"{PH}/files/{aid}")
            g = files["gltf"]["1k"]["gltf"]
        except Exception:
            continue
        base = f"{OUT}/models/{aid}"
        save(f"{base}/{aid}.gltf", get(g["url"]))
        for rel, inc in g.get("include", {}).items():
            save(f"{base}/{rel}", get(inc["url"]))
        credit("modelo", aid, f"https://polyhaven.com/a/{aid}")
        print("modelo", aid)
        n += 1


# ---------------------------------------------------------------- Sons (OpenGameArt, CC0)
OGA_PAGES = {
    "armas": "https://opengameart.org/content/the-free-firearm-sound-library",
    "impactos": "https://kenney.nl/assets/impact-sounds",
    "interface": "https://kenney.nl/assets/interface-sounds",
    "rpg": "https://kenney.nl/assets/rpg-audio",
    "ui": "https://kenney.nl/assets/ui-audio",
}


def fetch_sounds():
    for role, page in OGA_PAGES.items():
        try:
            html = get(page, False)
        except Exception as e:
            print("falhou página", page, e)
            continue
        links = sorted(set(re.findall(r'https://opengameart\.org/sites/default/files/[^"\']+\.(?:zip|7z|ogg|wav)', html)))
        links += sorted(set(re.findall(r'https://kenney\.nl/media/[^"\']+\.zip', html)))
        if not links:
            print("sem ficheiros em", page)
            continue
        url = links[0]
        try:
            data = get(url.replace(" ", "%20"))
        except Exception as e:
            print("falhou ficheiro", url, e)
            continue
        dest = f"{OUT}/raw_snd/{role}"
        os.makedirs(dest, exist_ok=True)
        fn = os.path.join(dest, os.path.basename(url).replace("%20", "_"))
        save(fn, data)
        if fn.endswith(".zip"):
            zipfile.ZipFile(io.BytesIO(data)).extractall(dest)
        elif fn.endswith(".7z"):
            subprocess.run(["7z", "x", "-y", "-o" + dest, fn], check=False, stdout=subprocess.DEVNULL)
        credit("sons " + role, os.path.basename(url), page)
        print("sons", role, "<-", url)


SND_ROLES = {
    "tiro_pistola": ["pistol", "handgun", "9mm", "glock", "revolver"],
    "tiro_smg": ["smg", "uzi", "mp5", "submachine"],
    "tiro_espingarda": ["rifle", "ak", "m4", "ar15", "assault"],
    "recarregar": ["reload", "magazine", "mag_in", "clip"],
    "seco": ["dry", "empty", "click"],
    "passo": ["footstep", "step"],
    "porta": ["door"],
    "vidro": ["glass", "shatter"],
    "impacto": ["impact", "hit", "punch"],
    "metal": ["metal"],
    "ui": ["click", "select", "switch", "confirm", "tick"],
    "moeda": ["coin", "cash", "money"],
}


def curate_sounds(per_role=4):
    import shutil
    raw = f"{OUT}/raw_snd"
    if not os.path.isdir(raw):
        return
    files = []
    for root, _, fs in os.walk(raw):
        for f in fs:
            if f.lower().endswith((".wav", ".ogg", ".mp3", ".flac")):
                files.append(os.path.join(root, f))
    files.sort()
    print("ficheiros de som:", len(files))
    for fp in files[::max(1, len(files) // 60)]:
        print("  ", fp[len(raw):])
    os.makedirs(f"{OUT}/snd", exist_ok=True)
    for role, words in SND_ROLES.items():
        n = 0
        for fp in files:
            name = fp.lower().replace("\\", "/")
            if role == "ui" and "/interface/" not in name:
                continue
            if not any(w in name[len(raw):] for w in words):
                continue
            dst = f"{OUT}/snd/{role}_{n}.ogg"
            r = subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", fp, "-ac", "1", "-ar", "44100", "-t", "4", "-c:a", "libvorbis", "-q:a", "3", dst])
            if r.returncode == 0:
                n += 1
            if n >= per_role:
                break
        print("som", role, n)
    shutil.rmtree(raw, ignore_errors=True)


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for step in (fetch_textures, fetch_hdris, fetch_models, fetch_sounds, curate_sounds):
        try:
            step()
        except Exception as e:
            print("ERRO em", step.__name__, e)
    with open(f"{OUT}/LICENSES.md", "w") as f:
        f.write("# Recursos externos (todos CC0)\n\n| Uso | Recurso | Origem | Licença |\n|---|---|---|---|\n")
        f.write("\n".join(LIC) + "\n")
    print("FEITO", len(LIC), "recursos")
