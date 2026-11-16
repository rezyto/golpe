extends Node3D
## GOLPE — jogo principal. Cidade, modelos e interface construídos por código (conteúdo original).

const D = preload("res://game/data.gd")
const SAVE_PATH := "user://save.json"
const ZW := 128.0
const ZH := 92.0
const RW := 4.0
const RX := [22.0, 90.0]
const RY := [19.0, 64.0]
const GOLD := Color("#e8b931")
const RED := Color("#e0483e")
const OK_C := Color("#3cc48a")
const DIM := Color("#9a9ca3")
const PANEL := Color("#1d2027")
const LINE := Color("#2c313b")

var S: Dictionary = {}
var mode = "login"
var Z: Dictionary = {}
var world: Node3D
var cam: Camera3D
var sun: DirectionalLight3D
var siren: OmniLight3D
var ring: MeshInstance3D
var cloth: MeshInstance3D
var ui: CanvasLayer
var hud: Control
var overlay: Control
var toasts: VBoxContainer
var lbl_money: Label
var lbl_lvl: Label
var bar_xp: ProgressBar
var bar_hp: ProgressBar
var bar_car: ProgressBar
var lbl_bag: Label
var lbl_zone: Label
var prog_box: PanelContainer
var prog_lbl: Label
var prog_bar: ProgressBar
var act_panel: Panel
var act_lbl: Label
var fire_panel: Panel
var menu_panel: Panel
var modal: Control
var modal_title: Label
var modal_body: VBoxContainer
var modal_render: Callable
var map_ui: Control
var map_area: Control
var map_info: Label
var login_ui: Control
var nick_edit: LineEdit
var travel_ui: ColorRect

var P = {"x": 0.0, "y": 0.0, "ang": 0.0, "in_car": false, "fire_cd": 0.0, "hurt": 0.0, "phase": 0.0, "px": 0.0, "py": 0.0}
var player_mesh: Node3D
var car: Dictionary = {}
var police: Array = []
var gang: Array = []
var bullets: Array = []
var parts: Array = []
var bullet_pool: Array = []
var part_pool: Array = []
var wanted = 0
var lost_t = 0.0
var heist: Dictionary = {}
var bust = 0.0
var cap = 0.0
var spawn_t = 0.0
var t = 0.0
var cam_t = Vector3.ZERO
var snap_cam = true
var joy: Dictionary = {}
var firing = false
var fire_touch = -99
var last_act = ""
var content_version = "dev"
var mat_cache: Dictionary = {}
var fac_cache: Dictionary = {}
var save_t = 0.0
var reset_arm = 0.0


# =====================================================================
#  ARRANQUE
# =====================================================================
func _ready() -> void:
	content_version = _read_txt("res://game/content_version.txt", "dev")
	if Engine.has_meta("content_version"):
		content_version = str(Engine.get_meta("content_version"))
	load_game()
	setup_3d()
	setup_ui()
	offline_income()
	show_login()
	if OS.get_cmdline_user_args().has("--autotest"):
		autotest()


func autotest() -> void:
	## Teste automático no CI: percorre os sistemas principais e falha se houver erros de script.
	var tr = get_tree()
	S = default_save()
	S["nick"] = "CI"
	S["lvl"] = 6
	S["money"] = 100000
	login_ui.visible = false
	hud.visible = true
	enter_zone("home")
	await tr.create_timer(0.5).timeout
	for id in ["home", "bar", "armeiro", "stand", "imob"]:
		open_shop(id)
		await tr.process_frame
		close_menu()
	menu_pause()
	await tr.process_frame
	close_menu()
	open_map()
	await tr.process_frame
	map_ui.visible = false
	enter_zone("cafe")
	await tr.create_timer(0.5).timeout
	P["in_car"] = false
	P["x"] = Z["door"]["x"]
	P["y"] = Z["door"]["y"] + 1.0
	await tr.process_frame
	do_action()
	heist["t"] = heist["need"] - 0.1
	await tr.create_timer(0.5).timeout
	print("autotest: saque ", S["inv"].size(), " wanted ", wanted)
	wanted = 4
	firing = true
	await tr.create_timer(4.0).timeout
	firing = false
	print("autotest: policia ", police.size())
	enter_zone("bar")
	await tr.create_timer(0.3).timeout
	open_shop("bar")
	await tr.process_frame
	close_menu()
	enter_zone("t_docas")
	P["in_car"] = false
	P["x"] = Z["flag"]["x"] - 10.0
	P["y"] = Z["flag"]["y"]
	firing = true
	await tr.create_timer(4.0).timeout
	firing = false
	print("autotest: gangue ", gang.size(), " hp ", S["hp"])
	for g in gang:
		g["hp"] = 0
	await tr.create_timer(0.3).timeout
	P["x"] = Z["flag"]["x"]
	P["y"] = Z["flag"]["y"] + 1.0
	P["in_car"] = false
	await tr.create_timer(3.5).timeout
	print("autotest: territorio ", S["terr"].has("t_docas"))
	leave_zone()
	await tr.process_frame
	print("AUTOTEST OK")
	tr.quit()


func _read_txt(path: String, def: String) -> String:
	if FileAccess.file_exists(path):
		return FileAccess.get_file_as_string(path).strip_edges()
	return def


func now_ms() -> float:
	return Time.get_unix_time_from_system() * 1000.0


# =====================================================================
#  GRAVAÇÃO
# =====================================================================
func default_save() -> Dictionary:
	return {"nick": "", "money": 500, "xp": 0, "lvl": 1, "hp": 100.0, "weapon": "p22", "weapons": ["p22"],
		"car": "pardal", "cars": ["pardal"], "car_hp": 100.0, "bag": "b10", "bags": ["b10"], "props": {}, "terr": {},
		"inv": [], "cds": {}, "pending": 0.0, "last": now_ms(), "mission": {},
		"stats": {"heists": 0, "busted": 0, "earned": 0, "hospital": 0}}


func load_game() -> void:
	S = default_save()
	if FileAccess.file_exists(SAVE_PATH):
		var j = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
		if typeof(j) == TYPE_DICTIONARY:
			for k in j.keys():
				S[k] = j[k]
	S["lvl"] = int(S["lvl"])
	S["money"] = int(S["money"])


func save_game() -> void:
	S["last"] = now_ms()
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(S))
		f.close()


func offline_income() -> void:
	var el: float = now_ms() - float(S["last"])
	var r = income_rate()
	if r > 0 and el > 60000.0:
		var add = r * minf(el, 8.0 * 3600000.0) / 60000.0
		S["pending"] = float(S["pending"]) + add
		toast("Enquanto estiveste fora: +%s em rendas por recolher" % fmt(add), GOLD)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if not S.is_empty():
			save_game()


# =====================================================================
#  HELPERS DE DADOS
# =====================================================================
func find_by_id(list: Array, id: String) -> Dictionary:
	for it in list:
		if it["id"] == id:
			return it
	return list[0]


func weapon() -> Dictionary:
	return find_by_id(D.WEAPONS, S["weapon"])


func car_def() -> Dictionary:
	return find_by_id(D.CARS, S["car"])


func bag_def() -> Dictionary:
	return find_by_id(D.BAGS, S["bag"])


func kind_of(id: String) -> String:
	if D.HEISTS.has(id):
		return "heist"
	if D.TERRS.has(id):
		return "terr"
	if id == "home":
		return "home"
	return "shop"


func def_of(id: String) -> Dictionary:
	if D.HEISTS.has(id):
		return D.HEISTS[id]
	if D.TERRS.has(id):
		return D.TERRS[id]
	return D.SHOPS[id]


func inv_kg() -> float:
	var s = 0.0
	for i in S["inv"]:
		s += float(i["kg"])
	return s


func income_rate() -> float:
	var r = 0.0
	for p in D.PROPS:
		if S["props"].has(p["id"]) and S["props"][p["id"]]["rented"]:
			r += p["rent"]
	for k in D.TERRS.keys():
		if S["terr"].has(k):
			r += D.TERRS[k]["income"]
	return r


func xp_need(l: int) -> int:
	return 100 * l


func terr_bonus() -> float:
	return 1.0 + 0.05 * S["terr"].size()


func add_xp(n: float) -> void:
	S["xp"] = float(S["xp"]) + n
	while float(S["xp"]) >= xp_need(int(S["lvl"])):
		S["xp"] = float(S["xp"]) - xp_need(int(S["lvl"]))
		S["lvl"] = int(S["lvl"]) + 1
		toast("Subiste para o nível %d!" % S["lvl"], GOLD)


func add_money(n: float) -> void:
	S["money"] = int(S["money"]) + int(n)
	if n > 0:
		S["stats"]["earned"] = int(S["stats"]["earned"]) + int(n)


func fmt(n) -> String:
	var v = int(floor(float(n)))
	var neg = v < 0
	var s = str(absi(v))
	var out = ""
	while s.length() > 3:
		out = " " + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if neg else "") + "$" + s + out


func mmss(ms: float) -> String:
	var s = int(ceil(ms / 1000.0))
	return "%d:%02d" % [s / 60, s % 60]


func ang_diff(a: float, b: float) -> float:
	var d = a - b
	while d > PI:
		d -= TAU
	while d < -PI:
		d += TAU
	return d


func dist(a: Dictionary, b: Dictionary) -> float:
	return Vector2(a["x"] - b["x"], a["y"] - b["y"]).length()


# =====================================================================
#  3D: AMBIENTE, MATERIAIS, MODELOS
# =====================================================================
func setup_3d() -> void:
	var env = Environment.new()
	var sky = Sky.new()
	var sm = ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("#5f86bd")
	sm.sky_horizon_color = Color("#e3cfae")
	sm.ground_horizon_color = Color("#e3cfae")
	sm.ground_bottom_color = Color("#3a3a33")
	sky.sky_material = sm
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.85
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color("#cdbfa6")
	env.fog_density = 0.005
	var we = WorldEnvironment.new()
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.light_color = Color("#ffe2b5")
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70.0
	sun.rotation_degrees = Vector3(-52, -35, 0)
	add_child(sun)
	cam = Camera3D.new()
	cam.fov = 45.0
	cam.far = 300.0
	add_child(cam)
	cam.current = true
	siren = OmniLight3D.new()
	siren.omni_range = 16.0
	siren.light_energy = 0.0
	add_child(siren)
	var bm = unshaded(Color("#ffe28a"))
	for i in 60:
		var b = MeshInstance3D.new()
		var m = BoxMesh.new()
		m.size = Vector3(0.7, 0.08, 0.08)
		b.mesh = m
		b.material_override = bm
		b.visible = false
		b.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(b)
		bullet_pool.append(b)
	for i in 120:
		var p = MeshInstance3D.new()
		var s = SphereMesh.new()
		s.radius = 0.14
		s.height = 0.28
		s.radial_segments = 6
		s.rings = 3
		p.mesh = s
		p.material_override = unshaded(Color.WHITE)
		p.visible = false
		p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(p)
		part_pool.append(p)
	player_mesh = make_person("#2aa39a", "#2b3240", true)
	player_mesh.visible = false
	add_child(player_mesh)


func mat(col: String, rough := 0.85, metal := 0.0) -> StandardMaterial3D:
	var k = "%s|%s|%s" % [col, rough, metal]
	if mat_cache.has(k):
		return mat_cache[k]
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(col)
	m.roughness = rough
	m.metallic = metal
	mat_cache[k] = m
	return m


func unshaded(c: Color, alpha := 1.0) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = Color(c.r, c.g, c.b, alpha)
	if alpha < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m


