extends Node2D
class_name PlaceableObject

enum ObjectKind {
	PLANT,
	DEVICE
}

var object_id: String = ""
var display_name: String = ""
var object_kind: int = ObjectKind.DEVICE
var grid_position: Vector2i = Vector2i.ZERO
var cell_size: int = 48

# Для устройств
var radius: int = 0
var signal_outputs: Dictionary = {}
var blocks_signals: bool = false
var is_harvester: bool = false
var is_timer: bool = false
var can_be_toggled: bool = true
var enabled: bool = true

var timer_on_duration: float = 5.0
var timer_off_duration: float = 5.0
var timer_elapsed: float = 0.0
var timer_is_on: bool = true

# Для растений
var likes: Dictionary = {}
var dislikes: Dictionary = {}
var contradictions: Array = []
var required_phases: Dictionary = {}
var phase_memory: Dictionary = {}
var phase_score: float = 0.0

var growth_threshold: float = 50.0
var max_growth: float = 100.0
var output_item_id: String = ""
var output_item_name: String = ""
var output_amount: int = 1

var belief: float = 0.0
var suspicion: float = 0.0
var growth: float = 0.0

var last_positive_signals: Dictionary = {}
var last_negative_signals: Dictionary = {}
var last_raw_signals: Dictionary = {}

func setup(
	new_object_id: String,
	new_display_name: String,
	new_object_kind: int,
	new_grid_position: Vector2i,
	new_cell_size: int,
	definition: Dictionary
) -> void:
	object_id = new_object_id
	display_name = new_display_name
	object_kind = new_object_kind
	grid_position = new_grid_position
	cell_size = new_cell_size

	radius = int(definition.get("radius", 0))
	signal_outputs = Dictionary(definition.get("signal_outputs", {}))
	blocks_signals = bool(definition.get("blocks_signals", false))
	is_harvester = bool(definition.get("is_harvester", false))
	is_timer = bool(definition.get("is_timer", false))
	can_be_toggled = bool(definition.get("can_be_toggled", true))
	enabled = bool(definition.get("enabled", true))

	timer_on_duration = float(definition.get("timer_on_duration", 5.0))
	timer_off_duration = float(definition.get("timer_off_duration", 5.0))
	timer_elapsed = 0.0
	timer_is_on = true

	likes = Dictionary(definition.get("likes", {}))
	dislikes = Dictionary(definition.get("dislikes", {}))
	contradictions = Array(definition.get("contradictions", []))
	required_phases = Dictionary(definition.get("required_phases", {}))
	phase_memory.clear()

	for phase_name_variant in required_phases.keys():
		phase_memory[String(phase_name_variant)] = 0.0

	phase_score = 0.0

	growth_threshold = float(definition.get("growth_threshold", 50.0))
	max_growth = float(definition.get("max_growth", 100.0))

	output_item_id = String(definition.get("output_item_id", ""))
	output_item_name = String(definition.get("output_item_name", output_item_id))
	output_amount = int(definition.get("output_amount", 1))

	queue_redraw()

func is_plant() -> bool:
	return object_kind == ObjectKind.PLANT

func is_device() -> bool:
	return object_kind == ObjectKind.DEVICE

func is_mature() -> bool:
	return is_plant() and growth >= max_growth

func set_enabled_state(new_enabled: bool) -> void:
	if enabled == new_enabled:
		return

	enabled = new_enabled
	queue_redraw()

func set_timer_state(new_timer_is_on: bool, new_elapsed: float) -> void:
	timer_is_on = new_timer_is_on
	timer_elapsed = new_elapsed
	queue_redraw()

func get_signal_outputs() -> Dictionary:
	if not is_device():
		return {}

	if not enabled:
		return {}

	return signal_outputs

func set_plant_state(
	new_belief: float,
	new_suspicion: float,
	new_growth: float,
	new_positive_signals: Dictionary = {},
	new_negative_signals: Dictionary = {},
	new_raw_signals: Dictionary = {},
	new_phase_memory: Dictionary = {},
	new_phase_score: float = 0.0
) -> void:
	belief = new_belief
	suspicion = new_suspicion
	growth = new_growth
	last_positive_signals = new_positive_signals
	last_negative_signals = new_negative_signals
	last_raw_signals = new_raw_signals

	if not new_phase_memory.is_empty():
		phase_memory = new_phase_memory

	phase_score = new_phase_score
	queue_redraw()

