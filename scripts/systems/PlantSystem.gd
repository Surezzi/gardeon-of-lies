extends Node2D
class_name PlantSystem

@export var grid_system: GridSystem
@export var object_root: Node2D
@export var signal_map_system: SignalMapSystem

var update_interval: float = 0.25
var update_timer: float = 0.0

var debug_print_interval: float = 1.0
var debug_print_timer: float = 0.0
var debug_enabled: bool = false

var phase_memory_gain_rate: float = 10.0
var phase_memory_decay_rate: float = 3.0
var phase_match_threshold: float = 70.0

func _ready() -> void:
	if grid_system == null:
		push_error("PlantSystem: grid_system is not assigned.")

	if object_root == null:
		push_error("PlantSystem: object_root is not assigned.")

	if signal_map_system == null:
		push_error("PlantSystem: signal_map_system is not assigned.")

func _process(delta: float) -> void:
	update_timer += delta
	if update_timer >= update_interval:
		update_timer = 0.0
		update_plants(update_interval)

	if not debug_enabled:
		return

	debug_print_timer += delta

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

	var new_phase_memory: Dictionary = update_phase_memory(plant, signals, delta)
	var phase_score: float = calculate_phase_score(new_phase_memory)

	var belief: float = 0.0

	if plant.required_phases.is_empty():
		belief = float(clamp(positive - negative, 0.0, 100.0))
	else:
		belief = float(clamp(phase_score - negative, 0.0, 100.0))

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
		signals,
		new_phase_memory,
		phase_score
	)

func update_phase_memory(plant: PlaceableObject, signals: Dictionary, delta: float) -> Dictionary:
	var new_memory: Dictionary = Dictionary(plant.phase_memory)

	if plant.required_phases.is_empty():
		return new_memory

	for phase_name_variant in plant.required_phases.keys():
		var phase_name: String = String(phase_name_variant)
		var requirements: Dictionary = Dictionary(plant.required_phases[phase_name_variant])
		var match_score: float = calculate_phase_match(requirements, signals)

		var current_memory: float = float(new_memory.get(phase_name, 0.0))

		if match_score >= phase_match_threshold:
			current_memory += delta * phase_memory_gain_rate
		else:
			current_memory -= delta * phase_memory_decay_rate

		current_memory = float(clamp(current_memory, 0.0, 100.0))
		new_memory[phase_name] = current_memory

	return new_memory

func calculate_phase_match(requirements: Dictionary, signals: Dictionary) -> float:
	if requirements.is_empty():
		return 0.0

	var total_required: float = 0.0
	var total_matched: float = 0.0

	for signal_name_variant in requirements.keys():
		var signal_name: String = String(signal_name_variant)
		var required_amount: float = float(requirements[signal_name_variant])
		var current_amount: float = float(signals.get(signal_name, 0.0))

		total_required += required_amount
		total_matched += min(current_amount, required_amount)

	if total_required <= 0.0:
		return 0.0

	return float(clamp((total_matched / total_required) * 100.0, 0.0, 100.0))

func calculate_phase_score(memory: Dictionary) -> float:
	if memory.is_empty():
		return 0.0

	var total: float = 0.0

	for phase_name_variant in memory.keys():
		total += float(memory[phase_name_variant])

	return total / float(memory.size())

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
					round(plant.growth),
					" | phase: ",
					round(plant.phase_score)
				)
