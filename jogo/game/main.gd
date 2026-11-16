extends Node3D
## GOLPE v0.3 — cidade única (Vila Rubra), região, interiores, câmara 3ª pessoa.
## Tudo construído por código, conteúdo original.

const D = preload("res://game/data.gd")
const SAVE_PATH = "user://save.json"
const GOLD = Color("#e8b931")
const RED = Color("#e0483e")
const OK_C = Color("#3cc48a")
const DIM = Color("#9a9ca3")
const PANEL = Color("#1d2027")
const LINE = Color("#2c313b")
const PURPLE = Color("#9a6ad0")

var S = {}
var mode = "login"
var cur_place = ""
var Z = {}
var blocks_now = []
var world: Node3D
var world_int: Node3D
var cam: Camera3D
var sun: DirectionalLight3D
var siren: OmniLight3D
var rings = []
var flags = {}
var ui: CanvasLayer
var hud: Control
var overlay: Control
var minimap: Control
var toasts: VBoxContainer
var feed_box: VBoxContainer
var hotbar: HBoxContainer
var slot_panels = []
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
var map_btn: Panel
var modal: Control
var modal_title: Label
var modal_body: VBoxContainer
var modal_render: Callable
var region_ui: Control
var region_area: Control
var region_card: PanelContainer
var region_card_title: Label
var region_card_desc: Label
var region_pick = ""
var fullmap_ui: Control
var fullmap_area: Control
var loot_ui: Control
var loot_title: Label
var loot_info: Label
var loot_bag_info: Label
var loot_grid: GridContainer
var bag_grid: GridContainer
var login_ui: Control
var nick_edit: LineEdit
var travel_ui: ColorRect

var P = {"x": 0.0, "y": 0.0, "ang": 0.0, "in_car": false, "fire_cd": 0.0, "hurt": 0.0, "phase": 0.0, "px": 0.0, "py": 0.0}
var player_mesh: Node3D
var hostage_mesh: Node3D
var car = {}
var police = []
var gang = []
var bullets = []
var parts = []
var civ = []
var peds = []
var bullet_pool = []
var part_pool = []
var wanted = 0
var lost_t = 0.0
var bust = 0.0
var cap = 0.0
var spawn_t = 0.0
var t = 0.0
var cam_yaw = 0.0
var cam_t = Vector3.ZERO
var cam_p = Vector3.ZERO
var snap_cam = true
var joy = {}
var cam_drag = {}
var firing = false
var fire_touch = -99
var inside = false
var I = {}
var search = {}
var loot_c = {}
var waypoint = {}
var gang_spawned = {}
var last_act = ""
var content_version = "dev"
var mat_cache = {}
var fac_cache = {}
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


func _read_txt(path: String, def: String) -> String:
	if FileAccess.file_exists(path):
		return FileAccess.get_file_as_string(path).strip_edges()
	return def


func now_ms() -> float:
	return Time.get_unix_time_from_system() * 1000.0


func autotest() -> void:
	## Teste automático no CI: percorre os sistemas e falha se houver erros de script.
	var tr = get_tree()
	S = default_save()
	S["nick"] = "CI"
	S["lvl"] = 6
	S["money"] = 100000
	login_ui.visible = false
	hud.visible = true
	enter_place("home")
	await tr.create_timer(0.4).timeout
	for id in ["home", "armeiro", "stand", "imob"]:
		open_shop(id)
		await tr.process_frame
		close_menu()
	menu_pause()
	await tr.process_frame
	close_menu()
	open_region()
	await tr.process_frame
	_region_select("city")
	await tr.process_frame
	_region_go()
	await tr.create_timer(1.0).timeout
	print("autotest: cidade blocos ", Z["blocks"].size(), " pois ", Z["pois"].size(), " civ ", civ.size(), " peoes ", peds.size())
	open_fullmap()
	await tr.process_frame
	_fullmap_pick("museu")
	close_fullmap()
	var cafe = find_poi("cafe")
	P["in_car"] = false
	P["x"] = cafe["x"]
	P["y"] = cafe["y"] + 1.0
	await tr.process_frame
	do_action()
	await tr.create_timer(0.3).timeout
	print("autotest: dentro ", inside, " contentores ", I.get("conts", []).size())
	for c in I["conts"]:
		P["x"] = c["x"] + c["w"] / 2.0
		P["y"] = c["y"] + c["h"] + 0.6
		start_search(c)
		search["t"] = 999.0
		await tr.process_frame
		await tr.process_frame
		_loot_take_all()
		close_loot()
	print("autotest: saque ", S["inv"].size(), " wanted ", wanted)
	firing = true
	await tr.create_timer(0.5).timeout
	firing = false
	P["x"] = I["w"] / 2.0
	P["y"] = I["d"] + 1.0
	await tr.create_timer(0.3).timeout
	print("autotest: saiu ", not inside, " wanted ", wanted)
	wanted = 4
	await tr.create_timer(4.0).timeout
	print("autotest: policia ", police.size())
	var tv = find_poi("t_velho")
	P["in_car"] = false
	P["x"] = tv["x"] - 12.0
	P["y"] = tv["y"]
	wanted = 0
	await tr.create_timer(0.5).timeout
	firing = true
	await tr.create_timer(3.0).timeout
	firing = false
	print("autotest: gangue ", gang.size(), " hp ", S["hp"])
	for g in gang:
		g["hp"] = 0
	await tr.create_timer(0.3).timeout
	P["x"] = tv["x"]
	P["y"] = tv["y"] + 1.0
	await tr.create_timer(3.5).timeout
	print("autotest: territorio ", S["terr"].has("t_velho"))
	leave_place()
	await tr.process_frame
	_region_select("bar")
	_region_go()
	await tr.create_timer(0.8).timeout
	open_shop("bar")
	await tr.process_frame
	close_menu()
	print("AUTOTEST OK")
	tr.quit()


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
	var el = now_ms() - float(S["last"])
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
#  HELPERS
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


func inv_value() -> int:
	var s = 0
	for i in S["inv"]:
		s += int(i["v"])
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


func find_poi(id: String) -> Dictionary:
	if Z.has("pois"):
		for p in Z["pois"]:
			if p["id"] == id:
				return p
	return {}


func rarity_col(v: int) -> Color:
	if v < 150:
		return Color("#3a3f47")
	if v < 700:
		return Color("#2f5a3a")
	if v < 2000:
		return Color("#2f4a6e")
	if v < 5000:
		return Color("#5a3a72")
	return Color("#7a5a22")


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
	env.ambient_light_energy = 0.9
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color("#d3c6ae")
	env.fog_density = 0.0065
	var we = WorldEnvironment.new()
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.light_color = Color("#ffe2b5")
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 55.0
	sun.rotation_degrees = Vector3(-50, -35, 0)
	add_child(sun)
	cam = Camera3D.new()
	cam.fov = 60.0
	cam.near = 0.2
	cam.far = 400.0
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
		m.size = Vector3(0.7, 0.06, 0.06)
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
	player_mesh = make_person("#2aa39a", "#2b3240", true, "#1f1f1f")
	player_mesh.visible = false
	add_child(player_mesh)


func mat(col: String, rough = 0.85, metal = 0.0) -> StandardMaterial3D:
	var k = "%s|%s|%s" % [col, rough, metal]
	if mat_cache.has(k):
		return mat_cache[k]
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(col)
	m.roughness = rough
	m.metallic = metal
	mat_cache[k] = m
	return m


func unshaded(c: Color, alpha = 1.0) -> StandardMaterial3D:
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


func box(size: Vector3, m: Material, pos: Vector3, parent: Node3D, shadow = true) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var bm = BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = m
	mi.position = pos
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


func cyl(r_top: float, r_bot: float, h: float, m: Material, pos: Vector3, parent: Node3D, segs = 8) -> MeshInstance3D:
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
	for sx in [1.35, -1.35]:
		for sz in [0.9, -0.9]:
			var w = cyl(0.37, 0.37, 0.32, mat("#17181a"), Vector3(sx, 0.37, sz), g, 10)
			w.rotation.x = PI / 2
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


func make_simple_car(col: String, parent: Node3D, pos: Vector3, ang: float) -> Node3D:
	## carro estacionado/trânsito com menos peças (desempenho)
	var g = Node3D.new()
	box(Vector3(4.2, 0.8, 1.9), mat(col, 0.4, 0.3), Vector3(0, 0.75, 0), g)
	box(Vector3(2.3, 0.6, 1.7), mat("#1b2633", 0.15, 0.6), Vector3(-0.25, 1.4, 0), g)
	box(Vector3(3.4, 0.5, 2.0), mat("#17181a"), Vector3(0, 0.3, 0), g, false)
	g.position = pos
	g.rotation.y = -ang
	parent.add_child(g)
	return g


func make_person(shirt: String, pants: String, armed: bool, hair = "#2a1d14") -> Node3D:
	var g = Node3D.new()
	var legs = []
	for s in [-0.15, 0.15]:
		var piv = Node3D.new()
		piv.position = Vector3(0, 0.9, s)
		g.add_child(piv)
		box(Vector3(0.24, 0.9, 0.24), mat(pants), Vector3(0, -0.45, 0), piv)
		box(Vector3(0.32, 0.12, 0.26), mat("#1c1c1e"), Vector3(0.05, -0.88, 0), piv)
		legs.append(piv)
	box(Vector3(0.36, 0.72, 0.62), mat(shirt), Vector3(0, 1.26, 0), g)
	var arms = []
	for s in [-0.4, 0.4]:
		var piv = Node3D.new()
		piv.position = Vector3(0, 1.56, s)
		g.add_child(piv)
		box(Vector3(0.2, 0.66, 0.2), mat(shirt), Vector3(0, -0.3, 0), piv)
		box(Vector3(0.18, 0.16, 0.18), mat("#d9a77c"), Vector3(0, -0.68, 0), piv)
		arms.append(piv)
	if armed:
		box(Vector3(0.42, 0.14, 0.09), mat("#151515", 0.4, 0.6), Vector3(0.2, -0.7, 0), arms[1])
		box(Vector3(0.5, 0.42, 0.62), mat("#1d1f22"), Vector3(-0.3, 1.25, 0), g)
	box(Vector3(0.38, 0.38, 0.38), mat("#d9a77c"), Vector3(0, 1.84, 0), g)
	box(Vector3(0.4, 0.13, 0.4), mat(hair), Vector3(-0.02, 2.06, 0), g)
	g.set_meta("legs", legs)
	g.set_meta("arms", arms)
	return g


func animate_person(m: Node3D, phase: float, moving: bool, hands_up = false) -> void:
	var legs = m.get_meta("legs")
	var arms = m.get_meta("arms")
	var a = sin(phase) * 0.65 if moving else 0.0
	legs[0].rotation.z = a
	legs[1].rotation.z = -a
	if hands_up:
		arms[0].rotation.z = PI * 0.92 + sin(t * 6.0) * 0.05
		arms[1].rotation.z = PI * 0.92 - sin(t * 6.0) * 0.05
	else:
		arms[0].rotation.z = -a * 0.8
		arms[1].rotation.z = a * 0.8


# =====================================================================
#  GERAÇÃO: ZONAS PEQUENAS (casa, bar) E CIDADE
# =====================================================================
func base_zone(id: String, w: float, h: float, rw: float, rx: Array, ry: Array) -> Dictionary:
	return {"id": id, "kind": "", "w": w, "h": h, "rw": rw, "rx": rx, "ry": ry, "blocks": [], "lots": [], "trees": [],
		"pois": [], "water": [], "parked": [], "spawn": {}, "armed": false, "exits": []}


func fill_lot(z: Dictionary, r: RandomNumberGenerator, bx: float, by: float, bw: float, bh: float) -> void:
	## preenche um quarteirão com prédios nas duas frentes e árvores no meio
	var rows = [true, false] if bh > 26.0 else [r.randf() < 0.5]
	for top in rows:
		var cx = bx
		while cx < bx + bw - 3.5:
			var w = minf(bx + bw - cx, 6.5 + r.randf() * 12.0)
			if w < 3.5:
				break
			var depth = minf(bh * (0.45 if rows.size() == 2 else 0.85), 8.0 + r.randf() * 9.0)
			var y = by if top else by + bh - depth
			z["blocks"].append({"x": cx, "y": y, "w": w - 1.1, "h": depth, "col": D.BPAL[r.randi() % D.BPAL.size()], "hgt": 5.0 + r.randf() * 18.0})
			cx += w
	if rows.size() == 2:
		for k in 3:
			z["trees"].append({"x": bx + 3.0 + r.randf() * (bw - 6.0), "y": by + bh / 2.0 + (r.randf() - 0.5) * 2.0, "r": 1.0 + r.randf() * 0.7})


func poi_building(z: Dictionary, id: String, bx: float, by: float, bw: float, bh: float, r: RandomNumberGenerator) -> void:
	var def = def_of(id)
	var kind = kind_of(id)
	if kind == "terr":
		var fx = bx + bw / 2.0
		var fy = by + bh / 2.0
		for k in 9:
			var cx = bx + 3.0 + r.randf() * (bw - 9.0)
			var cy = by + 3.0 + r.randf() * (bh - 7.0)
			if Vector2(cx - fx, cy - fy).length() < 8.0:
				continue
			z["blocks"].append({"x": cx, "y": cy, "w": 3.0 + r.randf() * 2.5, "h": 2.4 + r.randf() * 2.0, "col": "#7a5f3c", "crate": true, "hgt": 1.4 + r.randf() * 0.8})
		z["pois"].append({"id": id, "kind": kind, "x": fx, "y": fy, "name": def["name"], "plaza": [bx, by, bw, bh]})
		return
	var tw = minf(bw, 44.0 if id == "museu" else 32.0)
	var th = minf(bh, 26.0 if id == "museu" else 22.0)
	var tx = bx + (bw - tw) / 2.0
	var ty = by + bh - th - 2.5
	z["blocks"].append({"x": tx, "y": ty, "w": tw, "h": th, "col": def["col"], "label": def["name"], "main": true, "hgt": 12.0 if kind == "heist" else 8.0})
	z["pois"].append({"id": id, "kind": kind, "x": tx + tw / 2.0, "y": ty + th + 0.8, "name": def["name"]})
	for k in 5:
		z["trees"].append({"x": bx + 2.0 + r.randf() * (bw - 4.0), "y": by + 1.5 + r.randf() * maxf(1.0, ty - by - 3.0), "r": 1.0 + r.randf() * 0.8})


