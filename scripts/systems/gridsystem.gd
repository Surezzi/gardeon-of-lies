extends Node2D
class_name GridSystem

@export var grid_width: int = 16
@export var grid_height: int = 16
@export var cell_size: int = 48

var cells: Dictionary = {}
# Vector2i -> CellData

class CellData:
	var plant: Node = null
	var device: Node = null
	var blocked: bool = false

func _ready() -> void:
	initialize_cells()

func initialize_cells() -> void:
	cells.clear()

	for x in range(grid_width):
		for y in range(grid_height):
			cells[Vector2i(x, y)] = CellData.new()

func world_to_grid(world_position: Vector2) -> Vector2i:
	return Vector2i(
		floori(world_position.x / cell_size),
		floori(world_position.y / cell_size)
	)

func grid_to_world(grid_position: Vector2i) -> Vector2:
	return Vector2(
		grid_position.x * cell_size,
		grid_position.y * cell_size
	)

func grid_to_world_center(grid_position: Vector2i) -> Vector2:
	return grid_to_world(grid_position) + Vector2(cell_size, cell_size) * 0.5

func is_inside_grid(grid_position: Vector2i) -> bool:
	return (
		grid_position.x >= 0
		and grid_position.y >= 0
		and grid_position.x < grid_width
		and grid_position.y < grid_height
	)

func get_cell(grid_position: Vector2i) -> CellData:
	if not is_inside_grid(grid_position):
		return null

	return cells.get(grid_position)

func is_cell_empty(grid_position: Vector2i) -> bool:
	var cell := get_cell(grid_position)

	if cell == null:
		return false

	return cell.plant == null and cell.device == null and not cell.blocked

func set_plant(grid_position: Vector2i, plant: Node) -> void:
	var cell := get_cell(grid_position)

	if cell == null:
		return

	cell.plant = plant

func set_device(grid_position: Vector2i, device: Node) -> void:
	var cell := get_cell(grid_position)

	if cell == null:
		return

	cell.device = device

func get_object_at(grid_position: Vector2i) -> Node:
	var cell := get_cell(grid_position)

	if cell == null:
		return null

	if cell.plant != null:
		return cell.plant

	if cell.device != null:
		return cell.device

	return null

func clear_cell(grid_position: Vector2i) -> void:
	var cell := get_cell(grid_position)

	if cell == null:
		return

	cell.plant = null
	cell.device = null

func is_signal_blocker(grid_position: Vector2i) -> bool:
	var cell: CellData = get_cell(grid_position)

	if cell == null:
		return false

	if cell.device is PlaceableObject:
		return cell.device.blocks_signals

	return false
