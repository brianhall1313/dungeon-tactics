extends CanvasLayer

@onready var selected=$selected_character_info
@onready var targeted=$targeted_character_info
@onready var selected_portrait =$left_portrait
@onready var targeted_portrait=$right_portrait
@onready var turn_end_button=$"turn end"
signal continue_pressed
signal end_turn_pressed


func turn_end_trigger():
	turn_end_button.show()


func _on_map_hide_selected_ui():
	selected.hide()
	selected_portrait.hide()


func _on_map_hide_targeted_ui():
	targeted.hide()
	targeted_portrait.hide()


func _on_map_show_selected_ui():
	selected.show()
	selected_portrait.show()


func _on_map_show_targeted_ui():
	targeted.show()
	targeted_portrait.show()


func _on_map_update_selected_ui(character):
	selected.update(character)
	selected_portrait.update(character)


func _on_map_update_targeted_ui(character):
	targeted.update(character)
	targeted_portrait.update(character)



func _on_field_menu_continue_pressed():
	continue_pressed.emit()


func _on_field_menu_end_turn_pressed():
	end_turn_pressed.emit()
	turn_end_button.hide()


func _on_turn_end_button_up():
	end_turn_pressed.emit()
	turn_end_button.hide()
