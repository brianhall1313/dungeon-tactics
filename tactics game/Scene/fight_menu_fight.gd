extends Button
signal fight_selected


func _on_button_up():
	print('fight pressed')
	fight_selected.emit()
	get_viewport().set_input_as_handled()
