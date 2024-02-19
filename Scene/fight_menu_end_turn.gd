extends Button
signal end_selected


func _on_button_up():
	print('end pressed')
	end_selected.emit()
	get_viewport().set_input_as_handled()
