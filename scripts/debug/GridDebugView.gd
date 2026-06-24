extends Node2D

@export var grid_system: GridSystem

var hovered_cell: Vector2i = Vector2i(-999, -999)

func _ready() -> void:
	if grid_system == null:
		push_error("GridDebugView: grid_system is not assigned.")

func _process(_delta: float) -> void:
	if grid_system == null:
		return

	var mouse_world_position := get_global_mouse_position()
	var new_hovered_cell := grid_system.world_to_grid(mouse_world_position)

	if new_hovered_cell != hovered_cell:
		hovered_cell = new_hovered_cell
		queue_redraw()

func _draw() -> void:
	if grid_system == null:
		return

	draw_grid()

	if grid_system.is_inside_grid(hovered_cell):
		draw_hovered_cell()

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

	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.18), true)
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.9), false, 2.0)