func harvest() -> Dictionary:
	if not is_mature():
		return {}

	if output_item_id == "":
		return {}

	growth = 0.0
	queue_redraw()

	return {
		"item_id": output_item_id,
		"item_name": output_item_name,
		"amount": output_amount
	}

func get_average_phase_memory() -> float:
	if phase_memory.is_empty():
		return 0.0

	var total: float = 0.0

	for phase_name_variant in phase_memory.keys():
		total += float(phase_memory[phase_name_variant])

	return total / float(phase_memory.size())

func _draw() -> void:
	var half: float = cell_size * 0.5
	var padding: float = 8.0
	var size: Vector2 = Vector2(cell_size - padding * 2.0, cell_size - padding * 2.0)
	var top_left: Vector2 = Vector2(-half + padding, -half + padding)

	match object_id:
		"glass_cactus":
			draw_glass_cactus()

		"rot_lotus":
			draw_rot_lotus()

		"moon_bean":
			draw_moon_bean()

		"impossible_orchid":
			draw_impossible_orchid()

		"ember_fern":
			draw_ember_fern()

		"mirror_reed":
			draw_mirror_reed()

		"chorus_bulb":
			draw_chorus_bulb()

		"echo_blossom":
			draw_echo_blossom()

		"heat_lamp":
			draw_heat_lamp(top_left, size)

		"mist_sprayer":
			draw_mist_sprayer(top_left, size)

		"isolation_screen":
			draw_isolation_screen()

		"rot_scent_pot":
			draw_rot_scent_pot()

		"frog_sound_box":
			draw_frog_sound_box()

		"harvester":
			draw_harvester()

		"moon_lantern":
			draw_moon_lantern()

		"silence_box":
			draw_silence_box()

		"timer":
			draw_timer()

		"compost_heater":
			draw_compost_heater()

		"wind_turbine":
			draw_wind_turbine()

		"choir_bell":
			draw_choir_bell()

		_:
			draw_rect(Rect2(top_left, size), Color(1.0, 1.0, 1.0), true)

	if is_device() and can_be_toggled and not enabled:
		draw_disabled_overlay()

func draw_heat_lamp(top_left: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(top_left, size), Color(1.0, 0.82, 0.15), true)
	draw_rect(Rect2(top_left, size), Color(1.0, 0.55, 0.05), false, 2.0)

func draw_mist_sprayer(top_left: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(top_left, size), Color(0.25, 0.55, 1.0), true)
	draw_circle(Vector2.ZERO, cell_size * 0.16, Color(0.65, 0.85, 1.0))

func draw_disabled_overlay() -> void:
	var half: float = cell_size * 0.5
	var rect: Rect2 = Rect2(
		Vector2(-half + 4.0, -half + 4.0),
		Vector2(cell_size - 8.0, cell_size - 8.0)
	)

	draw_rect(rect, Color(0.0, 0.0, 0.0, 0.55), true)
	draw_line(
		Vector2(-cell_size * 0.28, -cell_size * 0.28),
		Vector2(cell_size * 0.28, cell_size * 0.28),
		Color(1.0, 0.15, 0.15),
		3.0
	)
	draw_line(
		Vector2(cell_size * 0.28, -cell_size * 0.28),
		Vector2(-cell_size * 0.28, cell_size * 0.28),
		Color(1.0, 0.15, 0.15),
		3.0
	)

