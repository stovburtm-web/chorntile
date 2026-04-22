class_name RestoreModal
extends CanvasLayer

## Модалка підтвердження відновлення/скасування будівлі.
## Викликається з game.gd методом open(building).
## Самостійно чіпляється до натискань Так/Ні і закривається.

signal confirmed  ## Користувач натиснув "Так".

@onready var panel: PanelContainer = $Panel
@onready var title: Label = $Panel/Margin/VBox/Title
@onready var description: Label = $Panel/Margin/VBox/Description
@onready var yes_btn: Button = $Panel/Margin/VBox/Buttons/YesButton
@onready var no_btn: Button = $Panel/Margin/VBox/Buttons/NoButton


func _ready() -> void:
	hide()
	yes_btn.pressed.connect(_on_yes)
	no_btn.pressed.connect(_on_no)


## Показати модалку з заданим текстом.
func open(title_text: String, description_text: String) -> void:
	title.text = title_text
	description.text = description_text
	show()


func _on_yes() -> void:
	hide()
	confirmed.emit()


func _on_no() -> void:
	hide()
