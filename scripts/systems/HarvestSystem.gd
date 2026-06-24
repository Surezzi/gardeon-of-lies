extends Node2D
class_name HarvestSystem

@export var grid_system: GridSystem
@export var object_root: Node2D
@export var inventory_system: InventorySystem

var auto_harvest_interval: float = 0.5
var auto_harvest_timer: float = 0.0
var log_actions: bool = false

var adjacent_offsets: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1)
]

func _ready() -> void:
	if grid_system == null:
		push_error("HarvestSystem: grid_system is not assigned.")

	if object_root == null:
		push_error("HarvestSystem: object_root is not assigned.")

	if inventory_system == null:
		push_error("HarvestSystem: inventory_system is not assigned.")

func _process(delta: float) -> void:
	auto_harvest_timer += delta

	if auto_harvest_timer >= auto_harvest_interval:
		auto_harvest_timer = 0.0
		update_auto_harvesters()

func _unhandled_input(event: InputEvent) -> void:
	if grid_system == null or inventory_system == null:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.is_action_pressed(InputConfig.HARVEST_HOVERED_ACTION):
			try_harvest_hovered_cell()

func update_auto_harvesters() -> void:
	if object_root == null:
		return

	for child in object_root.get_children():
		if not child is PlaceableObject:
			continue

		var device: PlaceableObject = child as PlaceableObject

		if not device.is_device():
			continue

		if not device.is_harvester:
			continue

		harvest_adjacent_plants(device)

func harvest_adjacent_plants(harvester: PlaceableObject) -> void:
	for offset in adjacent_offsets:
		var target_position: Vector2i = harvester.grid_position + offset

		if not grid_system.is_inside_grid(target_position):
			continue

		try_harvest_cell(target_position, true)

func try_harvest_hovered_cell() -> void:
	var mouse_world_position: Vector2 = get_global_mouse_position()
	var grid_position: Vector2i = grid_system.world_to_grid(mouse_world_position)

	if not grid_system.is_inside_grid(grid_position):
		return

	try_harvest_cell(grid_position, false)

func try_harvest_cell(grid_position: Vector2i, silent_if_not_ready: bool) -> void:
	var object: Node = grid_system.get_object_at(grid_position)

	if not object is PlaceableObject:
		if not silent_if_not_ready and log_actions:
			print("No plant to harvest at ", grid_position)
		return

	var placeable: PlaceableObject = object as PlaceableObject

	if not placeable.is_plant():
		if not silent_if_not_ready and log_actions:
			print("Object is not a plant: ", placeable.display_name)
		return

	if not placeable.is_mature():
		if not silent_if_not_ready and log_actions:
			print(placeable.display_name, " is not mature yet. Growth: ", round(placeable.growth), "%")
		return

	var harvest_data: Dictionary = placeable.harvest()

	if harvest_data.is_empty():
		if not silent_if_not_ready and log_actions:
			print("Nothing to harvest from ", placeable.display_name)
		return

	var item_id: String = String(harvest_data.get("item_id", ""))
	var item_name: String = String(harvest_data.get("item_name", item_id))
	var amount: int = int(harvest_data.get("amount", 1))

	inventory_system.add_item(item_id, item_name, amount)

	if not silent_if_not_ready and log_actions:
		print("Harvested ", placeable.display_name, " at ", grid_position)
	elif log_actions:
		print("Auto-harvested ", placeable.display_name, " at ", grid_position)
