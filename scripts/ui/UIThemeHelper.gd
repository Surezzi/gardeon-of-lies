extends RefCounted
class_name UIThemeHelper

static func apply_panel_style(panel: PanelContainer) -> void:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.075, 0.09, 0.11, 0.92)
	style_box.border_color = Color(0.24, 0.33, 0.39, 0.95)
	style_box.corner_radius_top_left = 14
	style_box.corner_radius_top_right = 14
	style_box.corner_radius_bottom_right = 14
	style_box.corner_radius_bottom_left = 14
	style_box.border_width_left = 1
	style_box.border_width_top = 1
	style_box.border_width_right = 1
	style_box.border_width_bottom = 1
	style_box.shadow_color = Color(0.0, 0.0, 0.0, 0.22)
	style_box.shadow_size = 6
	style_box.content_margin_left = 0
	style_box.content_margin_top = 0
	style_box.content_margin_right = 0
	style_box.content_margin_bottom = 0
	panel.add_theme_stylebox_override("panel", style_box)

func apply_title_style(label: Label) -> void:
	label.add_theme_color_override("font_color", Color(0.95, 0.97, 0.98))

func apply_section_style(label: Label) -> void:
	label.add_theme_color_override("font_color", Color(0.65, 0.82, 0.77))

func apply_body_style(label: Label) -> void:
	label.add_theme_color_override("font_color", Color(0.83, 0.88, 0.9))

func apply_muted_style(label: Label) -> void:
	label.add_theme_color_override("font_color", Color(0.62, 0.69, 0.73))

static func apply_primary_button_style(button: Button, selected: bool = false) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.corner_radius_top_left = 10
	normal.corner_radius_top_right = 10
	normal.corner_radius_bottom_right = 10
	normal.corner_radius_bottom_left = 10
	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 1
	normal.content_margin_left = 10
	normal.content_margin_top = 8
	normal.content_margin_right = 10
	normal.content_margin_bottom = 8

	var hover: StyleBoxFlat = normal.duplicate()
	var pressed: StyleBoxFlat = normal.duplicate()

	if selected:
		normal.bg_color = Color(0.15, 0.34, 0.3, 0.98)
		normal.border_color = Color(0.48, 0.84, 0.74, 1.0)
		hover.bg_color = Color(0.17, 0.39, 0.34, 1.0)
		hover.border_color = Color(0.55, 0.9, 0.8, 1.0)
		pressed.bg_color = Color(0.13, 0.3, 0.26, 1.0)
		pressed.border_color = Color(0.46, 0.82, 0.72, 1.0)
	else:
		normal.bg_color = Color(0.11, 0.14, 0.17, 0.98)
		normal.border_color = Color(0.24, 0.3, 0.35, 1.0)
		hover.bg_color = Color(0.14, 0.18, 0.22, 1.0)
		hover.border_color = Color(0.34, 0.47, 0.55, 1.0)
		pressed.bg_color = Color(0.1, 0.13, 0.16, 1.0)
		pressed.border_color = Color(0.4, 0.55, 0.63, 1.0)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_color_override("font_color", Color(0.9, 0.95, 0.96))

