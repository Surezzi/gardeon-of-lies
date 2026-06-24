extends PanelContainer
class_name GameStatusPanel

@export var grid_system: GridSystem
@export var build_system: Node2D
@export var selection_system: SelectionSystem
@export var signal_overlay: SignalOverlay
@export var inventory_system: InventorySystem

var objective_label: Label = null
var hover_label: Label = null
var selected_label: Label = null
var overlay_label: Label = null
var hint_label: Label = null
var overlay_buttons: HFlowContainer = null

func _ready() -> void:
	build_ui_if_needed()
	UIThemeHelper.apply_panel_style(self)
	setup_static_text()

	if build_system != null and build_system.has_signal("selected_object_changed"):
		build_system.selected_object_changed.connect(_on_selected_build_changed)

	if selection_system != null:
		selection_system.inspected_object_changed.connect(_on_inspected_object_changed)

	if signal_overlay != null:
		signal_overlay.overlay_changed.connect(_on_overlay_changed)

	if inventory_system != null:
		inventory_system.inventory_changed.connect(update_objective)

	update_objective()
	update_hover()
	update_selected_build()
	update_overlay()
	rebuild_overlay_buttons()

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

	objective_label = ensure_label(vbox_container, "ObjectiveLabel")
	hover_label = ensure_label(vbox_container, "HoverLabel")
	selected_label = ensure_label(vbox_container, "SelectedLabel")
	overlay_label = ensure_label(vbox_container, "OverlayLabel")

	overlay_buttons = vbox_container.get_node_or_null("OverlayButtons") as HFlowContainer
	if overlay_buttons == null:
		overlay_buttons = HFlowContainer.new()
		overlay_buttons.name = "OverlayButtons"
		overlay_buttons.add_theme_constant_override("h_separation", 6)
		overlay_buttons.add_theme_constant_override("v_separation", 6)
		vbox_container.add_child(overlay_buttons)

	hint_label = ensure_label(vbox_container, "HintLabel")

func ensure_label(parent: Node, node_name: String) -> Label:
	var label: Label = parent.get_node_or_null(node_name) as Label

	if label == null:
		label = Label.new()
		label.name = node_name
		parent.add_child(label)

	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func setup_static_text() -> void:
	hint_label.text = (
		"Mouse-first controls: left click empty to place, left click object to inspect, right click to remove."
	)

	var styler: UIThemeHelper = UIThemeHelper.new()
	styler.apply_section_style(objective_label)
	styler.apply_body_style(hover_label)
	styler.apply_body_style(selected_label)
	styler.apply_body_style(overlay_label)
	styler.apply_muted_style(hint_label)

func _process(_delta: float) -> void:
	update_hover()

func update_objective() -> void:
	if objective_label == null:
		return

	if inventory_system == null:
		objective_label.text = "Goal: stabilize the garden."
		return

	var needles: int = inventory_system.get_item_amount("glass_needle")
	var resin: int = inventory_system.get_item_amount("rot_resin")
	var pollen: int = inventory_system.get_item_amount("sleepy_pollen")
	var petals: int = inventory_system.get_item_amount("paradox_petal")
	var ember_dust: int = inventory_system.get_item_amount("ember_dust")
	var mirror_fiber: int = inventory_system.get_item_amount("mirror_fiber")
	var chorus_spore: int = inventory_system.get_item_amount("chorus_spore")
	var echo_bloom: int = inventory_system.get_item_amount("echo_bloom")

	if echo_bloom > 0:
		objective_label.text = "Mastery: complete. The Echo Blossom answered back."
		return

	var lattice: int = inventory_system.get_item_amount("crystal_lattice")
	var relay: int = inventory_system.get_item_amount("relay_matrix")
	var prism_frame: int = inventory_system.get_item_amount("prism_frame")
	var phase_resonator: int = inventory_system.get_item_amount("phase_resonator")

	if petals > 0:
		if prism_frame > 0 and phase_resonator > 0 and chorus_spore > 0:
			objective_label.text = "Mastery: place the Echo Blossom."
			return

		objective_label.text = (
			"Mastery: gather Ember Dust %s/1, Mirror Fiber %s/1, Chorus Spore %s/1."
			% [str(min(ember_dust, 1)), str(min(mirror_fiber, 1)), str(min(chorus_spore, 1))]
		)
		return

	if needles >= 1 and resin >= 1 and pollen >= 1 and (lattice <= 0 or relay <= 0):
		objective_label.text = "Goal: craft Crystal Lattice and Relay Matrix."
		return

	if needles >= 1 and resin >= 1 and pollen >= 1:
		objective_label.text = "Goal: place the Impossible Orchid."
		return

	objective_label.text = (
		"Goal: gather Needle %s/1, Resin %s/1, Pollen %s/1."
		% [str(min(needles, 1)), str(min(resin, 1)), str(min(pollen, 1))]
	)

