extends Camera2D
class_name CameraController

@export var grid_system: GridSystem
@export var pan_speed: float = 900.0
@export var drag_pan_speed: float = 1.0
@export var zoom_step: float = 0.1
@export var min_zoom_value: float = 0.55
@export var max_zoom_value: float = 1.6

var is_dragging: bool = false
var last_mouse_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	make_current()
	position_smoothing_enabled = true
	position_smoothing_speed = 8.0

	if grid_system != null:
		center_on_grid()
		setup_limits()

func _process(delta: float) -> void:
	var move_input: Vector2 = Vector2.ZERO

	move_input.x = Input.get_axis(&"camera_pan_left", &"camera_pan_right")
	move_input.y = Input.get_axis(&"camera_pan_up", &"camera_pan_down")

	if move_input != Vector2.ZERO:
		global_position += move_input.normalized() * pan_speed * delta

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton

		if mouse_event.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging = mouse_event.pressed
			last_mouse_position = mouse_event.position

		elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			apply_zoom(-zoom_step)

		elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			apply_zoom(zoom_step)

	elif event is InputEventMouseMotion and is_dragging:
		var motion_event: InputEventMouseMotion = event as InputEventMouseMotion
		global_position -= motion_event.relative * drag_pan_speed / zoom.x

func apply_zoom(delta_zoom: float) -> void:
	var new_zoom_value: float = clamp(zoom.x + delta_zoom, min_zoom_value, max_zoom_value)
	zoom = Vector2(new_zoom_value, new_zoom_value)

func center_on_grid() -> void:
	var center_x: float = grid_system.grid_width * grid_system.cell_size * 0.5
	var center_y: float = grid_system.grid_height * grid_system.cell_size * 0.5
	global_position = Vector2(center_x, center_y)

func setup_limits() -> void:
	limit_left = 0
	limit_top = 0
	limit_right = grid_system.grid_width * grid_system.cell_size
	limit_bottom = grid_system.grid_height * grid_system.cell_size
