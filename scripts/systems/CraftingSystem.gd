extends Node2D
class_name CraftingSystem

signal recipes_changed

@export var inventory_system: InventorySystem

var recipe_order: Array[String] = [
	"glass_housing",
	"spore_core",
	"moon_circuit",
	"ember_core",
	"prism_frame",
	"hush_coil",
	"crystal_lattice",
	"relay_matrix",
	"phase_resonator"
]

var recipes: Dictionary = {
	"glass_housing": {
		"display_name": "Glass Housing",
		"category": "Foundations",
		"cost": {
			"glass_needle": 2
		},
		"output": {
			"item_id": "glass_housing",
			"item_name": "Glass Housing",
			"amount": 1
		},
		"unlock_requirements": {
			"glass_needle": 1
		}
	},
	"spore_core": {
		"display_name": "Spore Core",
		"category": "Foundations",
		"cost": {
			"rot_resin": 2
		},
		"output": {
			"item_id": "spore_core",
			"item_name": "Spore Core",
			"amount": 1
		},
		"unlock_requirements": {
			"rot_resin": 1
		}
	},
	"moon_circuit": {
		"display_name": "Moon Circuit",
		"category": "Foundations",
		"cost": {
			"sleepy_pollen": 1,
			"glass_needle": 1
		},
		"output": {
			"item_id": "moon_circuit",
			"item_name": "Moon Circuit",
			"amount": 1
		},
		"unlock_requirements": {
			"sleepy_pollen": 1
		}
	},
	"ember_core": {
		"display_name": "Ember Core",
		"category": "Foundations",
		"cost": {
			"ember_dust": 2,
			"rot_resin": 1
		},
		"output": {
			"item_id": "ember_core",
			"item_name": "Ember Core",
			"amount": 1
		},
		"unlock_requirements": {
			"ember_dust": 1
		}
	},
	"prism_frame": {
		"display_name": "Prism Frame",
		"category": "Foundations",
		"cost": {
			"mirror_fiber": 2,
			"glass_needle": 1
		},
		"output": {
			"item_id": "prism_frame",
			"item_name": "Prism Frame",
			"amount": 1
		},
		"unlock_requirements": {
			"mirror_fiber": 1
		}
	},
	"hush_coil": {
		"display_name": "Hush Coil",
		"category": "Foundations",
		"cost": {
			"mirror_fiber": 1,
			"sleepy_pollen": 1
		},
		"output": {
			"item_id": "hush_coil",
			"item_name": "Hush Coil",
			"amount": 1
		},
		"unlock_requirements": {
			"mirror_fiber": 1,
			"sleepy_pollen": 1
		}
	},
	"crystal_lattice": {
		"display_name": "Crystal Lattice",
		"category": "Advanced",
		"cost": {
			"glass_housing": 1,
			"rot_resin": 2
		},
		"output": {
			"item_id": "crystal_lattice",
			"item_name": "Crystal Lattice",
			"amount": 1
		},
		"unlock_requirements": {
			"glass_housing": 1,
			"rot_resin": 1
		}
	},
	"relay_matrix": {
		"display_name": "Relay Matrix",
		"category": "Advanced",
		"cost": {
			"glass_housing": 1,
			"spore_core": 1,
			"moon_circuit": 1
		},
		"output": {
			"item_id": "relay_matrix",
			"item_name": "Relay Matrix",
			"amount": 1
		},
		"unlock_requirements": {
			"glass_housing": 1,
			"spore_core": 1,
			"moon_circuit": 1
		}
	},
	"phase_resonator": {
		"display_name": "Phase Resonator",
		"category": "Advanced",
		"cost": {
			"ember_core": 1,
			"hush_coil": 1,
			"chorus_spore": 1
		},
		"output": {
			"item_id": "phase_resonator",
			"item_name": "Phase Resonator",
			"amount": 1
		},
		"unlock_requirements": {
			"ember_core": 1,
			"chorus_spore": 1
		}
	}
}

