extends Node2D
class_name PlantSystem

@export var grid_system: GridSystem
@export var object_root: Node2D
@export var signal_map_system: SignalMapSystem

var update_interval: float = 0.25
var update_timer: float = 0.0

var debug_print_interval: float = 1.0
var debug_print_timer: float = 0.0

func _ready() -> void:
	if grid_system == null:
		push_error("PlantSystem: grid_system is not assigned.")

	if object_root == null:
		push_error("PlantSystem: object_root is not assigned.")

	if signal_map_system == null:
		push_error("PlantSystem: signal_map_system is not assigned.")

func _process(delta: float) -> void:
	update_timer += delta
	debug_print_timer += delta

	if update_timer >= update_interval:
		update_timer = 0.0
		update_plants(update_interval)

	if debug_print_timer >= debug_print_interval:
		debug_print_timer = 0.0
		debug_print_plants()

func update_plants(delta: float) -> void:
	if object_root == null or signal_map_system == null:
		return

	for child in object_root.get_children():
		if child is PlaceableObject:
			var plant: PlaceableObject = child as PlaceableObject

			if plant.is_plant():
				update_plant(plant, delta)

func update_plant(plant: PlaceableObject, delta: float) -> void:
	var signals: Dictionary = signal_map_system.get_signals_at(plant.grid_position)

	var positive_signals: Dictionary = get_positive_signals(plant, signals)
	var negative_signals: Dictionary = get_negative_signals(plant, signals)

	var positive: float = sum_signal_values(positive_signals)
	var negative: float = sum_signal_values(negative_signals)

	var belief: float = float(clamp(positive - negative, 0.0, 100.0))
	var suspicion: float = calculate_suspicion(plant, signals)

	var growth_rate: float = belief - suspicion

	var new_growth: float = plant.growth

	if growth_rate >= plant.growth_threshold:
		new_growth += delta * growth_rate * 0.35
	else:
		new_growth -= delta * 2.0

	new_growth = float(clamp(new_growth, 0.0, plant.max_growth))

	plant.set_plant_state(
		belief,
		suspicion,
		new_growth,
		positive_signals,
		negative_signals,
		signals
	)

func get_positive_signals(plant: PlaceableObject, signals: Dictionary) -> Dictionary:
	var result: Dictionary = {}

	for signal_name in plant.likes.keys():
		var signal_amount: float = float(signals.get(signal_name, 0.0))
		var max_useful_amount: float = float(plant.likes[signal_name])
		var used_amount: float = min(signal_amount, max_useful_amount)

		if used_amount > 0.0:
			result[String(signal_name)] = used_amount

	return result

func get_negative_signals(plant: PlaceableObject, signals: Dictionary) -> Dictionary:
	var result: Dictionary = {}

	for signal_name in plant.dislikes.keys():
		var signal_amount: float = float(signals.get(signal_name, 0.0))
		var max_bad_amount: float = float(plant.dislikes[signal_name])
		var used_amount: float = min(signal_amount, max_bad_amount)

		if used_amount > 0.0:
			result[String(signal_name)] = used_amount

	return result

func sum_signal_values(values: Dictionary) -> float:
	var total: float = 0.0

	for key in values.keys():
		total += float(values[key])

	return total

func calculate_suspicion(plant: PlaceableObject, signals: Dictionary) -> float:
	var suspicion: float = 0.0

	for contradiction_data in plant.contradictions:
		if not contradiction_data is Array:
			continue

		var pair: Array = contradiction_data as Array

		if pair.size() < 2:
			continue

		var first_signal: String = String(pair[0])
		var second_signal: String = String(pair[1])

		var first_amount: float = float(signals.get(first_signal, 0.0))
		var second_amount: float = float(signals.get(second_signal, 0.0))

		if first_amount > 10.0 and second_amount > 10.0:
			suspicion += 20.0

	return suspicion

func debug_print_plants() -> void:
	if object_root == null:
		return

	for child in object_root.get_children():
		if child is PlaceableObject:
			var plant: PlaceableObject = child as PlaceableObject

			if plant.is_plant():
				print(
					plant.display_name,
					" | belief: ",
					round(plant.belief),
					" | suspicion: ",
					round(plant.suspicion),
					" | growth: ",
					round(plant.growth)
				)
