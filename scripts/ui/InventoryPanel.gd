extends PanelContainer
class_name InventoryPanel

@export var inventory_system: InventorySystem

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var items_label: Label = $MarginContainer/VBoxContainer/ItemsLabel

func _ready() -> void:
	title_label.text = "Инвентарь"
	items_label.text = "Пока пусто"

	if inventory_system == null:
		push_error("InventoryPanel: inventory_system is not assigned.")
		return

	inventory_system.inventory_changed.connect(update_view)
	update_view()

func update_view() -> void:
	if inventory_system == null:
		return

	var lines: Array[String] = inventory_system.get_inventory_lines()

	if lines.is_empty():
		items_label.text = "Пока пусто"
	else:
		items_label.text = "\n".join(lines)