func draw_glass_cactus() -> void:
	var growth_ratio: float = float(clamp(growth / max_growth, 0.0, 1.0))
	var radius_value: float = float(lerp(cell_size * 0.18, cell_size * 0.34, growth_ratio))

	var cactus_color: Color = Color(0.16, 0.75, 0.22)

	if belief >= growth_threshold:
		cactus_color = Color(0.25, 1.0, 0.3)
	elif belief < 20.0:
		cactus_color = Color(0.25, 0.35, 0.25)

	draw_circle(Vector2.ZERO, radius_value, cactus_color)
	draw_circle(Vector2.ZERO, radius_value * 0.62, Color(0.08, 0.45, 0.12))

	if is_mature():
		draw_mature_ring(Color(0.75, 1.0, 0.75, 0.95))

	draw_growth_bar(growth_ratio, Color(0.3, 1.0, 0.35, 0.9))

func draw_rot_lotus() -> void:
	var growth_ratio: float = float(clamp(growth / max_growth, 0.0, 1.0))
	var radius_value: float = float(lerp(cell_size * 0.16, cell_size * 0.32, growth_ratio))

	var lotus_color: Color = Color(0.45, 0.18, 0.65)

	if belief >= growth_threshold:
		lotus_color = Color(0.75, 0.25, 1.0)
	elif belief < 20.0:
		lotus_color = Color(0.22, 0.18, 0.24)

	draw_circle(Vector2(-cell_size * 0.12, 0.0), radius_value * 0.75, Color(0.08, 0.35, 0.16))
	draw_circle(Vector2(cell_size * 0.12, 0.0), radius_value * 0.75, Color(0.08, 0.35, 0.16))

	draw_circle(Vector2.ZERO, radius_value, lotus_color)
	draw_circle(Vector2.ZERO, radius_value * 0.45, Color(0.95, 0.65, 1.0))

	if is_mature():
		draw_mature_ring(Color(1.0, 0.75, 1.0, 0.95))

	draw_growth_bar(growth_ratio, Color(0.75, 0.25, 1.0, 0.9))

func draw_moon_bean() -> void:
	var growth_ratio: float = float(clamp(growth / max_growth, 0.0, 1.0))
	var stem_height: float = float(lerp(cell_size * 0.16, cell_size * 0.34, growth_ratio))

	var stem_color: Color = Color(0.35, 0.55, 0.85)
	var bean_color: Color = Color(0.55, 0.7, 1.0)

	if belief >= growth_threshold:
		bean_color = Color(0.75, 0.9, 1.0)
	elif belief < 20.0:
		bean_color = Color(0.18, 0.22, 0.32)

	draw_line(
		Vector2(0.0, stem_height * 0.45),
		Vector2(0.0, -stem_height * 0.45),
		stem_color,
		4.0
	)

	draw_circle(Vector2(-cell_size * 0.08, -stem_height * 0.1), cell_size * 0.11, Color(0.18, 0.32, 0.55))
	draw_circle(Vector2(cell_size * 0.08, stem_height * 0.05), cell_size * 0.11, Color(0.18, 0.32, 0.55))

	draw_circle(Vector2(0.0, -stem_height * 0.48), cell_size * 0.13, bean_color)
	draw_circle(Vector2(0.0, -stem_height * 0.48), cell_size * 0.06, Color(0.92, 0.96, 1.0))

	if is_mature():
		draw_mature_ring(Color(0.75, 0.9, 1.0, 0.95))

	draw_growth_bar(growth_ratio, Color(0.55, 0.75, 1.0, 0.9))

