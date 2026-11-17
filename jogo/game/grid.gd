extends Control
## Grelha de inventário: itens com tamanho (w×h), arrastar e largar entre grelhas,
## toque rápido para mover, e revelação com suspense ao revistar.

signal tapped(grid, item)
signal dropped(from_grid, to_grid, item, cell)

var game = null
var cols = 5
var rows = 4
var cell = 64.0
var items = []
var price_fn = null
var selected = null
var _press_item = null
var _press_pos = Vector2.ZERO
var _hover_cell = Vector2i(-1, -1)
var _hover_item = null
var _hover_ok = false
var _time = 0.0

const GAP = 3.0
const TIER_COL = [Color("#7a7f88"), Color("#4fae62"), Color("#3f8be0"), Color("#a05ae0"), Color("#e8b931")]


func setup(g, c: int, r: int, cs: float) -> void:
	game = g
	cols = c
	rows = r
	cell = cs
	custom_minimum_size = Vector2(cols * cell, rows * cell)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP


func _process(dt: float) -> void:
	_time += dt
	if visible:
		queue_redraw()


func item_rect(it: Dictionary) -> Rect2:
	var sz = game.item_size(it["id"])
	return Rect2(Vector2(it["x"], it["y"]) * cell + Vector2(GAP, GAP), Vector2(sz.x, sz.y) * cell - Vector2(GAP, GAP) * 2.0)


func item_at(pos: Vector2):
	for it in items:
		if item_rect(it).grow(GAP).has_point(pos):
			return it
	return null


func _draw() -> void:
	if game == null:
		return
	var font = game.get_font()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.035, 0.04, 0.05, 0.9))
	for y in rows:
		for x in cols:
			var r = Rect2(Vector2(x, y) * cell + Vector2(1.5, 1.5), Vector2(cell, cell) - Vector2(3, 3))
			draw_rect(r, Color(0.13, 0.14, 0.17))
			draw_rect(r, Color(1, 1, 1, 0.05), false, 1.0)
	for it in items:
		var r = item_rect(it)
		var tier = game.item_tier(it)
		var tc = TIER_COL[tier]
		if it.get("hid", false):
			draw_rect(r, Color(0.09, 0.1, 0.12))
			draw_rect(r, Color(1, 1, 1, 0.12), false, 1.5)
			var c = r.get_center()
			if it.get("rev", 0.0) > 0.0:
				var a0 = _time * 6.0
				draw_arc(c, minf(r.size.x, r.size.y) * 0.28, a0, a0 + TAU * 0.75, 24, Color(1, 1, 1, 0.85), 3.0, true)
			else:
				draw_string(font, c + Vector2(-20, 10), "?", HORIZONTAL_ALIGNMENT_CENTER, 40, 30, Color(1, 1, 1, 0.25))
			continue
		var bg = Color(tc.r * 0.22 + 0.06, tc.g * 0.22 + 0.06, tc.b * 0.22 + 0.07)
		draw_rect(r, bg)
		draw_rect(Rect2(r.position, Vector2(r.size.x, r.size.y * 0.5)), Color(1, 1, 1, 0.04))
		draw_rect(Rect2(r.position + Vector2(0, r.size.y - 3), Vector2(r.size.x, 3)), tc)
		var bw = 3.0 if it == selected else 1.5
		draw_rect(r, Color("#e8b931") if it == selected else Color(tc.r, tc.g, tc.b, 0.55), false, bw)
		var tex = game.icon_tex(it["id"])
		if tex != null:
			var s = minf(r.size.x, r.size.y - 14.0) * 0.86
			var tr = Rect2(r.get_center() - Vector2(s, s) * 0.5 - Vector2(0, 6), Vector2(s, s))
			draw_texture_rect(tex, tr, false)
		var fl = float(it.get("flash", 0.0))
		if fl > 0.0:
			draw_rect(r.grow(fl * 6.0), Color(tc.r, tc.g, tc.b, fl * 0.5), false, 4.0)
			draw_rect(r, Color(1, 1, 1, fl * 0.35))
		if it["id"] != "cash" and int(it.get("q", 1)) > 1:
			draw_string(font, r.position + Vector2(4, 18), "×%d" % it["q"], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
		var val = game.stack_value(it)
		var txt = ""
		var tcol = Color("#e8dfc8")
		if price_fn != null:
			var pr = price_fn.call(it)
			if pr > 0:
				txt = game.fmt(pr)
				tcol = Color("#9be0a8")
		elif val > 0:
			txt = game.fmt(val)
		if txt != "":
			draw_string(font, Vector2(r.position.x, r.end.y - 6), txt, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 15, tcol)
	# pré-visualização ao arrastar
	if _hover_item != null and _hover_cell.x > -50:
		var sz = game.item_size(_hover_item["id"])
		var hr = Rect2(Vector2(_hover_cell) * cell, Vector2(sz) * cell)
		draw_rect(hr, Color(0.25, 0.8, 0.45, 0.25) if _hover_ok else Color(0.9, 0.25, 0.2, 0.25))
		draw_rect(hr, Color(0.25, 0.8, 0.45) if _hover_ok else Color(0.9, 0.25, 0.2), false, 2.0)


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.pressed:
			_press_item = item_at(e.position)
			_press_pos = e.position
		else:
			if _press_item != null and e.position.distance_to(_press_pos) < 12.0 and not _press_item.get("hid", false):
				tapped.emit(self, _press_item)
			_press_item = null


func _get_drag_data(at: Vector2):
	var it = item_at(at)
	if it == null or it.get("hid", false):
		return null
	_press_item = null
	var sz = game.item_size(it["id"])
	var pv = Control.new()
	var tr = TextureRect.new()
	tr.texture = game.icon_tex(it["id"])
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.size = Vector2(sz) * cell
	tr.position = -Vector2(sz) * cell * 0.5
	tr.modulate = Color(1, 1, 1, 0.85)
	pv.add_child(tr)
	set_drag_preview(pv)
	return {"grid": self, "item": it}


func _target_cell(at: Vector2, it: Dictionary) -> Vector2i:
	var sz = game.item_size(it["id"])
	var c = at / cell - Vector2(sz) * 0.5 + Vector2(0.5, 0.5)
	return Vector2i(int(floor(c.x)), int(floor(c.y)))


func _can_drop_data(at: Vector2, data) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("item"):
		return false
	var it = data["item"]
	_hover_item = it
	_hover_cell = _target_cell(at, it)
	_hover_ok = game.grid_fits(items, cols, rows, _hover_cell.x, _hover_cell.y, game.item_size(it["id"]), it)
	return true


func _drop_data(at: Vector2, data) -> void:
	var it = data["item"]
	var c = _target_cell(at, it)
	_hover_item = null
	dropped.emit(data["grid"], self, it, c)


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT or what == NOTIFICATION_DRAG_END:
		_hover_item = null
		_hover_cell = Vector2i(-99, -99)
