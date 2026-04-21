class_name TileGrid
extends RefCounted

## Утиліта для переведення між грід-координатами (Vector2i) і піксельними (Vector2).
## Усі сутності, що "стоять на плитці", використовують цю конвертацію.
##
## Примітка: це не Node, це статичний хелпер. Використовуй як `TileGrid.grid_to_world(...)`.

const TILE_SIZE: int = 64
const MAP_SIZE: Vector2i = Vector2i(20, 20)


## Конвертує грід-координати у піксельні (центр плитки).
static func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * TILE_SIZE + TILE_SIZE / 2.0,
		grid_pos.y * TILE_SIZE + TILE_SIZE / 2.0
	)


## Конвертує піксельні координати у грід.
static func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(floor(world_pos.x / TILE_SIZE)),
		int(floor(world_pos.y / TILE_SIZE))
	)


## Перевіряє, чи грід-координата в межах карти.
static func is_in_bounds(grid_pos: Vector2i) -> bool:
	return (
		grid_pos.x >= 0 and grid_pos.x < MAP_SIZE.x
		and grid_pos.y >= 0 and grid_pos.y < MAP_SIZE.y
	)
