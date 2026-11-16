extends Control
## Arranque: procura atualizações nos Releases do GitHub, descarrega o pacote de conteúdo
## (game.pck) se houver versão nova e só depois abre o jogo. Tudo automático.

const BASE := "https://github.com/rezyto/golpe/releases/download/latest/"
const PCK := "user://game.pck"
const PCK_NEW := "user://game_new.pck"
const PCK_VER := "user://content_version.txt"

var http: HTTPRequest
var status: Label
var bar: ProgressBar
var app_btn: Button
var app_version := "0.0.0"
var builtin_version := "0.0.0"
var downloading := false
var remote_content := ""


func _ready() -> void:
	app_version = _read("res://boot/app_version.txt", "0.0.0")
	builtin_version = _read("res://game/content_version.txt", "0.0.0")
	_build_ui()
	http = HTTPRequest.new()
	http.timeout = 10.0
	http.use_threads = true
	add_child(http)
	http.request_completed.connect(_on_version)
	var err := http.request(BASE + "version.json?t=%d" % int(Time.get_unix_time_from_system()))
	if err != OK:
		_start_game("Sem ligação — a jogar offline")


func _process(_delta: float) -> void:
	if downloading:
		var total := http.get_body_size()
		var got := http.get_downloaded_bytes()
		if total > 0:
			bar.value = 100.0 * got / total
			status.text = "A descarregar atualização %s… %d%%" % [remote_content, int(bar.value)]


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
	status.text = "A procurar atualizações…"
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
	v.add_child(ver)


func _on_version(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	http.request_completed.disconnect(_on_version)
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_start_game("Sem ligação ao servidor — a jogar offline")
		return
	var j = JSON.parse_string(body.get_string_from_utf8())
	if typeof(j) != TYPE_DICTIONARY or not j.has("content"):
		_start_game("")
		return
	if j.has("app") and _cmp(str(j["app"]), app_version) > 0:
		app_btn.text = "Nova app %s disponível — descarregar" % str(j["app"])
		app_btn.visible = true
	remote_content = str(j["content"])
	if _cmp(remote_content, _installed_version()) > 0:
		status.text = "A descarregar atualização %s…" % remote_content
		http.download_file = PCK_NEW
		http.request_completed.connect(_on_pck)
		downloading = true
		var err := http.request(BASE + "game.pck")
		if err != OK:
			downloading = false
			_start_game("Falhou a atualização — a usar a versão atual")
	else:
		bar.value = 100
		_start_game("Jogo atualizado ✓")


func _on_pck(result: int, code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	downloading = false
	if result == HTTPRequest.RESULT_SUCCESS and code == 200 and FileAccess.file_exists(PCK_NEW):
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
		_start_game("Atualizado para %s ✓" % remote_content)
	else:
		_start_game("Falhou a atualização — a usar a versão atual")


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
