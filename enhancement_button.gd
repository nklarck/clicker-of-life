extends PanelContainer

@onready var icon: TextureRect = $HBoxContainer/MarginContainer3/Icon
@onready var name_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/Name
@onready var cost_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/Cost
@onready var count_label: Label = $HBoxContainer/MarginContainer2/Count
@onready var button: Button = $Button

var enhancement_ref: Enhancement

func button_setup(enhancement: Enhancement) -> void:
	enhancement_ref = enhancement
	icon.texture = enhancement.icon
	name_label.text = enhancement.name
	cost_label.text = "Cost: " + Utilities.number_format(enhancement.cost)
	count_label.text = str(enhancement.count)
	button.tooltip_text = enhancement.get_description()
	
func update_button(enhancement: Enhancement) -> void:
	cost_label.text = "Cost: " + Utilities.number_format(enhancement.cost)
	count_label.text = str(enhancement.count)
	button.tooltip_text = enhancement.get_description()

func set_disabled(value: bool) -> void:
	button.disabled = value
	cost_label.add_theme_color_override("font_color", Color("#cc4444") if value else Color("#a8d8b0"))

func set_hidden(value: bool) -> void:
	if value: icon.modulate = Color(0,0,0,1)
	else: icon.modulate = Color(1,1,1,1)
	if value: name_label.text = "????" 
	else: name_label.text = enhancement_ref.name
	count_label.visible = !value
	set_disabled(value)