func make_small(id: String) -> Dictionary:
	var r = RandomNumberGenerator.new()
	r.seed = hash(id)
	var z = base_zone(id, 128.0, 92.0, 4.0, [22.0, 90.0], [19.0, 64.0])
	z["kind"] = "small"
	z["name"] = def_of(id)["name"]
	var xs = [[0.0, 18.0], [26.0, 86.0], [94.0, 128.0]]
	var ys = [[0.0, 15.0], [23.0, 60.0], [68.0, 92.0]]
	for i in 3:
		for j in 3:
			var lot = {"x": xs[i][0], "y": ys[j][0], "w": xs[i][1] - xs[i][0], "h": ys[j][1] - ys[j][0], "kind": "normal"}
			z["lots"].append(lot)
			if i == 1 and j == 1:
				poi_building(z, id, lot["x"] + 2.0, lot["y"] + 2.0, lot["w"] - 4.0, lot["h"] - 4.0, r)
			else:
				fill_lot(z, r, lot["x"] + 2.0, lot["y"] + 2.0, lot["w"] - 4.0, lot["h"] - 4.0)
	finish_zone(z, r, 6)
	return z


func make_city() -> Dictionary:
	var r = RandomNumberGenerator.new()
	r.seed = 4242
	var rx = [30.0, 95.0, 160.0, 250.0, 315.0, 380.0]
	var ry = [30.0, 95.0, 160.0, 225.0]
	var z = base_zone("city", 420.0, 300.0, 5.0, rx, ry)
	z["kind"] = "city"
	z["name"] = "Vila Rubra"
	z["armed"] = true
	var rw = 5.0
	var xs = []
	var prev = 0.0
	for x in rx:
		xs.append([prev, x - rw])
		prev = x + rw
	xs.append([prev, 420.0])
	var ys = []
	prev = 0.0
	for y in ry:
		ys.append([prev, y - rw])
		prev = y + rw
	# água: canal (com pontes nas ruas) e mar a sul
	var cx0 = 192.0
	var cw = 26.0
	z["water"].append({"x": cx0, "y": 0.0, "w": cw, "h": 254.0})
	z["water"].append({"x": -60.0, "y": 254.0, "w": 540.0, "h": 90.0})
	var cuts = []
	for y in ry:
		cuts.append([y - rw - 2.0, y + rw + 2.0])
	var a = 0.0
	for c in cuts:
		if c[0] > a:
			z["blocks"].append({"x": cx0, "y": a, "w": cw, "h": c[0] - a, "hgt": -1.0, "water": true})
		a = c[1]
	z["blocks"].append({"x": cx0, "y": a, "w": cw, "h": 254.0 - a, "hgt": -1.0, "water": true})
	z["blocks"].append({"x": -60.0, "y": 256.0, "w": 540.0, "h": 90.0, "hgt": -1.0, "water": true})
	z["lots"].append({"x": 0.0, "y": ry[3] + rw, "w": 420.0, "h": 254.0 - ry[3] - rw, "kind": "beach"})
	for i in xs.size():
		for j in ys.size():
			var subs = []
			if xs[i][0] < cx0 and xs[i][1] > cx0 + cw:
				subs.append([xs[i][0], cx0 - 2.0])
				subs.append([cx0 + cw + 2.0, xs[i][1]])
			else:
				subs.append(xs[i])
			for s in subs:
				var lot = {"x": s[0], "y": ys[j][0], "w": s[1] - s[0], "h": ys[j][1] - ys[j][0], "kind": "normal"}
				z["lots"].append(lot)
				var key = "%d,%d" % [i, j]
				var bx = lot["x"] + 2.0
				var by = lot["y"] + 2.0
				var bw = lot["w"] - 4.0
				var bh = lot["h"] - 4.0
				if D.CITY_CELLS.has(key) and subs.size() == 1:
					var pid = D.CITY_CELLS[key]
					if kind_of(pid) == "terr":
						lot["kind"] = "plaza"
					poi_building(z, pid, bx, by, bw, bh, r)
				elif bw > 4.0 and bh > 4.0:
					fill_lot(z, r, bx, by, bw, bh)
	# palmeiras na praia
	for k in 26:
		z["trees"].append({"x": 6.0 + r.randf() * 408.0, "y": ry[3] + rw + 4.0 + r.randf() * 14.0, "r": 1.1, "palm": true})
	# saídas: pontas das estradas a oeste, este e norte
	for y in ry:
		z["exits"].append({"x": 0.0, "y": y, "vert": false})
		z["exits"].append({"x": 420.0, "y": y, "vert": false})
	for x in rx:
		z["exits"].append({"x": x, "y": 0.0, "vert": true})
	finish_zone(z, r, 34)
	return z


func finish_zone(z: Dictionary, r: RandomNumberGenerator, n_parked: int) -> void:
	if z["kind"] == "small":
		for y in z["ry"]:
			z["exits"].append({"x": 0.0, "y": y, "vert": false})
			z["exits"].append({"x": z["w"], "y": y, "vert": false})
		for x in z["rx"]:
			z["exits"].append({"x": x, "y": 0.0, "vert": true})
			z["exits"].append({"x": x, "y": z["h"], "vert": true})
	# árvores não podem cair dentro de prédios
	var keep = []
	for tr in z["trees"]:
		var bad = false
		for b in z["blocks"]:
			if tr["x"] > b["x"] - 0.6 and tr["x"] < b["x"] + b["w"] + 0.6 and tr["y"] > b["y"] - 0.6 and tr["y"] < b["y"] + b["h"] + 0.6:
				bad = true
				break
		if not bad:
			keep.append(tr)
	z["trees"] = keep
	# carros estacionados
	var rw: float = z["rw"]
	var off = rw - 0.55
	var tries = 0
	while z["parked"].size() < n_parked and tries < n_parked * 8:
		tries += 1
		var horiz = r.randf() < 0.6
		var side = 1.0 if r.randf() < 0.5 else -1.0
		var px = 0.0
		var py = 0.0
		var ang = 0.0
		if horiz:
			py = z["ry"][r.randi() % z["ry"].size()] + side * off
			px = 8.0 + r.randf() * (z["w"] - 16.0)
		else:
			px = z["rx"][r.randi() % z["rx"].size()] + side * off
			py = 8.0 + r.randf() * (z["h"] - 16.0)
			ang = PI / 2
		var ok = true
		for x in z["rx"]:
			if absf(px - x) < rw + 4.5 and horiz:
				ok = false
		for y in z["ry"]:
			if absf(py - y) < rw + 4.5 and not horiz:
				ok = false
		for p in z["pois"]:
			if Vector2(p["x"] - px, p["y"] - py).length() < 9.0:
				ok = false
		for b in z["blocks"]:
			if b.get("water", false) and px > b["x"] - 3 and px < b["x"] + b["w"] + 3 and py > b["y"] - 3 and py < b["y"] + b["h"] + 3:
				ok = false
		if py > 250.0 or px < 6.0:
			ok = false
		for q in z["parked"]:
			if Vector2(q["cx"] - px, q["cy"] - py).length() < 6.0:
				ok = false
		if not ok:
			continue
		var hw = 2.1 if horiz else 0.95
		var hh = 0.95 if horiz else 2.1
		var blk = {"x": px - hw, "y": py - hh, "w": hw * 2.0, "h": hh * 2.0, "hgt": 1.7, "car": true, "cx": px, "cy": py, "ang": ang, "col": ["#8a2b2b", "#2b4a8a", "#d8d8d8", "#2f2f33", "#6a7a3a", "#b88a2b"][r.randi() % 6]}
		z["parked"].append(blk)
		z["blocks"].append(blk)


func push_out(o: Dictionary, rad: float) -> bool:
	var hit = false
	for b in blocks_now:
		var bx: float = b["x"]
		var by: float = b["y"]
		var bw: float = b["w"]
		var bh: float = b["h"]
		if o["x"] < bx - rad or o["x"] > bx + bw + rad or o["y"] < by - rad or o["y"] > by + bh + rad:
			continue
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
	for b in blocks_now:
		if b.get("water", false):
			continue
		if x > b["x"] and x < b["x"] + b["w"] and y > b["y"] and y < b["y"] + b["h"]:
			return true
	return false


func solid_at(x: float, y: float, h: float) -> bool:
	for b in blocks_now:
		var hg = float(b.get("hgt", 10.0))
		if hg <= 0:
			continue
		if h < hg + 0.6 and x > b["x"] - 0.3 and x < b["x"] + b["w"] + 0.3 and y > b["y"] - 0.3 and y < b["y"] + b["h"] + 0.3:
			return true
	return false


# =====================================================================
#  CONSTRUÇÃO 3D DO MUNDO
# =====================================================================
func mm_add(parent: Node3D, mesh: Mesh, m: Material, xforms: Array, shadow = true) -> void:
	if xforms.is_empty():
		return
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xforms.size()
	for i in xforms.size():
		mm.set_instance_transform(i, xforms[i])
	var mmi = MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = m
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mmi)


