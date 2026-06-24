extends Node
class_name InputConfig

const PLACE_OBJECT_ACTION: StringName = &"place_object"
const REMOVE_OBJECT_ACTION: StringName = &"remove_object"
const INSPECT_HOVERED_ACTION: StringName = &"inspect_hovered"
const CLEAR_SELECTION_ACTION: StringName = &"clear_selection"
const HARVEST_HOVERED_ACTION: StringName = &"harvest_hovered"
const CAMERA_PAN_LEFT_ACTION: StringName = &"camera_pan_left"
const CAMERA_PAN_RIGHT_ACTION: StringName = &"camera_pan_right"
const CAMERA_PAN_UP_ACTION: StringName = &"camera_pan_up"
const CAMERA_PAN_DOWN_ACTION: StringName = &"camera_pan_down"

const BUILD_ACTIONS: Dictionary = {
	&"select_glass_cactus": KEY_1,
	&"select_heat_lamp": KEY_2,
	&"select_mist_sprayer": KEY_3,
	&"select_isolation_screen": KEY_4,
	&"select_rot_lotus": KEY_5,
	&"select_rot_scent_pot": KEY_6,
	&"select_frog_sound_box": KEY_7,
	&"select_harvester": KEY_8,
	&"select_moon_bean": KEY_9,
	&"select_moon_lantern": KEY_0,
	&"select_silence_box": KEY_Q,
	&"select_timer": KEY_W,
	&"select_impossible_orchid": KEY_R
}

const OVERLAY_ACTIONS: Dictionary = {
	&"overlay_heat": KEY_Z,
	&"overlay_dryness": KEY_X,
	&"overlay_humidity": KEY_C,
	&"overlay_yellow_light": KEY_V,
	&"overlay_rot_smell": KEY_N,
	&"overlay_frog_sound": KEY_M,
	&"overlay_blue_light": KEY_A,
	&"overlay_cold": KEY_S,
	&"overlay_silence": KEY_D,
	&"overlay_hide": KEY_B
}

func _ready() -> void:
	ensure_mouse_action(PLACE_OBJECT_ACTION, MOUSE_BUTTON_LEFT)
	ensure_mouse_action(REMOVE_OBJECT_ACTION, MOUSE_BUTTON_RIGHT)
	ensure_key_action(INSPECT_HOVERED_ACTION, KEY_E)
	ensure_key_action(CLEAR_SELECTION_ACTION, KEY_ESCAPE)
	ensure_key_action(HARVEST_HOVERED_ACTION, KEY_H)
	ensure_key_action(CAMERA_PAN_LEFT_ACTION, KEY_LEFT)
	ensure_key_action(CAMERA_PAN_RIGHT_ACTION, KEY_RIGHT)
	ensure_key_action(CAMERA_PAN_UP_ACTION, KEY_UP)
	ensure_key_action(CAMERA_PAN_DOWN_ACTION, KEY_DOWN)

	for action_variant in BUILD_ACTIONS.keys():
		var action_name: StringName = action_variant
		ensure_key_action(action_name, int(BUILD_ACTIONS[action_variant]))

	for action_variant in OVERLAY_ACTIONS.keys():
		var overlay_action: StringName = action_variant
		ensure_key_action(overlay_action, int(OVERLAY_ACTIONS[action_variant]))

func ensure_key_action(action_name: StringName, keycode: Key) -> void:
	ensure_action_exists(action_name)

	if has_key_binding(action_name, keycode):
		return

	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = keycode
	event.keycode = keycode
	InputMap.action_add_event(action_name, event)

func ensure_mouse_action(action_name: StringName, button_index: MouseButton) -> void:
	ensure_action_exists(action_name)

	if has_mouse_binding(action_name, button_index):
		return

	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = button_index
	InputMap.action_add_event(action_name, event)

func ensure_action_exists(action_name: StringName) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

func has_key_binding(action_name: StringName, keycode: Key) -> bool:
	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey:
			var key_event: InputEventKey = event as InputEventKey
			if key_event.physical_keycode == keycode:
				return true

	return false

func has_mouse_binding(action_name: StringName, button_index: MouseButton) -> bool:
	for event in InputMap.action_get_events(action_name):
		if event is InputEventMouseButton:
			var mouse_event: InputEventMouseButton = event as InputEventMouseButton
			if mouse_event.button_index == button_index:
				return true

	return false
