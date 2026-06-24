extends PanelContainer
class_name CraftingPanel

@export var crafting_system: CraftingSystem

var title_label: Label = null
var help_label: Label = null
var recipe_scroll: ScrollContainer = null
var recipe_container: VBoxContainer = null

func _ready() -> void:
	build_ui_if_needed()
	UIThemeHelper.apply_panel_style(self)
	setup_text()
	connect_crafting_system()
	rebuild_recipes()

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

	recipe_scroll = vbox_container.get_node_or_null("RecipeScroll") as ScrollContainer
	if recipe_scroll == null:
		recipe_scroll = ScrollContainer.new()
		recipe_scroll.name = "RecipeScroll"
		recipe_scroll.custom_minimum_size = Vector2(0, 180)
		recipe_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vbox_container.add_child(recipe_scroll)

	recipe_container = recipe_scroll.get_node_or_null("RecipeContainer") as VBoxContainer
	if recipe_container == null:
		recipe_container = VBoxContainer.new()
		recipe_container.name = "RecipeContainer"
		recipe_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		recipe_container.add_theme_constant_override("separation", 10)
		recipe_scroll.add_child(recipe_container)

	help_label = ensure_label(vbox_container, "HelpLabel")

func ensure_label(parent: Node, node_name: String) -> Label:
	var label: Label = parent.get_node_or_null(node_name) as Label

	if label == null:
		label = Label.new()
		label.name = node_name
		parent.add_child(label)

	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func setup_text() -> void:
	title_label.text = "Crafting"
	help_label.text = "Turn harvests into machine parts before you invest in automation."

	var styler: UIThemeHelper = UIThemeHelper.new()
	styler.apply_title_style(title_label)
	styler.apply_muted_style(help_label)

func connect_crafting_system() -> void:
	if crafting_system == null:
		push_error("CraftingPanel: crafting_system is not assigned.")
		return

	crafting_system.recipes_changed.connect(rebuild_recipes)

func rebuild_recipes() -> void:
	if recipe_container == null:
		return

	for child in recipe_container.get_children():
		recipe_container.remove_child(child)
		child.queue_free()

	if crafting_system == null:
		return

	var entries: Array[Dictionary] = crafting_system.get_recipe_entries()
	var groups: Dictionary = {
		"Foundations": [],
		"Advanced": []
	}

	for entry_variant in entries:
		var entry: Dictionary = entry_variant
		var category: String = String(entry.get("category", "Foundations"))
		var category_entries: Array = groups.get(category, [])
		category_entries.append(entry)
		groups[category] = category_entries

	add_category("Foundations", groups["Foundations"])
	add_category("Advanced", groups["Advanced"])

func add_category(title: String, entries: Array) -> void:
	if entries.is_empty():
		return

	var section_label: Label = Label.new()
	section_label.text = title
	UIThemeHelper.new().apply_section_style(section_label)
	recipe_container.add_child(section_label)

	var buttons_container: VBoxContainer = VBoxContainer.new()
	buttons_container.add_theme_constant_override("separation", 6)
	recipe_container.add_child(buttons_container)

	for entry_variant in entries:
		var entry: Dictionary = entry_variant
		var button: Button = Button.new()
		var recipe_id: String = String(entry.get("recipe_id", ""))
		var display_name: String = String(entry.get("display_name", recipe_id))
		var cost_text: String = String(entry.get("cost_text", ""))
		var locked: bool = bool(entry.get("locked", false))
		var craftable: bool = bool(entry.get("craftable", false))
		var unlock_text: String = String(entry.get("unlock_text", ""))

		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.disabled = locked or not craftable
		button.text = format_recipe_text(display_name, cost_text, locked)

		if locked and unlock_text != "":
			button.tooltip_text = "Unlock with: %s" % unlock_text
		elif not craftable:
			button.tooltip_text = "Missing ingredients"
		else:
			button.tooltip_text = "Craft %s" % display_name

		UIThemeHelper.apply_primary_button_style(button, false)
		button.pressed.connect(_on_recipe_pressed.bind(recipe_id))
		buttons_container.add_child(button)

func format_recipe_text(display_name: String, cost_text: String, locked: bool) -> String:
	if locked:
		return "Locked %s\n%s" % [display_name, cost_text]

	return "Craft %s\n%s" % [display_name, cost_text]

func _on_recipe_pressed(recipe_id: String) -> void:
	if crafting_system == null:
		return

	crafting_system.craft_recipe(recipe_id)
