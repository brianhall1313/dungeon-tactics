extends Control
signal continue_pressed
signal end_turn_pressed
@onready var continue_button=$VBoxContainer/continue
@onready var end_turn_button=$VBoxContainer/end_turn

func _ready():
	hide()
	GlobalSignalBus.connect('hide_menu',hide_menu)

func show_menu():
	show()
	
func hide_menu():
	hide()

func _on_pause_menu_show_pause_menu():
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
