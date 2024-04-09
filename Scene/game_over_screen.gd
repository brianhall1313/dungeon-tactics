extends Control
@onready var game_over_screen_label=$ColorRect/VBoxContainer/PanelContainer/Label
@onready var button_text=$ColorRect/VBoxContainer/Button

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	GlobalSignalBus.connect('game_over',show_game_over)




func show_game_over(victor:bool):
	show()
	if victor:
		game_over_screen_label.text +='\nPlayer Wins!!!!'
		button_text.text='Level Select'
	else:
		game_over_screen_label.text = '\nYou lose~~~~~ ;_;'
		button_text.text='Quit to Menu'


func _on_button_button_up():
	if button_text.text == 'Level Select':
		get_tree().change_scene_to_file("res://Scene/level_select.tscn")
	elif button_text.text == 'Quit to Menu':
		get_tree().change_scene_to_file("res://Scene/start_screen.tscn")
