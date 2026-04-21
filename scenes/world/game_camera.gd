class_name GameCamera
extends Camera2D

## Камера з pan (drag середньою або правою кнопкою) та zoom (коліщатко).
## Прив'язана до сцени гри (res://scenes/world/game.tscn).

@export var zoom_min: float = 0.25
@export var zoom_max: float = 3.0
@export var zoom_step: float = 0.1
@export var pan_speed_keyboard: float = 600.0

var _is_dragging: bool = false


func _ready() -> void:
	# Центруємо камеру по центру карти 20×20.
	var map_pixels: Vector2 = Vector2(TileGrid.MAP_SIZE) * TileGrid.TILE_SIZE
	position = map_pixels / 2.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion and _is_dragging:
		# Pan: рух миші зі затиснутою правою → рух камери у протилежному напрямку.
		position -= event.relative / zoom.x


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	match event.button_index:
		MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE:
			_is_dragging = event.pressed
		MOUSE_BUTTON_WHEEL_UP:
			if event.pressed:
				_zoom_by(zoom_step)
		MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				_zoom_by(-zoom_step)


func _zoom_by(delta: float) -> void:
	var new_zoom: float = clampf(zoom.x + delta, zoom_min, zoom_max)
	zoom = Vector2(new_zoom, new_zoom)


func _process(delta: float) -> void:
	# WASD / стрілки — додатковий pan з клавіатури.
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir != Vector2.ZERO:
		position += input_dir * pan_speed_keyboard * delta / zoom.x