func facade(col: String) -> StandardMaterial3D:
	if fac_cache.has(col):
		return fac_cache[col]
	var base = Color(col)
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(base)
	img.fill_rect(Rect2i(0, 0, 64, 3), base.darkened(0.25))
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(col)
	for i in 2:
		var x = 6 + i * 32
		img.fill_rect(Rect2i(x - 1, 15, 22, 34), base.darkened(0.45))
		var lit = rng.randf() < 0.3
		img.fill_rect(Rect2i(x, 16, 20, 32), Color("#f2d38a") if lit else Color("#5b7590"))
		img.fill_rect(Rect2i(x, 16, 20, 7), Color("#fbe7b5") if lit else Color("#7f98b0"))
		img.fill_rect(Rect2i(x - 2, 48, 24, 3), base.darkened(0.3))
	var tex = ImageTexture.create_from_image(img)
	var m = StandardMaterial3D.new()
	m.albedo_texture = tex
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3(0.25, 0.3125, 0.25)
	m.roughness = 0.9
	fac_cache[col] = m
	return m


func box(size: Vector3, m: Material, pos: Vector3, parent: Node3D, shadow := true) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var bm = BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = m
	mi.position = pos
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


func cyl(r_top: float, r_bot: float, h: float, m: Material, pos: Vector3, parent: Node3D, segs := 8) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var cm = CylinderMesh.new()
	cm.top_radius = r_top
	cm.bottom_radius = r_bot
	cm.height = h
	cm.radial_segments = segs
	cm.rings = 1
	mi.mesh = cm
	mi.material_override = m
	mi.position = pos
	parent.add_child(mi)
	return mi


func make_car(col: String, pol: bool) -> Node3D:
	var g = Node3D.new()
	var body = StandardMaterial3D.new()
	body.albedo_color = Color(col)
	body.roughness = 0.35
	body.metallic = 0.35
	box(Vector3(4.2, 0.7, 1.9), body, Vector3(0, 0.72, 0), g)
	box(Vector3(4.3, 0.25, 1.95), mat("#22252a"), Vector3(0, 0.42, 0), g)
	box(Vector3(2.3, 0.62, 1.72), mat("#1b2633", 0.15, 0.6), Vector3(-0.25, 1.36, 0), g)
	box(Vector3(2.0, 0.1, 1.72), body, Vector3(-0.3, 1.71, 0), g)
	var wheels: Array = []
	for sx in [1.35, -1.35]:
		for sz in [0.9, -0.9]:
			var w = cyl(0.37, 0.37, 0.32, mat("#17181a"), Vector3(sx, 0.37, sz), g, 10)
			w.rotation.x = PI / 2
			wheels.append(w)
	var head = unshaded(Color("#fff3c4"))
	box(Vector3(0.06, 0.16, 0.42), head, Vector3(2.13, 0.82, 0.62), g, false)
	box(Vector3(0.06, 0.16, 0.42), head, Vector3(2.13, 0.82, -0.62), g, false)
	var tail = unshaded(Color("#d4352b"))
	box(Vector3(0.06, 0.16, 0.36), tail, Vector3(-2.13, 0.82, 0.65), g, false)
	box(Vector3(0.06, 0.16, 0.36), tail, Vector3(-2.13, 0.82, -0.65), g, false)
	if pol:
		box(Vector3(2.4, 0.22, 1.93), mat("#1f3a7a"), Vector3(0.2, 0.68, 0), g, false)
		var lr = box(Vector3(0.35, 0.18, 0.55), unshaded(Color("#ff2a2a")), Vector3(-0.3, 1.86, 0.32), g, false)
		var lb = box(Vector3(0.35, 0.18, 0.55), unshaded(Color("#2a6aff")), Vector3(-0.3, 1.86, -0.32), g, false)
		g.set_meta("lr", lr)
		g.set_meta("lb", lb)
	g.set_meta("body", body)
	g.set_meta("col", col)
	return g


func make_person(shirt: String, pants: String, armed: bool) -> Node3D:
	var g = Node3D.new()
	var legs: Array = []
	for s in [-0.15, 0.15]:
		var piv = Node3D.new()
		piv.position = Vector3(0, 0.9, s)
		g.add_child(piv)
		box(Vector3(0.24, 0.9, 0.24), mat(pants), Vector3(0, -0.45, 0), piv)
		box(Vector3(0.32, 0.12, 0.26), mat("#1c1c1e"), Vector3(0.05, -0.88, 0), piv)
		legs.append(piv)
	box(Vector3(0.36, 0.72, 0.62), mat(shirt), Vector3(0, 1.26, 0), g)
	var arms: Array = []
	for s in [-0.4, 0.4]:
		var piv = Node3D.new()
		piv.position = Vector3(0, 1.56, s)
		g.add_child(piv)
		box(Vector3(0.2, 0.66, 0.2), mat(shirt), Vector3(0, -0.3, 0), piv)
		box(Vector3(0.18, 0.16, 0.18), mat("#d9a77c"), Vector3(0, -0.68, 0), piv)
		arms.append(piv)
	if armed:
		box(Vector3(0.42, 0.14, 0.09), mat("#151515", 0.4, 0.6), Vector3(0.2, -0.7, 0), arms[1])
	box(Vector3(0.38, 0.38, 0.38), mat("#d9a77c"), Vector3(0, 1.84, 0), g)
	box(Vector3(0.4, 0.13, 0.4), mat("#2a1d14"), Vector3(-0.02, 2.06, 0), g)
	g.set_meta("legs", legs)
	g.set_meta("arms", arms)
	return g


func animate_person(m: Node3D, phase: float, moving: bool) -> void:
	var legs: Array = m.get_meta("legs")
	var arms: Array = m.get_meta("arms")
	var a = sin(phase) * 0.65 if moving else 0.0
	legs[0].rotation.z = a
	legs[1].rotation.z = -a
	arms[0].rotation.z = -a * 0.8
	arms[1].rotation.z = a * 0.8


# =====================================================================
#  ZONAS (cidade gerada por zona)
# =====================================================================
func make_zone(id: String) -> Dictionary:
	var r = RandomNumberGenerator.new()
	r.seed = hash(id)
	var kind = kind_of(id)
	var def = def_of(id)
	var z = {"id": id, "kind": kind, "def": def, "blocks": [], "lots": [], "trees": [], "door": {}, "flag": {}, "armed": false, "cleared": false, "spawn": {}}
	var xs = [[0.0, RX[0] - RW], [RX[0] + RW, RX[1] - RW], [RX[1] + RW, ZW]]
	var ys = [[0.0, RY[0] - RW], [RY[0] + RW, RY[1] - RW], [RY[1] + RW, ZH]]
	for i in 3:
		for j in 3:
			var lot = {"x": xs[i][0], "y": ys[j][0], "w": xs[i][1] - xs[i][0], "h": ys[j][1] - ys[j][0]}
			z["lots"].append(lot)
			var bx: float = lot["x"] + 2.0
			var by: float = lot["y"] + 2.0
			var bw: float = lot["w"] - 4.0
			var bh: float = lot["h"] - 4.0
			if i == 1 and j == 1:
				if kind == "terr":
					z["flag"] = {"x": bx + bw / 2.0, "y": by + bh / 2.0}
					for k in 8:
						var cx = bx + 3.0 + r.randf() * (bw - 9.0)
						var cy = by + 3.0 + r.randf() * (bh - 7.0)
						if Vector2(cx - z["flag"]["x"], cy - z["flag"]["y"]).length() < 8.0:
							continue
						z["blocks"].append({"x": cx, "y": cy, "w": 3.0 + r.randf() * 2.5, "h": 2.4 + r.randf() * 2.0, "col": "#7a5f3c", "crate": true, "hgt": 1.4 + r.randf() * 0.8})
				else:
					var tw = minf(bw, 43.0 if id == "museu" else 36.0)
					var th = minf(bh, 24.0)
					var tx = bx + (bw - tw) / 2.0
					var ty = by + bh - th - 2.5
					z["blocks"].append({"x": tx, "y": ty, "w": tw, "h": th, "col": def["col"], "label": def["name"], "main": true, "hgt": 11.0 if kind == "heist" else 8.0})
					z["door"] = {"x": tx + tw / 2.0, "y": ty + th + 0.7}
					for k in 7:
						z["trees"].append({"x": bx + 2.0 + r.randf() * (bw - 4.0), "y": by + 1.5 + r.randf() * maxf(1.0, ty - by - 3.0), "r": 1.1 + r.randf() * 0.8})
				continue
			var cx2 = bx
			while cx2 < bx + bw - 3.5:
				var w = minf(bx + bw - cx2, 6.5 + r.randf() * 12.0)
				if w < 3.5:
					break
				var h = bh * (0.5 + r.randf() * 0.5)
				var y = by if r.randf() < 0.5 else by + bh - h
				z["blocks"].append({"x": cx2, "y": y, "w": w - 1.1, "h": h, "col": D.BPAL[r.randi() % D.BPAL.size()], "hgt": 5.0 + r.randf() * 16.0})
				if r.randf() < 0.6:
					var ty2 = by + h + 1.4 if y == by else y - 1.4
					z["trees"].append({"x": cx2 + w / 2.0, "y": ty2, "r": 0.9 + r.randf() * 0.6})
				cx2 += w
	var keep: Array = []
	for tr in z["trees"]:
		var bad = false
		for b in z["blocks"]:
			if tr["x"] > b["x"] - 0.6 and tr["x"] < b["x"] + b["w"] + 0.6 and tr["y"] > b["y"] - 0.6 and tr["y"] < b["y"] + b["h"] + 0.6:
				bad = true
				break
		if not bad:
			keep.append(tr)
	z["trees"] = keep
	return z


func push_out(o: Dictionary, rad: float) -> bool:
	var hit = false
	for b in Z["blocks"]:
		var bx: float = b["x"]
		var by: float = b["y"]
		var bw: float = b["w"]
		var bh: float = b["h"]
		var cx = clampf(o["x"], bx, bx + bw)
		var cy = clampf(o["y"], by, by + bh)
		var dx: float = o["x"] - cx
		var dy: float = o["y"] - cy
		var d2 = dx * dx + dy * dy
		if d2 < rad * rad:
			hit = true
			if d2 > 0.000001:
				var d = sqrt(d2)
				o["x"] = cx + dx / d * rad
				o["y"] = cy + dy / d * rad
			else:
				var l: float = o["x"] - bx
				var rr: float = bx + bw - o["x"]
				var tt: float = o["y"] - by
				var bb: float = by + bh - o["y"]
				var m = minf(minf(l, rr), minf(tt, bb))
				if m == l:
					o["x"] = bx - rad
				elif m == rr:
					o["x"] = bx + bw + rad
				elif m == tt:
					o["y"] = by - rad
				else:
					o["y"] = by + bh + rad
	return hit


func in_block(x: float, y: float) -> bool:
	for b in Z["blocks"]:
		if x > b["x"] and x < b["x"] + b["w"] and y > b["y"] and y < b["y"] + b["h"]:
			return true
	return false


