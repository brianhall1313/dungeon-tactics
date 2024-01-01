extends Sprite2D
@export var grid_position: Vector2i=Vector2i(0,0)
signal pointer_position(pos:Vector2i)


func movement(direction):
	if direction == 'Down':
		grid_position.y=clamp(grid_position.y+1,0,Global.height-1) 
	elif direction == 'Up':
		grid_position.y=clamp(grid_position.y-1,0,Global.height-1)
	elif direction == 'Right':
		grid_position.x=clamp(grid_position.x+1,0,Global.width-1)
	elif direction == 'Left':
		grid_position.x=clamp(grid_position.x-1,0,Global.height-1)
	pointer_position.emit(grid_position)


func go_to(new_position:Vector2i):
	grid_position=new_position
	pointer_position.emit(grid_position)



func _on_grid_interact_moved(direction):
	movement(direction)




func _on_movement_selection_moved(direction):
	movement(direction)


func _on_fight_selection_moved(direction):
	movement(direction)
