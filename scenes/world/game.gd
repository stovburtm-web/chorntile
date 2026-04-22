class_name Game
extends Node2D

## Коренева сцена геймплею. M2 Крок 4: клік по руїні відкриває модалку
## підтвердження. "Так" → відбудова. Клік по будівлі, що будується → модалка
## скасування.

const BUILDING_SCENE: PackedScene = preload("res://scenes/buildings/building.tscn")
const VILLAGE_COUNCIL_DATA: BuildingData = preload("res://resources/buildings/village_council.tres")

@onready var grid_overlay: Node2D = $GridOverlay
@onready var hover_highlight: ColorRect = $HoverHighlight
@onready var debug_label: Label = $UI/DebugLabel
@onready var buildings_layer: Node2D = $Buildings
@onready var camera: Camera2D = $GameCamera
@onready var restore_modal: RestoreModal = $RestoreModal
@onready var power_label: Label = $UI/PowerLabel

func _ready() -> void:
	_draw_grid()
	hover_highlight.size = Vector2.ONE * TileGrid.TILE_SIZE
	hover_highlight.color = Color(1, 1, 1, 0.25)
	SettlementPower.changed.connect(_on_power_changed)
	_on_power_changed(SettlementPower.total)
	_spawn_starting_buildings()


func _on_power_changed(new_total: int) -> void:
	power_label.text = "Бойова потужність: %d" % new_total


func _process(_delta: float) -> void:
	var mouse_world: Vector2 = get_global_mouse_position()
	var grid_pos: Vector2i = TileGrid.world_to_grid(mouse_world)

	if TileGrid.is_in_bounds(grid_pos):
		hover_highlight.visible = true
		hover_highlight.position = Vector2(grid_pos) * TileGrid.TILE_SIZE
		debug_label.text = "tile: %d, %d" % [grid_pos.x, grid_pos.y]
	else:
		hover_highlight.visible = false
		debug_label.text = "tile: —"


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	var mb: InputEventMouseButton = event
	if not (mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT):
		return

	var grid_pos: Vector2i = TileGrid.world_to_grid(get_global_mouse_position())
	if not TileGrid.is_in_bounds(grid_pos):
		return

	var building: Building = _find_building_at(grid_pos)
	if building == null:
		return

	match building.state:
		Building.State.RUIN:
			_ask_restore(building)
		Building.State.RESTORING:
			_ask_cancel(building)
		Building.State.BUILT:
			pass


func _ask_restore(building: Building) -> void:
	var title: String = "Відновити %s?" % building.data.display_name
	var desc: String = "Час: %.0f с" % building.data.restore_time
	_open_modal(title, desc, building.start_restoring)


func _ask_cancel(building: Building) -> void:
	var title: String = "Скасувати будівництво?"
	var desc: String = "Прогрес буде втрачено."
	_open_modal(title, desc, building.cancel_restoring)


func _open_modal(title: String, desc: String, on_yes: Callable) -> void:
	# Скидаємо всі старі підписки (після "Ні" сигнал не емітився, підписка висіла).
	for c in restore_modal.confirmed.get_connections():
		restore_modal.confirmed.disconnect(c["callable"])
	restore_modal.confirmed.connect(on_yes, CONNECT_ONE_SHOT)
	restore_modal.open(title, desc)


func _find_building_at(gp: Vector2i) -> Building:
	for child in buildings_layer.get_children():
		if child is Building and child.contains_grid(gp):
			return child
	return null


func _spawn_starting_buildings() -> void:
	var center: Vector2i = TileGrid.MAP_SIZE / 2 - Vector2i(1, 1)
	_spawn_building(VILLAGE_COUNCIL_DATA, center)


func _spawn_building(data: BuildingData, gp: Vector2i) -> Building:
	var building: Building = BUILDING_SCENE.instantiate()
	building.data = data
	building.grid_pos = gp
	building.position = Vector2(gp) * TileGrid.TILE_SIZE
	building.built.connect(func() -> void: SettlementPower.add(data.power_rating))
	buildings_layer.add_child(building)
	return building


func _draw_grid() -> void:
	var line_color: Color = Color(1, 1, 1, 0.15)
	var map_pixels: Vector2 = Vector2(TileGrid.MAP_SIZE) * TileGrid.TILE_SIZE

	for x in range(TileGrid.MAP_SIZE.x + 1):
		var line: Line2D = Line2D.new()
		line.width = 1.0
		line.default_color = line_color
		line.add_point(Vector2(x * TileGrid.TILE_SIZE, 0))
		line.add_point(Vector2(x * TileGrid.TILE_SIZE, map_pixels.y))
		grid_overlay.add_child(line)

	for y in range(TileGrid.MAP_SIZE.y + 1):
		var line: Line2D = Line2D.new()
		line.width = 1.0
		line.default_color = line_color
		line.add_point(Vector2(0, y * TileGrid.TILE_SIZE))
		line.add_point(Vector2(map_pixels.x, y * TileGrid.TILE_SIZE))
		grid_overlay.add_child(line)
