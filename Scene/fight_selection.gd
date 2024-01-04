extends State
signal grid_interaction
signal escape_pressed
signal moved



func _enter_state():
	print('entered fight selection')


func movement(direction):
	GlobalSignalBus.movement.emit(direction)
	
func interact():
	grid_interaction.emit()
	
func cancle():
	escape_pressed.emit()

