extends PanelContainer
class_name InventoryPanel

@export var inventory_system: InventorySystem

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var items_label: Label = $MarginContainer/VBoxContainer/ItemsLabel

func _ready() -> void:
	UIThemeHelper.apply_panel_style(self)
	title_label.text = "Inventory"
	items_label.text = "Empty for now"

	var styler: UIThemeHelper = UIThemeHelper.new()
	styler.apply_title_style(title_label)
	styler.apply_body_style(items_label)

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
		items_label.text = "Empty for now"
	else:
		items_label.text = "\n".join(lines)
