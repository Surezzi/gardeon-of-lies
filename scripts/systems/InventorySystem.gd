extends Node2D
class_name InventorySystem

signal inventory_changed

var items: Dictionary = {}
var item_names: Dictionary = {}
var log_actions: bool = false

func _ready() -> void:
	register_item_name("glass_needle", "Glass Needle")
	register_item_name("rot_resin", "Rot Resin")
	register_item_name("sleepy_pollen", "Sleepy Pollen")
	register_item_name("paradox_petal", "Paradox Petal")
	register_item_name("ember_dust", "Ember Dust")
	register_item_name("mirror_fiber", "Mirror Fiber")
	register_item_name("chorus_spore", "Chorus Spore")
	register_item_name("ember_core", "Ember Core")
	register_item_name("prism_frame", "Prism Frame")
	register_item_name("hush_coil", "Hush Coil")
	register_item_name("phase_resonator", "Phase Resonator")
	register_item_name("echo_bloom", "Echo Bloom")

func add_item(item_id: String, item_name: String, amount: int) -> void:
	if item_id == "":
		return

	if amount <= 0:
		return

	items[item_id] = int(items.get(item_id, 0)) + amount
	item_names[item_id] = item_name

	if log_actions:
		print("Inventory: +", amount, " ", item_name, " | total: ", int(items[item_id]))

	inventory_changed.emit()

func remove_item(item_id: String, amount: int) -> bool:
	if item_id == "":
		return false

	if amount <= 0:
		return true

	var current_amount: int = get_item_amount(item_id)

	if current_amount < amount:
		return false

	items[item_id] = current_amount - amount

	if int(items[item_id]) <= 0:
		items.erase(item_id)

	inventory_changed.emit()
	return true

func can_afford(cost: Dictionary) -> bool:
	for item_id_variant in cost.keys():
		var item_id: String = String(item_id_variant)
		var required_amount: int = int(cost[item_id_variant])

		if get_item_amount(item_id) < required_amount:
			return false

	return true

func spend_items(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false

	for item_id_variant in cost.keys():
		var item_id: String = String(item_id_variant)
		var required_amount: int = int(cost[item_id_variant])
		remove_item(item_id, required_amount)

	return true

func get_item_amount(item_id: String) -> int:
	return int(items.get(item_id, 0))

func get_item_name(item_id: String) -> String:
	return String(item_names.get(item_id, get_default_item_name(item_id)))

func register_item_name(item_id: String, item_name: String) -> void:
	if item_id == "":
		return

	item_names[item_id] = item_name
	inventory_changed.emit()

func get_default_item_name(item_id: String) -> String:
	match item_id:
		"glass_needle":
			return "Glass Needle"
		"rot_resin":
			return "Rot Resin"
		"sleepy_pollen":
			return "Sleepy Pollen"
		"paradox_petal":
			return "Paradox Petal"
		"ember_dust":
			return "Ember Dust"
		"mirror_fiber":
			return "Mirror Fiber"
		"chorus_spore":
			return "Chorus Spore"
		"ember_core":
			return "Ember Core"
		"prism_frame":
			return "Prism Frame"
		"hush_coil":
			return "Hush Coil"
		"phase_resonator":
			return "Phase Resonator"
		"echo_bloom":
			return "Echo Bloom"
		_:
			return item_id

func get_inventory_lines() -> Array[String]:
	var lines: Array[String] = []
	var item_ids: Array[String] = []

	for item_id_variant in items.keys():
		var item_id: String = String(item_id_variant)
		item_ids.append(item_id)

	item_ids.sort()

	for item_id in item_ids:
		var amount: int = int(items[item_id])

		if amount <= 0:
			continue

		var item_name: String = get_item_name(item_id)
		lines.append("%s: %s" % [item_name, str(amount)])

	return lines

func format_cost(cost: Dictionary) -> String:
	if cost.is_empty():
		return "free"

	var parts: Array[String] = []

	for item_id_variant in cost.keys():
		var item_id: String = String(item_id_variant)
		var amount: int = int(cost[item_id_variant])
		var item_name: String = get_item_name(item_id)
		parts.append("%s x%s" % [item_name, str(amount)])

	parts.sort()
	return ", ".join(parts)
