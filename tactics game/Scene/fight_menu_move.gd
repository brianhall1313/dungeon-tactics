extends Button
signal move_selected



func _on_button_up():
	print('move pressed')
	move_selected.emit()
	get_viewport().set_input_as_handled()
	
