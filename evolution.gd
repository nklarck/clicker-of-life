class_name Evolution extends Resource

@export_group("Enhancement Description")
@export var name: String = ""
@export var icon: Texture2D = preload("res://icon.svg")
@export var purchased: bool = false
@export_multiline var description: String = ""

@export_group("Values")
@export var multiplier: float = 1.0
@export var cost: float = 1.0
@export var visibility_cost: float = 0.0

var button: PanelContainer = null
var active: bool = false