func update_hover() -> void:
	if hover_label == null or grid_system == null:
		return

	var mouse_world_position: Vector2 = get_global_mouse_position()
	var grid_position: Vector2i = grid_system.world_to_grid(mouse_world_position)

	if not grid_system.is_inside_grid(grid_position):
		hover_label.text = "Hover: outside the garden."
		return

	var object: Node = grid_system.get_object_at(grid_position)

	if object is PlaceableObject:
		var placeable: PlaceableObject = object as PlaceableObject
		var status_text: String = "Hover: %s at %s." % [
			placeable.display_name,
			format_cell(grid_position)
		]

		if placeable.is_plant():
			status_text += " Growth %s%%." % str(round(placeable.growth))
		else:
			status_text += " Radius %s." % str(placeable.radius)

		hover_label.text = status_text
		return

	var build_hint: String = "ready"
	if build_system != null and build_system.has_method("can_place_selected_at"):
		if not bool(build_system.can_place_selected_at(grid_position)):
			build_hint = "blocked"

	hover_label.text = "Hover: empty cell %s, placement %s." % [format_cell(grid_position), build_hint]

func update_selected_build() -> void:
	if selected_label == null:
		return

	if build_system == null or not build_system.has_method("get_selected_summary"):
		selected_label.text = "Build: unavailable."
		return

	selected_label.text = "Build: " + String(build_system.get_selected_summary())

func update_overlay() -> void:
	if overlay_label == null or signal_overlay == null:
		return

	if signal_overlay.is_visible_overlay:
		overlay_label.text = "Overlay: " + format_overlay_name(signal_overlay.selected_signal)
	else:
		overlay_label.text = "Overlay: off"

func rebuild_overlay_buttons() -> void:
	if overlay_buttons == null:
		return

	for child in overlay_buttons.get_children():
		overlay_buttons.remove_child(child)
		child.queue_free()

	if signal_overlay == null or not signal_overlay.has_method("get_overlay_entries"):
		return

	var entries: Array[Dictionary] = signal_overlay.get_overlay_entries()

	for entry_variant in entries:
		var entry: Dictionary = entry_variant
		var signal_name: String = String(entry.get("signal_name", ""))
		var selected: bool = bool(entry.get("selected", false))
		var button: Button = Button.new()

		button.toggle_mode = true
		button.button_pressed = selected
		button.text = format_overlay_name(signal_name)
		button.tooltip_text = "Toggle %s overlay" % signal_name
		UIThemeHelper.apply_primary_button_style(button, selected)
		button.pressed.connect(_on_overlay_button_pressed.bind(signal_name))
		overlay_buttons.add_child(button)

	var clear_button: Button = Button.new()
	clear_button.text = "Hide"
	UIThemeHelper.apply_primary_button_style(clear_button, false)
	clear_button.pressed.connect(_on_hide_overlay_pressed)
	overlay_buttons.add_child(clear_button)

func _on_overlay_button_pressed(signal_name: String) -> void:
	if signal_overlay == null:
		return

	signal_overlay.toggle_signal(signal_name)
	rebuild_overlay_buttons()

func _on_hide_overlay_pressed() -> void:
	if signal_overlay == null:
		return

	signal_overlay.hide_overlay()
	rebuild_overlay_buttons()

func format_overlay_name(signal_name: String) -> String:
	return signal_name.capitalize().replace("_", " ")

func format_cell(grid_position: Vector2i) -> String:
	return "(%s, %s)" % [str(grid_position.x), str(grid_position.y)]

func _on_selected_build_changed(_object_id: String, _display_name: String, _cost_text: String) -> void:
	update_selected_build()

func _on_inspected_object_changed(_object) -> void:
	update_hover()

func _on_overlay_changed(_signal_name: String, _visible_now: bool) -> void:
	update_overlay()
	rebuild_overlay_buttons()
