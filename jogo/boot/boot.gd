extends Control
## Arranque: procura atualizações nos Releases do GitHub, descarrega o pacote de conteúdo
## (game.pck) se houver versão nova e só depois abre o jogo. Tudo automático.

const BASE := "https://github.com/rezyto/golpe/releases/download/latest/"
const PCK := "user://game.pck"
const PCK_NEW := "user://game_new.pck"
const PCK_VER := "user://content_version.txt"
const PENDING := "user://boot_pending.txt"   # existe enquanto um pacote novo ainda não arrancou bem
const BAD_VER := "user://bad_version.txt"    # versão que falhou ao arrancar (não volta a ser descarregada)
const STALL_S := 25.0                         # sem bytes novos durante isto => desiste

var http: HTTPRequest
var status: Label
var bar: ProgressBar
var app_btn: Button
var app_version := "0.0.0"
var builtin_version := "0.0.0"
var downloading := false
var remote_content := ""
var remote_size := 0
var remote_sha := ""
var last_bytes := 0
var stall_t := 0.0


func _ready() -> void:
	app_version = _read("res://boot/app_version.txt", "0.0.0")
	builtin_version = _read("res://game/content_version.txt", "0.0.0")
	_build_ui()
	if OS.has_feature("editor"):
		# No editor corre sempre o código local (sem descarregar nem carregar PCK).
		Engine.set_meta("content_version", builtin_version + "-dev")
		Engine.set_meta("app_version", app_version)
		get_tree().change_scene_to_file.call_deferred("res://game/main.tscn")
		return
	_check_previous_boot()
	http = HTTPRequest.new()
	http.timeout = 10.0
	http.use_threads = true
	add_child(http)
	http.request_completed.connect(_on_version)
	var err := http.request(BASE + "version3.json?t=%d" % int(Time.get_unix_time_from_system()))
	if err != OK:
		_start_game("")


func _process(delta: float) -> void:
	if downloading:
		var total := http.get_body_size()
		var got := http.get_downloaded_bytes()
		if got != last_bytes:
			last_bytes = got
			stall_t = 0.0
		else:
			stall_t += delta
			if stall_t > STALL_S:
				downloading = false
				http.cancel_request()
				DirAccess.remove_absolute(ProjectSettings.globalize_path(PCK_NEW))
				_start_game("Sem rede estável — a jogar a versão atual")
				return
		if total > 0:
			bar.value = 100.0 * got / total
			status.text = "A atualizar… %d%%" % int(bar.value)


func _build_ui() -> void:
	var th := Theme.new()
	th.default_font_size = 22
	theme = th
	var bg := ColorRect.new()
	bg.color = Color("#14161b")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	center.add_child(v)
	var title := Label.new()
	title.text = "GOLPE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 110)
	title.add_theme_color_override("font_color", Color("#e8b931"))
	title.add_theme_color_override("font_shadow_color", Color("#6b1f1a"))
	title.add_theme_constant_override("shadow_offset_x", 6)
	title.add_theme_constant_override("shadow_offset_y", 6)
	v.add_child(title)
	status = Label.new()
	status.text = ""
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_color_override("font_color", Color("#9a9ca3"))
	v.add_child(status)
	bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(420, 14)
	bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("#e8b931")
	fill.set_corner_radius_all(7)
	var back := StyleBoxFlat.new()
	back.bg_color = Color("#2b2f37")
	back.set_corner_radius_all(7)
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", back)
	v.add_child(bar)
	app_btn = Button.new()
	app_btn.visible = false
	app_btn.pressed.connect(func(): OS.shell_open(BASE + "golpe.apk"))
	v.add_child(app_btn)
	var ver := Label.new()
	ver.text = "app %s · conteúdo %s" % [app_version, _installed_version()]
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ver.add_theme_font_size_override("font_size", 15)
	ver.add_theme_color_override("font_color", Color("#5d616b"))