func draw_impossible_orchid() -> void:
	var growth_ratio: float = float(clamp(growth / max_growth, 0.0, 1.0))
	var memory_ratio: float = float(clamp(get_average_phase_memory() / 100.0, 0.0, 1.0))

	var stem_height: float = float(lerp(cell_size * 0.18, cell_size * 0.36, growth_ratio))
	var petal_radius: float = float(lerp(cell_size * 0.08, cell_size * 0.14, growth_ratio))

	var stem_color: Color = Color(0.25, 0.55, 0.35)
	var petal_a: Color = Color(1.0, 0.7, 0.25)
	var petal_b: Color = Color(0.45, 0.65, 1.0)

	if memory_ratio < 0.35:
		petal_a = Color(0.3, 0.25, 0.2)
		petal_b = Color(0.18, 0.2, 0.32)

	draw_line(
		Vector2(0.0, cell_size * 0.18),
		Vector2(0.0, -stem_height),
		stem_color,
		4.0
	)

	draw_circle(Vector2(-cell_size * 0.09, -stem_height * 0.45), cell_size * 0.09, Color(0.12, 0.35, 0.18))
	draw_circle(Vector2(cell_size * 0.09, -stem_height * 0.25), cell_size * 0.09, Color(0.12, 0.35, 0.18))

	var flower_center: Vector2 = Vector2(0.0, -stem_height)
	draw_circle(flower_center + Vector2(-petal_radius, 0.0), petal_radius, petal_a)
	draw_circle(flower_center + Vector2(petal_radius, 0.0), petal_radius, petal_b)
	draw_circle(flower_center + Vector2(0.0, -petal_radius), petal_radius, petal_b)
	draw_circle(flower_center + Vector2(0.0, petal_radius), petal_radius, petal_a)
	draw_circle(flower_center, petal_radius * 0.7, Color(1.0, 1.0, 0.9))

	if is_mature():
		draw_mature_ring(Color(1.0, 0.95, 0.45, 0.95))

	draw_growth_bar(growth_ratio, Color(1.0, 0.85, 0.35, 0.9))

func draw_ember_fern() -> void:
	var growth_ratio: float = float(clamp(growth / max_growth, 0.0, 1.0))
	var leaf_height: float = float(lerp(cell_size * 0.18, cell_size * 0.34, growth_ratio))
	var leaf_color: Color = Color(0.7, 0.3, 0.15)

	if belief >= growth_threshold:
		leaf_color = Color(1.0, 0.45, 0.18)
	elif belief < 20.0:
		leaf_color = Color(0.28, 0.18, 0.16)

	draw_line(Vector2(0.0, cell_size * 0.18), Vector2(0.0, -leaf_height * 0.45), Color(0.35, 0.28, 0.18), 3.0)
	draw_circle(Vector2(-10.0, -4.0), cell_size * 0.12, leaf_color)
	draw_circle(Vector2(10.0, -10.0), cell_size * 0.11, leaf_color)
	draw_circle(Vector2(0.0, -leaf_height * 0.45), cell_size * 0.13, Color(1.0, 0.75, 0.18))

	if is_mature():
		draw_mature_ring(Color(1.0, 0.65, 0.25, 0.95))

	draw_growth_bar(growth_ratio, Color(1.0, 0.5, 0.2, 0.9))

func draw_mirror_reed() -> void:
	var growth_ratio: float = float(clamp(growth / max_growth, 0.0, 1.0))
	var stem_height: float = float(lerp(cell_size * 0.16, cell_size * 0.38, growth_ratio))
	var stem_color: Color = Color(0.55, 0.8, 0.95)

	if belief < 20.0:
		stem_color = Color(0.28, 0.35, 0.42)

	draw_line(Vector2(-6.0, cell_size * 0.16), Vector2(-2.0, -stem_height * 0.45), stem_color, 3.0)
	draw_line(Vector2(6.0, cell_size * 0.16), Vector2(2.0, -stem_height * 0.55), stem_color, 3.0)
	draw_circle(Vector2(-6.0, -stem_height * 0.25), cell_size * 0.08, Color(0.82, 0.95, 1.0))
	draw_circle(Vector2(8.0, -stem_height * 0.5), cell_size * 0.1, Color(0.72, 0.9, 1.0))
	draw_circle(Vector2(1.0, -stem_height * 0.62), cell_size * 0.06, Color(1.0, 1.0, 1.0))

	if is_mature():
		draw_mature_ring(Color(0.75, 0.95, 1.0, 0.95))

	draw_growth_bar(growth_ratio, Color(0.65, 0.9, 1.0, 0.9))