func build_world() -> void:
	if world:
		world.queue_free()
	world = Node3D.new()
	add_child(world)
	ring = null
	cloth = null
	# chão
	var ground = MeshInstance3D.new()
	var pm = PlaneMesh.new()
	pm.size = Vector2(ZW + 260, ZH + 260)
	ground.mesh = pm
	ground.material_override = mat("#4b6640")
	ground.position = Vector3(ZW / 2.0, -0.02, ZH / 2.0)
	world.add_child(ground)
	# estradas
	var asphalt = mat("#2f3238", 0.95)
	for y in RY:
		box(Vector3(ZW + 260, 0.04, RW * 2.0), asphalt, Vector3(ZW / 2.0, 0.0, y), world, false)
	for x in RX:
		box(Vector3(RW * 2.0, 0.045, ZH + 260), asphalt, Vector3(x, 0.002, ZH / 2.0), world, false)
	# passeios e relva
	var li = 0
	for l in Z["lots"]:
		var cx: float = l["x"] + l["w"] / 2.0
		var cz: float = l["y"] + l["h"] / 2.0
		box(Vector3(l["w"], 0.25, l["h"]), mat("#a8a398"), Vector3(cx, 0.125, cz), world, false)
		var inner = mat("#6a6152") if (Z["kind"] == "terr" and li == 4) else mat("#587a48")
		box(Vector3(l["w"] - 2.0, 0.27, l["h"] - 2.0), inner, Vector3(cx, 0.135, cz), world, false)
		li += 1
	# marcas na estrada (multimesh)
	var dash_list: Array = []
	for y in RY:
		var x = -120.0
		while x < ZW + 120.0:
			var near = false
			for rx in RX:
				if absf(x - rx) < RW + 1.5:
					near = true
			if not near:
				dash_list.append(Transform3D(Basis(), Vector3(x, 0.03, y)))
			x += 3.4
	for xr in RX:
		var y2 = -120.0
		while y2 < ZH + 120.0:
			var near2 = false
			for ry in RY:
				if absf(y2 - ry) < RW + 1.5:
					near2 = true
			if not near2:
				dash_list.append(Transform3D(Basis(Vector3.UP, PI / 2), Vector3(xr, 0.035, y2)))
			y2 += 3.4
	for xr in RX:
		for yr in RY:
			for k in range(-3, 4):
				dash_list.append(Transform3D(Basis(Vector3.UP, PI / 2).scaled(Vector3(0.7, 1, 0.3)), Vector3(xr + k * 1.0, 0.03, yr - RW - 1.1)))
				dash_list.append(Transform3D(Basis(Vector3.UP, PI / 2).scaled(Vector3(0.7, 1, 0.3)), Vector3(xr + k * 1.0, 0.03, yr + RW + 1.1)))
				dash_list.append(Transform3D(Basis().scaled(Vector3(0.7, 1, 0.3)), Vector3(xr - RW - 1.1, 0.03, yr + k * 1.0)))
				dash_list.append(Transform3D(Basis().scaled(Vector3(0.7, 1, 0.3)), Vector3(xr + RW + 1.1, 0.03, yr + k * 1.0)))
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	var dm = BoxMesh.new()
	dm.size = Vector3(1.8, 0.02, 0.22)
	mm.mesh = dm
	mm.instance_count = dash_list.size()
	for i in dash_list.size():
		mm.set_instance_transform(i, dash_list[i])
	var mmi = MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = mat("#e4d27a")
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(mmi)
	# saídas (borda verde)
	var ex = unshaded(OK_C, 0.5)
	for y in RY:
		box(Vector3(0.6, 0.06, RW * 2.0), ex, Vector3(0.3, 0.06, y), world, false)
		box(Vector3(0.6, 0.06, RW * 2.0), ex, Vector3(ZW - 0.3, 0.06, y), world, false)
	for x in RX:
		box(Vector3(RW * 2.0, 0.06, 0.6), ex, Vector3(x, 0.06, 0.3), world, false)
		box(Vector3(RW * 2.0, 0.06, 0.6), ex, Vector3(x, 0.06, ZH - 0.3), world, false)
	# candeeiros
	var lamp_m = mat("#3c3f44", 0.5, 0.5)
	var bulb = unshaded(Color("#fff1c2"))
	for y in RY:
		var x3 = 8.0
		while x3 < ZW:
			var near3 = false
			for rx in RX:
				if absf(x3 - rx) < RW + 3.0:
					near3 = true
			if not near3:
				for side in [-1.0, 1.0]:
					var pz: float = y + side * (RW + 0.9)
					cyl(0.07, 0.09, 4.2, lamp_m, Vector3(x3, 2.35, pz), world, 6)
					box(Vector3(0.12, 0.1, 1.2), lamp_m, Vector3(x3, 4.4, pz - side * 0.55), world, false)
					box(Vector3(0.3, 0.12, 0.45), bulb, Vector3(x3, 4.32, pz - side * 1.05), world, false)
			x3 += 16.0
	# prédios
	for b in Z["blocks"]:
		var w: float = b["w"]
		var d: float = b["h"]
		var hgt: float = b["hgt"]
		var cx2: float = b["x"] + w / 2.0
		var cz2: float = b["y"] + d / 2.0
		if b.get("crate", false):
			box(Vector3(w, hgt, d), mat("#7a5f3c"), Vector3(cx2, hgt / 2.0 + 0.25, cz2), world)
			box(Vector3(w * 0.9, 0.08, d + 0.02), mat("#5a4528"), Vector3(cx2, hgt * 0.55 + 0.25, cz2), world, false)
			continue
		box(Vector3(w, hgt, d), facade(b["col"]), Vector3(cx2, hgt / 2.0 + 0.25, cz2), world)
		var roofc = Color(b["col"]).darkened(0.35)
		box(Vector3(w + 0.3, 0.35, d + 0.3), mat("#" + roofc.to_html(false)), Vector3(cx2, hgt + 0.42, cz2), world)
		box(Vector3(w - 0.6, 0.12, d - 0.6), mat("#5d5f63"), Vector3(cx2, hgt + 0.62, cz2), world, false)
		if w > 7.0:
			box(Vector3(1.6, 0.9, 1.2), mat("#9aa0a6", 0.5, 0.4), Vector3(cx2 - w * 0.25, hgt + 1.1, cz2 + d * 0.2), world)
		if b.get("main", false):
			var front: float = b["y"] + d
			var shop_c = Color(b["col"])
			box(Vector3(w * 0.84, 3.0, 0.15), mat("#1b2633", 0.12, 0.6), Vector3(cx2, 1.75, front + 0.02), world, false)
			box(Vector3(2.2, 2.6, 0.2), mat("#1a1410"), Vector3(cx2, 1.55, front + 0.05), world, false)
			box(Vector3(w * 0.9, 0.25, 1.8), mat("#" + shop_c.lightened(0.15).to_html(false)), Vector3(cx2, 3.55, front + 0.9), world)
			var sign_bg = box(Vector3(minf(w * 0.7, 16.0), 1.6, 0.2), mat("#" + shop_c.darkened(0.45).to_html(false)), Vector3(cx2, 4.9, front + 0.1), world, false)
			sign_bg.name = "sign"
			var lab = Label3D.new()
			lab.text = b["label"]
			lab.font_size = 96
			lab.pixel_size = 0.012
			lab.outline_size = 10
			lab.modulate = Color("#fff3d6")
			lab.outline_modulate = Color(0, 0, 0, 0.6)
			lab.position = Vector3(cx2, 4.9, front + 0.25)
			lab.width = 1200
			world.add_child(lab)
	# árvores
	var trunk = mat("#5a4030")
	var leaf = mat("#3f7a45")
	var leaf2 = mat("#4f8f50")
	for tr in Z["trees"]:
		var rad: float = tr["r"]
		cyl(0.14, 0.2, 1.6, trunk, Vector3(tr["x"], 1.05, tr["y"]), world, 6)
		var f = MeshInstance3D.new()
		var sm = SphereMesh.new()
		sm.radius = rad
		sm.height = rad * 1.7
		sm.radial_segments = 7
		sm.rings = 4
		f.mesh = sm
		f.material_override = leaf if int(tr["x"] * 10) % 2 == 0 else leaf2
		f.position = Vector3(tr["x"], 1.85 + rad * 0.7, tr["y"])
		world.add_child(f)
	# porta (anel a pulsar) e bandeira
	if not Z["door"].is_empty():
		ring = MeshInstance3D.new()
		var tm = TorusMesh.new()
		tm.inner_radius = 1.2
		tm.outer_radius = 1.55
		tm.rings = 24
		tm.ring_segments = 6
		ring.mesh = tm
		ring.material_override = unshaded(RED if Z["kind"] == "heist" else GOLD, 0.75)
		ring.position = Vector3(Z["door"]["x"], 0.35, Z["door"]["y"])
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		world.add_child(ring)
	if not Z["flag"].is_empty():
		var fx: float = Z["flag"]["x"]
		var fz: float = Z["flag"]["y"]
		cyl(0.08, 0.1, 6.0, mat("#d8d8d8", 0.4, 0.6), Vector3(fx, 3.25, fz), world, 6)
		cloth = box(Vector3(2.4, 1.5, 0.06), mat("#3cc48a") if S["terr"].has(Z["id"]) else mat(D.TERRS[Z["id"]]["col"]), Vector3(fx + 1.25, 5.4, fz), world)
		ring = MeshInstance3D.new()
		var tm2 = TorusMesh.new()
		tm2.inner_radius = 3.8
		tm2.outer_radius = 4.2
		tm2.rings = 32
		tm2.ring_segments = 6
		ring.mesh = tm2
		ring.material_override = unshaded(Color("#9a6ad0"), 0.6)
		ring.position = Vector3(fx, 0.35, fz)
		world.add_child(ring)


func free_entities() -> void:
	for p in police:
		p["mesh"].queue_free()
	for g in gang:
		g["mesh"].queue_free()
	if car.has("mesh") and is_instance_valid(car["mesh"]):
		car["mesh"].queue_free()
	police = []
	gang = []
	bullets = []
	parts = []


func enter_zone(id: String) -> void:
	free_entities()
	Z = make_zone(id)
	heist = {}
	bust = 0.0
	cap = 0.0
	wanted = 0
	lost_t = 0.0
	var cd = car_def()
	if float(S["car_hp"]) <= 0:
		S["car_hp"] = round(cd["hp"] * 0.35)
		add_money(-mini(int(S["money"]), 200))
		toast("Carro rebocado e remendado (-$200)", RED)
	if Z["kind"] == "home":
		car = {"x": Z["door"]["x"] + 9.0, "y": RY[1] + 1.8, "ang": 0.0, "spd": 0.0}
		P["x"] = Z["door"]["x"]
		P["y"] = Z["door"]["y"] + 2.5
		P["in_car"] = false
		S["car_hp"] = cd["hp"]
	else:
		car = {"x": 4.5, "y": RY[1] + 1.8, "ang": 0.0, "spd": 0.0}
		P["in_car"] = true
		P["x"] = car["x"]
		P["y"] = car["y"]
	car["mesh"] = make_car(cd["col"], false)
	add_child(car["mesh"])
	Z["spawn"] = {"x": P["x"], "y": P["y"]}
	if Z["kind"] == "terr" and not S["terr"].has(id):
		var tdef: Dictionary = D.TERRS[id]
		var n: int = tdef["gang"]
		for k in n:
			var a = float(k) / n * TAU
			var rr = randf_range(6.5, 16.0)
			var gx: float = Z["flag"]["x"] + cos(a) * rr
			var gy: float = Z["flag"]["y"] + sin(a) * rr
			var gm = make_person("#6a3a8a", "#2a2a33", true)
			add_child(gm)
			gang.append({"x": gx, "y": gy, "hp": 40.0, "cd": randf_range(0.5, 1.5), "ang": 0.0, "mesh": gm, "phase": 0.0})
	build_world()
	var zn: String = Z["def"]["name"]
	if Z["kind"] == "terr":
		zn += " · teu território" if S["terr"].has(id) else " · território inimigo"
	lbl_zone.text = zn
	snap_cam = true
	mode = "play"
	save_game()


# =====================================================================
#  INPUT
# =====================================================================
func hud_hit(pos: Vector2) -> String:
	if mode != "play":
		return ""
	if fire_panel.get_global_rect().grow(10).has_point(pos):
		return "fire"
	if act_panel.get_global_rect().grow(10).has_point(pos):
		return "act"
	if menu_panel.get_global_rect().grow(6).has_point(pos):
		return "menu"
	return ""


