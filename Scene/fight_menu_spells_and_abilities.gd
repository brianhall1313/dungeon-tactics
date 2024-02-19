extends Button
signal sa_selected



func _on_button_up():
	print('spells and abilities pressed')
	sa_selected.emit()
	get_viewport().set_input_as_handled()