func _ready() -> void:
	if inventory_system == null:
		push_error("CraftingSystem: inventory_system is not assigned.")
		return

	register_recipe_item_names()
	inventory_system.inventory_changed.connect(_on_inventory_changed)
	recipes_changed.emit()

func register_recipe_item_names() -> void:
	inventory_system.register_item_name("glass_housing", "Glass Housing")
	inventory_system.register_item_name("spore_core", "Spore Core")
	inventory_system.register_item_name("moon_circuit", "Moon Circuit")
	inventory_system.register_item_name("crystal_lattice", "Crystal Lattice")
	inventory_system.register_item_name("relay_matrix", "Relay Matrix")
	inventory_system.register_item_name("ember_core", "Ember Core")
	inventory_system.register_item_name("prism_frame", "Prism Frame")
	inventory_system.register_item_name("hush_coil", "Hush Coil")
	inventory_system.register_item_name("phase_resonator", "Phase Resonator")

func craft_recipe(recipe_id: String) -> bool:
	if inventory_system == null:
		return false

	if not recipes.has(recipe_id):
		return false

	if not is_recipe_unlocked(recipe_id):
		return false

	var recipe: Dictionary = Dictionary(recipes[recipe_id])
	var cost: Dictionary = Dictionary(recipe.get("cost", {}))

	if not inventory_system.can_afford(cost):
		return false

	if not inventory_system.spend_items(cost):
		return false

	var output: Dictionary = Dictionary(recipe.get("output", {}))
	var item_id: String = String(output.get("item_id", ""))
	var item_name: String = String(output.get("item_name", item_id))
	var amount: int = int(output.get("amount", 1))
	inventory_system.add_item(item_id, item_name, amount)
	recipes_changed.emit()
	return true

func get_recipe_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []

	for recipe_id in recipe_order:
		if not recipes.has(recipe_id):
			continue

		var recipe: Dictionary = Dictionary(recipes[recipe_id])
		entries.append({
			"recipe_id": recipe_id,
			"display_name": String(recipe.get("display_name", recipe_id)),
			"category": String(recipe.get("category", "Foundations")),
			"cost_text": get_recipe_cost_text(recipe_id),
			"locked": not is_recipe_unlocked(recipe_id),
			"unlock_text": get_recipe_unlock_text(recipe_id),
			"craftable": can_craft(recipe_id)
		})

	return entries

func can_craft(recipe_id: String) -> bool:
	if inventory_system == null:
		return false

	if not recipes.has(recipe_id):
		return false

	if not is_recipe_unlocked(recipe_id):
		return false

	var recipe: Dictionary = Dictionary(recipes[recipe_id])
	var cost: Dictionary = Dictionary(recipe.get("cost", {}))
	return inventory_system.can_afford(cost)

func is_recipe_unlocked(recipe_id: String) -> bool:
	if inventory_system == null:
		return false

	if not recipes.has(recipe_id):
		return false

	var recipe: Dictionary = Dictionary(recipes[recipe_id])
	var requirements: Dictionary = Dictionary(recipe.get("unlock_requirements", {}))

	if requirements.is_empty():
		return true

	return inventory_system.can_afford(requirements)

func get_recipe_cost_text(recipe_id: String) -> String:
	if not recipes.has(recipe_id):
		return "Unavailable"

	var recipe: Dictionary = Dictionary(recipes[recipe_id])

	if not is_recipe_unlocked(recipe_id):
		return "Unlock: " + get_recipe_unlock_text(recipe_id)

	return inventory_system.format_cost(Dictionary(recipe.get("cost", {})))

func get_recipe_unlock_text(recipe_id: String) -> String:
	if not recipes.has(recipe_id):
		return ""

	var recipe: Dictionary = Dictionary(recipes[recipe_id])
	var requirements: Dictionary = Dictionary(recipe.get("unlock_requirements", {}))
	return inventory_system.format_cost(requirements)

func _on_inventory_changed() -> void:
	recipes_changed.emit()