func _input(e: InputEvent) -> void:
	var touch = DisplayServer.is_touchscreen_available()
	if e is InputEventScreenTouch:
		var st = e as InputEventScreenTouch
		_pointer(st.index, st.position, st.pressed)
	elif e is InputEventScreenDrag:
		var sd = e as InputEventScreenDrag
		if not joy.is_empty() and joy["id"] == sd.index:
			joy["pos"] = sd.position
	elif e is InputEventMouseButton:
		var mb = e as InputEventMouseButton
		if not touch and mb.button_index == MOUSE_BUTTON_LEFT:
			_pointer(-1, mb.position, mb.pressed)
	elif e is InputEventMouseMotion:
		var mm = e as InputEventMouseMotion
		if not touch and not joy.is_empty() and joy["id"] == -1:
			joy["pos"] = mm.position
	elif e is InputEventKey:
		var k = e as InputEventKey
		if k.pressed and not k.echo:
			if mode == "play":
				if k.keycode == KEY_E:
					do_action()
				elif k.keycode == KEY_SPACE:
					firing = true
				elif k.keycode == KEY_ESCAPE:
					menu_pause()
			elif mode == "menu" and k.keycode == KEY_ESCAPE:
				close_menu()
		elif not k.pressed and k.keycode == KEY_SPACE:
			firing = false


func _pointer(id: int, pos: Vector2, pressed: bool) -> void:
	if pressed:
		var h = hud_hit(pos)
		if h == "fire":
			firing = true
			fire_touch = id
		elif h == "act":
			do_action()
		elif h == "menu":
			menu_pause()
		elif mode == "play" and joy.is_empty() and pos.x < get_viewport().get_visible_rect().size.x * 0.55:
			joy = {"id": id, "base": pos, "pos": pos}
	else:
		if id == fire_touch:
			firing = false
			fire_touch = -99
		if not joy.is_empty() and joy["id"] == id:
			joy = {}


func input_vec() -> Vector2:
	var v = Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		v.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		v.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		v.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		v.y += 1
	if not joy.is_empty():
		var d: Vector2 = joy["pos"] - joy["base"]
		var R = 80.0
		if d.length() > 8.0:
			v = d / R if d.length() < R else d.normalized()
	if v.length() > 1.0:
		v = v.normalized()
	return v


# =====================================================================
#  CARROS
# =====================================================================
func drive(c: Dictionary, iv: Vector2, dt: float, maxspd: float) -> void:
	var m = iv.length()
	if m > 0.15:
		var ta = atan2(iv.y, iv.x)
		var da = ang_diff(ta, c["ang"])
		var turn = 3.4 * dt * minf(1.0, absf(c["spd"]) / 6.5 + 0.45)
		c["ang"] = c["ang"] + clampf(da, -turn, turn)
		var tgt = maxspd * m * (0.45 if absf(da) > 1.6 else 1.0)
		c["spd"] = c["spd"] + (tgt - c["spd"]) * minf(1.0, dt * 1.7)
	else:
		c["spd"] = c["spd"] * pow(0.12, dt)
	c["x"] = c["x"] + cos(c["ang"]) * c["spd"] * dt
	c["y"] = c["y"] + sin(c["ang"]) * c["spd"] * dt
	if push_out(c, 1.85):
		c["spd"] = c["spd"] * 0.55
	c["x"] = clampf(c["x"], 0.3, ZW - 0.3)
	c["y"] = clampf(c["y"], 0.3, ZH - 0.3)


# =====================================================================
#  AÇÕES
# =====================================================================
func ctx_action() -> Dictionary:
	if mode != "play":
		return {}
	if not P["in_car"] and not Z["door"].is_empty() and dist(P, Z["door"]) < 4.3:
		if Z["kind"] == "heist":
			if not heist.is_empty():
				return {"l": "A ASSALTAR…", "off": true}
			var left: float = float(S["cds"].get(Z["id"], 0)) - now_ms()
			if left > 0:
				return {"l": "FECHADO\n" + mmss(left), "off": true}
			return {"l": "ASSALTAR", "f": start_heist}
		return {"l": "ENTRAR", "f": func(): open_shop(Z["id"])}
	if not P["in_car"] and float(S["car_hp"]) > 0 and dist(P, car) < 5.5:
		return {"l": "CONDUZIR", "f": func(): P["in_car"] = true}
	if P["in_car"]:
		return {"l": "SAIR", "f": exit_car}
	return {}


func do_action() -> void:
	var a = ctx_action()
	if a.has("f"):
		a["f"].call()


func exit_car() -> void:
	P["in_car"] = false
	car["spd"] = 0.0
	P["x"] = car["x"] + cos(car["ang"] + PI / 2) * 2.2
	P["y"] = car["y"] + sin(car["ang"] + PI / 2) * 2.2
	push_out(P, 0.45)


func start_heist() -> void:
	var h: Dictionary = D.HEISTS[Z["id"]]
	if int(S["lvl"]) < h["lvl"]:
		toast("Precisas de nível %d" % h["lvl"], RED)
		return
	heist = {"t": 0.0, "need": h["time"]}
	if randf() < h["alarm"]:
		wanted = maxi(wanted, maxi(1, int(h["stars"]) - 1))
		toast("Alarme disparado!", RED)
	else:
		toast("Ninguém deu por nada… despacha-te")


func finish_heist() -> void:
	var h: Dictionary = D.HEISTS[Z["id"]]
	heist = {}
	var got: Array = []
	var lost = 0
	var capkg: float = bag_def()["cap"]
	var items: Array = []
	if h["cash"][1] > 0:
		var v = randi_range(h["cash"][0], h["cash"][1])
		items.append({"n": "Dinheiro sujo", "kg": maxf(0.1, snappedf(v / 1000.0, 0.01)), "v": v, "dirty": true})
	for L in h["loot"]:
		if randf() < L["ch"]:
			var q = randi_range(L["q"][0], L["q"][1])
			for k in q:
				items.append({"n": L["n"], "kg": L["kg"], "v": L["v"]})
	if items.is_empty():
		var L0: Dictionary = h["loot"][0]
		items.append({"n": L0["n"], "kg": L0["kg"], "v": L0["v"]})
	for it in items:
		if inv_kg() + float(it["kg"]) <= capkg:
			S["inv"].append(it)
			got.append(it)
		else:
			lost += 1
	var val = 0
	for it in got:
		val += int(it["v"])
	toast("Saque: %d itens (%s)" % [got.size(), fmt(val)], GOLD)
	if lost > 0:
		toast("Saco cheio — ficaram %d itens para trás" % lost, RED)
	wanted = mini(5, wanted + int(h["stars"]))
	lost_t = 0.0
	S["cds"][Z["id"]] = now_ms() + float(h["cd"]) * 1000.0
	S["stats"]["heists"] = int(S["stats"]["heists"]) + 1
	add_xp(h["xp"])
	var m: Dictionary = S["mission"]
	if not m.is_empty() and m["target"] == Z["id"] and not m["done"]:
		m["done"] = true
		toast("Contrato cumprido! Vai ao Bar O Farol", GOLD)
	save_game()


func busted() -> void:
	var fine = int(S["money"] * 0.1)
	S["money"] = int(S["money"]) - fine
	S["inv"] = []
	S["stats"]["busted"] = int(S["stats"]["busted"]) + 1
	toast("Foste detido! Perdeste o saque e %s de multa" % fmt(fine), RED)
	go_home()


func hospital() -> void:
	var fine = int(S["money"] * 0.15)
	S["money"] = int(S["money"]) - fine
	S["inv"] = []
	S["hp"] = 100.0
	S["stats"]["hospital"] = int(S["stats"]["hospital"]) + 1
	toast("Acordaste no hospital. Conta: %s. Saque perdido." % fmt(fine), RED)
	go_home()


func go_home() -> void:
	travel(func(): enter_zone("home"))


func leave_zone() -> void:
	if wanted > 0:
		toast("Escapaste da zona com a polícia atrás!", OK_C)
		add_xp(10 * wanted)
	wanted = 0
	for p in police:
		p["mesh"].queue_free()
	police = []
	heist = {}
	save_game()
	open_map()


# =====================================================================
#  COMBATE
# =====================================================================
func fire_bullet(x: float, y: float, a: float, from: String, dmg: float, life: float) -> void:
	bullets.append({"x": x, "y": y, "vx": cos(a) * 52.0, "vy": sin(a) * 52.0, "from": from, "dmg": dmg, "life": life})


func shoot() -> void:
	var w = weapon()
	var tgt: Dictionary = {}
	var best: float = w["range"]
	for tt in police + gang:
		var d = dist(P, tt)
		if d < best:
			best = d
			tgt = tt
	var a: float = P["ang"]
	if not tgt.is_empty():
		a = atan2(tgt["y"] - P["y"], tgt["x"] - P["x"])
	if not P["in_car"]:
		P["ang"] = a
	for i in int(w["pel"]):
		fire_bullet(P["x"] + cos(a), P["y"] + sin(a), a + randf_range(-w["spr"], w["spr"]), "p", w["dmg"], w["range"] / 52.0)
	P["fire_cd"] = w["rate"]
	for i in 3:
		add_part(P["x"] + cos(a) * 1.1, P["y"] + sin(a) * 1.1, 1.3, cos(a) * randf_range(4, 10), sin(a) * randf_range(4, 10), 0.12, Color("#ffd56a"))
	if Z["kind"] == "heist" and wanted == 0:
		wanted = 1
		lost_t = 0.0
		toast("Tiros ouvidos — polícia a caminho", RED)


func add_part(x: float, y: float, h: float, vx: float, vy: float, life: float, col: Color, vh := 0.0) -> void:
	if parts.size() < part_pool.size():
		parts.append({"x": x, "y": y, "h": h, "vx": vx, "vy": vy, "vh": vh, "life": life, "max": life, "col": col})


func boom(x: float, y: float, col := Color("#ff8a3a"), n := 18) -> void:
	for i in n:
		var a = randf() * TAU
		var s = randf_range(3, 14)
		add_part(x, y, 0.8, cos(a) * s, sin(a) * s, randf_range(0.3, 0.7), col, randf_range(2, 8))


func hurt_player(d: float) -> void:
	if P["in_car"]:
		S["car_hp"] = float(S["car_hp"]) - d * 0.7
		if float(S["car_hp"]) <= 0:
			S["car_hp"] = 0.0
			boom(car["x"], car["y"])
			exit_car()
			toast("Carro destruído!", RED)
	else:
		S["hp"] = float(S["hp"]) - d
		P["hurt"] = 0.15
		if float(S["hp"]) <= 0:
			S["hp"] = 0.0
			hospital()


func spawn_police() -> void:
	var pts: Array = []
	for y in RY:
		pts.append({"x": 1.5, "y": y + 1.5, "a": 0.0})
		pts.append({"x": ZW - 1.5, "y": y - 1.5, "a": PI})
	for x in RX:
		pts.append({"x": x - 1.5, "y": 1.5, "a": PI / 2})
		pts.append({"x": x + 1.5, "y": ZH - 1.5, "a": -PI / 2})
	var ok: Array = []
	for p in pts:
		if dist(p, P) > 34.0:
			ok.append(p)
	if ok.is_empty():
		ok = pts
	var s: Dictionary = ok[randi() % ok.size()]
	var m = make_car("#e8ecf2", true)
	add_child(m)
	police.append({"x": s["x"], "y": s["y"], "ang": s["a"], "spd": 0.0, "hp": 60.0, "cd": randf_range(0.6, 1.4), "stuck": 0.0, "rev": 0.0, "rd": 1.0, "hit_cd": 0.0, "mesh": m})


