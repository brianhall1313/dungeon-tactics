class_name GridInteract
extends State
var input_timer:float=0.0
signal moved(direction:String)
signal grid_interaction
signal escape_pressed
var is_menu:bool=false


func _enter_state():
	print('entered grid interaction')

func movement(direction):
	moved.emit(direction)
	
func interact():
	grid_interaction.emit()
	
func cancle():
	escape_pressed.emit()

