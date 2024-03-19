extends Button



func _on_button_up():
	get_viewport().set_input_as_handled()
	GlobalSignalBus.sa_button_pressed.emit(text)
	
