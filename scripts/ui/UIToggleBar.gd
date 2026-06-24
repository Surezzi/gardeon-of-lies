extends PanelContainer
class_name UIToggleBar

@export var left_sidebar: Control
@export var right_sidebar: Control

var factory_button: Button = null
var tools_button: Button = null

func _ready() -> void:
	build_ui_if_needed()
	UIThemeHelper.apply_panel_style(self)

	if left_sidebar != null:
		left_sidebar.visible = false

	if right_sidebar != null:
		right_sidebar.visible = false

	refresh_buttons()

func build_ui_if_needed() -> void:
	var margin_container: MarginContainer = get_node_or_null("MarginContainer") as MarginContainer

	if margin_container == null:
		margin_container = MarginContainer.new()
		margin_container.name = "MarginContainer"
		add_child(margin_container)

	margin_container.add_theme_constant_override("margin_left", 8)
	margin_container.add_theme_constant_override("margin_top", 8)
	margin_container.add_theme_constant_override("margin_right", 8)
	margin_container.add_theme_constant_override("margin_bottom", 8)

	var hbox_container: HBoxContainer = margin_container.get_node_or_null("HBoxContainer") as HBoxContainer

	if hbox_container == null:
		hbox_container = HBoxContainer.new()
		hbox_container.name = "HBoxContainer"
		hbox_container.add_theme_constant_override("separation", 8)
		margin_container.add_child(hbox_container)

	factory_button = ensure_button(hbox_container, "FactoryButton", "Factory")
	tools_button = ensure_button(hbox_container, "ToolsButton", "Tools")

	factory_button.pressed.connect(_on_factory_pressed)
	tools_button.pressed.connect(_on_tools_pressed)

func ensure_button(parent: Node, node_name: String, text_value: String) -> Button:
	var button: Button = parent.get_node_or_null(node_name) as Button

	if button == null:
		button = Button.new()
		button.name = node_name
		parent.add_child(button)

	button.toggle_mode = true
	button.text = text_value
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return button

func _on_factory_pressed() -> void:
	if left_sidebar == null:
		return

	left_sidebar.visible = not left_sidebar.visible
	refresh_buttons()

func _on_tools_pressed() -> void:
	if right_sidebar == null:
		return

	right_sidebar.visible = not right_sidebar.visible
	refresh_buttons()

func refresh_buttons() -> void:
	if factory_button != null:
		var factory_open: bool = left_sidebar != null and left_sidebar.visible
		factory_button.button_pressed = factory_open
		factory_button.text = "Factory" if not factory_open else "Hide Factory"
		UIThemeHelper.apply_primary_button_style(factory_button, factory_open)

	if tools_button != null:
		var tools_open: bool = right_sidebar != null and right_sidebar.visible
		tools_button.button_pressed = tools_open
		tools_button.text = "Tools" if not tools_open else "Hide Tools"
		UIThemeHelper.apply_primary_button_style(tools_button, tools_open)