func draw_chorus_bulb() -> void:
	var growth_ratio: float = float(clamp(growth / max_growth, 0.0, 1.0))
	var bulb_radius: float = float(lerp(cell_size * 0.12, cell_size * 0.2, growth_ratio))
	var bulb_color: Color = Color(0.9, 0.75, 0.25)

	if belief >= growth_threshold:
		bulb_color = Color(1.0, 0.9, 0.28)
	elif belief < 20.0:
		bulb_color = Color(0.28, 0.24, 0.16)

	draw_circle(Vector2.ZERO, bulb_radius * 1.3, Color(0.18, 0.55, 0.25))
	draw_circle(Vector2.ZERO, bulb_radius, bulb_color)
	draw_circle(Vector2(-10.0, -6.0), cell_size * 0.07, Color(0.85, 1.0, 0.55))
	draw_circle(Vector2(10.0, -6.0), cell_size * 0.07, Color(0.85, 1.0, 0.55))
	draw_circle(Vector2(0.0, -16.0), cell_size * 0.06, Color(0.85, 1.0, 0.55))

	if is_mature():
		draw_mature_ring(Color(1.0, 0.95, 0.55, 0.95))

	draw_growth_bar(growth_ratio, Color(1.0, 0.9, 0.4, 0.9))

func draw_echo_blossom() -> void:
	var growth_ratio: float = float(clamp(growth / max_growth, 0.0, 1.0))
	var memory_ratio: float = float(clamp(get_average_phase_memory() / 100.0, 0.0, 1.0))
	var center: Vector2 = Vector2(0.0, -cell_size * 0.08)
	var petal_radius: float = float(lerp(cell_size * 0.07, cell_size * 0.12, growth_ratio))
	var left_color: Color = Color(0.95, 0.8, 0.35)
	var right_color: Color = Color(0.6, 0.85, 1.0)

	if memory_ratio < 0.35:
		left_color = Color(0.35, 0.28, 0.18)
		right_color = Color(0.2, 0.24, 0.34)

	draw_line(Vector2(0.0, cell_size * 0.18), Vector2(0.0, -cell_size * 0.12), Color(0.24, 0.5, 0.3), 4.0)
	draw_circle(center + Vector2(-petal_radius * 1.2, 0.0), petal_radius, left_color)
	draw_circle(center + Vector2(petal_radius * 1.2, 0.0), petal_radius, right_color)
	draw_circle(center + Vector2(0.0, -petal_radius * 1.15), petal_radius, right_color)
	draw_circle(center + Vector2(0.0, petal_radius * 1.15), petal_radius, left_color)
	draw_circle(center, petal_radius * 0.65, Color(1.0, 1.0, 0.95))

	if is_mature():
		draw_mature_ring(Color(0.95, 0.95, 1.0, 0.95))

	draw_growth_bar(growth_ratio, Color(0.82, 0.92, 1.0, 0.9))

func draw_mature_ring(ring_color: Color) -> void:
	draw_arc(
		Vector2.ZERO,
		cell_size * 0.42,
		0.0,
		TAU,
		48,
		ring_color,
		3.0
	)

func draw_growth_bar(growth_ratio: float, bar_color: Color) -> void:
	var bar_width: float = cell_size * 0.7
	var bar_height: float = 5.0
	var bar_x: float = -bar_width * 0.5
	var bar_y: float = cell_size * 0.36

	draw_rect(
		Rect2(Vector2(bar_x, bar_y), Vector2(bar_width, bar_height)),
		Color(0.1, 0.1, 0.1, 0.8),
		true
	)

	draw_rect(
		Rect2(Vector2(bar_x, bar_y), Vector2(bar_width * growth_ratio, bar_height)),
		bar_color,
		true
	)

func draw_isolation_screen() -> void:
	var half: float = cell_size * 0.5
	var padding: float = 6.0
	var width: float = cell_size - padding * 2.0
	var height: float = cell_size - padding * 2.0

	var rect: Rect2 = Rect2(
		Vector2(-half + padding, -half + padding),
		Vector2(width, height)
	)

	draw_rect(rect, Color(0.35, 0.35, 0.38), true)
	draw_rect(rect, Color(0.75, 0.75, 0.8), false, 2.0)

	var stripe_count: int = 3

	for i in range(stripe_count):
		var t: float = float(i + 1) / float(stripe_count + 1)
		var x: float = rect.position.x + rect.size.x * t

		draw_line(
			Vector2(x, rect.position.y + 4.0),
			Vector2(x, rect.position.y + rect.size.y - 4.0),
			Color(0.18, 0.18, 0.2),
			2.0
		)

