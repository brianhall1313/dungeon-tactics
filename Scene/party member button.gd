extends Button


func _on_button_up():
	get_viewport().set_input_as_handled()
	GlobalSignalBus.character_selected.emit(text)
