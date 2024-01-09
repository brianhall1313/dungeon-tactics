extends Control
var interaction:Array = ["Space","Enter"]
var direction:Array = ['Up','Down','Left','Right']
var go_back:Array = ['Escape']




func _unhandled_input(event):
	if event is InputEventKey:
		#if event.is_released():
			#print(event.as_text_keycode())
		if event.is_released() and event.as_text_keycode() in interaction:
			GlobalSignalBus.interact.emit()
			get_viewport().set_input_as_handled()
			print("interaction pressed:input manager")
		if event.is_released() and event.as_text_keycode() in direction:
			GlobalSignalBus.moved.emit(event.as_text_keycode())
			get_viewport().set_input_as_handled()
		if event.is_released() and event.as_text_keycode() in go_back:
			GlobalSignalBus.cancel.emit()
			get_viewport().set_input_as_handled()
