extends Node2D
class_name SignalMapSystem

@export var grid_system: GridSystem
@export var object_root: Node2D

var signal_map: Dictionary = {}
# Vector2i -> Dictionary
# Например:
# Vector2i(4, 5) -> { "heat": 20.0, "humidity": 10.0 }

var update_interval: float = 0.25
var update_timer: float = 0.0

func _ready() -> void:
	if grid_system == null:
		push_error("SignalMapSystem: grid_system is not assigned.")

	if object_root == null:
		push_error("SignalMapSystem: object_root is not assigned.")

	rebuild_signal_map()

func _process(delta: float) -> void:
	update_timer += delta

	if update_timer >= update_interval:
		update_timer = 0.0
		rebuild_signal_map()

func rebuild_signal_map() -> void:
	signal_map.clear()

	if grid_system == null or object_root == null:
		return

	initialize_empty_signal_map()

	for child in object_root.get_children():
		if child is PlaceableObject and child.is_device():
			add_device_signals(child)

func initialize_empty_signal_map() -> void:
	for x in range(grid_system.grid_width):
		for y in range(grid_system.grid_height):
			signal_map[Vector2i(x, y)] = {}

func add_device_signals(device: PlaceableObject) -> void:
	var origin: Vector2i = device.grid_position
	var radius: int = device.radius
	var outputs: Dictionary = device.get_signal_outputs()

	if outputs.is_empty():
		return

	for x in range(origin.x - radius, origin.x + radius + 1):
		for y in range(origin.y - radius, origin.y + radius + 1):
			var pos: Vector2i = Vector2i(x, y)

			if not grid_system.is_inside_grid(pos):
				continue

			var distance: float = origin.distance_to(pos)

			if distance > float(radius):
				continue

			if is_blocked_by_screen(origin, pos):
				continue

			var falloff: float = 1.0 - (distance / float(radius + 1))

			for signal_name in outputs.keys():
				var output_amount: float = float(outputs[signal_name])
				var amount: float = output_amount * falloff
				add_signal(pos, String(signal_name), amount)

func is_blocked_by_screen(origin: Vector2i, target: Vector2i) -> bool:
	if origin == target:
		return false

	var cells_on_line: Array[Vector2i] = get_line_cells(origin, target)

	for cell_position in cells_on_line:
		# Источник не должен блокировать сам себя.
		if cell_position == origin:
			continue

		# Целевая клетка тоже не блокирует сигнал для самой себя.
		# Это позволит, например, устройству стоять рядом со стенкой без странных эффектов.
		if cell_position == target:
			continue

		if grid_system.is_signal_blocker(cell_position):
			return true

	return false

func get_line_cells(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	var x0: int = start.x
	var y0: int = start.y
	var x1: int = end.x
	var y1: int = end.y

	var dx: int = absi(x1 - x0)
	var dy: int = -absi(y1 - y0)

	var sx: int = 1
	if x0 >= x1:
		sx = -1

	var sy: int = 1
	if y0 >= y1:
		sy = -1

	var error: int = dx + dy

	while true:
		result.append(Vector2i(x0, y0))

		if x0 == x1 and y0 == y1:
			break

		var double_error: int = 2 * error

		if double_error >= dy:
			error += dy
			x0 += sx

		if double_error <= dx:
			error += dx
			y0 += sy

	return result
	
	
func add_signal(grid_position: Vector2i, signal_name: String, amount: float) -> void:
	if not signal_map.has(grid_position):
		signal_map[grid_position] = {}

	var cell_signals: Dictionary = signal_map[grid_position]
	cell_signals[signal_name] = cell_signals.get(signal_name, 0.0) + amount

func get_signals_at(grid_position: Vector2i) -> Dictionary:
	return signal_map.get(grid_position, {})
