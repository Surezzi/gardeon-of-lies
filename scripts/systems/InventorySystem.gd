extends Node2D
class_name InventorySystem

signal inventory_changed

var items: Dictionary = {}
var item_names: Dictionary = {}

func add_item(item_id: String, item_name: String, amount: int) -> void:
	if item_id == "":
		return

	if amount <= 0:
		return

	items[item_id] = int(items.get(item_id, 0)) + amount
	item_names[item_id] = item_name

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
			return "Стеклянные иглы"

		"rot_resin":
			return "Болотная смола"

		"sleepy_pollen":
			return "Сонная пыльца"

		_:
			return item_id

func get_inventory_lines() -> Array[String]:
	var lines: Array[String] = []

	for item_id_variant in items.keys():
		var item_id: String = String(item_id_variant)
		var amount: int = int(items[item_id_variant])

		if amount <= 0:
			continue

		var item_name: String = get_item_name(item_id)
		lines.append("%s: %s" % [item_name, str(amount)])

	return lines

func format_cost(cost: Dictionary) -> String:
	if cost.is_empty():
		return "бесплатно"

	var parts: Array[String] = []

	for item_id_variant in cost.keys():
		var item_id: String = String(item_id_variant)
		var amount: int = int(cost[item_id_variant])
		var item_name: String = get_item_name(item_id)

		parts.append("%s x%s" % [item_name, str(amount)])

	return ", ".join(parts)
