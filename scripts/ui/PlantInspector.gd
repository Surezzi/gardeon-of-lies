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

var inspected_plant: PlaceableObject = null

func _ready() -> void:
	visible = false
	positive_title_label.text = "Помогает:"
	negative_title_label.text = "Мешает:"

func _process(_delta: float) -> void:
	if inspected_plant == null:
		return

	if not is_instance_valid(inspected_plant):
		clear()
		return

	update_view()

func inspect_plant(plant: PlaceableObject) -> void:
	inspected_plant = plant
	visible = true
	update_view()

func clear() -> void:
	inspected_plant = null
	visible = false

func update_view() -> void:
	if inspected_plant == null:
		return

	title_label.text = inspected_plant.display_name

	belief_label.text = "Вера: %s%%" % str(round(inspected_plant.belief))
	suspicion_label.text = "Подозрение: %s%%" % str(round(inspected_plant.suspicion))
	growth_label.text = "Рост: %s%%" % str(round(inspected_plant.growth))

	positive_signals_label.text = format_signal_dictionary(inspected_plant.last_positive_signals, "+")
	negative_signals_label.text = format_signal_dictionary(inspected_plant.last_negative_signals, "-")

func format_signal_dictionary(signals: Dictionary, prefix: String) -> String:
	if signals.is_empty():
		return "—"

	var lines: Array[String] = []

	for signal_name in signals.keys():
		var amount: float = float(signals[signal_name])
		lines.append("%s %s: %s" % [
			prefix,
			String(signal_name),
			str(round(amount))
		])

	return "\n".join(lines)
