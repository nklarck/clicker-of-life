class_name Enhancement extends Resource

@export_group("Enhancement Description")
@export var name: String = "Name"
@export var icon: Texture2D = preload("res://icon.svg")
@export var type: String = "Generator"
@export var unlocked: bool = false
@export var mysterious: bool = true

@export_group("Values")
@export var value: float = 0.0
@export var cost: float = 0.0
@export var unlock_cost: float = 0.0
@export var visibility_cost: float = 0.0
@export var count: int = 0

var button: PanelContainer = null

func get_description():
	if type == "Generator":
		return "Produces " + Utilities.number_format(value) + " DNA per second"
	elif type == "Click":
		return "+" + Utilities.number_format(value) + " DNA per click"