func build_world() -> void:
	if world:
		world.queue_free()
	world = Node3D.new()
	add_child(world)
	rings = []
	flags = {}
	var W: float = Z["w"]
	var H: float = Z["h"]
	var rw: float = Z["rw"]
	var city = Z["kind"] == "city"
	var vis = 160.0
	# chão
	var ground = MeshInstance3D.new()
	var pm = PlaneMesh.new()
	pm.size = Vector2(W + 400, H + 400)
	ground.mesh = pm
	ground.material_override = mat("#4b6640")
	ground.position = Vector3(W / 2.0, -0.02, H / 2.0)
	world.add_child(ground)
	# água
	var water_m = StandardMaterial3D.new()
	water_m.albedo_color = Color("#2a6f8f")
	water_m.roughness = 0.08
	water_m.metallic = 0.3
	for wtr in Z["water"]:
		box(Vector3(wtr["w"], 0.1, wtr["h"]), water_m, Vector3(wtr["x"] + wtr["w"] / 2.0, -0.05, wtr["y"] + wtr["h"] / 2.0), world, false)
	if city:
		box(Vector3(W + 120, 0.1, 400), water_m, Vector3(W / 2.0, -0.06, 254.0 + 200.0), world, false)
	# passeios, relva, praia
	for l in Z["lots"]:
		var lcx: float = l["x"] + l["w"] / 2.0
		var lcz: float = l["y"] + l["h"] / 2.0
		if l["kind"] == "beach":
			box(Vector3(l["w"], 0.2, l["h"] + 2.0), mat("#c9b27e"), Vector3(lcx, 0.08, lcz + 1.0), world, false)
			continue
		box(Vector3(l["w"], 0.25, l["h"]), mat("#a8a398"), Vector3(lcx, 0.125, lcz), world, false)
		var inner = mat("#6a6152") if l["kind"] == "plaza" else mat("#587a48")
		box(Vector3(maxf(0.5, l["w"] - 2.0), 0.27, maxf(0.5, l["h"] - 2.0)), inner, Vector3(lcx, 0.135, lcz), world, false)
	# estradas
	var asphalt = mat("#2f3238", 0.95)
	var vmax = 254.0 if city else H + 200.0
	for y in Z["ry"]:
		box(Vector3(W + 400, 0.04, rw * 2.0), asphalt, Vector3(W / 2.0, 0.0, y), world, false)
	for x in Z["rx"]:
		var y0 = -200.0
		box(Vector3(rw * 2.0, 0.045, vmax - y0), asphalt, Vector3(x, 0.002, (vmax + y0) / 2.0), world, false)
	# pontes (guardas)
	if city:
		for y in Z["ry"]:
			for side in [-1.0, 1.0]:
				box(Vector3(30.0, 0.9, 0.3), mat("#8f939b", 0.5, 0.4), Vector3(205.0, 0.45, y + side * (rw + 2.0)), world)
				box(Vector3(30.0, 0.25, 1.8), mat("#a8a398"), Vector3(205.0, 0.12, y + side * (rw + 0.9)), world, false)
	# marcas na estrada
	var dash = []
	var cross = []
	for y in Z["ry"]:
		var x = -150.0
		while x < W + 150.0:
			var near = false
			for xr in Z["rx"]:
				if absf(x - xr) < rw + 1.5:
					near = true
			if not near:
				dash.append(Transform3D(Basis(), Vector3(x, 0.03, y)))
			x += 3.4
	for xr in Z["rx"]:
		var y2 = -150.0
		while y2 < vmax:
			var near2 = false
			for yr in Z["ry"]:
				if absf(y2 - yr) < rw + 1.5:
					near2 = true
			if not near2:
				dash.append(Transform3D(Basis(Vector3.UP, PI / 2), Vector3(xr, 0.035, y2)))
			y2 += 3.4
		for yr in Z["ry"]:
			for k in range(-3, 4):
				var sc = Basis(Vector3.UP, PI / 2).scaled(Vector3(0.7, 1, 0.35))
				cross.append(Transform3D(sc, Vector3(xr + k * 1.2, 0.03, yr - rw - 1.2)))
				cross.append(Transform3D(sc, Vector3(xr + k * 1.2, 0.03, yr + rw + 1.2)))
				cross.append(Transform3D(Basis().scaled(Vector3(0.7, 1, 0.35)), Vector3(xr - rw - 1.2, 0.03, yr + k * 1.2)))
				cross.append(Transform3D(Basis().scaled(Vector3(0.7, 1, 0.35)), Vector3(xr + rw + 1.2, 0.03, yr + k * 1.2)))
	var dm = BoxMesh.new()
	dm.size = Vector3(1.8, 0.02, 0.22)
	mm_add(world, dm, mat("#e4d27a"), dash, false)
	var cm = BoxMesh.new()
	cm.size = Vector3(2.4, 0.02, 0.9)
	mm_add(world, cm, mat("#e9e6dc"), cross, false)
	# saídas
	var ex = unshaded(OK_C, 0.55)
	for e in Z["exits"]:
		if e["vert"]:
			box(Vector3(rw * 2.0, 0.08, 0.8), ex, Vector3(e["x"], 0.06, clampf(e["y"], 0.4, H - 0.4)), world, false)
		else:
			box(Vector3(0.8, 0.08, rw * 2.0), ex, Vector3(clampf(e["x"], 0.4, W - 0.4), 0.06, e["y"]), world, false)
	# candeeiros (multimesh)
	var poles = []
	var arms = []
	var bulbs = []
	for y in Z["ry"]:
		var x3 = 8.0
		while x3 < W:
			var near3 = false
			for xr in Z["rx"]:
				if absf(x3 - xr) < rw + 3.0:
					near3 = true
			if city and x3 > 188.0 and x3 < 222.0:
				near3 = true
			if not near3:
				for side in [-1.0, 1.0]:
					var pz = y + side * (rw + 0.9)
					poles.append(Transform3D(Basis(), Vector3(x3, 2.35, pz)))
					arms.append(Transform3D(Basis(), Vector3(x3, 4.4, pz - side * 0.55)))
					bulbs.append(Transform3D(Basis(), Vector3(x3, 4.32, pz - side * 1.05)))
			x3 += 18.0
	var pc = CylinderMesh.new()
	pc.top_radius = 0.07
	pc.bottom_radius = 0.09
	pc.height = 4.2
	pc.radial_segments = 6
	mm_add(world, pc, mat("#3c3f44", 0.5, 0.5), poles)
	var am = BoxMesh.new()
	am.size = Vector3(0.12, 0.1, 1.2)
	mm_add(world, am, mat("#3c3f44", 0.5, 0.5), arms, false)
	var bmesh = BoxMesh.new()
	bmesh.size = Vector3(0.3, 0.12, 0.45)
	mm_add(world, bmesh, unshaded(Color("#fff1c2")), bulbs, false)
	# prédios
	for b in Z["blocks"]:
		if b.get("water", false) or b.get("car", false):
			continue
		var w: float = b["w"]
		var d: float = b["h"]
		var hgt: float = b["hgt"]
		var bcx: float = b["x"] + w / 2.0
		var bcz: float = b["y"] + d / 2.0
		if b.get("crate", false):
			var cr = box(Vector3(w, hgt, d), mat("#7a5f3c"), Vector3(bcx, hgt / 2.0 + 0.25, bcz), world)
			cr.visibility_range_end = vis
			continue
		var body = box(Vector3(w, hgt, d), facade(b["col"]), Vector3(bcx, hgt / 2.0 + 0.25, bcz), world)
		body.visibility_range_end = vis + 60.0
		var roofc = Color(b["col"]).darkened(0.35)
		var roof = box(Vector3(w + 0.3, 0.35, d + 0.3), mat("#" + roofc.to_html(false)), Vector3(bcx, hgt + 0.42, bcz), world)
		roof.visibility_range_end = vis + 60.0
		if b.get("main", false):
			var front: float = b["y"] + d
			var shop_c = Color(b["col"])
			box(Vector3(w * 0.84, 3.0, 0.15), mat("#1b2633", 0.12, 0.6), Vector3(bcx, 1.75, front + 0.02), world, false)
			box(Vector3(2.2, 2.6, 0.2), mat("#1a1410"), Vector3(bcx, 1.55, front + 0.05), world, false)
			box(Vector3(w * 0.9, 0.25, 1.8), mat("#" + shop_c.lightened(0.15).to_html(false)), Vector3(bcx, 3.55, front + 0.9), world)
			box(Vector3(minf(w * 0.7, 16.0), 1.6, 0.2), mat("#" + shop_c.darkened(0.45).to_html(false)), Vector3(bcx, 4.9, front + 0.1), world, false)
			var lab = Label3D.new()
			lab.text = b["label"]
			lab.font_size = 96
			lab.pixel_size = 0.012
			lab.outline_size = 10
			lab.modulate = Color("#fff3d6")
			lab.outline_modulate = Color(0, 0, 0, 0.6)
			lab.position = Vector3(bcx, 4.9, front + 0.25)
			world.add_child(lab)
	# carros estacionados
	for q in Z["parked"]:
		var pcar = make_simple_car(q["col"], world, Vector3(q["cx"], 0, q["cy"]), q["ang"])
		for ch in pcar.get_children():
			(ch as GeometryInstance3D).visibility_range_end = vis
	# árvores (multimesh)
	var trunks = []
	var leaves = []
	var palms = []
	for tr in Z["trees"]:
		var rad: float = tr["r"]
		if tr.get("palm", false):
			trunks.append(Transform3D(Basis().scaled(Vector3(0.8, 2.6, 0.8)), Vector3(tr["x"], 2.1, tr["y"])))
			palms.append(Transform3D(Basis().scaled(Vector3(2.2, 0.5, 2.2)), Vector3(tr["x"], 4.3, tr["y"])))
		else:
			trunks.append(Transform3D(Basis(), Vector3(tr["x"], 1.05, tr["y"])))
			leaves.append(Transform3D(Basis().scaled(Vector3(rad, rad * 0.85, rad)), Vector3(tr["x"], 1.85 + rad * 0.7, tr["y"])))
	var tm = CylinderMesh.new()
	tm.top_radius = 0.14
	tm.bottom_radius = 0.2
	tm.height = 1.6
	tm.radial_segments = 6
	mm_add(world, tm, mat("#5a4030"), trunks)
	var lm = SphereMesh.new()
	lm.radius = 1.0
	lm.height = 2.0
	lm.radial_segments = 7
	lm.rings = 4
	mm_add(world, lm, mat("#3f7a45"), leaves)
	mm_add(world, lm, mat("#4f8f50"), palms)
	# pontos de interesse: anéis nas portas e bandeiras
	for p in Z["pois"]:
		if p["kind"] == "terr":
			var fx: float = p["x"]
			var fz: float = p["y"]
			cyl(0.08, 0.1, 6.0, mat("#d8d8d8", 0.4, 0.6), Vector3(fx, 3.25, fz), world, 6)
			var cl = box(Vector3(2.4, 1.5, 0.06), mat("#3cc48a") if S["terr"].has(p["id"]) else mat(D.TERRS[p["id"]]["col"]), Vector3(fx + 1.25, 5.4, fz), world)
			flags[p["id"]] = cl
			rings.append(make_ring(Vector3(fx, 0.35, fz), 3.8, 4.2, PURPLE))
		else:
			rings.append(make_ring(Vector3(p["x"], 0.35, p["y"]), 1.2, 1.55, RED if p["kind"] == "heist" else GOLD))


func make_ring(pos: Vector3, r_in: float, r_out: float, col: Color) -> MeshInstance3D:
	var ring = MeshInstance3D.new()
	var tm = TorusMesh.new()
	tm.inner_radius = r_in
	tm.outer_radius = r_out
	tm.rings = 28
	tm.ring_segments = 6
	ring.mesh = tm
	ring.material_override = unshaded(col, 0.7)
	ring.position = pos
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(ring)
	return ring


# =====================================================================
#  ENTRAR / SAIR DE LUGARES
# =====================================================================
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
	civ = []
	peds = []
	if world_int:
		world_int.queue_free()
		world_int = null
	inside = false
	I = {}
	search = {}


func enter_place(id: String) -> void:
	free_entities()
	cur_place = id
	if id == "city":
		Z = make_city()
	else:
		Z = make_small(id)
	blocks_now = Z["blocks"]
	bust = 0.0
	cap = 0.0
	wanted = 0
	lost_t = 0.0
	gang_spawned = {}
	var cd = car_def()
	if float(S["car_hp"]) <= 0:
		S["car_hp"] = round(cd["hp"] * 0.35)
		add_money(-mini(int(S["money"]), 200))
		toast("Carro rebocado e remendado (-$200)", RED)
	if Z["kind"] == "small":
		var door = Z["pois"][0]
		car = {"x": door["x"] + 9.0, "y": Z["ry"][1] + 1.6, "ang": 0.0, "spd": 0.0}
		P["x"] = door["x"]
		P["y"] = door["y"] + 2.5
		P["in_car"] = false
		P["ang"] = -PI / 2
		if id == "home":
			S["car_hp"] = cd["hp"]
		cam_yaw = 0.0
	else:
		car = {"x": 5.0, "y": Z["ry"][1] + 1.9, "ang": 0.0, "spd": 0.0}
		P["in_car"] = true
		P["x"] = car["x"]
		P["y"] = car["y"]
		P["ang"] = 0.0
		cam_yaw = yaw_behind(0.0)
	car["mesh"] = make_car(cd["col"], false)
	add_child(car["mesh"])
	Z["spawn"] = {"x": P["x"], "y": P["y"]}
	build_world()
	lbl_zone.text = Z["name"]
	snap_cam = true
	mode = "play"
	spawn_life()
	refresh_hotbar()
	feed_add("Chegaste a " + Z["name"])
	save_game()


func leave_place() -> void:
	if wanted > 0:
		toast("Escapaste com a polícia atrás!", OK_C)
		add_xp(10 * wanted)
		feed_add("Fuga bem-sucedida", OK_C)
	wanted = 0
	for p in police:
		p["mesh"].queue_free()
	police = []
	save_game()
	open_region()


# =====================================================================
#  VIDA NA CIDADE: TRÂNSITO E PEÕES
# =====================================================================
func spawn_life() -> void:
	civ = []
	peds = []
	var nc = 9 if Z["kind"] == "city" else 3
	var np = 14 if Z["kind"] == "city" else 5
	for i in nc:
		spawn_civ(true)
	for i in np:
		spawn_ped(true)


func road_point_near(min_d: float, max_d: float, horiz: bool) -> Vector2:
	var W: float = Z["w"]
	var H: float = Z["h"]
	for k in 12:
		var v = Vector2.ZERO
		if horiz:
			v.y = Z["ry"][randi() % Z["ry"].size()]
			v.x = clampf(P["x"] + randf_range(-max_d, max_d), 3.0, W - 3.0)
		else:
			v.x = Z["rx"][randi() % Z["rx"].size()]
			v.y = clampf(P["y"] + randf_range(-max_d, max_d), 3.0, minf(H - 3.0, 250.0))
		var d = v.distance_to(Vector2(P["x"], P["y"]))
		if d >= min_d and d <= max_d * 1.5:
			return v
	return Vector2(-1, -1)


func spawn_civ(first: bool) -> void:
	var horiz = randf() < 0.6
	var v = road_point_near(10.0 if first else 55.0, 95.0, horiz)
	if v.x < 0:
		return
	var dir = 1.0 if randf() < 0.5 else -1.0
	var lane: float = float(Z["rw"]) * 0.38
	var c = {"horiz": horiz, "dir": dir, "spd": randf_range(7.0, 11.0), "cur": 0.0, "stop": 0.0}
	if horiz:
		c["x"] = v.x
		c["y"] = v.y + lane * dir
		c["ang"] = 0.0 if dir > 0 else PI
	else:
		c["x"] = v.x - lane * dir
		c["y"] = v.y
		c["ang"] = PI / 2 if dir > 0 else -PI / 2
	c["mesh"] = make_simple_car(["#c9c9c9", "#7a2b2b", "#2b4a7a", "#3a3a3a", "#c9a23a", "#4a6a4a"][randi() % 6], world, Vector3(c["x"], 0, c["y"]), c["ang"])
	civ.append(c)


func spawn_ped(first: bool) -> void:
	var horiz = randf() < 0.55
	var v = road_point_near(8.0 if first else 40.0, 70.0, horiz)
	if v.x < 0:
		return
	var side = 1.0 if randf() < 0.5 else -1.0
	var off: float = float(Z["rw"]) + 1.0
	var p = {"dir": 1.0 if randf() < 0.5 else -1.0, "horiz": horiz, "phase": randf() * 6.0, "spd": randf_range(1.1, 1.6), "dodge": 0.0}
	if horiz:
		p["x"] = v.x
		p["y"] = v.y + side * off
	else:
		p["x"] = v.x + side * off
		p["y"] = v.y
	var shirts = ["#c0392b", "#2e86c1", "#f1c40f", "#8e44ad", "#16a085", "#d35400", "#ecf0f1", "#34495e"]
	var m = make_person(shirts[randi() % shirts.size()], ["#2b3240", "#4a3a2a", "#3a3a3a", "#1f2a44"][randi() % 4], false, ["#2a1d14", "#5a3a1a", "#111111", "#a0784a"][randi() % 4])
	world.add_child(m)
	p["mesh"] = m
	peds.append(p)