func _on_version(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	http.request_completed.disconnect(_on_version)
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_start_game("")
		return
	var j = JSON.parse_string(body.get_string_from_utf8())
	if typeof(j) != TYPE_DICTIONARY or not j.has("content"):
		_start_game("")
		return
	if j.has("app") and _cmp(str(j["app"]), app_version) > 0:
		app_btn.text = "Nova app %s disponível — descarregar" % str(j["app"])
		app_btn.visible = true
	remote_content = str(j["content"])
	remote_size = int(j.get("size", 0))
	remote_sha = str(j.get("sha256", ""))
	if j.has("min_app") and _cmp(app_version, str(j["min_app"])) < 0:
		# o conteúdo novo precisa de uma app mais recente: não o carrega
		app_btn.visible = true
		_start_game("Atualiza a app para receber o conteúdo novo")
		return
	if remote_content == _read(BAD_VER, ""):
		_start_game("")
		return
	if _cmp(remote_content, _installed_version()) > 0:
		status.text = "A atualizar…"
		http.download_file = PCK_NEW
		http.timeout = 0.0  # sem limite total; o vigia de bloqueio em _process trata das redes lentas
		http.request_completed.connect(_on_pck)
		downloading = true
		last_bytes = 0
		stall_t = 0.0
		var err := http.request(BASE + "game3.pck")
		if err != OK:
			downloading = false
			_start_game("")
	else:
		bar.value = 100
		_start_game("")


func _on_pck(result: int, code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	downloading = false
	if result == HTTPRequest.RESULT_SUCCESS and code == 200 and FileAccess.file_exists(PCK_NEW) and _pck_ok():
		var a := ProjectSettings.globalize_path(PCK)
		var b := ProjectSettings.globalize_path(PCK_NEW)
		if FileAccess.file_exists(PCK):
			DirAccess.remove_absolute(a)
		DirAccess.rename_absolute(b, a)
		var f := FileAccess.open(PCK_VER, FileAccess.WRITE)
		if f:
			f.store_string(remote_content)
			f.close()
		bar.value = 100
		_start_game("")
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PCK_NEW))
		_start_game("")


func _pck_ok() -> bool:
	var f := FileAccess.open(PCK_NEW, FileAccess.READ)
	if f == null:
		return false
	var n := f.get_length()
	f.close()
	if remote_size > 0 and n != remote_size:
		return false
	if remote_sha != "" and FileAccess.get_sha256(PCK_NEW) != remote_sha:
		return false
	return n > 0


func _check_previous_boot() -> void:
	## Se o último arranque com um pacote novo não chegou ao jogo, volta à versão de fábrica.
	if FileAccess.file_exists(PENDING):
		var v := _read(PENDING, "")
		var f := FileAccess.open(BAD_VER, FileAccess.WRITE)
		if f:
			f.store_string(v)
			f.close()
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PCK))
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PCK_VER))
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PENDING))


func _installed_version() -> String:
	if FileAccess.file_exists(PCK) and FileAccess.file_exists(PCK_VER):
		var v := _read(PCK_VER, "0.0.0")
		if _cmp(v, builtin_version) > 0:
			return v
	return builtin_version


func _start_game(msg: String) -> void:
	if msg != "":
		status.text = msg
	var v := _installed_version()
	if v != builtin_version and FileAccess.file_exists(PCK):
		if not ProjectSettings.load_resource_pack(PCK, true):
			v = builtin_version
		else:
			var f := FileAccess.open(PENDING, FileAccess.WRITE)
			if f:
				f.store_string(v)
				f.close()
	Engine.set_meta("content_version", v)
	Engine.set_meta("app_version", app_version)
	await get_tree().create_timer(0.6).timeout
	get_tree().change_scene_to_file("res://game/main.tscn")


func _read(path: String, def: String) -> String:
	if FileAccess.file_exists(path):
		return FileAccess.get_file_as_string(path).strip_edges()
	return def


func _cmp(a: String, b: String) -> int:
	var x := a.split(".")
	var y := b.split(".")
	for i in 3:
		var xi := int(x[i]) if i < x.size() else 0
		var yi := int(y[i]) if i < y.size() else 0
		if xi > yi:
			return 1
		if xi < yi:
			return -1
	return 0
