class_name CharacterInteraction
extends State

signal show_fight_menu
signal moved(direction:String)
signal grid_interaction
signal escape_pressed
# Called when the node enters the scene tree for the first time.

func _enter_state():
	print('entered character interaction')
	show_fight_menu.emit()



func movement(_direction):
	#moved.emit(direction)
	pass
	
func interact():
	grid_interaction.emit()
	
func cancle():
	escape_pressed.emit()