func update_life(dt: float) -> void:
	var keep = []
	for c in civ:
		var far = dist(c, P) > 120.0
		if far:
			c["mesh"].queue_free()
			continue
		var fx = cos(c["ang"])
		var fy = sin(c["ang"])
		var blocked = false
		var others = [P]
		if not P["in_car"]:
			others = [P]
		for o in others:
			var dx: float = o["x"] - c["x"]
			var dy: float = o["y"] - c["y"]
			var ahead = dx * fx + dy * fy
			var lat = absf(-dx * fy + dy * fx)
			if ahead > 0 and ahead < 9.0 and lat < 2.4:
				blocked = true
		for o2 in civ:
			if o2 == c:
				continue
			var dx2: float = o2["x"] - c["x"]
			var dy2: float = o2["y"] - c["y"]
			var ah2 = dx2 * fx + dy2 * fy
			if ah2 > 0 and ah2 < 7.0 and absf(-dx2 * fy + dy2 * fx) < 1.6:
				blocked = true
		if c["stop"] > 0:
			c["stop"] = c["stop"] - dt
			blocked = true
		var tgt = 0.0 if blocked else float(c["spd"])
		c["cur"] = c["cur"] + (tgt - c["cur"]) * minf(1.0, dt * (5.0 if blocked else 1.2))
		c["x"] = c["x"] + fx * c["cur"] * dt
		c["y"] = c["y"] + fy * c["cur"] * dt
		if c["x"] < -5 or c["x"] > Z["w"] + 5 or c["y"] < -5 or c["y"] > Z["h"] + 5:
			c["mesh"].queue_free()
			continue
		if P["in_car"] and dist(c, car) < 3.4:
			var d = maxf(0.01, dist(c, car))
			car["x"] = car["x"] + (car["x"] - c["x"]) / d * (3.4 - d) * 0.6
			car["y"] = car["y"] + (car["y"] - c["y"]) / d * (3.4 - d) * 0.6
			car["spd"] = car["spd"] * 0.4
			c["stop"] = 2.0
		var m: Node3D = c["mesh"]
		m.position = Vector3(c["x"], 0, c["y"])
		keep.append(c)
	civ = keep
	var nc = 9 if Z["kind"] == "city" else 3
	if civ.size() < nc and randf() < dt * 2.0:
		spawn_civ(false)
	var pk = []
	for p in peds:
		if dist(p, P) > 85.0:
			p["mesh"].queue_free()
			continue
		var spd: float = p["spd"] * (2.6 if wanted > 0 else 1.0)
		var mv = Vector2(1, 0) if p["horiz"] else Vector2(0, 1)
		mv *= p["dir"]
		# desviar de carros que se aproximam
		if P["in_car"] and dist(p, car) < 6.0 and absf(car["spd"]) > 3.0:
			var away = Vector2(p["x"] - car["x"], p["y"] - car["y"]).normalized()
			p["x"] = p["x"] + away.x * 6.0 * dt
			p["y"] = p["y"] + away.y * 6.0 * dt
		p["x"] = p["x"] + mv.x * spd * dt
		p["y"] = p["y"] + mv.y * spd * dt
		var before = Vector2(p["x"], p["y"])
		push_out(p, 0.4)
		if before.distance_to(Vector2(p["x"], p["y"])) > 0.01:
			p["dir"] = -p["dir"]
		if p["x"] < 2 or p["x"] > Z["w"] - 2 or p["y"] < 2 or p["y"] > minf(Z["h"] - 2, 252.0):
			p["dir"] = -p["dir"]
		p["phase"] = p["phase"] + dt * spd * 4.5
		var m2: Node3D = p["mesh"]
		m2.position = Vector3(p["x"], 0.25, p["y"])
		m2.rotation.y = -mv.angle()
		animate_person(m2, p["phase"], true)
		pk.append(p)
	peds = pk
	var np = 14 if Z["kind"] == "city" else 5
	if peds.size() < np and randf() < dt * 3.0:
		spawn_ped(false)


# =====================================================================
#  INTERIORES
# =====================================================================
func enter_interior(poi: Dictionary) -> void:
	var id: String = poi["id"]
	var h = D.HEISTS[id]
	if int(S["lvl"]) < int(h["lvl"]):
		toast("Precisas de nível %d" % h["lvl"], RED)
		return
	var def = D.INTERIORS[id]
	var w: float = def["w"]
	var d: float = def["d"]
	I = {"id": id, "w": w, "d": d, "blocks": [], "conts": [], "raid": 0.0, "searched": 0, "door": poi, "def": def}
	var th = 0.3
	var wh = 3.4
	I["blocks"].append({"x": -th, "y": -th, "w": w + th * 2, "h": th, "hgt": wh, "wall": true})
	I["blocks"].append({"x": -th, "y": 0.0, "w": th, "h": d, "hgt": wh, "wall": true})
	I["blocks"].append({"x": w, "y": 0.0, "w": th, "h": d, "hgt": wh, "wall": true})
	I["blocks"].append({"x": -th, "y": d, "w": w / 2.0 - 1.2 + th, "h": th, "hgt": wh, "wall": true})
	I["blocks"].append({"x": w / 2.0 + 1.2, "y": d, "w": w / 2.0 - 1.2 + th, "h": th, "hgt": wh, "wall": true})
	for pr in def["props"]:
		I["blocks"].append({"x": pr["x"], "y": pr["y"], "w": pr["w"], "h": pr["h"], "hgt": pr["hh"], "col": pr["col"], "prop": true})
	for c in def["conts"]:
		var cc = c.duplicate(true)
		cc["hgt"] = c["hh"]
		cc["searched"] = false
		cc["items"] = []
		I["conts"].append(cc)
		I["blocks"].append(cc)
	inside = true
	blocks_now = I["blocks"]
	for p in police:
		p["mesh"].queue_free()
	police = []
	world.visible = false
	car["mesh"].visible = false
	build_interior()
	P["x"] = w / 2.0
	P["y"] = d - 1.0
	P["in_car"] = false
	P["ang"] = -PI / 2
	cam_yaw = 0.0
	snap_cam = true
	lbl_zone.text = h["name"] + " · interior"
	feed_add("Entraste em " + h["name"])
	if randf() < float(h["alarm"]) * 0.5:
		trigger_alarm()


func trigger_alarm() -> void:
	if not inside:
		return
	var h = D.HEISTS[I["id"]]
	if wanted == 0:
		wanted = maxi(1, int(h["stars"]) - 1)
		I["raid"] = 0.0
		toast("O alarme disparou! A polícia vem a caminho", RED)
		feed_add("Alarme: " + h["name"], RED)


func raid_time() -> float:
	return 26.0 - float(D.HEISTS[I["id"]]["stars"]) * 3.0


func build_interior() -> void:
	if world_int:
		world_int.queue_free()
	world_int = Node3D.new()
	add_child(world_int)
	var def = I["def"]
	var w: float = I["w"]
	var d: float = I["d"]
	box(Vector3(300, 0.1, 300), mat("#1b1c1f"), Vector3(w / 2.0, -0.12, d / 2.0), world_int, false)
	box(Vector3(w, 0.2, d), mat(def["floor"], 0.7), Vector3(w / 2.0, -0.1, d / 2.0), world_int, false)
	# marcações no chão
	var ln = mat("#d9b84a")
	box(Vector3(w * 0.5, 0.02, 0.12), ln, Vector3(w / 2.0, 0.01, d * 0.55), world_int, false)
	box(Vector3(w * 0.5, 0.02, 0.12), ln, Vector3(w / 2.0, 0.01, d * 0.85), world_int, false)
	# paredes com faixa de cor
	for b in I["blocks"]:
		if b.get("wall", false):
			var cx: float = b["x"] + b["w"] / 2.0
			var cz: float = b["y"] + b["h"] / 2.0
			box(Vector3(b["w"], 1.1, b["h"]), mat(def["stripe"]), Vector3(cx, 0.55, cz), world_int)
			box(Vector3(b["w"], 2.3, b["h"]), mat(def["wall"]), Vector3(cx, 2.25, cz), world_int)
			box(Vector3(b["w"] + 0.05, 0.12, b["h"] + 0.05), mat("#3a3a3a"), Vector3(cx, 3.42, cz), world_int, false)
		elif b.get("prop", false):
			box(Vector3(b["w"], b["hgt"], b["h"]), mat(b["col"], 0.6), Vector3(b["x"] + b["w"] / 2.0, b["hgt"] / 2.0, b["y"] + b["h"] / 2.0), world_int)
	# contentores
	for c in I["conts"]:
		var cx2: float = c["x"] + c["w"] / 2.0
		var cz2: float = c["y"] + c["h"] / 2.0
		var hh: float = c["hgt"]
		box(Vector3(c["w"], hh, c["h"]), mat(c["col"], 0.5, 0.2), Vector3(cx2, hh / 2.0, cz2), world_int)
		box(Vector3(c["w"] * 0.9, 0.05, 0.04), mat("#111111"), Vector3(cx2, hh * 0.6, c["y"] + c["h"] + 0.01), world_int, false)
		box(Vector3(c["w"] * 0.9, 0.05, 0.04), mat("#111111"), Vector3(cx2, hh * 0.3, c["y"] + c["h"] + 0.01), world_int, false)
		box(Vector3(c["w"] + 0.06, 0.06, c["h"] + 0.06), mat("#5a5d63", 0.4, 0.5), Vector3(cx2, hh + 0.03, cz2), world_int, false)
		var lab = Label3D.new()
		lab.text = c["n"]
		lab.font_size = 42
		lab.pixel_size = 0.008
		lab.outline_size = 8
		lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		lab.no_depth_test = true
		lab.modulate = Color("#ffe9a8")
		lab.position = Vector3(cx2, hh + 0.55, cz2)
		world_int.add_child(lab)
		c["label"] = lab
	# luzes de teto (painéis) e iluminação
	var nl = maxi(1, int(w / 7.0))
	for i in nl:
		var lx = (i + 0.5) * w / nl
		box(Vector3(2.2, 0.08, 0.5), unshaded(Color("#fffbe8")), Vector3(lx, 3.3, d * 0.3), world_int, false)
		box(Vector3(2.2, 0.08, 0.5), unshaded(Color("#fffbe8")), Vector3(lx, 3.3, d * 0.7), world_int, false)
	var ol = OmniLight3D.new()
	ol.position = Vector3(w / 2.0, 3.0, d / 2.0)
	ol.omni_range = maxf(w, d) * 0.9
	ol.light_energy = 1.4
	ol.light_color = Color("#fff3dc")
	world_int.add_child(ol)
	# refém (mãos no ar)
	hostage_mesh = make_person("#c9c9c9", "#2b3240", false, "#5a3a1a")
	hostage_mesh.position = Vector3(def["hostage"][0], 0.0, def["hostage"][1])
	hostage_mesh.rotation.y = -PI / 2
	world_int.add_child(hostage_mesh)
	I["blocks"].append({"x": def["hostage"][0] - 0.35, "y": def["hostage"][1] - 0.35, "w": 0.7, "h": 0.7, "hgt": 2.0, "prop": true, "col": "#000000", "hostage": true})
	# saída
	var exm = make_ring(Vector3(w / 2.0, 0.05, d + 0.6), 0.9, 1.2, OK_C)
	exm.reparent(world_int)


func near_cont() -> Dictionary:
	var best = {}
	var bd = 1.5
	for c in I.get("conts", []):
		var cx = clampf(P["x"], c["x"], c["x"] + c["w"])
		var cy = clampf(P["y"], c["y"], c["y"] + c["h"])
		var d = Vector2(P["x"] - cx, P["y"] - cy).length()
		if d < bd:
			bd = d
			best = c
	return best


func start_search(c: Dictionary) -> void:
	search = {"c": c, "t": 0.0}
	if c.get("alarm", false) and randf() < 0.7:
		trigger_alarm()


func finish_search(c: Dictionary) -> void:
	c["searched"] = true
	c["items"] = roll_loot(c["loot"])
	I["searched"] = int(I["searched"]) + 1
	search = {}
	if c.has("label") and is_instance_valid(c["label"]):
		(c["label"] as Label3D).modulate = Color("#8a8a8a")
	open_loot(c)


func roll_loot(table: Array) -> Array:
	var out = []
	for L in table:
		if L.has("cash"):
			var v = randi_range(L["cash"][0], L["cash"][1])
			out.append({"n": "Dinheiro sujo", "kg": maxf(0.1, snappedf(v / 1000.0, 0.01)), "v": v, "dirty": true})
		elif randf() < float(L["ch"]):
			var q = randi_range(L["q"][0], L["q"][1])
			for k in q:
				out.append({"n": L["n"], "kg": L["kg"], "v": L["v"]})
	if out.is_empty():
		out.append({"n": "Trocos", "kg": 0.1, "v": randi_range(10, 40), "dirty": true})
	return out


func exit_interior() -> void:
	var h = D.HEISTS[I["id"]]
	var door = I["door"]
	var searched = int(I["searched"])
	inside = false
	if world_int:
		world_int.queue_free()
		world_int = null
	world.visible = true
	car["mesh"].visible = true
	blocks_now = Z["blocks"]
	P["x"] = door["x"]
	P["y"] = door["y"] + 1.6
	P["ang"] = PI / 2
	cam_yaw = 0.0
	snap_cam = true
	lbl_zone.text = Z["name"]
	if searched > 0:
		S["cds"][I["id"]] = now_ms() + float(h["cd"]) * 1000.0
		S["stats"]["heists"] = int(S["stats"]["heists"]) + 1
		add_xp(h["xp"])
		wanted = mini(5, maxi(wanted, int(h["stars"])))
		lost_t = 0.0
		toast("Assalto concluído — foge!", GOLD)
		feed_add("Assalto: " + h["name"], GOLD)
		var m = S["mission"]
		if not m.is_empty() and m["target"] == I["id"] and not m["done"]:
			m["done"] = true
			toast("Contrato cumprido! Vai ao Bar O Farol", GOLD)
	I = {}
	search = {}
	save_game()


func update_interior(dt: float) -> void:
	var iv = cam_rel(input_vec())
	P["px"] = P["x"]
	P["py"] = P["y"]
	P["x"] = P["x"] + iv.x * 5.0 * dt
	P["y"] = P["y"] + iv.y * 5.0 * dt
	if iv.length() > 0.1 and not firing:
		P["ang"] = atan2(iv.y, iv.x)
	push_out(P, 0.4)
	P["fire_cd"] = P["fire_cd"] - dt
	if firing and P["fire_cd"] <= 0:
		shoot()
		bullets = []
		trigger_alarm()
	if not search.is_empty():
		var c = search["c"]
		if near_cont() == c:
			search["t"] = search["t"] + dt
			if search["t"] >= float(c["time"]):
				finish_search(c)
				return
		else:
			search = {}
			toast("Busca interrompida", RED)
	if wanted > 0:
		I["raid"] = float(I["raid"]) + dt
		if I["raid"] >= raid_time():
			toast("A polícia invadiu o edifício!", RED)
			busted()
			return
	if P["y"] > float(I["d"]) + 0.5:
		exit_interior()
		return
	update_act_button()


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
	if map_btn.get_global_rect().grow(6).has_point(pos) or minimap.get_global_rect().has_point(pos):
		return "map"
	for i in slot_panels.size():
		if slot_panels[i].get_global_rect().grow(4).has_point(pos):
			return "slot%d" % i
	return ""