func draw_rot_scent_pot() -> void:
	var half: float = cell_size * 0.5
	var padding: float = 9.0
	var size: Vector2 = Vector2(cell_size - padding * 2.0, cell_size - padding * 2.0)
	var top_left: Vector2 = Vector2(-half + padding, -half + padding)

	draw_rect(Rect2(top_left, size), Color(0.28, 0.18, 0.12), true)
	draw_rect(Rect2(top_left, size), Color(0.55, 0.35, 0.18), false, 2.0)

	draw_circle(Vector2(-8.0, -8.0), 4.0, Color(0.35, 0.8, 0.2, 0.8))
	draw_circle(Vector2(4.0, -12.0), 3.0, Color(0.35, 0.8, 0.2, 0.65))
	draw_circle(Vector2(10.0, -4.0), 2.5, Color(0.35, 0.8, 0.2, 0.55))

func draw_frog_sound_box() -> void:
	var half: float = cell_size * 0.5
	var padding: float = 9.0
	var size: Vector2 = Vector2(cell_size - padding * 2.0, cell_size - padding * 2.0)
	var top_left: Vector2 = Vector2(-half + padding, -half + padding)

	draw_rect(Rect2(top_left, size), Color(0.1, 0.35, 0.18), true)
	draw_rect(Rect2(top_left, size), Color(0.35, 0.85, 0.45), false, 2.0)

	draw_circle(Vector2(-6.0, -4.0), 3.0, Color(0.8, 1.0, 0.75))
	draw_circle(Vector2(6.0, -4.0), 3.0, Color(0.8, 1.0, 0.75))

	draw_arc(Vector2.ZERO, 10.0, 0.2, 2.9, 16, Color(0.75, 1.0, 0.75), 2.0)

func draw_harvester() -> void:
	var half: float = cell_size * 0.5
	var padding: float = 8.0
	var size: Vector2 = Vector2(cell_size - padding * 2.0, cell_size - padding * 2.0)
	var top_left: Vector2 = Vector2(-half + padding, -half + padding)

	draw_rect(Rect2(top_left, size), Color(0.45, 0.42, 0.36), true)
	draw_rect(Rect2(top_left, size), Color(0.95, 0.85, 0.55), false, 2.0)

	draw_circle(Vector2.ZERO, cell_size * 0.16, Color(0.12, 0.1, 0.08))
	draw_circle(Vector2.ZERO, cell_size * 0.08, Color(0.95, 0.85, 0.45))

	draw_line(Vector2(-14.0, 0.0), Vector2(14.0, 0.0), Color(0.95, 0.85, 0.45), 3.0)
	draw_line(Vector2(0.0, -14.0), Vector2(0.0, 14.0), Color(0.95, 0.85, 0.45), 3.0)

func draw_moon_lantern() -> void:
	var half: float = cell_size * 0.5
	var padding: float = 8.0
	var size: Vector2 = Vector2(cell_size - padding * 2.0, cell_size - padding * 2.0)
	var top_left: Vector2 = Vector2(-half + padding, -half + padding)

	draw_rect(Rect2(top_left, size), Color(0.08, 0.1, 0.22), true)
	draw_rect(Rect2(top_left, size), Color(0.45, 0.65, 1.0), false, 2.0)

	draw_circle(Vector2.ZERO, cell_size * 0.18, Color(0.45, 0.65, 1.0, 0.95))
	draw_circle(Vector2(cell_size * 0.06, -cell_size * 0.04), cell_size * 0.18, Color(0.08, 0.1, 0.22, 0.95))

