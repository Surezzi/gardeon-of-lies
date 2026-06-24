extends Node2D
class_name TimerSystem

@export var grid_system: GridSystem
@export var object_root: Node2D

var debug_timer_events: bool = false

var phase_a_offsets: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(-1, 0)
]

var phase_b_offsets: Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(0, -1)
]

func _ready() -> void:
	process_priority = -100

	if grid_system == null:
		grid_system = get_tree().current_scene.get_node_or_null("GridSystem") as GridSystem

	if object_root == null:
		object_root = get_tree().current_scene.get_node_or_null("ObjectRoot") as Node2D

	if grid_system == null:
		push_error("TimerSystem: grid_system is not assigned and could not be found.")

	if object_root == null:
		push_error("TimerSystem: object_root is not assigned and could not be found.")

func _process(delta: float) -> void:
	if grid_system == null or object_root == null:
		return

	reset_togglable_devices()
	update_timers(delta)

func reset_togglable_devices() -> void:
	for child in object_root.get_children():
		if not child is PlaceableObject:
			continue

		var device: PlaceableObject = child as PlaceableObject

		if not device.is_device():
			continue

		if not device.can_be_toggled:
			continue

		device.set_enabled_state(true)

func update_timers(delta: float) -> void:
	for child in object_root.get_children():
		if not child is PlaceableObject:
			continue

		var timer: PlaceableObject = child as PlaceableObject

		if not timer.is_device():
			continue

		if not timer.is_timer:
			continue

		var switched: bool = update_timer_state(timer, delta)
		var affected_count: int = apply_timer_to_adjacent_devices(timer)

		if switched and debug_timer_events:
			var state_text: String = "A"
			if not timer.timer_is_on:
				state_text = "B"

			print(
				"Timer at ",
				timer.grid_position,
				" switched to phase ",
				state_text,
				" | affected devices: ",
				affected_count
			)

func update_timer_state(timer: PlaceableObject, delta: float) -> bool:
	var new_elapsed: float = timer.timer_elapsed + delta
	var new_is_on: bool = timer.timer_is_on
	var switched: bool = false

	if new_is_on:
		if new_elapsed >= timer.timer_on_duration:
			new_elapsed = 0.0
			new_is_on = false
			switched = true
	else:
		if new_elapsed >= timer.timer_off_duration:
			new_elapsed = 0.0
			new_is_on = true
			switched = true

	timer.set_timer_state(new_is_on, new_elapsed)
	return switched

func apply_timer_to_adjacent_devices(timer: PlaceableObject) -> int:
	var affected_count: int = 0

	for offset in phase_a_offsets:
		var target_position: Vector2i = timer.grid_position + offset
		affected_count += set_device_at_position_enabled(target_position, timer.timer_is_on)

	for offset in phase_b_offsets:
		var target_position: Vector2i = timer.grid_position + offset
		affected_count += set_device_at_position_enabled(target_position, not timer.timer_is_on)

	return affected_count

func set_device_at_position_enabled(target_position: Vector2i, target_enabled: bool) -> int:
	if not grid_system.is_inside_grid(target_position):
		return 0

	var object: Node = grid_system.get_object_at(target_position)

	if not object is PlaceableObject:
		return 0

	var device: PlaceableObject = object as PlaceableObject

	if not device.is_device():
		return 0

	if not device.can_be_toggled:
		return 0

	if device.is_timer:
		return 0

	device.set_enabled_state(target_enabled)
	return 1
