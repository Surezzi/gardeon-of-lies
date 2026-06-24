extends Node2D
class_name SelectionSystem

signal inspected_object_changed(object)

@export var grid_system: GridSystem
@export var plant_inspector: PlantInspector

var inspected_object: PlaceableObject = null

func _ready() -> void:
	if grid_system == null:
		push_error("SelectionSystem: grid_system is not assigned.")

	if plant_inspector == null:
		push_error("SelectionSystem: plant_inspector is not assigned.")

func _process(_delta: float) -> void:
	if inspected_object == null:
		return

	if not is_instance_valid(inspected_object):
		clear_selection()

func _unhandled_input(event: InputEvent) -> void:
	if grid_system == null or plant_inspector == null:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.is_action_pressed(InputConfig.INSPECT_HOVERED_ACTION):
			try_inspect_hovered_cell()

		if event.is_action_pressed(InputConfig.CLEAR_SELECTION_ACTION):
			clear_selection()

	if event is InputEventMouseButton and event.pressed:
		if event.is_action_pressed(InputConfig.PLACE_OBJECT_ACTION):
			try_inspect_hovered_cell()

func try_inspect_hovered_cell() -> void:
	var mouse_world_position: Vector2 = get_global_mouse_position()
	var grid_position: Vector2i = grid_system.world_to_grid(mouse_world_position)

	if not grid_system.is_inside_grid(grid_position):
		clear_selection()
		return

	var object: Node = grid_system.get_object_at(grid_position)

	if object is PlaceableObject:
		inspect_object(object)
	else:
		clear_selection()

func inspect_object(object: PlaceableObject) -> void:
	inspected_object = object
	plant_inspector.inspect_object(object)
	inspected_object_changed.emit(object)

func clear_selection() -> void:
	inspected_object = null
	plant_inspector.clear()
	inspected_object_changed.emit(null)
