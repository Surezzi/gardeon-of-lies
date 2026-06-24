extends Node2D
class_name SignalOverlay

signal overlay_changed(signal_name: String, visible_now: bool)

@export var grid_system: GridSystem
@export var signal_map_system: SignalMapSystem

var selected_signal: String = ""
var is_visible_overlay: bool = false
var overlay_order: Array[String] = [
	"heat",
	"dryness",
	"humidity",
	"yellow_light",
	"rot_smell",
	"frog_sound",
	"blue_light",
	"cold",
	"silence"
]

func _ready() -> void:
	if grid_system == null:
		push_error("SignalOverlay: grid_system is not assigned.")

	if signal_map_system == null:
		push_error("SignalOverlay: signal_map_system is not assigned.")

func _process(_delta: float) -> void:
	if is_visible_overlay:
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.is_action_pressed(&"overlay_heat"):
			set_signal("heat")
		elif event.is_action_pressed(&"overlay_dryness"):
			set_signal("dryness")
		elif event.is_action_pressed(&"overlay_humidity"):
			set_signal("humidity")
		elif event.is_action_pressed(&"overlay_yellow_light"):
			set_signal("yellow_light")
		elif event.is_action_pressed(&"overlay_rot_smell"):
			set_signal("rot_smell")
		elif event.is_action_pressed(&"overlay_frog_sound"):
			set_signal("frog_sound")
		elif event.is_action_pressed(&"overlay_blue_light"):
			set_signal("blue_light")
		elif event.is_action_pressed(&"overlay_cold"):
			set_signal("cold")
		elif event.is_action_pressed(&"overlay_silence"):
			set_signal("silence")
		elif event.is_action_pressed(&"overlay_hide"):
			hide_overlay()

func set_signal(signal_name: String) -> void:
	selected_signal = signal_name
	is_visible_overlay = true
	overlay_changed.emit(selected_signal, true)
	queue_redraw()

func hide_overlay() -> void:
	selected_signal = ""
	is_visible_overlay = false
	overlay_changed.emit("", false)
	queue_redraw()

func toggle_signal(signal_name: String) -> void:
	if is_visible_overlay and selected_signal == signal_name:
		hide_overlay()
		return

	set_signal(signal_name)

func get_overlay_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []

	for signal_name in overlay_order:
		entries.append({
			"signal_name": signal_name,
			"selected": is_visible_overlay and selected_signal == signal_name
		})

	return entries

func _draw() -> void:
	if not is_visible_overlay:
		return

	if grid_system == null or signal_map_system == null:
		return

	draw_signal_cells()

func draw_signal_cells() -> void:
	for x in range(grid_system.grid_width):
		for y in range(grid_system.grid_height):
			var grid_position: Vector2i = Vector2i(x, y)
			var signals: Dictionary = signal_map_system.get_signals_at(grid_position)
			var amount: float = float(signals.get(selected_signal, 0.0))

			if amount <= 0.0:
				continue

			var alpha: float = float(clamp(amount / 70.0, 0.05, 0.65))
			var color: Color = get_signal_color(selected_signal, alpha)

			var top_left: Vector2 = grid_system.grid_to_world(grid_position)
			var rect: Rect2 = Rect2(
				top_left,
				Vector2(grid_system.cell_size, grid_system.cell_size)
			)

			draw_rect(rect, color, true)

func get_signal_color(signal_name: String, alpha: float) -> Color:
	match signal_name:
		"heat":
			return Color(1.0, 0.25, 0.05, alpha)

		"dryness":
			return Color(0.95, 0.75, 0.25, alpha)

		"humidity":
			return Color(0.1, 0.45, 1.0, alpha)

		"yellow_light":
			return Color(1.0, 1.0, 0.15, alpha)

		"rot_smell":
			return Color(0.35, 0.85, 0.2, alpha)

		"frog_sound":
			return Color(0.1, 1.0, 0.55, alpha)

		"blue_light":
			return Color(0.25, 0.45, 1.0, alpha)

		"cold":
			return Color(0.55, 0.85, 1.0, alpha)

		"silence":
			return Color(0.75, 0.75, 0.95, alpha)

		_:
			return Color(1.0, 1.0, 1.0, alpha)