func _input(e: InputEvent) -> void:
	var touch = DisplayServer.is_touchscreen_available()
	if e is InputEventScreenTouch:
		var st = e as InputEventScreenTouch
		_pointer(st.index, st.position, st.pressed)
	elif e is InputEventScreenDrag:
		var sd = e as InputEventScreenDrag
		_drag(sd.index, sd.position)
	elif e is InputEventMouseButton:
		var mb = e as InputEventMouseButton
		if not touch and mb.button_index == MOUSE_BUTTON_LEFT:
			_pointer(-1, mb.position, mb.pressed)
	elif e is InputEventMouseMotion:
		var mm = e as InputEventMouseMotion
		if not touch:
			_drag(-1, mm.position)
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
				elif k.keycode == KEY_M:
					open_fullmap()
				elif k.keycode == KEY_Q:
					cam_yaw += 0.3
			elif k.keycode == KEY_ESCAPE:
				if mode == "menu":
					close_menu()
				elif mode == "loot":
					close_loot()
				elif mode == "fullmap":
					close_fullmap()
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
		elif h == "map":
			open_fullmap()
		elif h.begins_with("slot"):
			var i = int(h.substr(4))
			if i < S["weapons"].size():
				S["weapon"] = S["weapons"][i]
				refresh_hotbar()
		elif mode == "play":
			var vw = get_viewport().get_visible_rect().size.x
			if joy.is_empty() and pos.x < vw * 0.45:
				joy = {"id": id, "base": pos, "pos": pos}
			elif cam_drag.is_empty() and pos.x >= vw * 0.45:
				cam_drag = {"id": id, "last": pos}
	else:
		if id == fire_touch:
			firing = false
			fire_touch = -99
		if not joy.is_empty() and joy["id"] == id:
			joy = {}
		if not cam_drag.is_empty() and cam_drag["id"] == id:
			cam_drag = {}


func _drag(id: int, pos: Vector2) -> void:
	if not joy.is_empty() and joy["id"] == id:
		joy["pos"] = pos
	if not cam_drag.is_empty() and cam_drag["id"] == id:
		var dx: float = pos.x - cam_drag["last"].x
		cam_yaw -= dx * 0.0075
		cam_drag["last"] = pos


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


func cam_rel(iv: Vector2) -> Vector2:
	## converte o joystick (relativo ao ecrã) para direção no mundo, segundo a câmara
	var c = cos(cam_yaw)
	var s = sin(cam_yaw)
	return Vector2(c * iv.x + s * iv.y, -s * iv.x + c * iv.y)


func yaw_behind(ang: float) -> float:
	return atan2(-cos(ang), -sin(ang))


# =====================================================================
#  CARROS
# =====================================================================
func drive(c: Dictionary, iv: Vector2, dt: float, maxspd: float) -> void:
	var m = iv.length()
	if m > 0.15:
		var ta = atan2(iv.y, iv.x)
		var da = ang_diff(ta, c["ang"])
		var turn = 3.0 * dt * minf(1.0, absf(c["spd"]) / 6.5 + 0.45)
		c["ang"] = c["ang"] + clampf(da, -turn, turn)
		var tgt = maxspd * m * (0.45 if absf(da) > 1.6 else 1.0)
		c["spd"] = c["spd"] + (tgt - c["spd"]) * minf(1.0, dt * 1.6)
	else:
		c["spd"] = c["spd"] * pow(0.12, dt)
	c["x"] = c["x"] + cos(c["ang"]) * c["spd"] * dt
	c["y"] = c["y"] + sin(c["ang"]) * c["spd"] * dt
	if push_out(c, 1.85):
		c["spd"] = c["spd"] * 0.55
	c["x"] = clampf(c["x"], 0.3, Z["w"] - 0.3)
	c["y"] = clampf(c["y"], 0.3, Z["h"] - 0.3)


# =====================================================================
#  AÇÕES
# =====================================================================
func near_poi(r: float) -> Dictionary:
	for p in Z.get("pois", []):
		if p["kind"] != "terr" and dist(P, p) < r:
			return p
	return {}


func ctx_action() -> Dictionary:
	if mode != "play":
		return {}
	if inside:
		var c = near_cont()
		if not c.is_empty():
			if not search.is_empty():
				return {"l": "A VASCULHAR…", "off": true}
			if c["searched"]:
				return {"l": "ABRIR", "f": func(): open_loot(c)}
			return {"l": "VASCULHAR", "f": func(): start_search(c)}
		return {}
	if not P["in_car"]:
		var p = near_poi(4.3)
		if not p.is_empty():
			if p["kind"] == "heist":
				var left = float(S["cds"].get(p["id"], 0)) - now_ms()
				if left > 0:
					return {"l": "FECHADO\n" + mmss(left), "off": true}
				return {"l": "ENTRAR", "f": func(): enter_interior(p)}
			return {"l": "ENTRAR", "f": func(): open_shop(p["id"])}
	if not P["in_car"] and float(S["car_hp"]) > 0 and dist(P, car) < 5.5:
		return {"l": "CONDUZIR", "f": func(): enter_car()}
	if P["in_car"]:
		return {"l": "SAIR", "f": exit_car}
	return {}


func enter_car() -> void:
	P["in_car"] = true
	if cam_drag.is_empty():
		cam_yaw = yaw_behind(car["ang"])


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


func busted() -> void:
	var fine = int(S["money"] * 0.1)
	S["money"] = int(S["money"]) - fine
	S["inv"] = []
	S["stats"]["busted"] = int(S["stats"]["busted"]) + 1
	toast("Foste detido! Perdeste o saque e %s de multa" % fmt(fine), RED)
	feed_add("Foste detido", RED)
	go_home()


func hospital() -> void:
	var fine = int(S["money"] * 0.15)
	S["money"] = int(S["money"]) - fine
	S["inv"] = []
	S["hp"] = 100.0
	S["stats"]["hospital"] = int(S["stats"]["hospital"]) + 1
	toast("Acordaste no hospital. Conta: %s. Saque perdido." % fmt(fine), RED)
	feed_add("Hospital", RED)
	go_home()


func go_home() -> void:
	mode = "travel"
	travel(func(): enter_place("home"))


# =====================================================================
#  COMBATE
# =====================================================================
func fire_bullet(x: float, y: float, a: float, from: String, dmg: float, life: float) -> void:
	bullets.append({"x": x, "y": y, "vx": cos(a) * 52.0, "vy": sin(a) * 52.0, "from": from, "dmg": dmg, "life": life})


func shoot() -> void:
	var w = weapon()
	var tgt = {}
	var best: float = w["range"]
	for tt in police + gang:
		var d = dist(P, tt)
		if d < best:
			best = d
			tgt = tt
	var a: float = P["ang"]
	if not tgt.is_empty():
		a = atan2(tgt["y"] - P["y"], tgt["x"] - P["x"])
	elif not P["in_car"]:
		a = atan2(-cos(cam_yaw), -sin(cam_yaw))
	if not P["in_car"]:
		P["ang"] = a
	for i in int(w["pel"]):
		fire_bullet(P["x"] + cos(a), P["y"] + sin(a), a + randf_range(-w["spr"], w["spr"]), "p", w["dmg"], w["range"] / 52.0)
	P["fire_cd"] = w["rate"]
	for i in 3:
		add_part(P["x"] + cos(a) * 1.1, P["y"] + sin(a) * 1.1, 1.3, cos(a) * randf_range(4, 10), sin(a) * randf_range(4, 10), 0.12, Color("#ffd56a"))
	if not inside and wanted == 0 and gang.is_empty():
		wanted = 1
		lost_t = 0.0
		toast("Tiros ouvidos — polícia a caminho", RED)


func add_part(x: float, y: float, h: float, vx: float, vy: float, life: float, col: Color, vh = 0.0) -> void:
	if parts.size() < part_pool.size():
		parts.append({"x": x, "y": y, "h": h, "vx": vx, "vy": vy, "vh": vh, "life": life, "max": life, "col": col})


func boom(x: float, y: float, col = Color("#ff8a3a"), n = 18) -> void:
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
	var horiz = randf() < 0.5
	var v = road_point_near(40.0, 75.0, horiz)
	if v.x < 0:
		v = road_point_near(20.0, 90.0, not horiz)
	if v.x < 0:
		return
	var m = make_car("#e8ecf2", true)
	add_child(m)
	police.append({"x": v.x, "y": v.y, "ang": atan2(P["y"] - v.y, P["x"] - v.x), "spd": 0.0, "hp": 60.0, "cd": randf_range(0.6, 1.4), "stuck": 0.0, "rev": 0.0, "rd": 1.0, "hit_cd": 0.0, "mesh": m})
	if police.size() == 1:
		feed_add("Polícia a caminho", RED)


func spawn_gang_for(p: Dictionary) -> void:
	var tdef = D.TERRS[p["id"]]
	var n: int = tdef["gang"]
	for k in n:
		var a = float(k) / n * TAU
		var rr = randf_range(6.5, 15.0)
		var gm = make_person("#6a3a8a", "#2a2a33", true, "#111111")
		add_child(gm)
		gang.append({"x": p["x"] + cos(a) * rr, "y": p["y"] + sin(a) * rr, "hp": 40.0, "cd": randf_range(0.5, 1.5), "ang": 0.0, "mesh": gm, "phase": 0.0, "terr": p["id"]})
	gang_spawned[p["id"]] = true
	feed_add("Gangue avistado: " + tdef["name"], PURPLE)


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
		if inside:
			update_interior(dt)
		else:
			update_game(dt)
	if mode != "login" and not Z.is_empty():
		render(dt)
		update_hud()
	overlay.queue_redraw()
	if minimap.visible:
		minimap.queue_redraw()
	save_t += dt
	if save_t > 5.0 and mode != "login":
		save_t = 0.0
		save_game()


func update_game(dt: float) -> void:
	var iv = cam_rel(input_vec())
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
		P["x"] = clampf(P["x"], 0.1, Z["w"] - 0.1)
		P["y"] = clampf(P["y"], 0.1, Z["h"] - 0.1)
	if P["hurt"] > 0:
		P["hurt"] = P["hurt"] - dt
	# saída
	if not Z["armed"] and dist(P, Z["spawn"]) > 11.0:
		Z["armed"] = true
	if Z["armed"] and (P["x"] < 1.0 or P["y"] < 1.0 or P["x"] > Z["w"] - 1.0 or P["y"] > Z["h"] - 1.0):
		leave_place()
		return
	P["fire_cd"] = P["fire_cd"] - dt
	if firing and P["fire_cd"] <= 0:
		shoot()
	update_life(dt)
	# polícia
	var target = [0, 1, 2, 3, 4, 6][wanted]
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
		if d < 35.0:
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
		if d > 160.0:
			p["hp"] = -999.0
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
	var alive = []
	for p in police:
		if p["hp"] <= 0:
			if p["hp"] > -500:
				boom(p["x"], p["y"])
				add_xp(15)
				if wanted < 5:
					wanted += 1
					toast("Abateste uma patrulha — mais calor!", RED)
			p["mesh"].queue_free()
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
					feed_add("Polícia despistada", OK_C)
		else:
			lost_t = 0.0
	# territórios: gangues aparecem quando te aproximas
	for p in Z["pois"]:
		if p["kind"] == "terr" and not S["terr"].has(p["id"]) and not gang_spawned.has(p["id"]) and dist(P, p) < 60.0:
			spawn_gang_for(p)
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
	var galive = []
	var cleared = {}
	for g in gang:
		if g["hp"] <= 0:
			boom(g["x"], g["y"], Color("#b04040"), 10)
			g["mesh"].queue_free()
			add_xp(10)
			cleared[g["terr"]] = true
		else:
			galive.append(g)
	gang = galive
	for tid in cleared.keys():
		var still = false
		for g in gang:
			if g["terr"] == tid:
				still = true
		if not still:
			toast("Gangue eliminado! Fica junto à bandeira para tomar o território", GOLD)
	var capping = false
	for p in Z["pois"]:
		if p["kind"] == "terr" and not S["terr"].has(p["id"]) and gang_spawned.has(p["id"]) and not P["in_car"] and dist(P, p) < 4.3:
			var any = false
			for g in gang:
				if g["terr"] == p["id"]:
					any = true
			if not any:
				capping = true
				cap += dt
				if cap >= 3.0:
					S["terr"][p["id"]] = true
					cap = 0.0
					add_xp(120)
					toast("%s é teu! +%s/min" % [D.TERRS[p["id"]]["name"], fmt(D.TERRS[p["id"]]["income"])], GOLD)
					feed_add("Território tomado: " + D.TERRS[p["id"]]["name"], GOLD)
					if flags.has(p["id"]):
						flags[p["id"]].material_override = mat("#3cc48a")
					save_game()
	if not capping:
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
	var bl = []
	for b in bullets:
		if b["life"] > 0:
			bl.append(b)
	bullets = bl
	if wanted == 0 and float(S["hp"]) < 100:
		S["hp"] = minf(100.0, float(S["hp"]) + 3.0 * dt)
	if float(S["car_hp"]) <= 0 and randf() < 0.3:
		add_part(car["x"] + randf_range(-0.6, 0.6), car["y"] + randf_range(-0.6, 0.6), 1.2, 0, 0, 0.9, Color("#3c3c3c"), 2.5)
	update_act_button()


func update_act_button() -> void:
	var a = ctx_action()
	var lab = a.get("l", "—")
	if lab != last_act:
		last_act = lab
		act_lbl.text = lab
		var on = a.has("f")
		act_panel.add_theme_stylebox_override("panel", circle_style(Color(0.11, 0.12, 0.15, 0.85), GOLD if on else LINE))
		act_lbl.add_theme_color_override("font_color", GOLD if on else DIM)


