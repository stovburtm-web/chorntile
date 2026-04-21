class_name Game
extends Node2D

## Коренева сцена геймплею. Для M1: малює сітку 20×20 через Line2D-оверлей
## і дає Label з координатами плитки під курсором.
##
## Пізніше (M2+) замість примітивної сітки тут з'явиться TileMapLayer з ассетами.

@onready var grid_overlay: Node2D = $GridOverlay
@onready var hover_highlight: ColorRect = $HoverHighlight
@onready var debug_label: Label = $UI/DebugLabel
@onready var camera: Camera2D = $GameCamera


func _ready() -> void:
	_draw_grid()
	hover_highlight.size = Vector2.ONE * TileGrid.TILE_SIZE
	hover_highlight.color = Color(1, 1, 1, 0.25)


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


func _draw_grid() -> void:
	# Малюємо сітку лініями в $GridOverlay через _draw — але оскільки
	# GridOverlay це звичайний Node2D без скрипта, простіше додати
	# лінії як дітей (Line2D). Робимо це тут один раз.
	var line_color: Color = Color(1, 1, 1, 0.15)
	var map_pixels: Vector2 = Vector2(TileGrid.MAP_SIZE) * TileGrid.TILE_SIZE

	# Вертикальні лінії.
	for x in range(TileGrid.MAP_SIZE.x + 1):
		var line: Line2D = Line2D.new()
		line.width = 1.0
		line.default_color = line_color
		line.add_point(Vector2(x * TileGrid.TILE_SIZE, 0))
		line.add_point(Vector2(x * TileGrid.TILE_SIZE, map_pixels.y))
		grid_overlay.add_child(line)

	# Горизонтальні лінії.
	for y in range(TileGrid.MAP_SIZE.y + 1):
		var line: Line2D = Line2D.new()
		line.width = 1.0
		line.default_color = line_color
		line.add_point(Vector2(0, y * TileGrid.TILE_SIZE))
		line.add_point(Vector2(map_pixels.x, y * TileGrid.TILE_SIZE))
		grid_overlay.add_child(line)
