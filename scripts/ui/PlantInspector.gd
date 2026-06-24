extends PanelContainer
class_name PlantInspector

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var belief_label: Label = $MarginContainer/VBoxContainer/BeliefLabel
@onready var suspicion_label: Label = $MarginContainer/VBoxContainer/SuspicionLabel
@onready var growth_label: Label = $MarginContainer/VBoxContainer/GrowthLabel
@onready var positive_title_label: Label = $MarginContainer/VBoxContainer/PositiveTitleLabel
@onready var positive_signals_label: Label = $MarginContainer/VBoxContainer/PositiveSignalsLabel
@onready var negative_title_label: Label = $MarginContainer/VBoxContainer/NegativeTitleLabel
@onready var negative_signals_label: Label = $MarginContainer/VBoxContainer/NegativeSignalsLabel

var inspected_object: PlaceableObject = null

func _ready() -> void:
	UIThemeHelper.apply_panel_style(self)
	visible = false
	positive_title_label.text = "Helps:"
	negative_title_label.text = "Hurts:"

	var styler: UIThemeHelper = UIThemeHelper.new()
	styler.apply_title_style(title_label)
	styler.apply_body_style(belief_label)
	styler.apply_body_style(suspicion_label)
	styler.apply_body_style(growth_label)
	styler.apply_section_style(positive_title_label)
	styler.apply_body_style(positive_signals_label)
	styler.apply_section_style(negative_title_label)
	styler.apply_body_style(negative_signals_label)

func _process(_delta: float) -> void:
	if inspected_object == null:
		return

	if not is_instance_valid(inspected_object):
		clear()
		return

	update_view()

func inspect_object(placeable_object: PlaceableObject) -> void:
	inspected_object = placeable_object
	visible = true
	update_view()

func inspect_plant(plant: PlaceableObject) -> void:
	inspect_object(plant)

func clear() -> void:
	inspected_object = null
	visible = false

func update_view() -> void:
	if inspected_object == null:
		return

	title_label.text = inspected_object.display_name

	if inspected_object.is_plant():
		update_plant_view()
	else:
		update_device_view()

func update_plant_view() -> void:
	belief_label.text = "Belief: %s%%" % str(round(inspected_object.belief))
	suspicion_label.text = "Suspicion: %s%%" % str(round(inspected_object.suspicion))
	growth_label.text = "Growth: %s%% | Output: %s x%s" % [
		str(round(inspected_object.growth)),
		inspected_object.output_item_name,
		str(inspected_object.output_amount)
	]

	var positive_text: String = format_signal_dictionary(inspected_object.last_positive_signals, "+")

	if not inspected_object.phase_memory.is_empty():
		if positive_text == "-":
			positive_text = ""
		else:
			positive_text += "\n\n"

		positive_text += "Phase memory:\n"
		positive_text += format_phase_memory(inspected_object.phase_memory)
		positive_text += "\nAverage: %s%%" % str(round(inspected_object.phase_score))

	positive_title_label.text = "Helps:"
	negative_title_label.text = "Hurts:"
	positive_signals_label.text = positive_text
	negative_signals_label.text = format_signal_dictionary(inspected_object.last_negative_signals, "-")

func update_device_view() -> void:
	belief_label.text = "Type: device"
	suspicion_label.text = "Radius: %s" % str(inspected_object.radius)

	if inspected_object.can_be_toggled:
		growth_label.text = "Enabled: %s" % format_enabled_state(inspected_object.enabled)
	else:
		growth_label.text = "Enabled: fixed"

	if inspected_object.is_timer:
		growth_label.text += " | Phase: %s" % format_timer_phase()

	positive_title_label.text = "Properties:"
	negative_title_label.text = "Outputs:"
	positive_signals_label.text = format_device_details()
	negative_signals_label.text = format_signal_dictionary(inspected_object.get_signal_outputs(), "+")

func format_signal_dictionary(signals: Dictionary, prefix: String) -> String:
	if signals.is_empty():
		return "-"

	var lines: Array[String] = []

	for signal_name in signals.keys():
		var amount: float = float(signals[signal_name])
		lines.append("%s %s: %s" % [
			prefix,
			String(signal_name),
			str(round(amount))
		])

	return "\n".join(lines)

func format_phase_memory(memory: Dictionary) -> String:
	if memory.is_empty():
		return "-"

	var lines: Array[String] = []

	for phase_name_variant in memory.keys():
		var phase_name: String = String(phase_name_variant)
		var amount: float = float(memory[phase_name_variant])
		lines.append("%s: %s%%" % [phase_name, str(round(amount))])

	return "\n".join(lines)

func format_device_details() -> String:
	var lines: Array[String] = []

	if inspected_object.blocks_signals:
		lines.append("Blocks signals")

	if inspected_object.is_harvester:
		lines.append("Auto-harvester")

	if inspected_object.is_timer:
		lines.append(
			"Timer: %ss / %ss" % [
				str(snapped(inspected_object.timer_on_duration, 0.1)),
				str(snapped(inspected_object.timer_off_duration, 0.1))
			]
		)

	if lines.is_empty():
		lines.append("No special properties")

	return "\n".join(lines)

func format_enabled_state(is_enabled: bool) -> String:
	if is_enabled:
		return "yes"

	return "no"

func format_timer_phase() -> String:
	if inspected_object.timer_is_on:
		return "A"

	return "B"