# =====================================================================
#  CICLO PRINCIPAL
# =====================================================================
func _process(delta: float) -> void:
	var dt = minf(delta, 0.05)
	t += dt
	var rate = income_rate()
	if rate > 0 and not S.is_empty():
		S["pending"] = float(S["pending"]) + rate * dt / 60.0
	if mode == "play":
		update_game(dt)
	if mode != "login" and not Z.is_empty():
		render(dt)
		update_hud()
	overlay.queue_redraw()
	save_t += dt
	if save_t > 5.0 and mode != "login":
		save_t = 0.0
		save_game()


func update_game(dt: float) -> void:
	var iv = input_vec()
	var cd = car_def()
	P["px"] = P["x"]
	P["py"] = P["y"]
	if P["in_car"]:
		drive(car, iv, dt, cd["spd"])
		P["x"] = car["x"]
		P["y"] = car["y"]
		P["ang"] = car["ang"]
	else:
		P["x"] = P["x"] + iv.x * 6.5 * dt
		P["y"] = P["y"] + iv.y * 6.5 * dt
		if iv.length() > 0.1 and not firing:
			P["ang"] = atan2(iv.y, iv.x)
		push_out(P, 0.45)
		P["x"] = clampf(P["x"], 0.1, ZW - 0.1)
		P["y"] = clampf(P["y"], 0.1, ZH - 0.1)
	if P["hurt"] > 0:
		P["hurt"] = P["hurt"] - dt
	# saída da zona
	if not Z["armed"] and dist(P, Z["spawn"]) > 11.0:
		Z["armed"] = true
	if Z["armed"] and (P["x"] < 1.0 or P["y"] < 1.0 or P["x"] > ZW - 1.0 or P["y"] > ZH - 1.0):
		leave_zone()
		return
	# disparar
	P["fire_cd"] = P["fire_cd"] - dt
	if firing and P["fire_cd"] <= 0:
		shoot()
	# assalto
	if not heist.is_empty():
		if P["in_car"] or dist(P, Z["door"]) > 5.5:
			heist = {}
			toast("Assalto interrompido", RED)
		else:
			heist["t"] = heist["t"] + dt
			if heist["t"] >= heist["need"]:
				finish_heist()
	# polícia
	var target: int = [0, 1, 2, 3, 4, 6][wanted]
	if police.size() < target:
		spawn_t -= dt
		if spawn_t <= 0:
			spawn_police()
			spawn_t = 2.2
	if wanted == 0 and police.size() > 0:
		for p in police:
			p["mesh"].queue_free()
		police = []
	var seen = false
	var near = false
	for p in police:
		var dx: float = P["x"] - p["x"]
		var dy: float = P["y"] - p["y"]
		var d = maxf(0.001, Vector2(dx, dy).length())
		if d < 33.0:
			seen = true
		if p["rev"] > 0:
			p["rev"] = p["rev"] - dt
			p["spd"] = -8.5
			p["ang"] = p["ang"] + 1.9 * dt * p["rd"]
			p["x"] = p["x"] + cos(p["ang"]) * p["spd"] * dt
			p["y"] = p["y"] + sin(p["ang"]) * p["spd"] * dt
			push_out(p, 1.85)
		else:
			var slow = 0.3 if (not P["in_car"] and d < 9.0) else 1.0
			drive(p, Vector2(dx / d, dy / d), dt, (16.0 + wanted * 2.0) * slow)
			if absf(p["spd"]) < 1.8 and d > 4.5:
				p["stuck"] = p["stuck"] + dt
				if p["stuck"] > 0.8:
					p["rev"] = 0.7
					p["stuck"] = 0.0
					p["rd"] = -1.0 if randf() < 0.5 else 1.0
			else:
				p["stuck"] = 0.0
		if wanted >= 2:
			p["cd"] = p["cd"] - dt
			if p["cd"] <= 0 and d < 19.0:
				fire_bullet(p["x"], p["y"], atan2(dy, dx) + randf_range(-0.12, 0.12), "e", 5, 0.4)
				p["cd"] = maxf(0.45, 1.2 - wanted * 0.12)
		p["hit_cd"] = p["hit_cd"] - dt
		if d < 3.7:
			var ov = 3.7 - d
			p["x"] = p["x"] - dx / d * ov * 0.6
			p["y"] = p["y"] - dy / d * ov * 0.6
			if P["in_car"]:
				car["x"] = car["x"] + dx / d * ov * 0.4
				car["y"] = car["y"] + dy / d * ov * 0.4
				if p["hit_cd"] <= 0:
					var rel: float = absf(car["spd"]) + absf(p["spd"])
					hurt_player(4.0 + rel * 0.4)
					p["hp"] = p["hp"] - (6.0 + absf(car["spd"]) * 1.1)
					p["hit_cd"] = 0.5
					car["spd"] = car["spd"] * 0.5
					boom((p["x"] + car["x"]) / 2.0, (p["y"] + car["y"]) / 2.0, Color("#ffd56a"), 6)
			elif absf(p["spd"]) < 11.0:
				near = true
	if mode != "play":
		return
	if near:
		bust += dt
		if bust >= 2.0:
			bust = 0.0
			busted()
			return
	else:
		bust = maxf(0.0, bust - dt * 1.5)
	var alive: Array = []
	for p in police:
		if p["hp"] <= 0:
			boom(p["x"], p["y"])
			p["mesh"].queue_free()
			add_xp(15)
			if wanted < 5:
				wanted += 1
				toast("Abateste uma patrulha — mais calor!", RED)
		else:
			alive.append(p)
	police = alive
	if wanted > 0:
		if not seen:
			lost_t += dt
			if lost_t > 8.0:
				wanted -= 1
				lost_t = 0.0
				if wanted == 0:
					toast("Despistaste a polícia", OK_C)
		else:
			lost_t = 0.0
	# gangue
	for g in gang:
		var dx2: float = P["x"] - g["x"]
		var dy2: float = P["y"] - g["y"]
		var d2 = maxf(0.001, Vector2(dx2, dy2).length())
		g["ang"] = atan2(dy2, dx2)
		var moving = false
		if d2 < 27.0:
			if d2 > 12.0:
				g["x"] = g["x"] + dx2 / d2 * 4.0 * dt
				g["y"] = g["y"] + dy2 / d2 * 4.0 * dt
				moving = true
			g["cd"] = g["cd"] - dt
			if g["cd"] <= 0:
				fire_bullet(g["x"], g["y"], g["ang"] + randf_range(-0.15, 0.15), "e", 6, 0.6)
				g["cd"] = randf_range(0.9, 1.5)
		push_out(g, 0.45)
		g["moving"] = moving
	var galive: Array = []
	for g in gang:
		if g["hp"] <= 0:
			boom(g["x"], g["y"], Color("#b04040"), 10)
			g["mesh"].queue_free()
			add_xp(10)
		else:
			galive.append(g)
	gang = galive
	if Z["kind"] == "terr" and not S["terr"].has(Z["id"]):
		if gang.is_empty() and not Z["cleared"]:
			Z["cleared"] = true
			toast("Gangue eliminado! Fica junto à bandeira para tomar o território", GOLD)
		if gang.is_empty() and not P["in_car"] and dist(P, Z["flag"]) < 4.3:
			cap += dt
			if cap >= 3.0:
				S["terr"][Z["id"]] = true
				cap = 0.0
				add_xp(120)
				toast("%s é teu! +%s/min" % [D.TERRS[Z["id"]]["name"], fmt(D.TERRS[Z["id"]]["income"])], GOLD)
				lbl_zone.text = Z["def"]["name"] + " · teu território"
				if cloth:
					cloth.material_override = mat("#3cc48a")
				save_game()
		else:
			cap = maxf(0.0, cap - dt)
	# balas
	for b in bullets:
		b["x"] = b["x"] + b["vx"] * dt
		b["y"] = b["y"] + b["vy"] * dt
		b["life"] = b["life"] - dt
		if in_block(b["x"], b["y"]):
			b["life"] = 0.0
			add_part(b["x"], b["y"], 1.2, 0, 0, 0.15, Color("#cccccc"))
			continue
		if b["from"] == "p":
			for tt in police + gang:
				var rr = 2.0 if tt.has("spd") else 0.7
				if Vector2(tt["x"] - b["x"], tt["y"] - b["y"]).length() < rr:
					tt["hp"] = tt["hp"] - b["dmg"]
					b["life"] = 0.0
					add_part(b["x"], b["y"], 1.2, 0, 0, 0.15, Color("#ffeb99"))
					break
		elif Vector2(P["x"] - b["x"], P["y"] - b["y"]).length() < (1.5 if P["in_car"] else 0.7):
			hurt_player(b["dmg"])
			b["life"] = 0.0
			if mode != "play":
				return
	var bl: Array = []
	for b in bullets:
		if b["life"] > 0:
			bl.append(b)
	bullets = bl
	if wanted == 0 and float(S["hp"]) < 100:
		S["hp"] = minf(100.0, float(S["hp"]) + 3.0 * dt)
	if float(S["car_hp"]) <= 0 and randf() < 0.3:
		add_part(car["x"] + randf_range(-0.6, 0.6), car["y"] + randf_range(-0.6, 0.6), 1.2, 0, 0, 0.9, Color("#3c3c3c"), 2.5)
	# botão de ação
	var a = ctx_action()
	var lab: String = a.get("l", "—")
	if lab != last_act:
		last_act = lab
		act_lbl.text = lab
		var on = a.has("f")
		act_panel.add_theme_stylebox_override("panel", circle_style(Color(0.11, 0.12, 0.15, 0.85), GOLD if on else LINE))
		act_lbl.add_theme_color_override("font_color", GOLD if on else DIM)


func update_parts(dt: float) -> void:
	var keep: Array = []
	for p in parts:
		p["x"] = p["x"] + p["vx"] * dt
		p["y"] = p["y"] + p["vy"] * dt
		p["h"] = maxf(0.05, p["h"] + p["vh"] * dt)
		p["vh"] = p["vh"] - 12.0 * dt
		p["vx"] = p["vx"] * 0.92
		p["vy"] = p["vy"] * 0.92
		p["life"] = p["life"] - dt
		if p["life"] > 0:
			keep.append(p)
	parts = keep