func update_parts(dt: float) -> void:
	var keep = []
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
#  RENDER 3D + CÂMARA 3ª PESSOA
# =====================================================================
func render(dt: float) -> void:
	update_parts(dt)
	var cd = car_def()
	if car.has("mesh") and not inside:
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
	player_mesh.visible = not P["in_car"]
	if not P["in_car"]:
		var mv = Vector2(P["x"] - P["px"], P["y"] - P["py"]).length() / maxf(dt, 0.001)
		P["phase"] = P["phase"] + mv * dt * 1.7
		player_mesh.position = Vector3(P["x"], 0.25 if not inside else 0.0, P["y"])
		player_mesh.rotation.y = -P["ang"]
		animate_person(player_mesh, P["phase"], mv > 0.5)
	if inside and hostage_mesh and is_instance_valid(hostage_mesh):
		animate_person(hostage_mesh, 0.0, false, true)
	var flash = int(t * 8.0) % 2 == 0
	var near_p = {}
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
	if not near_p.is_empty() and not inside:
		siren.position = Vector3(near_p["x"], 3.0, near_p["y"])
		siren.light_color = Color("#ff3030") if flash else Color("#3060ff")
		siren.light_energy = 3.0
	else:
		siren.light_energy = 0.0
	for g in gang:
		var gm: Node3D = g["mesh"]
		g["phase"] = g["phase"] + (dt * 7.0 if g.get("moving", false) else 0.0)
		gm.position = Vector3(g["x"], 0.25, g["y"])
		gm.rotation.y = -g["ang"]
		animate_person(gm, g["phase"], g.get("moving", false))
	var base_h = 0.0 if inside else 0.25
	for i in bullet_pool.size():
		var bm: MeshInstance3D = bullet_pool[i]
		if i < bullets.size():
			var b = bullets[i]
			bm.visible = true
			bm.position = Vector3(b["x"], 1.3, b["y"])
			bm.rotation.y = -atan2(b["vy"], b["vx"])
		else:
			bm.visible = false
	for i in part_pool.size():
		var pm: MeshInstance3D = part_pool[i]
		if i < parts.size():
			var p = parts[i]
			pm.visible = true
			pm.position = Vector3(p["x"], p["h"] + base_h, p["y"])
			var k: float = clampf(p["life"] / p["max"], 0.2, 1.0)
			pm.scale = Vector3.ONE * (0.5 + k)
			(pm.material_override as StandardMaterial3D).albedo_color = p["col"]
		else:
			pm.visible = false
	var s = 1.0 + sin(t * 4.0) * 0.08
	for rg in rings:
		if is_instance_valid(rg):
			rg.scale = Vector3(s, 1, s)
	for fid in flags.keys():
		flags[fid].rotation.y = sin(t * 3.0 + fid.length()) * 0.12
	# câmara: atrás do jogador; no carro segue a direção
	if P["in_car"] and cam_drag.is_empty() and absf(car["spd"]) > 3.0:
		var ty = yaw_behind(car["ang"] if car["spd"] > 0 else car["ang"] + PI)
		cam_yaw += ang_diff(ty, cam_yaw) * (1.0 - exp(-dt * 2.2))
	var hgt = 3.4
	var dd = 6.2
	var look_h = 1.6
	if P["in_car"]:
		hgt = 4.6
		dd = 9.5
		look_h = 1.3
	if inside:
		hgt = 7.5
		dd = 4.8
		look_h = 0.9
	var tgt = Vector3(P["x"], 0, P["y"])
	if snap_cam:
		cam_t = tgt
	else:
		cam_t = cam_t.lerp(tgt, 1.0 - exp(-dt * 10.0))
	var focus = cam_t + Vector3(0, look_h, 0)
	var want = cam_t + Vector3(sin(cam_yaw) * dd, hgt, cos(cam_yaw) * dd)
	if not inside:
		want = cam_clip(focus, want)
	if snap_cam:
		cam_p = want
		snap_cam = false
	else:
		cam_p = cam_p.lerp(want, 1.0 - exp(-dt * 12.0))
	cam.position = cam_p
	cam.look_at(focus, Vector3.UP)


func cam_clip(from: Vector3, to: Vector3) -> Vector3:
	## aproxima a câmara se houver um prédio entre ela e o jogador
	for i in range(1, 13):
		var q = i / 12.0
		var p = from.lerp(to, q)
		if solid_at(p.x, p.z, p.y):
			return from.lerp(to, maxf(0.2, (i - 1) / 12.0))
	return to


# =====================================================================
#  INTERFACE: HELPERS
# =====================================================================
func lbl(text: String, size = 20, col = Color("#ecebe6")) -> Label:
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func flat(bg: Color, radius = 12, border = LINE, bw = 1) -> StyleBoxFlat:
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
	return flat(bg, 200, border, 3)


func pbar(col: Color, w = 150.0, h = 7.0) -> ProgressBar:
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


func ui_button(text: String, cb: Callable, kind = "", disabled = false) -> Button:
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


func hud_panel(x_anchor: float, x: float, y: float, w: float, h: float) -> PanelContainer:
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", flat(Color(0.08, 0.09, 0.11, 0.78), 8))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(p, x_anchor, 0, x, y, w, h)
	return p


func round_btn(text: String, size: int, col: Color, bg: Color, border: Color) -> Panel:
	var p = Panel.new()
	p.add_theme_stylebox_override("panel", circle_style(bg, border))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l = lbl(text, size, col)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	full(l)
	p.add_child(l)
	return p


# =====================================================================
#  INTERFACE: CONSTRUÇÃO
# =====================================================================
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
	minimap = Control.new()
	place(minimap, 0, 0, 14, 12, 230, 170)
	minimap.clip_contents = true
	minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minimap.draw.connect(_draw_minimap)
	hud.add_child(minimap)
	var mp = hud_panel(0, 254, 12, 150, 46)
	lbl_money = lbl("$0", 24, GOLD)
	mp.add_child(lbl_money)
	hud.add_child(mp)
	var lp = hud_panel(0, 254, 64, 150, 50)
	var lv = VBoxContainer.new()
	lv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl_lvl = lbl("Nível 1", 14, DIM)
	lv.add_child(lbl_lvl)
	bar_xp = pbar(GOLD, 124)
	lv.add_child(bar_xp)
	lp.add_child(lv)
	hud.add_child(lp)
	var rp = hud_panel(1, -340, 12, 200, 66)
	var rv = VBoxContainer.new()
	rv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rv.add_theme_constant_override("separation", 4)
	lbl_bag = lbl("Saco 0/10kg", 14, DIM)
	rv.add_child(lbl_bag)
	bar_hp = pbar(OK_C, 176)
	rv.add_child(bar_hp)
	bar_car = pbar(Color("#4a8fe0"), 176)
	rv.add_child(bar_car)
	rp.add_child(rv)
	hud.add_child(rp)
	map_btn = Panel.new()
	map_btn.add_theme_stylebox_override("panel", flat(Color(0.08, 0.09, 0.11, 0.85), 8))
	map_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(map_btn, 1, 0, -132, 12, 58, 58)
	var mpl = lbl("MAPA", 14)
	mpl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mpl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	full(mpl)
	map_btn.add_child(mpl)
	hud.add_child(map_btn)
	menu_panel = Panel.new()
	menu_panel.add_theme_stylebox_override("panel", flat(Color(0.08, 0.09, 0.11, 0.85), 8))
	menu_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(menu_panel, 1, 0, -68, 12, 58, 58)
	var ml = lbl("≡", 32)
	ml.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ml.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	full(ml)
	menu_panel.add_child(ml)
	hud.add_child(menu_panel)
	lbl_zone = lbl("", 15, DIM)
	lbl_zone.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	place(lbl_zone, 0.5, 0, -250, 96, 500, 22)
	hud.add_child(lbl_zone)
	prog_box = PanelContainer.new()
	prog_box.add_theme_stylebox_override("panel", flat(Color(0.08, 0.09, 0.11, 0.85)))
	prog_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(prog_box, 0.5, 1, -200, -200, 400, 66)
	var pv = VBoxContainer.new()
	pv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prog_lbl = lbl("", 18)
	prog_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pv.add_child(prog_lbl)
	prog_bar = pbar(GOLD, 370, 10)
	pv.add_child(prog_bar)
	prog_box.add_child(pv)
	prog_box.visible = false
	hud.add_child(prog_box)
	feed_box = VBoxContainer.new()
	feed_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feed_box.alignment = BoxContainer.ALIGNMENT_END
	feed_box.add_theme_constant_override("separation", 2)
	place(feed_box, 0, 0.5, 16, -10, 420, 160)
	hud.add_child(feed_box)
	hotbar = HBoxContainer.new()
	hotbar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hotbar.add_theme_constant_override("separation", 8)
	hotbar.alignment = BoxContainer.ALIGNMENT_CENTER
	place(hotbar, 0.5, 1, -260, -88, 520, 72)
	hud.add_child(hotbar)
	fire_panel = round_btn("DISPARAR", 19, Color("#ecebe6"), Color(0.33, 0.1, 0.08, 0.85), Color("#8b2f28"))
	place(fire_panel, 1, 1, -166, -166, 140, 140)
	hud.add_child(fire_panel)
	act_panel = round_btn("—", 16, DIM, Color(0.11, 0.12, 0.15, 0.85), LINE)
	act_lbl = act_panel.get_child(0)
	place(act_panel, 1, 1, -300, -250, 118, 118)
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
	place(toasts, 0.5, 0, -380, 124, 760, 200)
	toasts.alignment = BoxContainer.ALIGNMENT_BEGIN
	ui.add_child(toasts)
	build_region_ui(th)
	build_fullmap_ui(th)
	build_loot_ui(th)
	build_modal_ui(th)
	build_login_ui(th)
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


func dark_bg(parent: Control, a = 0.92) -> void:
	var bg = ColorRect.new()
	bg.color = Color(0.04, 0.045, 0.055, a)
	full(bg)
	parent.add_child(bg)


func header(parent: Control, title: String, close_cb: Callable) -> Label:
	var t1 = lbl(title, 26)
	place(t1, 0, 0, 28, 16, 700, 40)
	parent.add_child(t1)
	var cb = ui_button("Fechar", close_cb)
	place(cb, 1, 0, -160, 12, 140, 46)
	parent.add_child(cb)
	return t1


func build_region_ui(th: Theme) -> void:
	region_ui = Control.new()
	full(region_ui)
	region_ui.theme = th
	dark_bg(region_ui, 1.0)
	var t1 = lbl("REGIÃO DE VILA RUBRA — para onde vais?", 24, GOLD)
	place(t1, 0, 0, 28, 14, 800, 40)
	region_ui.add_child(t1)
	var arc = AspectRatioContainer.new()
	arc.ratio = 2.0
	arc.set_anchors_preset(Control.PRESET_FULL_RECT)
	arc.offset_left = 20
	arc.offset_top = 60
	arc.offset_right = -20
	arc.offset_bottom = -20
	region_ui.add_child(arc)
	region_area = Control.new()
	region_area.draw.connect(_draw_region)
	arc.add_child(region_area)
	for n in D.REGION:
		var b = Button.new()
		b.text = n["name"]
		b.anchor_left = n["x"] / 100.0
		b.anchor_right = n["x"] / 100.0
		b.anchor_top = n["y"] / 100.0
		b.anchor_bottom = n["y"] / 100.0
		b.offset_left = -95
		b.offset_right = 95
		b.offset_top = 22
		b.offset_bottom = 66
		var col = OK_C if n["id"] == "home" else (GOLD if n["id"] == "bar" else RED)
		var s = flat(Color(0.08, 0.09, 0.11, 0.95), 10, col, 2)
		b.add_theme_stylebox_override("normal", s)
		b.add_theme_stylebox_override("hover", s)
		b.add_theme_stylebox_override("pressed", flat(Color(0.15, 0.16, 0.2, 0.95), 10, col, 2))
		b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		b.add_theme_font_size_override("font_size", 20)
		var nid: String = n["id"]
		b.pressed.connect(func(): _region_select(nid))
		region_area.add_child(b)
	region_card = PanelContainer.new()
	region_card.add_theme_stylebox_override("panel", flat(Color(0.1, 0.11, 0.13, 0.97), 14, GOLD, 2))
	place(region_card, 0.5, 1, -260, -230, 520, 200)
	var cv = VBoxContainer.new()
	cv.add_theme_constant_override("separation", 10)
	region_card_title = lbl("", 26, GOLD)
	cv.add_child(region_card_title)
	region_card_desc = lbl("", 17, Color("#cfcbc2"))
	region_card_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	region_card_desc.custom_minimum_size = Vector2(480, 0)
	cv.add_child(region_card_desc)
	var go = ui_button("IR", _region_go, "g")
	go.custom_minimum_size = Vector2(0, 52)
	cv.add_child(go)
	region_card.add_child(cv)
	region_card.visible = false
	region_ui.add_child(region_card)
	region_ui.visible = false
	ui.add_child(region_ui)


func build_fullmap_ui(th: Theme) -> void:
	fullmap_ui = Control.new()
	full(fullmap_ui)
	fullmap_ui.theme = th
	dark_bg(fullmap_ui, 0.96)
	header(fullmap_ui, "VILA RUBRA — toca num ponto para o marcar", close_fullmap)
	var arc = AspectRatioContainer.new()
	arc.ratio = 1.4
	arc.set_anchors_preset(Control.PRESET_FULL_RECT)
	arc.offset_left = 20
	arc.offset_top = 66
	arc.offset_right = -20
	arc.offset_bottom = -14
	fullmap_ui.add_child(arc)
	fullmap_area = Control.new()
	fullmap_area.draw.connect(_draw_fullmap)
	arc.add_child(fullmap_area)
	fullmap_ui.visible = false
	ui.add_child(fullmap_ui)


