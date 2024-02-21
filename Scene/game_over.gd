class_name GameOver
extends State

signal show_results
signal grid_interaction
signal escape_pressed
# Called when the node enters the scene tree for the first time.

func _enter_state():
	print('entered game over')
	show_results.emit()

func _exit_state():
	GlobalSignalBus.hide_menu.emit()


func movement(_direction):
	#GlobalSignalBus.movement.emit(direction) #I had to turn this off because it futzs with menus
	pass
	
func interact():
	grid_interaction.emit()
	
func cancle():
	escape_pressed.emit()
