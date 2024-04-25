class_name PartyPlacement
extends State
signal moved(direction:String)
signal grid_interaction
signal escape_pressed



func _enter_state():
	print('entered party placement')

func movement(direction):
	GlobalSignalBus.movement.emit(direction)
	
func interact():
	grid_interaction.emit()
	
func cancel():
	escape_pressed.emit()
