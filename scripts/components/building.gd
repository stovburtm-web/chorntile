class_name Building
extends Node2D

## Одна будівля на гріді. Може бути в одному з трьох станів:
## RUIN — сіра пляма на карті, клік ініціює відбудову.
## RESTORING — тривалий таймер, над будівлею лейбл зворотнього відліку.
## BUILT — повноцінна будівля.
##
## Логіка станів централізована тут. Game.gd тільки інстанціює Building
## і викликає публічні методи (start_restoring/cancel_restoring).

enum State { RUIN, RESTORING, BUILT }

## Дані балансу (розмір, HP, час відбудови, візуали). Задається ззовні.
@export var data: BuildingData

@onready var visual_holder: Node2D = $Visual
@onready var build_label: Label = $BuildLabel

## Координати верхнього-лівого кута будівлі на гріді.
var grid_pos: Vector2i = Vector2i.ZERO

## Поточний стан.
var state: State = State.RUIN

var _time_left: float = 0.0

signal state_changed(new_state: State)
signal built  ## Випускається раз, коли стан стає BUILT.


func _ready() -> void:
	assert(data != null, "Building requires BuildingData")
	_apply_state(State.RUIN)


func _process(delta: float) -> void:
	if state != State.RESTORING:
		return
	_time_left -= delta
	build_label.text = "Будується %.1fс" % maxf(_time_left, 0.0)
	if _time_left <= 0.0:
		_apply_state(State.BUILT)
		built.emit()


## Починає відбудову. Працює тільки з RUIN.
func start_restoring() -> void:
	if state != State.RUIN:
		return
	_time_left = data.restore_time
	_apply_state(State.RESTORING)


## Скасовує відбудову. Працює тільки з RESTORING.
func cancel_restoring() -> void:
	if state != State.RESTORING:
		return
	_apply_state(State.RUIN)


## Повертає прямокутник (у грід-координатах), який займає ця будівля.
func get_grid_rect() -> Rect2i:
	return Rect2i(grid_pos, data.size)


## Чи клітинка gp всередині цієї будівлі.
func contains_grid(gp: Vector2i) -> bool:
	return get_grid_rect().has_point(gp)


func _apply_state(new_state: State) -> void:
	state = new_state

	# Видалити старий візуал.
	for child in visual_holder.get_children():
		child.queue_free()

	# Вибрати сцену для нового стану.
	var scene: PackedScene = null
	match state:
		State.RUIN, State.RESTORING:
			scene = data.visual_ruin
		State.BUILT:
			scene = data.visual_built

	if scene != null:
		var instance: Node = scene.instantiate()
		visual_holder.add_child(instance)

	# Лейбл таймера видно тільки під час відбудови.
	build_label.visible = (state == State.RESTORING)

	state_changed.emit(state)
