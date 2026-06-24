extends PanelContainer
class_name BuildPanel

@export var build_system: Node

var title_label: Label = null
var selected_label: Label = null
var cost_label: Label = null
var help_label: Label = null

func _ready() -> void:
	build_ui_if_needed()
	setup_default_text()
	connect_build_system()

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

	title_label = vbox_container.get_node_or_null("TitleLabel") as Label
	if title_label == null:
		title_label = Label.new()
		title_label.name = "TitleLabel"
		vbox_container.add_child(title_label)

	selected_label = vbox_container.get_node_or_null("SelectedLabel") as Label
	if selected_label == null:
		selected_label = Label.new()
		selected_label.name = "SelectedLabel"
		vbox_container.add_child(selected_label)

	cost_label = vbox_container.get_node_or_null("CostLabel") as Label
	if cost_label == null:
		cost_label = Label.new()
		cost_label.name = "CostLabel"
		vbox_container.add_child(cost_label)

	var separator: HSeparator = vbox_container.get_node_or_null("Separator") as HSeparator
	if separator == null:
		separator = HSeparator.new()
		separator.name = "Separator"
		vbox_container.add_child(separator)

	help_label = vbox_container.get_node_or_null("HelpLabel") as Label
	if help_label == null:
		help_label = Label.new()
		help_label.name = "HelpLabel"
		vbox_container.add_child(help_label)

	help_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func setup_default_text() -> void:
	title_label.text = "Постройка"
	selected_label.text = "Выбрано: —"
	cost_label.text = "Цена: —"

	help_label.text = (
		"1 — Стеклянный кактус\n"
		+ "2 — Теплолампа\n"
		+ "3 — Распылитель\n"
		+ "4 — Изоляционная ширма\n"
		+ "5 — Гнилой лотос\n"
		+ "6 — Горшок гнилого запаха\n"
		+ "7 — Ящик лягушачьих звуков\n"
		+ "8 — Сборщик\n"
		+ "9 — Лунная фасоль\n"
		+ "0 — Лунный фонарь\n"
		+ "Q — Глушитель тишины\n"
		+ "\n"
		+ "ЛКМ — построить\n"
		+ "ПКМ — удалить\n"
		+ "E — инспектор растения\n"
		+ "H — ручной сбор\n"
		+ "\n"
		+ "Overlay:\n"
		+ "Z heat | X dryness | C humidity\n"
		+ "V yellow | N rot | M frog\n"
		+ "A blue | S cold | D silence | B hide"
	)

func connect_build_system() -> void:
	if build_system == null:
		push_error("BuildPanel: build_system is not assigned.")
		return

	if build_system.has_signal("selected_object_changed"):
		build_system.selected_object_changed.connect(update_selected_object)
	else:
		push_error("BuildPanel: build_system has no selected_object_changed signal.")

func update_selected_object(_object_id: String, display_name: String, cost_text: String) -> void:
	if selected_label != null:
		selected_label.text = "Выбрано: " + display_name

	if cost_label != null:
		cost_label.text = "Цена: " + cost_text
