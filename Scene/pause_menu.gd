class_name PauseMenu
extends State

signal show_pause_menu
signal grid_interaction
signal escape_pressed
# Called when the node enters the scene tree for the first time.

func _enter_state():
	print('entered pause menu')
	GlobalSignalBus.show_pause_menu.emit()

func _exit_state():
	GlobalSignalBus.hide_menu.emit()


func movement(_direction):
	#GlobalSignalBus.movement.emit(direction) #I had to turn this off because it futzs with menus
	pass
	
func interact():
	grid_interaction.emit()
	
func cancel():
	escape_pressed.emit()
