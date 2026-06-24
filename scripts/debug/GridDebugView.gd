extends Node2D

@export var grid_system: GridSystem
@export var build_system: Node2D
@export var selection_system: SelectionSystem

var hovered_cell: Vector2i = Vector2i(-999, -999)
var last_selected_cell: Vector2i = Vector2i(-999, -999)

func _ready() -> void:
	if grid_system == null:
		push_error("GridDebugView: grid_system is not assigned.")

func _process(_delta: float) -> void:
	if grid_system == null:
		return

	var mouse_world_position := get_global_mouse_position()
	var new_hovered_cell := grid_system.world_to_grid(mouse_world_position)
	var new_selected_cell: Vector2i = Vector2i(-999, -999)

	if selection_system != null and selection_system.inspected_object != null:
		if is_instance_valid(selection_system.inspected_object):
			new_selected_cell = selection_system.inspected_object.grid_position

	if new_hovered_cell != hovered_cell or new_selected_cell != last_selected_cell:
		hovered_cell = new_hovered_cell
		last_selected_cell = new_selected_cell
		queue_redraw()

func _draw() -> void:
	if grid_system == null:
		return

	draw_grid()

	if grid_system.is_inside_grid(hovered_cell):
		draw_hovered_cell()

	draw_selected_cell()

func draw_grid() -> void:
	var width_px := grid_system.grid_width * grid_system.cell_size
	var height_px := grid_system.grid_height * grid_system.cell_size

	for x in range(grid_system.grid_width + 1):
		var x_pos := x * grid_system.cell_size
		draw_line(
			Vector2(x_pos, 0),
			Vector2(x_pos, height_px),
			Color(0.35, 0.35, 0.35),
			1.0
		)

	for y in range(grid_system.grid_height + 1):
		var y_pos := y * grid_system.cell_size
		draw_line(
			Vector2(0, y_pos),
			Vector2(width_px, y_pos),
			Color(0.35, 0.35, 0.35),
			1.0
		)

func draw_hovered_cell() -> void:
	var top_left := grid_system.grid_to_world(hovered_cell)
	var rect := Rect2(
		top_left,
		Vector2(grid_system.cell_size, grid_system.cell_size)
	)

	var fill_color: Color = Color(1.0, 1.0, 1.0, 0.18)
	var border_color: Color = Color(1.0, 1.0, 1.0, 0.9)

	if build_system != null and build_system.has_method("can_place_selected_at"):
		if grid_system.is_cell_empty(hovered_cell):
			if bool(build_system.can_place_selected_at(hovered_cell)):
				fill_color = Color(0.2, 1.0, 0.45, 0.18)
				border_color = Color(0.25, 1.0, 0.5, 0.95)
			else:
				fill_color = Color(1.0, 0.25, 0.25, 0.18)
				border_color = Color(1.0, 0.35, 0.35, 0.95)
		else:
			fill_color = Color(0.35, 0.6, 1.0, 0.18)
			border_color = Color(0.45, 0.72, 1.0, 0.95)

	draw_rect(rect, fill_color, true)
	draw_rect(rect, border_color, false, 2.0)

func draw_selected_cell() -> void:
	if selection_system == null:
		return

	if selection_system.inspected_object == null:
		return

	if not is_instance_valid(selection_system.inspected_object):
		return

	var top_left := grid_system.grid_to_world(selection_system.inspected_object.grid_position)
	var rect := Rect2(
		top_left + Vector2(4.0, 4.0),
		Vector2(grid_system.cell_size - 8.0, grid_system.cell_size - 8.0)
	)

	draw_rect(rect, Color(1.0, 0.95, 0.45, 0.95), false, 3.0)
