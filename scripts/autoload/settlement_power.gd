extends Node

## Глобальний лічильник бойової потужності поселення.
## Сума power_rating усіх готових будівель.
## Autoload: реєструється у Project Settings → Autoload як "SettlementPower".

signal changed(new_total: int)

var total: int = 0


func add(amount: int) -> void:
	if amount == 0:
		return
	total += amount
	changed.emit(total)


func reset() -> void:
	total = 0
	changed.emit(total)