func draw_silence_box() -> void:
	var half: float = cell_size * 0.5
	var padding: float = 8.0
	var size: Vector2 = Vector2(cell_size - padding * 2.0, cell_size - padding * 2.0)
	var top_left: Vector2 = Vector2(-half + padding, -half + padding)

	draw_rect(Rect2(top_left, size), Color(0.12, 0.12, 0.16), true)
	draw_rect(Rect2(top_left, size), Color(0.7, 0.75, 0.9), false, 2.0)

	draw_line(Vector2(-12.0, -12.0), Vector2(12.0, 12.0), Color(0.9, 0.9, 1.0), 3.0)
	draw_line(Vector2(12.0, -12.0), Vector2(-12.0, 12.0), Color(0.9, 0.9, 1.0), 3.0)

func draw_timer() -> void:
	var half: float = cell_size * 0.5
	var padding: float = 8.0
	var size: Vector2 = Vector2(cell_size - padding * 2.0, cell_size - padding * 2.0)
	var top_left: Vector2 = Vector2(-half + padding, -half + padding)

	var body_color: Color = Color(0.18, 0.18, 0.22)
	var outline_color: Color = Color(0.85, 0.85, 0.95)

	if timer_is_on:
		outline_color = Color(0.45, 1.0, 0.45)
	else:
		outline_color = Color(1.0, 0.3, 0.3)

	draw_rect(Rect2(top_left, size), body_color, true)
	draw_rect(Rect2(top_left, size), outline_color, false, 2.0)

	draw_circle(Vector2.ZERO, cell_size * 0.23, Color(0.08, 0.08, 0.1))
	draw_arc(Vector2.ZERO, cell_size * 0.23, -PI * 0.5, PI * 1.25, 32, outline_color, 3.0)

	draw_line(Vector2.ZERO, Vector2(0.0, -cell_size * 0.16), outline_color, 2.0)
	draw_line(Vector2.ZERO, Vector2(cell_size * 0.12, 0.0), outline_color, 2.0)

func draw_compost_heater() -> void:
	var half: float = cell_size * 0.5
	var padding: float = 8.0
	var size: Vector2 = Vector2(cell_size - padding * 2.0, cell_size - padding * 2.0)
	var top_left: Vector2 = Vector2(-half + padding, -half + padding)

	draw_rect(Rect2(top_left, size), Color(0.3, 0.18, 0.12), true)
	draw_rect(Rect2(top_left, size), Color(0.92, 0.48, 0.2), false, 2.0)
	draw_circle(Vector2(-6.0, -4.0), 4.0, Color(1.0, 0.58, 0.18))
	draw_circle(Vector2(4.0, -10.0), 3.0, Color(0.55, 0.85, 0.3, 0.7))
	draw_circle(Vector2(10.0, -2.0), 3.0, Color(1.0, 0.72, 0.25, 0.8))

func draw_wind_turbine() -> void:
	var body_color: Color = Color(0.28, 0.34, 0.4)
	var blade_color: Color = Color(0.75, 0.88, 1.0)

	draw_line(Vector2(0.0, 14.0), Vector2(0.0, -8.0), body_color, 4.0)
	draw_circle(Vector2(0.0, -8.0), 4.5, blade_color)
	draw_line(Vector2(0.0, -8.0), Vector2(0.0, -18.0), blade_color, 3.0)
	draw_line(Vector2(0.0, -8.0), Vector2(-10.0, -3.0), blade_color, 3.0)
	draw_line(Vector2(0.0, -8.0), Vector2(10.0, -3.0), blade_color, 3.0)

func draw_choir_bell() -> void:
	var half: float = cell_size * 0.5
	var padding: float = 8.0
	var size: Vector2 = Vector2(cell_size - padding * 2.0, cell_size - padding * 2.0)
	var top_left: Vector2 = Vector2(-half + padding, -half + padding)

	draw_rect(Rect2(top_left, size), Color(0.18, 0.18, 0.24), true)
	draw_rect(Rect2(top_left, size), Color(0.95, 0.88, 0.45), false, 2.0)
	draw_circle(Vector2.ZERO, cell_size * 0.16, Color(0.95, 0.88, 0.45))
	draw_line(Vector2(-14.0, -12.0), Vector2(14.0, -12.0), Color(0.75, 0.8, 1.0), 2.0)
	draw_line(Vector2(0.0, 0.0), Vector2(0.0, 10.0), Color(0.75, 0.8, 1.0), 2.0)
