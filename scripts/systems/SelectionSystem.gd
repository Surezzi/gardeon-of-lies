extends Node2D
class_name SelectionSystem

@export var grid_system: GridSystem
@export var plant_inspector: PlantInspector

func _ready() -> void:
	if grid_system == null:
		push_error("SelectionSystem: grid_system is not assigned.")

	if plant_inspector == null:
		push_error("SelectionSystem: plant_inspector is not assigned.")

func _unhandled_input(event: InputEvent) -> void:
	if grid_system == null or plant_inspector == null:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			try_inspect_hovered_cell()

		if event.keycode == KEY_ESCAPE:
			plant_inspector.clear()

func try_inspect_hovered_cell() -> void:
	var mouse_world_position: Vector2 = get_global_mouse_position()
	var grid_position: Vector2i = grid_system.world_to_grid(mouse_world_position)

	if not grid_system.is_inside_grid(grid_position):
		plant_inspector.clear()
		return

	var object: Node = grid_system.get_object_at(grid_position)

	if object is PlaceableObject and object.is_plant():
		plant_inspector.inspect_plant(object)
	else:
		plant_inspector.clear()