# =====================================================================
#  RENDER 3D
# =====================================================================
func render(dt: float) -> void:
	update_parts(dt)
	# carro do jogador
	var cd = car_def()
	if car.has("mesh"):
		var cm: Node3D = car["mesh"]
		if cm.get_meta("col") != cd["col"]:
			cm.queue_free()
			cm = make_car(cd["col"], false)
			add_child(cm)
			car["mesh"] = cm
		cm.position = Vector3(car["x"], 0, car["y"])
		cm.rotation.y = -car["ang"]
		var body: StandardMaterial3D = cm.get_meta("body")
		body.albedo_color = Color(cd["col"]) if float(S["car_hp"]) > 0 else Color("#2a2a2a")
	# jogador a pé
	player_mesh.visible = not P["in_car"]
	if not P["in_car"]:
		var mv = Vector2(P["x"] - P["px"], P["y"] - P["py"]).length() / maxf(dt, 0.001)
		P["phase"] = P["phase"] + mv * dt * 1.7
		player_mesh.position = Vector3(P["x"], 0.25, P["y"])
		player_mesh.rotation.y = -P["ang"]
		animate_person(player_mesh, P["phase"], mv > 0.5)
		player_mesh.scale = Vector3.ONE * (1.08 if P["hurt"] > 0 else 1.0)
	# polícia
	var flash = int(t * 8.0) % 2 == 0
	var near_p: Dictionary = {}
	var nd = 9999.0
	for p in police:
		var m: Node3D = p["mesh"]
		m.position = Vector3(p["x"], 0, p["y"])
		m.rotation.y = -p["ang"]
		m.get_meta("lr").visible = flash
		m.get_meta("lb").visible = not flash
		var d = dist(P, p)
		if d < nd:
			nd = d
			near_p = p
	if not near_p.is_empty():
		siren.position = Vector3(near_p["x"], 3.0, near_p["y"])
		siren.light_color = Color("#ff3030") if flash else Color("#3060ff")
		siren.light_energy = 3.0
	else:
		siren.light_energy = 0.0
	# gangue
	for g in gang:
		var gm: Node3D = g["mesh"]
		g["phase"] = g["phase"] + (dt * 7.0 if g.get("moving", false) else 0.0)
		gm.position = Vector3(g["x"], 0.25, g["y"])
		gm.rotation.y = -g["ang"]
		animate_person(gm, g["phase"], g.get("moving", false))
	# balas e partículas
	for i in bullet_pool.size():
		var bm: MeshInstance3D = bullet_pool[i]
		if i < bullets.size():
			var b: Dictionary = bullets[i]
			bm.visible = true
			bm.position = Vector3(b["x"], 1.3, b["y"])
			bm.rotation.y = -atan2(b["vy"], b["vx"])
		else:
			bm.visible = false
	for i in part_pool.size():
		var pm: MeshInstance3D = part_pool[i]
		if i < parts.size():
			var p: Dictionary = parts[i]
			pm.visible = true
			pm.position = Vector3(p["x"], p["h"], p["y"])
			var k: float = clampf(p["life"] / p["max"], 0.2, 1.0)
			pm.scale = Vector3.ONE * (0.5 + k)
			(pm.material_override as StandardMaterial3D).albedo_color = p["col"]
		else:
			pm.visible = false
	# marcadores
	if ring:
		var s = 1.0 + sin(t * 4.0) * 0.08
		ring.scale = Vector3(s, 1, s)
	if cloth:
		cloth.rotation.y = sin(t * 3.0) * 0.12
	# câmara
	var portrait = get_viewport().get_visible_rect().size.y > get_viewport().get_visible_rect().size.x
	var k2 = 1.45 if portrait else 1.0
	var tgt = Vector3(P["x"], 0, P["y"])
	if P["in_car"]:
		tgt += Vector3(cos(car["ang"]), 0, sin(car["ang"])) * car["spd"] * 0.25
	if snap_cam:
		cam_t = tgt
		snap_cam = false
	else:
		cam_t = cam_t.lerp(tgt, 1.0 - exp(-dt * 5.0))
	cam.position = cam_t + Vector3(0, 17.0 * k2, 12.5 * k2)
	cam.look_at(cam_t + Vector3(0, 1.0, 0), Vector3.UP)


# =====================================================================
#  INTERFACE
# =====================================================================
func lbl(text: String, size := 20, col := Color("#ecebe6")) -> Label:
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func flat(bg: Color, radius := 12, border := LINE, bw := 1) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.border_color = border
	s.set_border_width_all(bw)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s


func circle_style(bg: Color, border: Color) -> StyleBoxFlat:
	var s = flat(bg, 200, border, 3)
	return s


func pbar(col: Color, w := 150.0, h := 7.0) -> ProgressBar:
	var b = ProgressBar.new()
	b.custom_minimum_size = Vector2(w, h)
	b.show_percentage = false
	b.max_value = 100
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var f = StyleBoxFlat.new()
	f.bg_color = col
	f.set_corner_radius_all(4)
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color("#2b2f37")
	bg.set_corner_radius_all(4)
	b.add_theme_stylebox_override("fill", f)
	b.add_theme_stylebox_override("background", bg)
	return b


func place(c: Control, ax: float, ay: float, x: float, y: float, w: float, h: float) -> void:
	c.anchor_left = ax
	c.anchor_right = ax
	c.anchor_top = ay
	c.anchor_bottom = ay
	c.offset_left = x
	c.offset_top = y
	c.offset_right = x + w
	c.offset_bottom = y + h


func full(c: Control) -> void:
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.offset_left = 0
	c.offset_top = 0
	c.offset_right = 0
	c.offset_bottom = 0


func ui_button(text: String, cb: Callable, kind := "", disabled := false) -> Button:
	var b = Button.new()
	b.text = text
	b.disabled = disabled
	b.custom_minimum_size = Vector2(130, 46)
	var bg = Color("#2f3440")
	var fg = Color("#ecebe6")
	if kind == "g":
		bg = GOLD
		fg = Color("#1a1a1a")
	elif kind == "o":
		bg = OK_C
		fg = Color("#0e2219")
	elif kind == "r":
		bg = RED
	var s = flat(bg, 10, bg, 0)
	b.add_theme_stylebox_override("normal", s)
	b.add_theme_stylebox_override("hover", s)
	b.add_theme_stylebox_override("pressed", flat(bg.darkened(0.2), 10, bg, 0))
	b.add_theme_stylebox_override("disabled", flat(bg.darkened(0.55), 10, bg, 0))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_color_override("font_color", fg)
	b.add_theme_color_override("font_hover_color", fg)
	b.add_theme_color_override("font_pressed_color", fg)
	b.add_theme_color_override("font_disabled_color", fg.darkened(0.4))
	b.add_theme_font_size_override("font_size", 19)
	b.pressed.connect(cb)
	return b


