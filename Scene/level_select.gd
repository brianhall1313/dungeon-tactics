extends Node2D

@onready var button1 =$"level_select_ui/Background/MarginContainer/Interface Frame/Save Access/Level 1/Frame/Button"
@onready var button2=$"level_select_ui/Background/MarginContainer/Interface Frame/Save Access/Level 2/Frame/Button"

# Called when the node enters the scene tree for the first time.
func _ready():
	if World.level_progress["test"]:
		button1.disabled=true
	if World.level_progress["road"]:
		button2.disabled=true






func level_two():
	Global.current_level=1
	get_tree().change_scene_to_file("res://Scene/encounter_manager.tscn")


func level_one():
	Global.current_level=0
	get_tree().change_scene_to_file("res://Scene/encounter_manager.tscn")


func _on_save_button_button_up():
	get_tree().change_scene_to_file("res://Scene/save_game.tscn")


func _on_party_management_pressed():
	get_tree().change_scene_to_file("res://Scene/party_management.tscn")