func build_loot_ui(th: Theme) -> void:
	loot_ui = Control.new()
	full(loot_ui)
	loot_ui.theme = th
	dark_bg(loot_ui, 0.75)
	var hb = HBoxContainer.new()
	hb.add_theme_constant_override("separation", 16)
	hb.set_anchors_preset(Control.PRESET_FULL_RECT)
	hb.offset_left = 30
	hb.offset_top = 24
	hb.offset_right = -30
	hb.offset_bottom = -24
	loot_ui.add_child(hb)
	var left = PanelContainer.new()
	left.add_theme_stylebox_override("panel", flat(Color("#23262d"), 6, Color("#3a3f49"), 1))
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(left)
	var lv = VBoxContainer.new()
	lv.add_theme_constant_override("separation", 10)
	left.add_child(lv)
	var lh = HBoxContainer.new()
	loot_title = lbl("", 24, Color("#ecebe6"))
	loot_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lh.add_child(loot_title)
	loot_info = lbl("", 18, GOLD)
	lh.add_child(loot_info)
	lv.add_child(lh)
	var ls = ScrollContainer.new()
	ls.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lv.add_child(ls)
	loot_grid = GridContainer.new()
	loot_grid.columns = 4
	loot_grid.add_theme_constant_override("h_separation", 6)
	loot_grid.add_theme_constant_override("v_separation", 6)
	ls.add_child(loot_grid)
	var take = ui_button("PEGAR TUDO", _loot_take_all, "g")
	take.custom_minimum_size = Vector2(0, 52)
	lv.add_child(take)
	var right = PanelContainer.new()
	right.add_theme_stylebox_override("panel", flat(Color("#23262d"), 6, Color("#3a3f49"), 1))
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(right)
	var rv = VBoxContainer.new()
	rv.add_theme_constant_override("separation", 10)
	right.add_child(rv)
	var rh = HBoxContainer.new()
	var rt = lbl("SACO", 24)
	rt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rh.add_child(rt)
	loot_bag_info = lbl("", 18, GOLD)
	rh.add_child(loot_bag_info)
	rv.add_child(rh)
	var rs = ScrollContainer.new()
	rs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rv.add_child(rs)
	bag_grid = GridContainer.new()
	bag_grid.columns = 4
	bag_grid.add_theme_constant_override("h_separation", 6)
	bag_grid.add_theme_constant_override("v_separation", 6)
	rs.add_child(bag_grid)
	var close = ui_button("FECHAR", close_loot)
	close.custom_minimum_size = Vector2(0, 52)
	rv.add_child(close)
	loot_ui.visible = false
	ui.add_child(loot_ui)


func build_modal_ui(th: Theme) -> void:
	modal = Control.new()
	full(modal)
	modal.theme = th
	dark_bg(modal, 0.8)
	var pc = PanelContainer.new()
	pc.add_theme_stylebox_override("panel", flat(PANEL, 16, LINE, 1))
	pc.set_anchors_preset(Control.PRESET_FULL_RECT)
	pc.anchor_left = 0.5
	pc.anchor_right = 0.5
	pc.offset_left = -380
	pc.offset_right = 380
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


func build_login_ui(th: Theme) -> void:
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
		enter_place("home")
		toast("Bem-vindo, %s. Conduz até à saída verde para abrir o mapa da região." % S["nick"]))


func travel(cb: Callable) -> void:
	mode = "travel"
	joy = {}
	cam_drag = {}
	firing = false
	travel_ui.visible = true
	await get_tree().create_timer(0.35).timeout
	cb.call()
	travel_ui.visible = false


func toast(text: String, col = LINE) -> void:
	if toasts == null:
		return
	var p = PanelContainer.new()
	p.add_theme_stylebox_override("panel", flat(Color(0.08, 0.09, 0.11, 0.93), 10, col, 2))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var l = lbl(text, 18)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	p.add_child(l)
	toasts.add_child(p)
	while toasts.get_child_count() > 3:
		var c = toasts.get_child(0)
		toasts.remove_child(c)
		c.queue_free()
	var tw = p.create_tween()
	tw.tween_interval(2.6)
	tw.tween_property(p, "modulate:a", 0.0, 0.4)
	tw.tween_callback(p.queue_free)


func feed_add(text: String, col = Color("#e8c46a")) -> void:
	if feed_box == null:
		return
	var tm = Time.get_time_dict_from_system()
	var l = lbl("%02d:%02d  %s" % [tm["hour"], tm["minute"], text], 15, col)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("shadow_offset_x", 1)
	l.add_theme_constant_override("shadow_offset_y", 1)
	feed_box.add_child(l)
	while feed_box.get_child_count() > 6:
		var c = feed_box.get_child(0)
		feed_box.remove_child(c)
		c.queue_free()


func refresh_hotbar() -> void:
	for c in hotbar.get_children():
		hotbar.remove_child(c)
		c.queue_free()
	slot_panels = []
	var i = 0
	for wid in S["weapons"]:
		if i >= 5:
			break
		var w = find_by_id(D.WEAPONS, wid)
		var eq = S["weapon"] == wid
		var p = PanelContainer.new()
		p.custom_minimum_size = Vector2(96, 66)
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.add_theme_stylebox_override("panel", flat(Color(0.18, 0.3, 0.12, 0.9) if eq else Color(0.08, 0.09, 0.11, 0.8), 6, Color("#9ad04a") if eq else LINE, 2 if eq else 1))
		var v = VBoxContainer.new()
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var nm: String = w["name"]
		var short = nm.split(" ")[0] + " " + nm.split(" ")[nm.split(" ").size() - 1]
		var a = lbl(short, 13, Color("#ecebe6"))
		a.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(a)
		var b = lbl(str(i + 1), 12, DIM)
		b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(b)
		p.add_child(v)
		hotbar.add_child(p)
		slot_panels.append(p)
		i += 1


func update_hud() -> void:
	lbl_money.text = fmt(S["money"])
	lbl_lvl.text = "Nível %d · %d/%d" % [S["lvl"], int(S["xp"]), xp_need(int(S["lvl"]))]
	bar_xp.value = 100.0 * float(S["xp"]) / xp_need(int(S["lvl"]))
	bar_hp.value = float(S["hp"])
	bar_car.value = 100.0 * float(S["car_hp"]) / float(car_def()["hp"])
	lbl_bag.text = "Saco %.1f/%dkg · %s" % [inv_kg(), bag_def()["cap"], fmt(inv_value())]
	var st = (prog_bar.get_theme_stylebox("fill") as StyleBoxFlat)
	if not search.is_empty():
		prog_box.visible = true
		prog_lbl.text = "A VASCULHAR: " + str(search["c"]["n"]).to_upper()
		prog_bar.value = 100.0 * search["t"] / float(search["c"]["time"])
		st.bg_color = Color("#ecebe6")
	elif inside and wanted > 0:
		prog_box.visible = true
		var left = raid_time() - float(I["raid"])
		prog_lbl.text = "POLÍCIA A CHEGAR — %ds" % int(ceil(left))
		prog_bar.value = 100.0 * float(I["raid"]) / raid_time()
		st.bg_color = RED
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


# =====================================================================
#  OVERLAY: BÚSSOLA, ESTRELAS, SETA GPS, JOYSTICK
# =====================================================================
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
	var font = ThemeDB.fallback_font
	if wanted > 0 and mode == "play":
		var c = Color(0.88, 0.24, 0.24) if int(t * 3) % 2 == 0 else Color(0.24, 0.43, 0.88)
		for i in 6:
			var a = 0.2 * (1.0 - i / 6.0)
			overlay.draw_rect(Rect2(Vector2(i * 9, i * 9), vs - Vector2(i * 18, i * 18)), Color(c.r, c.g, c.b, a), false, 9.0)
	# bússola
	var cx = vs.x / 2.0
	var heading = fposmod(-rad_to_deg(cam_yaw), 360.0)
	var cw = 420.0
	overlay.draw_rect(Rect2(cx - cw / 2.0, 10, cw, 30), Color(0.05, 0.06, 0.07, 0.55))
	var names = {0: "N", 45: "NE", 90: "E", 135: "SE", 180: "S", 225: "SO", 270: "O", 315: "NO"}
	for deg in range(0, 360, 15):
		var dd = ang_diff(deg_to_rad(float(deg)), deg_to_rad(heading))
		var x = cx + rad_to_deg(dd) * 3.2
		if absf(x - cx) > cw / 2.0 - 10:
			continue
		if names.has(deg):
			var big = deg % 90 == 0
			overlay.draw_string(font, Vector2(x - 20, 32), names[deg], HORIZONTAL_ALIGNMENT_CENTER, 40, 18 if big else 14, Color("#ffffff") if big else Color("#c9c9c9"))
		else:
			overlay.draw_line(Vector2(x, 20), Vector2(x, 30), Color(1, 1, 1, 0.5), 1.5)
	overlay.draw_line(Vector2(cx, 6), Vector2(cx, 14), GOLD, 3.0)
	# objetivo (waypoint) na bússola
	if not waypoint.is_empty() and not inside:
		var wa = atan2(waypoint["x"] - P["x"], -(waypoint["y"] - P["y"]))
		var wd = ang_diff(wa, deg_to_rad(heading))
		var wx = cx + clampf(rad_to_deg(wd) * 3.2, -cw / 2.0 + 8, cw / 2.0 - 8)
		overlay.draw_circle(Vector2(wx, 44), 5.0, GOLD)
	# estrelas
	var sx = cx - 2.0 * 34.0
	for i in 5:
		var on = i < wanted
		var col = (RED if int(t * 3) % 2 == 0 else GOLD) if on else Color(0.27, 0.29, 0.33, 0.8)
		overlay.draw_colored_polygon(star_pts(Vector2(sx + i * 34.0 + 2, 72.0), 13.0), Color(0, 0, 0, 0.5))
		overlay.draw_colored_polygon(star_pts(Vector2(sx + i * 34.0, 70.0), 13.0), col)
	if mode != "play":
		return
	# seta para o destino marcado
	if not waypoint.is_empty() and not inside:
		var gp = Vector3(waypoint["x"], 1.0, waypoint["y"])
		var sp = cam.unproject_position(gp)
		var behind = cam.is_position_behind(gp)
		if behind or sp.x < 0 or sp.y < 0 or sp.x > vs.x or sp.y > vs.y:
			var dir = (sp - vs / 2.0).normalized()
			if behind:
				dir = -dir
			var R = minf(vs.x, vs.y) * 0.36
			var ap = vs / 2.0 + dir * R
			var ang = dir.angle()
			var tri = PackedVector2Array([ap + Vector2(20, 0).rotated(ang), ap + Vector2(-10, -13).rotated(ang), ap + Vector2(-10, 13).rotated(ang)])
			overlay.draw_colored_polygon(tri, GOLD)
		else:
			overlay.draw_circle(sp, 8.0, GOLD)
			overlay.draw_string(font, sp + Vector2(-60, -14), "%dm" % int(dist(P, waypoint)), HORIZONTAL_ALIGNMENT_CENTER, 120, 16, GOLD)
	if not joy.is_empty():
		var base: Vector2 = joy["base"]
		var d: Vector2 = joy["pos"] - base
		if d.length() > 80.0:
			d = d.normalized() * 80.0
		overlay.draw_arc(base, 80.0, 0, TAU, 40, Color(1, 1, 1, 0.45), 3.0)
		overlay.draw_circle(base + d, 32.0, Color(1, 1, 1, 0.45))


# =====================================================================
#  MINIMAPA E MAPA COMPLETO
# =====================================================================
func _map_draw_world(ctl: Control, to_scr: Callable, s: float, view: Rect2) -> void:
	var rw: float = Z["rw"]
	ctl.draw_rect(Rect2(Vector2.ZERO, ctl.size), Color("#28322a"))
	for l in Z["lots"]:
		var r = Rect2(to_scr.call(Vector2(l["x"], l["y"])), Vector2(l["w"], l["h"]) * s)
		ctl.draw_rect(r, Color("#c9b27e") if l["kind"] == "beach" else Color("#3a4a3c"))
	for wtr in Z["water"]:
		ctl.draw_rect(Rect2(to_scr.call(Vector2(wtr["x"], wtr["y"])), Vector2(wtr["w"], wtr["h"]) * s), Color("#1f5a7a"))
	var vmax = 254.0 if Z["kind"] == "city" else float(Z["h"])
	for y in Z["ry"]:
		ctl.draw_rect(Rect2(to_scr.call(Vector2(0, y - rw)), Vector2(Z["w"], rw * 2) * s), Color("#8e939c"))
	for x in Z["rx"]:
		ctl.draw_rect(Rect2(to_scr.call(Vector2(x - rw, 0)), Vector2(rw * 2, vmax) * s), Color("#8e939c"))
	for b in Z["blocks"]:
		if b.get("water", false) or b.get("car", false):
			continue
		if not view.intersects(Rect2(b["x"], b["y"], b["w"], b["h"])):
			continue
		var col = Color("#56606e")
		if b.get("main", false):
			col = Color("#7a6a52")
		elif b.get("crate", false):
			col = Color("#6a5a3a")
		ctl.draw_rect(Rect2(to_scr.call(Vector2(b["x"], b["y"])), Vector2(b["w"], b["h"]) * s), col)


func _draw_icon(ctl: Control, pos: Vector2, id: String, r: float) -> void:
	var ic = D.ICONS.get(id, ["?", "#ffffff"])
	var col = Color(ic[1])
	if D.TERRS.has(id) and S["terr"].has(id):
		col = OK_C
	if D.HEISTS.has(id) and float(S["cds"].get(id, 0)) > now_ms():
		col = Color("#666a70")
	ctl.draw_circle(pos, r + 2.0, Color(0, 0, 0, 0.7))
	ctl.draw_circle(pos, r, col)
	ctl.draw_string(ThemeDB.fallback_font, pos + Vector2(-r, r * 0.45), ic[0], HORIZONTAL_ALIGNMENT_CENTER, r * 2, int(r * 1.2), Color("#111111"))


func _draw_player_arrow(ctl: Control, pos: Vector2, ang: float, sz: float) -> void:
	var tri = PackedVector2Array([pos + Vector2(sz, 0).rotated(ang), pos + Vector2(-sz * 0.7, -sz * 0.65).rotated(ang), pos + Vector2(-sz * 0.4, 0).rotated(ang), pos + Vector2(-sz * 0.7, sz * 0.65).rotated(ang)])
	ctl.draw_colored_polygon(tri, Color("#b8f04a"))
	ctl.draw_polyline(PackedVector2Array([tri[0], tri[1], tri[2], tri[3], tri[0]]), Color(0, 0, 0, 0.8), 1.5)


