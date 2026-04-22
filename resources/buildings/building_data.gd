class_name BuildingData
extends Resource

## Дані балансу для однієї будівлі. Зберігається у .tres файлі,
## редагується в інспекторі Godot. Логіка не хардкодить цифри — читає звідси.
##
## Приклад: resources/buildings/village_council.tres

## Унікальний ідентифікатор (для збережень, пошуку, локалізації).
@export var id: StringName = &""

## Відображуване ім'я (поки без локалізації — просто рядок).
@export var display_name: String = "Будівля"

## Розмір у плитках. 1x1 = звичайна, 2x2 = центральна (Сільрада).
@export var size: Vector2i = Vector2i(1, 1)

## Максимальне HP (для пізніших фаз, коли з'явиться руйнування).
@export var max_hp: int = 100

## Скільки секунд триває ремонт/будівництво з руїни.
@export var restore_time: float = 5.0

## Скільки ресурсів треба для відновлення. Порожній словник = безкоштовно.
## Приклад: {"wood": 10, "metal": 5}
@export var restore_cost: Dictionary = {}

## Наскільки збільшує "бойову потужність поселення" коли побудована.
@export var power_rating: int = 0

## Візуал готової будівлі. PackedScene з коренем Node2D/Control.
## У M2-M7 — плейсхолдер ColorRect з лейблом. У M8+ — справжній спрайт/модель.
@export var visual_built: PackedScene

## Візуал руїни (стан перед відновленням). Може бути null — тоді
## використовується дефолтний сірий прямокутник (див. Building.gd).
@export var visual_ruin: PackedScene
