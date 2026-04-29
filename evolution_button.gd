extends PanelContainer

@onready var icon: TextureRect = $HBoxContainer/MarginContainer3/Icon
@onready var name_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/Name
@onready var cost_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/Cost
@onready var button: Button = $Button

var evolution_ref: Evolution

func button_setup(evolution: Evolution) -> void:
	evolution_ref = evolution
	icon.texture = evolution.icon
	name_label.text = evolution.name
	cost_label.text = "Cost: " + Utilities.number_format(evolution.cost)
	button.tooltip_text = evolution.description
	evolution.active = true


func set_disabled(value: bool) -> void:
	button.disabled = value
	cost_label.add_theme_color_override("font_color", Color("#cc4444") if value else Color("#f0c96a"))
