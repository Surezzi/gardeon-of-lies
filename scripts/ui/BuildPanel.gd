extends PanelContainer
class_name BuildPanel

@export var build_system: Node

var title_label: Label = null
var selected_label: Label = null
var cost_label: Label = null
var help_label: Label = null
var catalog_scroll: ScrollContainer = null
var catalog_container: VBoxContainer = null

func _ready() -> void:
	build_ui_if_needed()
	UIThemeHelper.apply_panel_style(self)
	setup_default_text()
	connect_build_system()
	rebuild_catalog()

func build_ui_if_needed() -> void:
	var margin_container: MarginContainer = get_node_or_null("MarginContainer") as MarginContainer

	if margin_container == null:
		margin_container = MarginContainer.new()
		margin_container.name = "MarginContainer"
		add_child(margin_container)

	margin_container.add_theme_constant_override("margin_left", 12)
	margin_container.add_theme_constant_override("margin_top", 12)
	margin_container.add_theme_constant_override("margin_right", 12)
	margin_container.add_theme_constant_override("margin_bottom", 12)

	var vbox_container: VBoxContainer = margin_container.get_node_or_null("VBoxContainer") as VBoxContainer

	if vbox_container == null:
		vbox_container = VBoxContainer.new()
		vbox_container.name = "VBoxContainer"
		margin_container.add_child(vbox_container)

	vbox_container.add_theme_constant_override("separation", 8)

	title_label = ensure_label(vbox_container, "TitleLabel")
	selected_label = ensure_label(vbox_container, "SelectedLabel")
	cost_label = ensure_label(vbox_container, "CostLabel")

	catalog_scroll = vbox_container.get_node_or_null("CatalogScroll") as ScrollContainer
	if catalog_scroll == null:
		catalog_scroll = ScrollContainer.new()
		catalog_scroll.name = "CatalogScroll"
		catalog_scroll.custom_minimum_size = Vector2(0, 220)
		catalog_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vbox_container.add_child(catalog_scroll)

	catalog_container = catalog_scroll.get_node_or_null("CatalogContainer") as VBoxContainer
	if catalog_container == null:
		catalog_container = VBoxContainer.new()
		catalog_container.name = "CatalogContainer"
		catalog_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		catalog_container.add_theme_constant_override("separation", 10)
		catalog_scroll.add_child(catalog_container)

	var separator: HSeparator = vbox_container.get_node_or_null("Separator") as HSeparator
	if separator == null:
		separator = HSeparator.new()
		separator.name = "Separator"
		vbox_container.add_child(separator)

	help_label = ensure_label(vbox_container, "HelpLabel")
	help_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func ensure_label(parent: Node, node_name: String) -> Label:
	var label: Label = parent.get_node_or_null(node_name) as Label

	if label == null:
		label = Label.new()
		label.name = node_name
		parent.add_child(label)

	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func setup_default_text() -> void:
	title_label.text = "Build Palette"
	selected_label.text = "Selected: -"
	cost_label.text = "Cost: -"
	help_label.text = (
		"Primary controls:\n"
		+ "Left click empty cell to place.\n"
		+ "Left click object to inspect.\n"
		+ "Right click to remove.\n"
		+ "Use the buttons below or hotkeys to switch tools."
	)

	var styler: UIThemeHelper = UIThemeHelper.new()
	styler.apply_title_style(title_label)
	styler.apply_body_style(selected_label)
	styler.apply_body_style(cost_label)
	styler.apply_muted_style(help_label)

func connect_build_system() -> void:
	if build_system == null:
		push_error("BuildPanel: build_system is not assigned.")
		return

	if build_system.has_signal("selected_object_changed"):
		build_system.selected_object_changed.connect(_on_selected_object_changed)
	else:
		push_error("BuildPanel: build_system has no selected_object_changed signal.")

	if build_system.has_method("get_selected_display_name"):
		selected_label.text = "Selected: " + String(build_system.get_selected_display_name())

	if build_system.has_method("get_selected_cost_text"):
		cost_label.text = "Cost: " + String(build_system.get_selected_cost_text())

func rebuild_catalog() -> void:
	if catalog_container == null:
		return

	for child in catalog_container.get_children():
		catalog_container.remove_child(child)
		child.queue_free()

	if build_system == null or not build_system.has_method("get_build_entries"):
		return

	var entries: Array[Dictionary] = build_system.get_build_entries()
	var groups: Dictionary = {
		"Plants": [],
		"Devices": []
	}

	for entry_variant in entries:
		var entry: Dictionary = entry_variant
		var category: String = String(entry.get("category", "Devices"))

		if not groups.has(category):
			groups[category] = []

		var category_entries: Array = groups[category]
		category_entries.append(entry)
		groups[category] = category_entries

	add_category("Plants", groups["Plants"])
	add_category("Devices", groups["Devices"])

func add_category(title: String, entries: Array) -> void:
	if entries.is_empty():
		return

	var section_label: Label = Label.new()
	section_label.text = title
	UIThemeHelper.new().apply_section_style(section_label)
	catalog_container.add_child(section_label)

	var buttons_container: VBoxContainer = VBoxContainer.new()
	buttons_container.add_theme_constant_override("separation", 6)
	catalog_container.add_child(buttons_container)

	for entry_variant in entries:
		var entry: Dictionary = entry_variant
		var button: Button = Button.new()
		var object_id: String = String(entry.get("object_id", ""))
		var display_name: String = String(entry.get("display_name", object_id))
		var cost_text: String = String(entry.get("cost_text", "free"))
		var hotkey: String = String(entry.get("hotkey", ""))
		var selected: bool = bool(entry.get("selected", false))
		var locked: bool = bool(entry.get("locked", false))
		var unlock_text: String = String(entry.get("unlock_text", ""))

		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.toggle_mode = true
		button.button_pressed = selected
		button.disabled = locked
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text = format_build_button_text(display_name, cost_text, hotkey, selected, locked)

		if locked and unlock_text != "":
			button.tooltip_text = "Locked until you have: %s" % unlock_text
		else:
			button.tooltip_text = "Select %s" % display_name

		UIThemeHelper.apply_primary_button_style(button, selected)
		button.pressed.connect(_on_build_button_pressed.bind(object_id))
		buttons_container.add_child(button)

func format_build_button_text(
	display_name: String,
	cost_text: String,
	hotkey: String,
	selected: bool,
	locked: bool
) -> String:
	var prefix: String = ""

	if selected:
		prefix = "> "
	elif locked:
		prefix = "Locked "

	if hotkey == "":
		return "%s%s\n%s" % [prefix, display_name, cost_text]

	return "%s%s [%s]\n%s" % [prefix, display_name, hotkey, cost_text]

func _on_build_button_pressed(object_id: String) -> void:
	if build_system == null:
		return

	if build_system.has_method("select_object"):
		build_system.select_object(object_id)

func _on_selected_object_changed(_object_id: String, display_name: String, cost_text: String) -> void:
	if selected_label != null:
		selected_label.text = "Selected: " + display_name

	if cost_label != null:
		cost_label.text = "Cost: " + cost_text

	rebuild_catalog()