func setup_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)
	var th = Theme.new()
	th.default_font_size = 20
	# --- HUD
	hud = Control.new()
	full(hud)
	hud.theme = th
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(hud)
	var mp = PanelContainer.new()
	mp.add_theme_stylebox_override("panel", flat(Color(0.08, 0.09, 0.11, 0.8)))
	mp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(mp, 0, 0, 16, 14, 150, 52)
	lbl_money = lbl("$0", 26, GOLD)
	mp.add_child(lbl_money)
	hud.add_child(mp)
	var lp = PanelContainer.new()
	lp.add_theme_stylebox_override("panel", flat(Color(0.08, 0.09, 0.11, 0.8)))
	lp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(lp, 0, 0, 178, 14, 220, 52)
	var lv = VBoxContainer.new()
	lv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl_lvl = lbl("Nível 1", 16, DIM)
	lv.add_child(lbl_lvl)
	bar_xp = pbar(GOLD, 190)
	lv.add_child(bar_xp)
	lp.add_child(lv)
	hud.add_child(lp)
	var rp = PanelContainer.new()
	rp.add_theme_stylebox_override("panel", flat(Color(0.08, 0.09, 0.11, 0.8)))
	rp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(rp, 1, 0, -310, 14, 220, 66)
	var rv = VBoxContainer.new()
	rv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rv.add_theme_constant_override("separation", 4)
	lbl_bag = lbl("Saco 0/10kg", 15, DIM)
	rv.add_child(lbl_bag)
	bar_hp = pbar(OK_C, 190)
	rv.add_child(bar_hp)
	bar_car = pbar(Color("#4a8fe0"), 190)
	rv.add_child(bar_car)
	rp.add_child(rv)
	hud.add_child(rp)
	menu_panel = Panel.new()
	menu_panel.add_theme_stylebox_override("panel", flat(Color(0.08, 0.09, 0.11, 0.85)))
	menu_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(menu_panel, 1, 0, -78, 14, 62, 62)
	var ml = lbl("≡", 34)
	ml.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ml.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	full(ml)
	menu_panel.add_child(ml)
	hud.add_child(menu_panel)
	lbl_zone = lbl("", 16, DIM)
	lbl_zone.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	place(lbl_zone, 0.5, 0, -250, 70, 500, 24)
	hud.add_child(lbl_zone)
	prog_box = PanelContainer.new()
	prog_box.add_theme_stylebox_override("panel", flat(Color(0.08, 0.09, 0.11, 0.85)))
	prog_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(prog_box, 0.5, 0.25, -200, 0, 400, 70)
	var pv = VBoxContainer.new()
	pv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prog_lbl = lbl("", 19)
	prog_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pv.add_child(prog_lbl)
	prog_bar = pbar(GOLD, 370, 12)
	pv.add_child(prog_bar)
	prog_box.add_child(pv)
	prog_box.visible = false
	hud.add_child(prog_box)
	fire_panel = Panel.new()
	fire_panel.add_theme_stylebox_override("panel", circle_style(Color(0.33, 0.1, 0.08, 0.85), Color("#8b2f28")))
	fire_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(fire_panel, 1, 1, -170, -170, 140, 140)
	var fl = lbl("DISPARAR", 20)
	fl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	full(fl)
	fire_panel.add_child(fl)
	hud.add_child(fire_panel)
	act_panel = Panel.new()
	act_panel.add_theme_stylebox_override("panel", circle_style(Color(0.11, 0.12, 0.15, 0.85), LINE))
	act_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(act_panel, 1, 1, -310, -140, 118, 118)
	act_lbl = lbl("—", 17, DIM)
	act_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	act_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	full(act_lbl)
	act_panel.add_child(act_lbl)
	hud.add_child(act_panel)
	overlay = Control.new()
	full(overlay)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.draw.connect(_draw_overlay)
	ui.add_child(overlay)
	hud.visible = false
	# --- toasts
	toasts = VBoxContainer.new()
	toasts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toasts.alignment = BoxContainer.ALIGNMENT_END
	toasts.theme = th
	place(toasts, 0.5, 1, -380, -420, 760, 230)
	ui.add_child(toasts)
	# --- mapa
	map_ui = Control.new()
	full(map_ui)
	map_ui.theme = th
	var mbg = ColorRect.new()
	mbg.color = Color(0.04, 0.045, 0.055, 0.92)
	full(mbg)
	map_ui.add_child(mbg)
	var mt = lbl("Vila Rubra — para onde vais?", 26)
	place(mt, 0, 0, 30, 18, 600, 40)
	map_ui.add_child(mt)
	map_info = lbl("", 17, GOLD)
	map_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	place(map_info, 1, 0, -430, 24, 400, 30)
	map_ui.add_child(map_info)
	map_area = Control.new()
	map_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	map_area.offset_left = 24
	map_area.offset_top = 70
	map_area.offset_right = -24
	map_area.offset_bottom = -20
	map_area.draw.connect(_draw_map)
	map_ui.add_child(map_area)
	map_ui.visible = false
	ui.add_child(map_ui)
	# --- modal
	modal = Control.new()
	full(modal)
	modal.theme = th
	var dim = ColorRect.new()
	dim.color = Color(0.04, 0.045, 0.055, 0.8)
	full(dim)
	modal.add_child(dim)
	var pc = PanelContainer.new()
	pc.add_theme_stylebox_override("panel", flat(PANEL, 16, LINE, 1))
	pc.set_anchors_preset(Control.PRESET_FULL_RECT)
	pc.anchor_left = 0.5
	pc.anchor_right = 0.5
	pc.offset_left = -360
	pc.offset_right = 360
	pc.offset_top = 24
	pc.offset_bottom = -24
	modal.add_child(pc)
	var mv = VBoxContainer.new()
	mv.add_theme_constant_override("separation", 10)
	pc.add_child(mv)
	var mh = HBoxContainer.new()
	modal_title = lbl("", 26)
	modal_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mh.add_child(modal_title)
	mh.add_child(ui_button("Fechar", close_menu))
	mv.add_child(mh)
	var sc = ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	mv.add_child(sc)
	modal_body = VBoxContainer.new()
	modal_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_body.add_theme_constant_override("separation", 6)
	sc.add_child(modal_body)
	modal.visible = false
	ui.add_child(modal)
	# --- login
	login_ui = Control.new()
	full(login_ui)
	login_ui.theme = th
	var lbg = ColorRect.new()
	lbg.color = Color("#14161b")
	full(lbg)
	login_ui.add_child(lbg)
	var cc = CenterContainer.new()
	full(cc)
	login_ui.add_child(cc)
	var lvb = VBoxContainer.new()
	lvb.add_theme_constant_override("separation", 14)
	cc.add_child(lvb)
	var title = lbl("GOLPE", 110, GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_shadow_color", Color("#6b1f1a"))
	title.add_theme_constant_override("shadow_offset_x", 6)
	title.add_theme_constant_override("shadow_offset_y", 6)
	lvb.add_child(title)
	var tag = lbl("Vila Rubra · crime em mundo aberto", 18, DIM)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lvb.add_child(tag)
	nick_edit = LineEdit.new()
	nick_edit.placeholder_text = "Nome de jogador"
	nick_edit.max_length = 16
	nick_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	nick_edit.custom_minimum_size = Vector2(360, 54)
	nick_edit.add_theme_stylebox_override("normal", flat(PANEL, 10))
	nick_edit.add_theme_stylebox_override("focus", flat(PANEL, 10, GOLD))
	nick_edit.add_theme_font_size_override("font_size", 22)
	lvb.add_child(nick_edit)
	var play = ui_button("JOGAR", _on_play, "g")
	play.custom_minimum_size = Vector2(360, 60)
	play.add_theme_font_size_override("font_size", 24)
	lvb.add_child(play)
	var ver = lbl("conteúdo %s · app %s" % [content_version, str(Engine.get_meta("app_version", "dev"))], 14, Color("#5d616b"))
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lvb.add_child(ver)
	ui.add_child(login_ui)
	# --- viagem
	travel_ui = ColorRect.new()
	travel_ui.color = Color("#0d0e11")
	full(travel_ui)
	var tl = lbl("A caminho…", 26, GOLD)
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	full(tl)
	travel_ui.add_child(tl)
	travel_ui.visible = false
	ui.add_child(travel_ui)


func show_login() -> void:
	mode = "login"
	nick_edit.text = str(S["nick"])
	login_ui.visible = true
	hud.visible = false


func _on_play() -> void:
	var n = nick_edit.text.strip_edges()
	if n == "":
		toast("Escolhe um nome", RED)
		return
	S["nick"] = n.substr(0, 16)
	save_game()
	login_ui.visible = false
	hud.visible = true
	travel(func():
		enter_zone("home")
		toast("Bem-vindo a Vila Rubra, %s. Conduz até à borda verde para abrir o mapa." % S["nick"]))


func travel(cb: Callable) -> void:
	mode = "travel"
	joy = {}
	firing = false
	travel_ui.visible = true
	await get_tree().create_timer(0.35).timeout
	cb.call()
	travel_ui.visible = false


func toast(text: String, col := LINE) -> void:
	if toasts == null:
		return
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", flat(Color(0.08, 0.09, 0.11, 0.93), 10, col, 2))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var l = lbl(text, 19)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(0, 0)
	p.add_child(l)
	toasts.add_child(p)
	while toasts.get_child_count() > 4:
		var c = toasts.get_child(0)
		toasts.remove_child(c)
		c.queue_free()
	var tw = p.create_tween()
	tw.tween_interval(2.6)
	tw.tween_property(p, "modulate:a", 0.0, 0.4)
	tw.tween_callback(p.queue_free)


func update_hud() -> void:
	lbl_money.text = fmt(S["money"])
	lbl_lvl.text = "Nível %d · %d/%d XP" % [S["lvl"], int(S["xp"]), xp_need(int(S["lvl"]))]
	bar_xp.value = 100.0 * float(S["xp"]) / xp_need(int(S["lvl"]))
	bar_hp.value = float(S["hp"])
	bar_car.value = 100.0 * float(S["car_hp"]) / float(car_def()["hp"])
	lbl_bag.text = "Saco %.1f/%dkg" % [inv_kg(), bag_def()["cap"]]
	var st = (prog_bar.get_theme_stylebox("fill") as StyleBoxFlat)
	if not heist.is_empty():
		prog_box.visible = true
		prog_lbl.text = "A assaltar %s…" % D.HEISTS[Z["id"]]["name"]
		prog_bar.value = 100.0 * heist["t"] / heist["need"]
		st.bg_color = GOLD
	elif bust > 0:
		prog_box.visible = true
		prog_lbl.text = "A SER DETIDO — foge!"
		prog_bar.value = 100.0 * bust / 2.0
		st.bg_color = RED
	elif cap > 0:
		prog_box.visible = true
		prog_lbl.text = "A tomar território…"
		prog_bar.value = 100.0 * cap / 3.0
		st.bg_color = GOLD
	else:
		prog_box.visible = false


func star_pts(c: Vector2, r: float) -> PackedVector2Array:
	var pts = PackedVector2Array()
	for i in 10:
		var a = -PI / 2 + i * PI / 5
		var rr = r if i % 2 == 0 else r * 0.45
		pts.append(c + Vector2(cos(a), sin(a)) * rr)
	return pts


func _draw_overlay() -> void:
	if mode == "login" or Z.is_empty() or not hud.visible:
		return
	var vs = overlay.size
	if wanted > 0 and mode == "play":
		var c = Color(0.88, 0.24, 0.24) if int(t * 3) % 2 == 0 else Color(0.24, 0.43, 0.88)
		for i in 6:
			var a = 0.22 * (1.0 - i / 6.0)
			overlay.draw_rect(Rect2(Vector2(i * 9, i * 9), vs - Vector2(i * 18, i * 18)), Color(c.r, c.g, c.b, a), false, 9.0)
	var sx = vs.x / 2.0 - 2.0 * 40.0
	for i in 5:
		var on = i < wanted
		var col = (RED if int(t * 3) % 2 == 0 else GOLD) if on else Color(0.27, 0.29, 0.33)
		var pts = star_pts(Vector2(sx + i * 40.0, 40.0), 16.0)
		overlay.draw_colored_polygon(star_pts(Vector2(sx + i * 40.0 + 2, 42.0), 16.0), Color(0, 0, 0, 0.5))
		overlay.draw_colored_polygon(pts, col)
	if mode != "play":
		return
	var goal: Dictionary = Z["door"] if not Z["door"].is_empty() else Z["flag"]
	if not goal.is_empty():
		var gp = Vector3(goal["x"], 1.0, goal["y"])
		var sp = cam.unproject_position(gp)
		var behind = cam.is_position_behind(gp)
		if behind or sp.x < 0 or sp.y < 0 or sp.x > vs.x or sp.y > vs.y:
			var dir = (sp - vs / 2.0).normalized()
			if behind:
				dir = -dir
			var R = minf(vs.x, vs.y) * 0.38
			var ap = vs / 2.0 + dir * R
			var ang = dir.angle()
			var tri = PackedVector2Array([ap + Vector2(18, 0).rotated(ang), ap + Vector2(-10, -12).rotated(ang), ap + Vector2(-10, 12).rotated(ang)])
			overlay.draw_colored_polygon(tri, RED if Z["kind"] == "heist" else GOLD)
	if not joy.is_empty():
		var base: Vector2 = joy["base"]
		var d: Vector2 = joy["pos"] - base
		if d.length() > 80.0:
			d = d.normalized() * 80.0
		overlay.draw_arc(base, 80.0, 0, TAU, 40, Color(1, 1, 1, 0.45), 3.0)
		overlay.draw_circle(base + d, 32.0, Color(1, 1, 1, 0.45))


# =====================================================================
#  MAPA DA CIDADE
# =====================================================================
func open_map() -> void:
	mode = "map"
	joy = {}
	firing = false
	for c in map_area.get_children():
		c.queue_free()
	for n in D.MAPNODES:
		var id: String = n["id"]
		var k = kind_of(id)
		var d = def_of(id)
		var lvl: int = d.get("lvl", 1)
		var lock = int(S["lvl"]) < lvl
		var st = ""
		var border = GOLD
		if k == "heist":
			border = RED
		elif k == "terr":
			border = Color("#9a6ad0")
		elif k == "home":
			border = OK_C
		if lock:
			st = "Bloqueado · nível %d" % lvl
		elif k == "heist":
			var left: float = float(S["cds"].get(id, 0)) - now_ms()
			st = ("Fechado " + mmss(left)) if left > 0 else ("%d estrela%s · disponível" % [d["stars"], "s" if d["stars"] > 1 else ""])
		elif k == "terr":
			st = ("Teu · %s/min" % fmt(d["income"])) if S["terr"].has(id) else ("Gangue: %d" % d["gang"])
		var mis: Dictionary = S["mission"]
		var hi = (not mis.is_empty() and not mis["done"] and mis["target"] == id) or (not mis.is_empty() and mis["done"] and id == "bar")
		var b = Button.new()
		b.text = d["name"] + ("\n" + st if st != "" else "")
		b.anchor_left = n["x"] / 100.0
		b.anchor_right = n["x"] / 100.0
		b.anchor_top = n["y"] / 100.0
		b.anchor_bottom = n["y"] / 100.0
		b.offset_left = -105
		b.offset_right = 105
		b.offset_top = -34
		b.offset_bottom = 34
		var bg = Color(0.11, 0.12, 0.15, 0.95)
		if S["terr"].has(id):
			bg = Color("#3a2a52")
		var s = flat(bg, 14, GOLD if hi else border, 4 if hi else 2)
		b.add_theme_stylebox_override("normal", s)
		b.add_theme_stylebox_override("hover", s)
		b.add_theme_stylebox_override("pressed", flat(bg.lightened(0.1), 14, border, 2))
		b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		b.add_theme_font_size_override("font_size", 16)
		b.add_theme_color_override("font_color", DIM if lock else Color("#ecebe6"))
		b.pressed.connect(func(): _map_pick(id))
		map_area.add_child(b)
	var r = income_rate()
	map_info.text = ("Rendas: +%s/min" % fmt(r)) if r > 0 else ""
	map_ui.visible = true
	map_area.queue_redraw()


func _draw_map() -> void:
	var s = map_area.size
	map_area.draw_rect(Rect2(Vector2.ZERO, s), Color("#2c3a2e"))
	map_area.draw_circle(Vector2(s.x * 0.06, s.y * 1.0), s.y * 0.38, Color("#1f4c6b"))
	map_area.draw_circle(Vector2(s.x * 1.0, 0), s.y * 0.3, Color("#1f4c6b"))
	for i in 9:
		map_area.draw_line(Vector2(s.x * i / 8.0, 0), Vector2(s.x * i / 8.0, s.y), Color(1, 1, 1, 0.03), 2.0)
	var home: Dictionary = D.MAPNODES[0]
	var hp = Vector2(s.x * home["x"] / 100.0, s.y * home["y"] / 100.0)
	for n in D.MAPNODES:
		if n["id"] == "home":
			continue
		var np = Vector2(s.x * n["x"] / 100.0, s.y * n["y"] / 100.0)
		var mid = Vector2((hp.x + np.x) / 2.0, hp.y)
		var pts = PackedVector2Array()
		for i in 17:
			var q = i / 16.0
			pts.append(hp.lerp(mid, q).lerp(mid.lerp(np, q), q))
		map_area.draw_polyline(pts, Color("#555a52"), 7.0, true)


func _map_pick(id: String) -> void:
	var d = def_of(id)
	if int(S["lvl"]) < int(d.get("lvl", 1)):
		toast("Precisas de nível %d" % d["lvl"], RED)
		return
	map_ui.visible = false
	travel(func(): enter_zone(id))


# =====================================================================
#  MENUS (lojas, bar, esconderijo)
# =====================================================================
func open_menu(title: String, render_fn: Callable) -> void:
	mode = "menu"
	joy = {}
	firing = false
	modal_title.text = title
	modal_render = render_fn
	refresh_menu()
	modal.visible = true


func refresh_menu() -> void:
	for c in modal_body.get_children():
		modal_body.remove_child(c)
		c.queue_free()
	modal_render.call(modal_body)


func close_menu() -> void:
	modal.visible = false
	if mode == "menu":
		mode = "play"
	save_game()


func act(cb: Callable) -> Callable:
	return func():
		cb.call()
		save_game()
		if modal.visible:
			refresh_menu()


func h3(box: VBoxContainer, text: String) -> void:
	var l = lbl(text.to_upper(), 15, DIM)
	l.custom_minimum_size = Vector2(0, 34)
	l.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	box.add_child(l)


func note(box: VBoxContainer, text: String, italic := false) -> void:
	var l = lbl(text, 17, DIM)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if italic:
		l.add_theme_color_override("font_color", Color("#b9b6ad"))
	box.add_child(l)


func row(box: VBoxContainer, title: String, sub: String, btext: String, cb: Callable, kind := "", disabled := false) -> void:
	var h = HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	var v = VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(lbl(title, 20))
	if sub != "":
		var s = lbl(sub, 15, DIM)
		s.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(s)
	h.add_child(v)
	h.add_child(ui_button(btext, act(cb), kind, disabled))
	box.add_child(h)
	var sep = HSeparator.new()
	box.add_child(sep)


func big_button(box: VBoxContainer, text: String, cb: Callable, kind := "", disabled := false) -> void:
	var b = ui_button(text, act(cb), kind, disabled)
	b.custom_minimum_size = Vector2(0, 54)
	box.add_child(b)


func group_inv() -> Array:
	var m = {}
	var order: Array = []
	for i in S["inv"]:
		var k: String = i["n"]
		if not m.has(k):
			m[k] = {"n": k, "c": 0, "v": 0, "kg": 0.0, "dirty": i.get("dirty", false)}
			order.append(k)
		m[k]["c"] += 1
		m[k]["v"] += int(i["v"])
		m[k]["kg"] += float(i["kg"])
	var out: Array = []
	for k in order:
		out.append(m[k])
	return out


func sell_val(g: Dictionary) -> int:
	return int(floor(g["v"] * (0.8 if g["dirty"] else 1.0) * terr_bonus()))


func remove_items(name: String) -> void:
	var keep: Array = []
	for i in S["inv"]:
		if i["n"] != name:
			keep.append(i)
	S["inv"] = keep


func open_shop(id: String) -> void:
	if id == "bar":
		open_menu("Bar O Farol", menu_bar)
	elif id == "armeiro":
		open_menu("Armeiro do Lima", menu_arm)
	elif id == "stand":
		open_menu("Stand Rodas Livres", menu_stand)
	elif id == "imob":
		open_menu("Imobiliária Chave d'Ouro", menu_imob)
	elif id == "home":
		open_menu("Esconderijo", menu_home)


func menu_bar(box: VBoxContainer) -> void:
	note(box, "Zé Faísca, a limpar um copo: \"Traz-me coisas boas e eu arranjo comprador. Sem perguntas.\"", true)
	h3(box, "Vender saque")
	var gs = group_inv()
	if gs.is_empty():
		note(box, "O teu saco está vazio.")
	else:
		var tot = 0
		for g in gs:
			var v = sell_val(g)
			tot += v
			var nm: String = g["n"]
			row(box, "%s ×%d" % [nm, g["c"]], "%.1fkg%s" % [g["kg"], " · lavagem 80%" if g["dirty"] else ""], fmt(v), func():
				remove_items(nm)
				add_money(v)
				toast("+" + fmt(v), GOLD))
		big_button(box, "Vender tudo · " + fmt(tot), func():
			add_money(tot)
			S["inv"] = []
			toast("Vendeste tudo: +" + fmt(tot), GOLD), "g")
		if S["terr"].size() > 0:
			note(box, "Bónus de território: +%d%% no preço" % int(round((terr_bonus() - 1.0) * 100)))
	h3(box, "Contrato")
	var m: Dictionary = S["mission"]
	if m.is_empty():
		note(box, "O Zé tem sempre trabalho para quem não faz perguntas.")
		big_button(box, "Pedir contrato", func():
			var opts: Array = []
			for k in D.HEISTS.keys():
				if D.HEISTS[k]["lvl"] <= int(S["lvl"]):
					opts.append(k)
			var tg: String = opts[randi() % opts.size()]
			var hh: Dictionary = D.HEISTS[tg]
			S["mission"] = {"target": tg, "reward": 200 + hh["stars"] * 250 + int(S["lvl"]) * 60, "xp": hh["xp"], "done": false}
			toast("Novo contrato: " + hh["name"]))
	elif m["done"]:
		row(box, "Feito: " + D.HEISTS[m["target"]]["name"], "Trabalho cumprido", "Receber " + fmt(m["reward"]), func():
			add_money(m["reward"])
			add_xp(m["xp"])
			S["mission"] = {}
			toast("Recompensa: +" + fmt(m["reward"]), GOLD), "o")
	else:
		row(box, "Assaltar: " + D.HEISTS[m["target"]]["name"], "Recompensa %s + %d XP" % [fmt(m["reward"]), m["xp"]], "Desistir", func(): S["mission"] = {})


func buy_row(box: VBoxContainer, it: Dictionary, owned: bool, equipped: bool, sub: String, on_buy: Callable, on_equip: Callable) -> void:
	if equipped:
		row(box, it["name"], sub, "Equipado", func(): pass, "", true)
	elif owned:
		row(box, it["name"], sub, "Usar", on_equip, "o")
	elif int(S["lvl"]) < int(it["lvl"]):
		row(box, it["name"], sub, "Nível %d" % it["lvl"], func(): pass, "", true)
	else:
		var price: int = it["price"]
		row(box, it["name"], sub, fmt(price), func():
			if int(S["money"]) < price:
				return
			S["money"] = int(S["money"]) - price
			on_buy.call()
			toast("Compraste " + it["name"], GOLD), "g", int(S["money"]) < price)


func menu_arm(box: VBoxContainer) -> void:
	note(box, "\"Aqui não há recibos.\" — Lima", true)
	h3(box, "Armas")
	for w in D.WEAPONS:
		var wid: String = w["id"]
		var sub = "Dano %d%s · %.1f tiros/s · alcance %dm" % [w["dmg"], ("×%d" % w["pel"]) if w["pel"] > 1 else "", 1.0 / w["rate"], int(w["range"])]
		buy_row(box, w, S["weapons"].has(wid), S["weapon"] == wid, sub, func():
			S["weapons"].append(wid)
			S["weapon"] = wid, func(): S["weapon"] = wid)
	h3(box, "Sacos")
	for b in D.BAGS:
		var bid: String = b["id"]
		var capb: int = b["cap"]
		buy_row(box, b, S["bags"].has(bid), S["bag"] == bid, "Capacidade %dkg" % capb, func():
			S["bags"].append(bid)
			S["bag"] = bid, func():
			if inv_kg() > capb:
				toast("Tens demasiado peso para esse saco", RED)
				return
			S["bag"] = bid)


func menu_stand(box: VBoxContainer) -> void:
	note(box, "\"Documentos? Vêm no próximo mês.\" — vendedor", true)
	h3(box, "Carros")
	for c in D.CARS:
		var cid: String = c["id"]
		var chp: float = c["hp"]
		buy_row(box, c, S["cars"].has(cid), S["car"] == cid, "%s · vel %d km/h · resistência %d" % [c["d"], int(c["spd"] * 3.6), c["hp"]], func():
			S["cars"].append(cid)
			S["car"] = cid
			S["car_hp"] = chp, func():
			S["car"] = cid
			S["car_hp"] = chp)
	h3(box, "Oficina")
	var miss: float = float(car_def()["hp"]) - float(S["car_hp"])
	var cost = int(ceil(miss * 4.0))
	row(box, "Reparar " + car_def()["name"], "%d/%d" % [int(S["car_hp"]), car_def()["hp"]], fmt(cost), func():
		S["money"] = int(S["money"]) - cost
		S["car_hp"] = float(car_def()["hp"])
		toast("Carro reparado"), "", miss < 1 or int(S["money"]) < cost)


func collect_button(box: VBoxContainer) -> void:
	var p = int(floor(float(S["pending"])))
	big_button(box, "Recolher rendas · " + fmt(p), func():
		add_money(p)
		S["pending"] = float(S["pending"]) - p
		toast("Rendas recolhidas: +" + fmt(p), GOLD), "o", p < 1)


func menu_imob(box: VBoxContainer) -> void:
	note(box, "\"Compra, arrenda e deixa o dinheiro trabalhar.\"", true)
	h3(box, "Imóveis")
	for p in D.PROPS:
		var pid: String = p["id"]
		var price: int = p["price"]
		var owned: bool = S["props"].has(pid)
		var sub = "Renda %s/min" % fmt(p["rent"])
		if not owned:
			if int(S["lvl"]) < int(p["lvl"]):
				row(box, p["name"], sub, "Nível %d" % p["lvl"], func(): pass, "", true)
			else:
				row(box, p["name"], sub, fmt(price), func():
					S["money"] = int(S["money"]) - price
					S["props"][pid] = {"rented": false}
					toast("Compraste " + p["name"], GOLD), "g", int(S["money"]) < price)
		elif S["props"][pid]["rented"]:
			row(box, p["name"], sub + " · a render", "Arrendado ✓", func(): S["props"][pid]["rented"] = false)
		else:
			row(box, p["name"], sub + " · vazio", "Arrendar", func():
				S["props"][pid]["rented"] = true
				toast(p["name"] + " arrendado", GOLD), "o")
	note(box, "Rendimento total: %s/min (inclui territórios)" % fmt(income_rate()))
	collect_button(box)


func menu_home(box: VBoxContainer) -> void:
	note(box, "O teu canto. Aqui ninguém te encontra.", true)
	big_button(box, "Descansar e reparar carro", func():
		S["hp"] = 100.0
		S["car_hp"] = float(car_def()["hp"])
		toast("Descansaste. Vida e carro a 100%", OK_C), "", float(S["hp"]) >= 100 and float(S["car_hp"]) >= float(car_def()["hp"]))
	collect_button(box)
	h3(box, "Estatísticas")
	var st: Dictionary = S["stats"]
	note(box, "Assaltos: %d · Detenções: %d · Hospital: %d\nTotal ganho: %s · Territórios: %d/3 · Imóveis: %d/4" % [st["heists"], st["busted"], st["hospital"], fmt(st["earned"]), S["terr"].size(), S["props"].size()])


func menu_pause() -> void:
	open_menu("Menu", func(box: VBoxContainer):
		h3(box, "Saco")
		var gs = group_inv()
		if gs.is_empty():
			note(box, "Vazio.")
		for g in gs:
			var nm: String = g["n"]
			row(box, "%s ×%d" % [nm, g["c"]], "%.1fkg · vale ~%s" % [g["kg"], fmt(sell_val(g))], "Deitar fora", func(): remove_items(nm), "r")
		h3(box, "Equipamento")
		note(box, "Arma: %s · Carro: %s · Saco: %s" % [weapon()["name"], car_def()["name"], bag_def()["name"]])
		h3(box, "Jogo")
		note(box, "Jogador: %s · conteúdo %s\nPara mudar de zona, conduz até uma saída verde na borda." % [S["nick"], content_version])
		big_button(box, "Apagar progresso", func():
			if now_ms() - reset_arm < 3000.0:
				S = default_save()
				save_game()
				close_menu()
				free_entities()
				show_login()
			else:
				reset_arm = now_ms()
				toast("Toca outra vez para confirmar", RED), "r"))