func _draw_minimap() -> void:
	if Z.is_empty() or mode == "login":
		return
	var sz = minimap.size
	if inside:
		minimap.draw_rect(Rect2(Vector2.ZERO, sz), Color("#1b1c1f"))
		var s2 = minf((sz.x - 20) / float(I["w"]), (sz.y - 20) / float(I["d"]))
		var o = (sz - Vector2(I["w"], I["d"]) * s2) / 2.0
		minimap.draw_rect(Rect2(o, Vector2(I["w"], I["d"]) * s2), Color("#4a4740"))
		for c in I["conts"]:
			minimap.draw_rect(Rect2(o + Vector2(c["x"], c["y"]) * s2, Vector2(c["w"], c["h"]) * s2), Color("#666666") if c["searched"] else GOLD)
		_draw_player_arrow(minimap, o + Vector2(P["x"], P["y"]) * s2, P["ang"], 9.0)
	else:
		var s = 1.25
		var center = sz / 2.0
		var pp = Vector2(P["x"], P["y"])
		var to_scr = func(v: Vector2) -> Vector2: return center + (v - pp) * s
		var view = Rect2(pp - center / s, sz / s)
		_map_draw_world(minimap, to_scr, s, view)
		for p in Z["pois"]:
			var sp = to_scr.call(Vector2(p["x"], p["y"]))
			if Rect2(Vector2(-10, -10), sz + Vector2(20, 20)).has_point(sp):
				_draw_icon(minimap, sp, p["id"], 8.0)
		for p in police:
			minimap.draw_circle(to_scr.call(Vector2(p["x"], p["y"])), 4.5, RED if int(t * 6) % 2 == 0 else Color("#3a6aff"))
		for g in gang:
			minimap.draw_circle(to_scr.call(Vector2(g["x"], g["y"])), 3.0, PURPLE)
		if not waypoint.is_empty():
			var wp = to_scr.call(Vector2(waypoint["x"], waypoint["y"]))
			wp = Vector2(clampf(wp.x, 6, sz.x - 6), clampf(wp.y, 6, sz.y - 6))
			minimap.draw_circle(wp, 6.0, GOLD)
		_draw_player_arrow(minimap, center, P["ang"], 10.0)
	minimap.draw_rect(Rect2(Vector2.ZERO, sz), Color(0, 0, 0, 0.9), false, 3.0)


func open_fullmap() -> void:
	if Z.is_empty() or inside:
		return
	mode = "fullmap"
	joy = {}
	cam_drag = {}
	firing = false
	for c in fullmap_area.get_children():
		c.queue_free()
	for p in Z["pois"]:
		var b = Button.new()
		b.flat = true
		b.anchor_left = p["x"] / float(Z["w"])
		b.anchor_right = b.anchor_left
		b.anchor_top = p["y"] / float(Z["h"])
		b.anchor_bottom = b.anchor_top
		b.offset_left = -26
		b.offset_right = 26
		b.offset_top = -26
		b.offset_bottom = 26
		b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		var pid: String = p["id"]
		b.pressed.connect(func(): _fullmap_pick(pid))
		fullmap_area.add_child(b)
	fullmap_ui.visible = true
	fullmap_area.queue_redraw()


func _fullmap_pick(id: String) -> void:
	var p = find_poi(id)
	if p.is_empty():
		return
	if not waypoint.is_empty() and waypoint["id"] == id:
		waypoint = {}
		toast("Destino removido")
	else:
		waypoint = {"id": id, "x": p["x"], "y": p["y"]}
		toast("Destino marcado: " + p["name"], GOLD)
	fullmap_area.queue_redraw()


func close_fullmap() -> void:
	fullmap_ui.visible = false
	if mode == "fullmap":
		mode = "play"


func _draw_fullmap() -> void:
	if Z.is_empty():
		return
	var sz = fullmap_area.size
	var s = sz.x / float(Z["w"])
	var to_scr = func(v: Vector2) -> Vector2: return v * s
	_map_draw_world(fullmap_area, to_scr, s, Rect2(0, 0, Z["w"], Z["h"]))
	var font = ThemeDB.fallback_font
	if Z["kind"] == "city":
		for d in D.DISTRICTS:
			fullmap_area.draw_string(font, Vector2(d["x"], d["y"]) * s + Vector2(-150, 0), d["name"], HORIZONTAL_ALIGNMENT_CENTER, 300, 20, Color(1, 1, 1, 0.35))
	for p in Z["pois"]:
		var sp = to_scr.call(Vector2(p["x"], p["y"]))
		_draw_icon(fullmap_area, sp, p["id"], 13.0)
		var sub = p["name"]
		if D.HEISTS.has(p["id"]):
			var left = float(S["cds"].get(p["id"], 0)) - now_ms()
			if left > 0:
				sub += " · " + mmss(left)
			elif int(S["lvl"]) < int(D.HEISTS[p["id"]]["lvl"]):
				sub += " · nível %d" % D.HEISTS[p["id"]]["lvl"]
		fullmap_area.draw_string(font, sp + Vector2(-110, 30), sub, HORIZONTAL_ALIGNMENT_CENTER, 220, 14, Color("#ecebe6"))
		if not waypoint.is_empty() and waypoint["id"] == p["id"]:
			fullmap_area.draw_arc(sp, 20.0, 0, TAU, 32, GOLD, 3.0)
	for p in police:
		fullmap_area.draw_circle(to_scr.call(Vector2(p["x"], p["y"])), 5.0, RED)
	_draw_player_arrow(fullmap_area, to_scr.call(Vector2(P["x"], P["y"])), P["ang"], 13.0)


# =====================================================================
#  MAPA DA REGIÃO
# =====================================================================
func open_region() -> void:
	mode = "map"
	joy = {}
	cam_drag = {}
	firing = false
	region_pick = ""
	region_card.visible = false
	region_ui.visible = true
	region_area.queue_redraw()


func _region_select(id: String) -> void:
	region_pick = id
	for n in D.REGION:
		if n["id"] == id:
			region_card_title.text = n["name"]
			region_card_desc.text = n["desc"]
	region_card.visible = true
	region_area.queue_redraw()


func _region_go() -> void:
	if region_pick == "":
		return
	region_ui.visible = false
	var id = region_pick
	travel(func(): enter_place(id))


func _draw_region() -> void:
	var s = region_area.size
	var c = region_area
	c.draw_rect(Rect2(Vector2.ZERO, s), Color("#1f5a7a"))
	# terra (costa irregular)
	var land = PackedVector2Array()
	for i in 25:
		var x = s.x * i / 24.0
		var y = s.y * (0.86 + 0.05 * sin(i * 1.3) + 0.03 * sin(i * 3.1))
		land.append(Vector2(x, y))
	land.append(Vector2(s.x, 0))
	land.append(Vector2(0, 0))
	c.draw_colored_polygon(land, Color("#3d5a3a"))
	for i in 14:
		var hx = s.x * fposmod(i * 0.37, 1.0)
		var hy = s.y * (0.1 + fposmod(i * 0.23, 0.6))
		c.draw_circle(Vector2(hx, hy), s.y * (0.05 + fposmod(i * 0.07, 0.06)), Color("#4a6a44"))
	# estradas entre os lugares
	var pts = {}
	for n in D.REGION:
		pts[n["id"]] = Vector2(s.x * n["x"] / 100.0, s.y * n["y"] / 100.0)
	for pair in [["home", "city"], ["home", "bar"], ["bar", "city"]]:
		var a = pts[pair[0]]
		var b = pts[pair[1]]
		var mid = (a + b) / 2.0 + Vector2(0, -s.y * 0.08)
		var line = PackedVector2Array()
		for i in 21:
			var q = i / 20.0
			line.append(a.lerp(mid, q).lerp(mid.lerp(b, q), q))
		c.draw_polyline(line, Color("#2a2a2a"), 10.0, true)
		c.draw_polyline(line, Color("#8e939c"), 6.0, true)
	# cidade (bloco de prédios)
	var cp = pts["city"]
	for i in 30:
		var bx = cp.x + (fposmod(i * 0.61, 1.0) - 0.5) * s.x * 0.22
		var by = cp.y + (fposmod(i * 0.37, 1.0) - 0.5) * s.y * 0.25
		c.draw_rect(Rect2(bx, by, 14 + (i % 4) * 6, 14 + (i % 3) * 7), Color("#7a828e"))
	for n in D.REGION:
		var p = pts[n["id"]]
		var col = OK_C if n["id"] == "home" else (GOLD if n["id"] == "bar" else RED)
		c.draw_circle(p, 18.0, Color(0, 0, 0, 0.6))
		c.draw_circle(p, 14.0, col)
		if n["id"] == region_pick:
			c.draw_arc(p, 24.0, 0, TAU, 32, Color.WHITE, 3.0)
	if cur_place != "" and pts.has(cur_place):
		_draw_player_arrow(c, pts[cur_place] + Vector2(0, -34), PI / 2, 12.0)


# =====================================================================
#  JANELA DE SAQUE (inventário em grelha)
# =====================================================================
func item_tile(it: Dictionary, cb: Callable) -> Button:
	var b = Button.new()
	b.custom_minimum_size = Vector2(118, 96)
	var v = int(it["v"])
	var bg = rarity_col(v)
	var s = flat(bg, 4, bg.lightened(0.25), 1)
	s.content_margin_left = 4
	s.content_margin_right = 4
	b.add_theme_stylebox_override("normal", s)
	b.add_theme_stylebox_override("hover", s)
	b.add_theme_stylebox_override("pressed", flat(bg.lightened(0.15), 4, GOLD, 2))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_font_size_override("font_size", 13)
	var nm: String = it["n"]
	if nm.length() > 16:
		nm = nm.substr(0, 15) + "…"
	b.text = "%s\n%.1fkg\n%s" % [nm, float(it["kg"]), fmt(v)]
	b.clip_text = true
	b.pressed.connect(cb)
	return b


func open_loot(c: Dictionary) -> void:
	mode = "loot"
	joy = {}
	cam_drag = {}
	firing = false
	loot_c = c
	refresh_loot()
	loot_ui.visible = true


func refresh_loot() -> void:
	for ch in loot_grid.get_children():
		loot_grid.remove_child(ch)
		ch.queue_free()
	for ch in bag_grid.get_children():
		bag_grid.remove_child(ch)
		ch.queue_free()
	if loot_c.is_empty():
		return
	loot_title.text = str(loot_c["n"]).to_upper()
	var tot = 0
	var items: Array = loot_c["items"]
	for i in items.size():
		var idx = i
		tot += int(items[i]["v"])
		loot_grid.add_child(item_tile(items[i], func(): _loot_take(idx)))
	if items.is_empty():
		loot_grid.add_child(lbl("Vazio", 18, DIM))
	loot_info.text = fmt(tot)
	for it in S["inv"]:
		bag_grid.add_child(item_tile(it, func(): pass))
	loot_bag_info.text = "%.1f/%dkg · %s" % [inv_kg(), bag_def()["cap"], fmt(inv_value())]


func _loot_take(idx: int) -> void:
	var items: Array = loot_c["items"]
	if idx >= items.size():
		return
	var it = items[idx]
	if inv_kg() + float(it["kg"]) > float(bag_def()["cap"]):
		toast("Saco cheio! Compra um saco maior no Armeiro", RED)
		return
	S["inv"].append(it)
	items.remove_at(idx)
	refresh_loot()


func _loot_take_all() -> void:
	if loot_c.is_empty():
		return
	var items: Array = loot_c["items"]
	var left = []
	var full_bag = false
	for it in items:
		if inv_kg() + float(it["kg"]) <= float(bag_def()["cap"]):
			S["inv"].append(it)
		else:
			left.append(it)
			full_bag = true
	loot_c["items"] = left
	if full_bag:
		toast("Saco cheio — ficaram itens para trás", RED)
	refresh_loot()


func close_loot() -> void:
	loot_ui.visible = false
	loot_c = {}
	if mode == "loot":
		mode = "play"
	save_game()


# =====================================================================
#  MENUS (lojas, bar, esconderijo)
# =====================================================================
func open_menu(title: String, render_fn: Callable) -> void:
	mode = "menu"
	joy = {}
	cam_drag = {}
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
	refresh_hotbar()
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


func note(box: VBoxContainer, text: String, italic = false) -> void:
	var l = lbl(text, 17, DIM)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if italic:
		l.add_theme_color_override("font_color", Color("#b9b6ad"))
	box.add_child(l)


func row(box: VBoxContainer, title: String, sub: String, btext: String, cb: Callable, kind = "", disabled = false) -> void:
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
	box.add_child(HSeparator.new())


func big_button(box: VBoxContainer, text: String, cb: Callable, kind = "", disabled = false) -> void:
	var b = ui_button(text, act(cb), kind, disabled)
	b.custom_minimum_size = Vector2(0, 54)
	box.add_child(b)


func group_inv() -> Array:
	var m = {}
	var order = []
	for i in S["inv"]:
		var k: String = i["n"]
		if not m.has(k):
			m[k] = {"n": k, "c": 0, "v": 0, "kg": 0.0, "dirty": i.get("dirty", false)}
			order.append(k)
		m[k]["c"] += 1
		m[k]["v"] += int(i["v"])
		m[k]["kg"] += float(i["kg"])
	var out = []
	for k in order:
		out.append(m[k])
	return out


func sell_val(g: Dictionary) -> int:
	return int(floor(g["v"] * (0.8 if g["dirty"] else 1.0) * terr_bonus()))


func remove_items(name: String) -> void:
	var keep = []
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
			feed_add("Vendeste saque: +" + fmt(tot), GOLD)
			toast("Vendeste tudo: +" + fmt(tot), GOLD), "g")
		if S["terr"].size() > 0:
			note(box, "Bónus de território: +%d%% no preço" % int(round((terr_bonus() - 1.0) * 100)))
	h3(box, "Contrato")
	var m = S["mission"]
	if m.is_empty():
		note(box, "O Zé tem sempre trabalho para quem não faz perguntas.")
		big_button(box, "Pedir contrato", func():
			var opts = []
			for k in D.HEISTS.keys():
				if D.HEISTS[k]["lvl"] <= int(S["lvl"]):
					opts.append(k)
			var tg: String = opts[randi() % opts.size()]
			var hh = D.HEISTS[tg]
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
	var st = S["stats"]
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
		h3(box, "Controlos")
		note(box, "Esquerda: mover · Arrastar à direita: rodar a câmara · Toca no minimapa para o mapa da cidade.\nPara sair de um lugar, vai até uma saída verde na borda.")
		h3(box, "Jogo")
		note(box, "Jogador: %s · conteúdo %s" % [S["nick"], content_version])
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
