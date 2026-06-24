extends Node2D

signal selected_object_changed(object_id: String, display_name: String, cost_text: String)

@export var grid_system: GridSystem
@export var object_root: Node2D
@export var inventory_system: InventorySystem

var selected_object_id: String = "glass_cactus"

var object_definitions: Dictionary = {
	"glass_cactus": {
		"display_name": "Стеклянный кактус",
		"kind": PlaceableObject.ObjectKind.PLANT,
		"growth_threshold": 50.0,
		"max_growth": 100.0,
		"output_item_id": "glass_needle",
		"output_item_name": "Стеклянные иглы",
		"output_amount": 1,
		"build_cost": {},
		"likes": {
			"heat": 30.0,
			"dryness": 30.0,
			"yellow_light": 20.0
		},
		"dislikes": {
			"humidity": 45.0,
			"rot_smell": 25.0,
			"frog_sound": 20.0,
			"blue_light": 10.0
		},
		"contradictions": [
			["heat", "humidity"],
			["yellow_light", "rot_smell"],
			["dryness", "frog_sound"],
			["yellow_light", "blue_light"]
		]
	},
	"rot_lotus": {
		"display_name": "Гнилой лотос",
		"kind": PlaceableObject.ObjectKind.PLANT,
		"growth_threshold": 50.0,
		"max_growth": 100.0,
		"output_item_id": "rot_resin",
		"output_item_name": "Болотная смола",
		"output_amount": 1,
		"build_cost": {},
		"likes": {
			"humidity": 35.0,
			"rot_smell": 30.0,
			"frog_sound": 20.0
		},
		"dislikes": {
			"heat": 35.0,
			"dryness": 30.0,
			"yellow_light": 20.0,
			"silence": 20.0
		},
		"contradictions": [
			["humidity", "dryness"],
			["rot_smell", "yellow_light"],
			["frog_sound", "heat"],
			["frog_sound", "silence"]
		]
	},
	"moon_bean": {
		"display_name": "Лунная фасоль",
		"kind": PlaceableObject.ObjectKind.PLANT,
		"growth_threshold": 50.0,
		"max_growth": 100.0,
		"output_item_id": "sleepy_pollen",
		"output_item_name": "Сонная пыльца",
		"output_amount": 1,
		"build_cost": {},
		"likes": {
			"blue_light": 35.0,
			"cold": 25.0,
			"silence": 30.0
		},
		"dislikes": {
			"heat": 35.0,
			"yellow_light": 35.0,
			"frog_sound": 20.0,
			"rot_smell": 15.0
		},
		"contradictions": [
			["blue_light", "yellow_light"],
			["cold", "heat"],
			["silence", "frog_sound"]
		]
	},
	"heat_lamp": {
		"display_name": "Теплолампа",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 3,
		"build_cost": {},
		"can_be_toggled": true,
		"signal_outputs": {
			"heat": 35.0,
			"dryness": 25.0,
			"yellow_light": 25.0
		}
	},
	"mist_sprayer": {
		"display_name": "Распылитель",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 3,
		"build_cost": {},
		"can_be_toggled": true,
		"signal_outputs": {
			"humidity": 55.0
		}
	},
	"isolation_screen": {
		"display_name": "Изоляционная ширма",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 0,
		"signal_outputs": {},
		"blocks_signals": true,
		"can_be_toggled": false,
		"build_cost": {
			"glass_needle": 1
		}
	},
	"rot_scent_pot": {
		"display_name": "Горшок гнилого запаха",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 3,
		"build_cost": {},
		"can_be_toggled": true,
		"signal_outputs": {
			"rot_smell": 45.0
		}
	},
	"frog_sound_box": {
		"display_name": "Ящик лягушачьих звуков",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 3,
		"build_cost": {},
		"can_be_toggled": true,
		"signal_outputs": {
			"frog_sound": 40.0
		}
	},
	"harvester": {
		"display_name": "Сборщик",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 0,
		"signal_outputs": {},
		"is_harvester": true,
		"can_be_toggled": false,
		"build_cost": {
			"glass_needle": 2,
			"rot_resin": 1
		}
	},
	"moon_lantern": {
		"display_name": "Лунный фонарь",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 3,
		"can_be_toggled": true,
		"signal_outputs": {
			"blue_light": 45.0,
			"cold": 25.0
		},
		"build_cost": {}
	},
	"silence_box": {
		"display_name": "Глушитель тишины",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 3,
		"can_be_toggled": true,
		"signal_outputs": {
			"silence": 50.0
		},
		"build_cost": {
			"sleepy_pollen": 1
		}
	},
	"timer": {
		"display_name": "Таймер",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 0,
		"signal_outputs": {},
		"is_timer": true,
		"can_be_toggled": false,
		"timer_on_duration": 5.0,
		"timer_off_duration": 5.0,
		"build_cost": {
			"sleepy_pollen": 1,
			"glass_needle": 1
		}
	}
}

func _ready() -> void:
	if grid_system == null:
		push_error("BuildSystem: grid_system is not assigned.")

	if object_root == null:
		push_error("BuildSystem: object_root is not assigned.")

	if inventory_system == null:
		push_warning("BuildSystem: inventory_system is not assigned. Build costs will be ignored.")

	register_known_item_names()
	print_selected_object()
	emit_selected_object_changed()

