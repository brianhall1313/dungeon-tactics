extends Control
signal continue_pressed
signal end_turn_pressed
@onready var continue_button=$VBoxContainer/continue
@onready var end_turn_button=$VBoxContainer/end_turn

func _ready():
	hide()
	GlobalSignalBus.connect('hide_menu',hide_menu)
	GlobalSignalBus.connect('show_pause_menu',show_pause_menu)

func show_menu():
	show()
	
func hide_menu():
	hide()

func show_pause_menu():
	show_menu()
	continue_button.grab_focus()


func _on_continue_button_up():
	continue_pressed.emit()
	get_viewport().set_input_as_handled()
	hide()


func _on_end_turn_button_up():
	end_turn_pressed.emit()
	get_viewport().set_input_as_handled()
	hide()


func _on_quit_button_up():
	get_tree().change_scene_to_file("res://Scene/start_screen.tscn")


func _on_save_party_button_up():
	GlobalSignalBus.save.emit()
