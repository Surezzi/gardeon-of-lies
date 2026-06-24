extends Node2D

signal selected_object_changed(object_id: String, display_name: String, cost_text: String)

@export var grid_system: GridSystem
@export var object_root: Node2D
@export var inventory_system: InventorySystem

var selected_object_id: String = "glass_cactus"
var log_actions: bool = false
var build_order: Array[String] = [
	"glass_cactus",
	"rot_lotus",
	"moon_bean",
	"impossible_orchid",
	"ember_fern",
	"mirror_reed",
	"chorus_bulb",
	"echo_blossom",
	"heat_lamp",
	"mist_sprayer",
	"isolation_screen",
	"rot_scent_pot",
	"frog_sound_box",
	"harvester",
	"moon_lantern",
	"silence_box",
	"timer",
	"compost_heater",
	"wind_turbine",
	"choir_bell"
]

var object_definitions: Dictionary = {
	"glass_cactus": {
		"display_name": "Glass Cactus",
		"kind": PlaceableObject.ObjectKind.PLANT,
		"growth_threshold": 50.0,
		"max_growth": 100.0,
		"output_item_id": "glass_needle",
		"output_item_name": "Glass Needle",
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
		"display_name": "Rot Lotus",
		"kind": PlaceableObject.ObjectKind.PLANT,
		"growth_threshold": 50.0,
		"max_growth": 100.0,
		"output_item_id": "rot_resin",
		"output_item_name": "Rot Resin",
		"output_amount": 1,
		"build_cost": {
			"glass_needle": 1
		},
		"unlock_requirements": {
			"glass_needle": 1
		},
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
		"display_name": "Moon Bean",
		"kind": PlaceableObject.ObjectKind.PLANT,
		"growth_threshold": 50.0,
		"max_growth": 100.0,
		"output_item_id": "sleepy_pollen",
		"output_item_name": "Sleepy Pollen",
		"output_amount": 1,
		"build_cost": {
			"rot_resin": 1
		},
		"unlock_requirements": {
			"rot_resin": 1
		},
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
	"impossible_orchid": {
		"display_name": "Impossible Orchid",
		"kind": PlaceableObject.ObjectKind.PLANT,
		"growth_threshold": 55.0,
		"max_growth": 100.0,
		"output_item_id": "paradox_petal",
		"output_item_name": "Paradox Petal",
		"output_amount": 1,
		"build_cost": {
			"glass_needle": 1,
			"rot_resin": 1,
			"sleepy_pollen": 1,
			"crystal_lattice": 1,
			"relay_matrix": 1
		},
		"unlock_requirements": {
			"glass_needle": 1,
			"rot_resin": 1,
			"sleepy_pollen": 1,
			"crystal_lattice": 1,
			"relay_matrix": 1
		},
		"likes": {},
		"dislikes": {},
		"required_phases": {
			"Desert Phase": {
				"heat": 20.0,
				"dryness": 15.0,
				"yellow_light": 15.0
			},
			"Moon Phase": {
				"blue_light": 25.0,
				"cold": 15.0,
				"silence": 15.0
			}
		},
		"contradictions": [
			["heat", "blue_light"],
			["yellow_light", "blue_light"],
			["dryness", "humidity"],
			["frog_sound", "silence"]
		]
	},
	"ember_fern": {
		"display_name": "Ember Fern",
		"kind": PlaceableObject.ObjectKind.PLANT,
		"growth_threshold": 56.0,
		"max_growth": 100.0,
		"output_item_id": "ember_dust",
		"output_item_name": "Ember Dust",
		"output_amount": 1,
		"build_cost": {
			"glass_housing": 1,
			"rot_resin": 1
		},
		"unlock_requirements": {
			"glass_housing": 1,
			"rot_resin": 1
		},
		"likes": {
			"heat": 30.0,
			"rot_smell": 25.0,
			"silence": 20.0
		},
		"dislikes": {
			"humidity": 30.0,
			"blue_light": 20.0,
			"frog_sound": 20.0
		},
		"contradictions": [
			["heat", "humidity"],
			["rot_smell", "blue_light"],
			["silence", "frog_sound"]
		]
	},
	"mirror_reed": {
		"display_name": "Mirror Reed",
		"kind": PlaceableObject.ObjectKind.PLANT,
		"growth_threshold": 56.0,
		"max_growth": 100.0,
		"output_item_id": "mirror_fiber",
		"output_item_name": "Mirror Fiber",
		"output_amount": 1,
		"build_cost": {
			"glass_housing": 1,
			"sleepy_pollen": 1
		},
		"unlock_requirements": {
			"glass_housing": 1,
			"sleepy_pollen": 1
		},
		"likes": {
			"humidity": 30.0,
			"blue_light": 30.0,
			"silence": 20.0
		},
		"dislikes": {
			"dryness": 30.0,
			"heat": 25.0,
			"rot_smell": 20.0
		},
		"contradictions": [
			["humidity", "dryness"],
			["blue_light", "yellow_light"],
			["silence", "frog_sound"]
		]
	},
	"chorus_bulb": {
		"display_name": "Chorus Bulb",
		"kind": PlaceableObject.ObjectKind.PLANT,
		"growth_threshold": 58.0,
		"max_growth": 100.0,
		"output_item_id": "chorus_spore",
		"output_item_name": "Chorus Spore",
		"output_amount": 1,
		"build_cost": {
			"spore_core": 1,
			"moon_circuit": 1
		},
		"unlock_requirements": {
			"spore_core": 1,
			"moon_circuit": 1
		},
		"likes": {
			"frog_sound": 30.0,
			"yellow_light": 25.0,
			"humidity": 20.0
		},
		"dislikes": {
			"silence": 30.0,
			"dryness": 20.0,
			"cold": 20.0,
			"blue_light": 15.0
		},
		"contradictions": [
			["frog_sound", "silence"],
			["yellow_light", "blue_light"],
			["humidity", "dryness"]
		]
	},
	"echo_blossom": {
		"display_name": "Echo Blossom",
		"kind": PlaceableObject.ObjectKind.PLANT,
		"growth_threshold": 60.0,
		"max_growth": 100.0,
		"output_item_id": "echo_bloom",
		"output_item_name": "Echo Bloom",
		"output_amount": 1,
		"build_cost": {
			"phase_resonator": 1,
			"prism_frame": 1,
			"chorus_spore": 1
		},
		"unlock_requirements": {
			"paradox_petal": 1,
			"phase_resonator": 1,
			"prism_frame": 1,
			"chorus_spore": 1
		},
		"likes": {},
		"dislikes": {},
		"required_phases": {
			"Choir Phase": {
				"frog_sound": 20.0,
				"yellow_light": 15.0,
				"humidity": 15.0
			},
			"Mirror Phase": {
				"blue_light": 20.0,
				"silence": 15.0,
				"dryness": 10.0
			}
		},
		"contradictions": [
			["frog_sound", "silence"],
			["yellow_light", "blue_light"],
			["humidity", "dryness"]
		]
	},
	"heat_lamp": {
		"display_name": "Heat Lamp",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 3,
		"build_cost": {
			"glass_needle": 1
		},
		"can_be_toggled": true,
		"signal_outputs": {
			"heat": 35.0,
			"dryness": 25.0,
			"yellow_light": 25.0
		}
	},
	"mist_sprayer": {
		"display_name": "Mist Sprayer",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 3,
		"build_cost": {
			"glass_housing": 1
		},
		"unlock_requirements": {
			"glass_needle": 1
		},
		"can_be_toggled": true,
		"signal_outputs": {
			"humidity": 55.0
		}
	},
	"isolation_screen": {
		"display_name": "Isolation Screen",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 0,
		"signal_outputs": {},
		"blocks_signals": true,
		"can_be_toggled": false,
		"build_cost": {
			"glass_housing": 1,
			"rot_resin": 1
		},
		"unlock_requirements": {
			"glass_needle": 1
		}
	},
	"rot_scent_pot": {
		"display_name": "Rot Scent Pot",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 3,
		"build_cost": {
			"spore_core": 1
		},
		"unlock_requirements": {
			"glass_needle": 1
		},
		"can_be_toggled": true,
		"signal_outputs": {
			"rot_smell": 45.0
		}
	},
	"frog_sound_box": {
		"display_name": "Frog Sound Box",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 3,
		"build_cost": {
			"spore_core": 1
		},
		"unlock_requirements": {
			"glass_needle": 1
		},
		"can_be_toggled": true,
		"signal_outputs": {
			"frog_sound": 40.0
		}
	},
	"harvester": {
		"display_name": "Harvester",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 0,
		"signal_outputs": {},
		"is_harvester": true,
		"can_be_toggled": false,
		"build_cost": {
			"glass_housing": 2,
			"spore_core": 1,
			"moon_circuit": 1
		},
		"unlock_requirements": {
			"glass_housing": 1,
			"spore_core": 1
		}
	},
	"moon_lantern": {
		"display_name": "Moon Lantern",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 3,
		"can_be_toggled": true,
		"signal_outputs": {
			"blue_light": 45.0,
			"cold": 25.0
		},
		"build_cost": {
			"moon_circuit": 1
		},
		"unlock_requirements": {
			"moon_circuit": 1
		}
	},
	"silence_box": {
		"display_name": "Silence Box",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 3,
		"can_be_toggled": true,
		"signal_outputs": {
			"silence": 50.0
		},
		"build_cost": {
			"moon_circuit": 1
		},
		"unlock_requirements": {
			"moon_circuit": 1
		}
	},
	"timer": {
		"display_name": "Timer",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 0,
		"signal_outputs": {},
		"is_timer": true,
		"can_be_toggled": false,
		"timer_on_duration": 5.0,
		"timer_off_duration": 5.0,
		"build_cost": {
			"relay_matrix": 1,
			"moon_circuit": 1
		},
		"unlock_requirements": {
			"relay_matrix": 1
		}
	},
	"compost_heater": {
		"display_name": "Compost Heater",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 3,
		"build_cost": {
			"ember_core": 1
		},
		"unlock_requirements": {
			"ember_dust": 1
		},
		"can_be_toggled": true,
		"signal_outputs": {
			"heat": 28.0,
			"rot_smell": 35.0
		}
	},
	"wind_turbine": {
		"display_name": "Wind Turbine",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 3,
		"build_cost": {
			"prism_frame": 1
		},
		"unlock_requirements": {
			"prism_frame": 1
		},
		"can_be_toggled": true,
		"signal_outputs": {
			"dryness": 35.0,
			"silence": 22.0
		}
	},
	"choir_bell": {
		"display_name": "Choir Bell",
		"kind": PlaceableObject.ObjectKind.DEVICE,
		"radius": 3,
		"build_cost": {
			"hush_coil": 1,
			"chorus_spore": 1
		},
		"unlock_requirements": {
			"hush_coil": 1,
			"chorus_spore": 1
		},
		"can_be_toggled": true,
		"signal_outputs": {
			"frog_sound": 32.0,
			"yellow_light": 22.0
		}
	}
}

func _ready() -> void:
	if grid_system == null:
		push_error("BuildSystem: grid_system is not assigned.")

	if object_root == null:
		push_error("BuildSystem: object_root is not assigned.")

	if inventory_system == null:
		push_warning("BuildSystem: inventory_system is not assigned. Paid buildings will be blocked.")

	register_known_item_names()

	if inventory_system != null:
		inventory_system.inventory_changed.connect(_on_inventory_changed)

	ensure_selected_object_unlocked()
	print_selected_object()
	emit_selected_object_changed()

func register_known_item_names() -> void:
	if inventory_system == null:
		return

	inventory_system.register_item_name("glass_needle", "Glass Needle")
	inventory_system.register_item_name("rot_resin", "Rot Resin")
	inventory_system.register_item_name("sleepy_pollen", "Sleepy Pollen")
	inventory_system.register_item_name("paradox_petal", "Paradox Petal")
	inventory_system.register_item_name("glass_housing", "Glass Housing")
	inventory_system.register_item_name("spore_core", "Spore Core")
	inventory_system.register_item_name("moon_circuit", "Moon Circuit")
	inventory_system.register_item_name("crystal_lattice", "Crystal Lattice")
	inventory_system.register_item_name("relay_matrix", "Relay Matrix")
	inventory_system.register_item_name("ember_dust", "Ember Dust")
	inventory_system.register_item_name("mirror_fiber", "Mirror Fiber")
	inventory_system.register_item_name("chorus_spore", "Chorus Spore")
	inventory_system.register_item_name("ember_core", "Ember Core")
	inventory_system.register_item_name("prism_frame", "Prism Frame")
	inventory_system.register_item_name("hush_coil", "Hush Coil")
	inventory_system.register_item_name("phase_resonator", "Phase Resonator")
	inventory_system.register_item_name("echo_bloom", "Echo Bloom")

func _unhandled_input(event: InputEvent) -> void:
	if grid_system == null or object_root == null:
		return

	handle_keyboard_input(event)
	handle_mouse_input(event)

func handle_keyboard_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	var key_event: InputEventKey = event as InputEventKey

	if not key_event.pressed or key_event.echo:
		return

	if event.is_action_pressed(&"select_glass_cactus"):
		select_object("glass_cactus")
	elif event.is_action_pressed(&"select_heat_lamp"):
		select_object("heat_lamp")
	elif event.is_action_pressed(&"select_mist_sprayer"):
		select_object("mist_sprayer")
	elif event.is_action_pressed(&"select_isolation_screen"):
		select_object("isolation_screen")
	elif event.is_action_pressed(&"select_rot_lotus"):
		select_object("rot_lotus")
	elif event.is_action_pressed(&"select_rot_scent_pot"):
		select_object("rot_scent_pot")
	elif event.is_action_pressed(&"select_frog_sound_box"):
		select_object("frog_sound_box")
	elif event.is_action_pressed(&"select_harvester"):
		select_object("harvester")
	elif event.is_action_pressed(&"select_moon_bean"):
		select_object("moon_bean")
	elif event.is_action_pressed(&"select_moon_lantern"):
		select_object("moon_lantern")
	elif event.is_action_pressed(&"select_silence_box"):
		select_object("silence_box")
	elif event.is_action_pressed(&"select_timer"):
		select_object("timer")
	elif event.is_action_pressed(&"select_impossible_orchid"):
		select_object("impossible_orchid")

func select_object(object_id: String) -> void:
	if not object_definitions.has(object_id):
		return

	if not is_object_unlocked(object_id):
		return

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

	if event.is_action_pressed(InputConfig.PLACE_OBJECT_ACTION):
		if grid_system.is_cell_empty(grid_position):
			place_selected_object(grid_position)
	elif event.is_action_pressed(InputConfig.REMOVE_OBJECT_ACTION):
		remove_object(grid_position)

func place_selected_object(grid_position: Vector2i) -> void:
	if not grid_system.is_cell_empty(grid_position):
		if log_actions:
			print("Cell is occupied: ", grid_position)
		return

	if not is_object_unlocked(selected_object_id):
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

	if log_actions:
		print("Placed ", placeable.display_name, " at ", grid_position)

func can_pay_build_cost(build_cost: Dictionary) -> bool:
	if build_cost.is_empty():
		return true

	if inventory_system == null:
		return false

	return inventory_system.can_afford(build_cost)

func spend_build_cost(build_cost: Dictionary) -> bool:
	if build_cost.is_empty():
		return true

	if inventory_system == null:
		return false

	return inventory_system.spend_items(build_cost)

func print_cannot_afford(definition: Dictionary, build_cost: Dictionary) -> void:
	if not log_actions:
		return

	var object_name: String = String(definition.get("display_name", selected_object_id))

	if inventory_system == null:
		print("Cannot build ", object_name, ". InventorySystem is not assigned on BuildSystem.")
		return

	print("Cannot build ", object_name, ". Need: ", inventory_system.format_cost(build_cost))

func remove_object(grid_position: Vector2i) -> void:
	var object: Node = grid_system.get_object_at(grid_position)

	if object == null:
		if log_actions:
			print("Cell is empty: ", grid_position)
		return

	if object is PlaceableObject:
		var placeable: PlaceableObject = object as PlaceableObject
		if log_actions:
			print("Removed ", placeable.display_name, " from ", grid_position)
	else:
		if log_actions:
			print("Removed object from ", grid_position)

	object.queue_free()
	grid_system.clear_cell(grid_position)

func print_selected_object() -> void:
	if not log_actions:
		return

	var definition: Dictionary = object_definitions[selected_object_id]
	var build_cost: Dictionary = Dictionary(definition.get("build_cost", {}))
	var object_name: String = String(definition.get("display_name", selected_object_id))
	var unlock_text: String = get_unlock_text_for_object(selected_object_id)

	if inventory_system == null:
		print("Selected: ", object_name)
		return

	if unlock_text == "":
		print("Selected: ", object_name, " | cost: ", inventory_system.format_cost(build_cost))
	else:
		print("Selected: ", object_name, " | locked: ", unlock_text)

func emit_selected_object_changed() -> void:
	var definition: Dictionary = object_definitions[selected_object_id]
	var build_cost: Dictionary = Dictionary(definition.get("build_cost", {}))
	var object_name: String = String(definition.get("display_name", selected_object_id))
	var cost_text: String = "free"
	var unlock_text: String = get_unlock_text_for_object(selected_object_id)

	if inventory_system != null:
		cost_text = inventory_system.format_cost(build_cost)

	if unlock_text != "":
		cost_text = "Locked: " + unlock_text

	selected_object_changed.emit(selected_object_id, object_name, cost_text)

func get_selected_definition() -> Dictionary:
	return Dictionary(object_definitions.get(selected_object_id, {}))

func get_selected_cost() -> Dictionary:
	var definition: Dictionary = get_selected_definition()
	return Dictionary(definition.get("build_cost", {}))

func get_selected_display_name() -> String:
	var definition: Dictionary = get_selected_definition()
	return String(definition.get("display_name", selected_object_id))

func get_selected_cost_text() -> String:
	if inventory_system == null:
		return "free"

	if not is_object_unlocked(selected_object_id):
		return "Locked: " + get_unlock_text_for_object(selected_object_id)

	return inventory_system.format_cost(get_selected_cost())

func get_selected_summary() -> String:
	return "%s | cost: %s" % [get_selected_display_name(), get_selected_cost_text()]

func can_place_selected_at(grid_position: Vector2i) -> bool:
	if grid_system == null:
		return false

	if not grid_system.is_inside_grid(grid_position):
		return false

	if not grid_system.is_cell_empty(grid_position):
		return false

	if not is_object_unlocked(selected_object_id):
		return false

	return can_pay_build_cost(get_selected_cost())

func get_build_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []

	for object_id in build_order:
		if not object_definitions.has(object_id):
			continue

		var definition: Dictionary = Dictionary(object_definitions[object_id])
		var kind: int = int(definition.get("kind", PlaceableObject.ObjectKind.DEVICE))
		var category: String = "Devices"

		if kind == PlaceableObject.ObjectKind.PLANT:
			category = "Plants"

		entries.append({
			"object_id": object_id,
			"display_name": String(definition.get("display_name", object_id)),
			"cost_text": get_cost_text_for_object(object_id),
			"category": category,
			"selected": object_id == selected_object_id,
			"hotkey": get_hotkey_for_object(object_id),
			"locked": not is_object_unlocked(object_id),
			"unlock_text": get_unlock_text_for_object(object_id)
		})

	return entries

func get_cost_text_for_object(object_id: String) -> String:
	if not object_definitions.has(object_id):
		return "free"

	if not is_object_unlocked(object_id):
		return "Unlock: " + get_unlock_text_for_object(object_id)

	var definition: Dictionary = Dictionary(object_definitions[object_id])
	var build_cost: Dictionary = Dictionary(definition.get("build_cost", {}))

	if inventory_system == null:
		if build_cost.is_empty():
			return "free"
		return "cost unavailable"

	return inventory_system.format_cost(build_cost)

func get_hotkey_for_object(object_id: String) -> String:
	match object_id:
		"glass_cactus":
			return "1"
		"heat_lamp":
			return "2"
		"mist_sprayer":
			return "3"
		"isolation_screen":
			return "4"
		"rot_lotus":
			return "5"
		"rot_scent_pot":
			return "6"
		"frog_sound_box":
			return "7"
		"harvester":
			return "8"
		"moon_bean":
			return "9"
		"moon_lantern":
			return "0"
		"silence_box":
			return "Q"
		"timer":
			return "W"
		"impossible_orchid":
			return "R"
		_:
			return ""

func is_object_unlocked(object_id: String) -> bool:
	if not object_definitions.has(object_id):
		return false

	var definition: Dictionary = Dictionary(object_definitions[object_id])
	var requirements: Dictionary = Dictionary(definition.get("unlock_requirements", {}))

	if requirements.is_empty():
		return true

	if inventory_system == null:
		return false

	for item_id_variant in requirements.keys():
		var item_id: String = String(item_id_variant)
		var required_amount: int = int(requirements[item_id_variant])

		if inventory_system.get_item_amount(item_id) < required_amount:
			return false

	return true

func get_unlock_text_for_object(object_id: String) -> String:
	if not object_definitions.has(object_id):
		return ""

	var definition: Dictionary = Dictionary(object_definitions[object_id])
	var requirements: Dictionary = Dictionary(definition.get("unlock_requirements", {}))

	if requirements.is_empty():
		return ""

	if inventory_system == null:
		return "requirements unavailable"

	return inventory_system.format_cost(requirements)

func ensure_selected_object_unlocked() -> void:
	if is_object_unlocked(selected_object_id):
		return

	for object_id in build_order:
		if is_object_unlocked(object_id):
			selected_object_id = object_id
			return

func _on_inventory_changed() -> void:
	ensure_selected_object_unlocked()
	emit_selected_object_changed()