func register_known_item_names() -> void:
	if inventory_system == null:
		return

	inventory_system.register_item_name("glass_needle", "Стеклянные иглы")
	inventory_system.register_item_name("rot_resin", "Болотная смола")
	inventory_system.register_item_name("sleepy_pollen", "Сонная пыльца")

func _unhandled_input(event: InputEvent) -> void:
	if grid_system == null or object_root == null:
		return

	handle_keyboard_input(event)
	handle_mouse_input(event)

func handle_keyboard_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				select_object("glass_cactus")

			KEY_2:
				select_object("heat_lamp")

			KEY_3:
				select_object("mist_sprayer")

			KEY_4:
				select_object("isolation_screen")

			KEY_5:
				select_object("rot_lotus")

			KEY_6:
				select_object("rot_scent_pot")

			KEY_7:
				select_object("frog_sound_box")

			KEY_8:
				select_object("harvester")

			KEY_9:
				select_object("moon_bean")

			KEY_0:
				select_object("moon_lantern")

			KEY_Q:
				select_object("silence_box")

			KEY_W:
				select_object("timer")

func select_object(object_id: String) -> void:
	selected_object_id = object_id
	print_selected_object()
	emit_selected_object_changed()

func handle_mouse_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return

	if not event.pressed:
		return

	var mouse_world_position: Vector2 = get_global_mouse_position()
	var grid_position: Vector2i = grid_system.world_to_grid(mouse_world_position)

	if not grid_system.is_inside_grid(grid_position):
		return

	if event.button_index == MOUSE_BUTTON_LEFT:
		place_selected_object(grid_position)

	elif event.button_index == MOUSE_BUTTON_RIGHT:
		remove_object(grid_position)

func place_selected_object(grid_position: Vector2i) -> void:
	if not grid_system.is_cell_empty(grid_position):
		print("Cell is occupied: ", grid_position)
		return

	var definition: Dictionary = object_definitions[selected_object_id]
	var build_cost: Dictionary = Dictionary(definition.get("build_cost", {}))

	if not can_pay_build_cost(build_cost):
		print_cannot_afford(definition, build_cost)
		return

	if not spend_build_cost(build_cost):
		print_cannot_afford(definition, build_cost)
		return

	var kind: int = int(definition.get("kind", PlaceableObject.ObjectKind.DEVICE))

	var placeable: PlaceableObject = PlaceableObject.new()

	placeable.setup(
		selected_object_id,
		String(definition.get("display_name", selected_object_id)),
		kind,
		grid_position,
		grid_system.cell_size,
		definition
	)

	placeable.global_position = grid_system.grid_to_world_center(grid_position)
	object_root.add_child(placeable)

	if kind == PlaceableObject.ObjectKind.PLANT:
		grid_system.set_plant(grid_position, placeable)
	else:
		grid_system.set_device(grid_position, placeable)

	print("Placed ", placeable.display_name, " at ", grid_position)

func can_pay_build_cost(build_cost: Dictionary) -> bool:
	if build_cost.is_empty():
		return true

	if inventory_system == null:
		return true

	return inventory_system.can_afford(build_cost)

func spend_build_cost(build_cost: Dictionary) -> bool:
	if build_cost.is_empty():
		return true

	if inventory_system == null:
		return true

	return inventory_system.spend_items(build_cost)

func print_cannot_afford(definition: Dictionary, build_cost: Dictionary) -> void:
	var object_name: String = String(definition.get("display_name", selected_object_id))

	if inventory_system == null:
		print("Cannot build ", object_name, ": inventory system is missing.")
		return

	print("Cannot build ", object_name, ". Need: ", inventory_system.format_cost(build_cost))

func remove_object(grid_position: Vector2i) -> void:
	var object: Node = grid_system.get_object_at(grid_position)

	if object == null:
		print("Cell is empty: ", grid_position)
		return

	if object is PlaceableObject:
		var placeable: PlaceableObject = object as PlaceableObject
		print("Removed ", placeable.display_name, " from ", grid_position)
	else:
		print("Removed object from ", grid_position)

	object.queue_free()
	grid_system.clear_cell(grid_position)

func print_selected_object() -> void:
	var definition: Dictionary = object_definitions[selected_object_id]
	var build_cost: Dictionary = Dictionary(definition.get("build_cost", {}))
	var object_name: String = String(definition.get("display_name", selected_object_id))

	if inventory_system == null:
		print("Selected: ", object_name)
		return

	print("Selected: ", object_name, " | cost: ", inventory_system.format_cost(build_cost))

func emit_selected_object_changed() -> void:
	var definition: Dictionary = object_definitions[selected_object_id]
	var build_cost: Dictionary = Dictionary(definition.get("build_cost", {}))
	var object_name: String = String(definition.get("display_name", selected_object_id))
	var cost_text: String = "бесплатно"

	if inventory_system != null:
		cost_text = inventory_system.format_cost(build_cost)

	selected_object_changed.emit(selected_object_id, object_name, cost_text)
