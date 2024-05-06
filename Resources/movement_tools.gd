extends Node
var height:int
var width:int
var astar:AStarGrid2D

func _ready():
	astar=AStarGrid2D.new()


func setup(nheight,nwidth):
	height=nheight
	width=nwidth

func construct_astar(board_state,character):
	astar.clear()
	astar.region=Rect2i(0,0,width,height)
	astar.cell_size=Vector2(16,16)
	astar.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER#movement is only orthogonal
	astar.update()
	for row in range(len(board_state)):
		for column in range(len(board_state[0])):
			var movable:bool=is_movable(board_state,character,Vector2i(row,column))
			if movable == false:
				astar.set_point_solid(Vector2i(row,column))


func is_movable(board_state,character,pos):
	var space =board_state[pos.x][pos.y]['terrain']
	var occupant = board_state[pos.x][pos.y]['occupant']
	if Global.wall_spaces.has(space) or space == Global.cap_stone or Global.decorations.has(space):
		return false
	if occupant and occupant.faction != character.faction:
		return false
	if Global.water_spaces.has(space):
		return false
	if Global.flight_spaces.has(space):
		return false
	return true

func will_fall(board_state,_character,pos):
	var space =board_state[pos.x][pos.y]['terrain']
	if space in Global.flight_spaces:
		return true
	return false
		



func can_move_to(board_state,_character,pos):
	var space =board_state[pos.x][pos.y]['terrain']
	var occupant = board_state[pos.x][pos.y]['occupant']
	if Global.wall_spaces.has(space) or space == Global.cap_stone or Global.decorations.has(space):
		return false
	if occupant:
		return false
	if Global.water_spaces.has(space):
		return false
	if Global.flight_spaces.has(space):
		return false
	return true

func tiles_in_movement_range(board_state,character):
	construct_astar(board_state,character)
	var possible_movement:Array=[]
	for row in width:
		for column in height:
			var pos: Vector2i = Vector2i(row,column)
			var range_to_tile=abs(row-character.grid_position.x)+abs(column-character.grid_position.y)
			if character.grid_position != pos and range_to_tile<=character.move:
				var path = astar.get_id_path(character.grid_position,pos)
				var possible_move:bool=can_move_to(board_state,character,pos)
				if len(path) <= character.move+1 and possible_move and len(path) != 0:
					possible_movement.append(pos)
	#print(possible_movement)
	return possible_movement


func get_path_list(board_state,character,destination):
	construct_astar(board_state,character)
	var path = astar.get_id_path(character.grid_position,destination)
	return path
