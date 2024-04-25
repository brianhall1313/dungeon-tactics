class_name AnimationState
extends State

signal show_pause_menu
signal grid_interaction
signal escape_pressed

# Called when the node enters the scene tree for the first time.

func _enter_state():
	print('entered animation state')

func _exit_state():
	pass

func movement(_direction):
	#GlobalSignalBus.movement.emit(direction) #I had to turn this off because it futzs with menus
	pass
	
func interact():
	#grid_interaction.emit()
	pass
	
func cancel():
	#escape_pressed.emit()
	pass
