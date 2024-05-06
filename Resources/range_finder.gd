extends Node
var height:int
var width:int
var astar:AStarGrid2D

func setup(nheight,nwidth):
	self.height = nheight
	self.width = nwidth
	astar=AStarGrid2D.new()
	astar.region=Rect2i(0,0,width,height)
	astar.cell_size=Vector2(Global.cell_size,Global.cell_size)
	astar.update()
	

func targets_in_range_basic(board_state, character):
	construct_astar()
	var targets:Array=[]
	var attack_range=Weapons.weapons_dictionary[character.equipment[character.current_weapon]]['range']
	for row in range(len(board_state)):
		for column in range(len(board_state[0])):
			var range_to_tile=abs(row-character.grid_position.x)+abs(column-character.grid_position.y)
			var occupant=board_state[row][column]['occupant']
			if occupant  and occupant!= character:
				var path = astar.get_id_path(character.grid_position,Vector2i(row,column))
				if is_path_clear(board_state,path) and range_to_tile<=attack_range:
					targets.append(occupant)
	return targets

func targets_in_full_range(board_state,character):
	construct_astar()
	var targets:Array=[]
	var attack_range=Weapons.weapons_dictionary[character.equipment[character.current_weapon]]['range']+character.move
	for row in range(len(board_state)):
		for column in range(len(board_state[0])):
			var range_to_tile=abs(row-character.grid_position.x)+abs(column-character.grid_position.y)
			var occupant=board_state[row][column]['occupant']
			if occupant  and occupant!= character and occupant.faction!=character.faction:
				var path = astar.get_id_path(character.grid_position,Vector2i(row,column))
				if is_path_clear(board_state,path) and range_to_tile<=attack_range:
					targets.append(occupant)
	return targets


func targets_in_range_sa(board_state, character,sa):
	construct_astar()
	var targets:Array=[]
	var attack_range=SpellsAndAbilities.spells_and_abilities_directory[sa]['range']+1
	for row in range(len(board_state)):
		for column in range(len(board_state[0])):
			var range_to_tile=abs(row-character.grid_position.x)+abs(column-character.grid_position.y)
			var occupant=board_state[row][column]['occupant']
			if occupant  and occupant!= character:
				var path = astar.get_id_path(character.grid_position,Vector2i(row,column))
				if is_path_clear(board_state,path) and range_to_tile<=attack_range:
					targets.append(occupant)
	return targets



func targets_from_space(board_state,character,space):
	construct_astar()
	var targets:Array=[]
	var attack_range=Weapons.weapons_dictionary[character.equipment[character.current_weapon]]['range']
	for row in range(len(board_state)):
		for column in range(len(board_state[0])):
			var range_to_tile=abs(row-space.x)+abs(column-space.y)
			var occupant=board_state[row][column]['occupant']
			if occupant  and occupant!= character:
				var path = astar.get_id_path(character.grid_position,Vector2i(row,column))
				if is_path_clear(board_state,path) and range_to_tile<=attack_range:
					targets.append(occupant)
	return targets

func in_combat(board_state,character):
	var occupied_cells=get_surrounding(board_state,character.grid_position)
	if len(occupied_cells)>0:
		for dude in occupied_cells:
			if dude.faction != character.faction:
				return true
	return false


func would_put_in_combat(board_state,faction,grid_position):
	var occupied_cells=get_surrounding(board_state,grid_position)
	if len(occupied_cells)>0:
		for dude in occupied_cells:
			if dude.faction != faction:
				return true
	return false



func is_path_clear(board_state,path):
	for point in path:
		if Global.wall_spaces.has(board_state[point.x][point.y]['terrain']) or board_state[point.x][point.y]['terrain'] == Global.cap_stone or Global.decorations.has(board_state[point.x][point.y]['terrain']):
			return false
	return true


func construct_astar():
	astar.clear()
	astar.region=Rect2i(0,0,width,height)
	astar.cell_size=Vector2(16,16)
	astar.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astar.update()


func tiles_in_attack_range(board_state,character):
	var attack_range:int=Weapons.weapons_dictionary[character.equipment[character.current_weapon]]['range']+1
	var tiles_in_range:Array=[]
	var test_path
	construct_astar()
	for row in range(width):
		for column in range(height):
			var trimx = abs(row-character.grid_position.x)
			var trimy = abs(column-character.grid_position.y)
			test_path=astar.get_id_path(character.grid_position,Vector2i(row,column))
			if trimx+trimy<attack_range:
				if is_path_clear(board_state,test_path):
					tiles_in_range.append(Vector2i(row,column))
	return tiles_in_range



func tiles_in_attack_range_of_sa(board_state,character,sa):
	var attack_range:int=SpellsAndAbilities.spells_and_abilities_directory[sa]['range']+1
	var tiles_in_range:Array=[]
	var test_path
	construct_astar()
	for row in range(width):
		for column in range(height):
			var trimx = abs(row-character.grid_position.x)
			var trimy = abs(column-character.grid_position.y)
			test_path=astar.get_id_path(character.grid_position,Vector2i(row,column))
			if trimx+trimy<attack_range:
				if is_path_clear(board_state,test_path):
					tiles_in_range.append(Vector2i(row,column))
	return tiles_in_range


func get_surrounding(board_state,character_grid_position):
	var occupied_cells:Array=[]
	var test_cell
	if character_grid_position.y+1<height:
		test_cell=board_state[character_grid_position.x][character_grid_position.y+1]["occupant"]
		if test_cell:
			occupied_cells.append(test_cell)
	if character_grid_position.y-1>=0:
		test_cell=board_state[character_grid_position.x][character_grid_position.y-1]["occupant"]
		if test_cell:
			occupied_cells.append(test_cell)
	if character_grid_position.x+1<width:
		test_cell=board_state[character_grid_position.x+1][character_grid_position.y]["occupant"]
		if test_cell:
			occupied_cells.append(test_cell)
	if character_grid_position.x-1>=0:
		test_cell=board_state[character_grid_position.x-1][character_grid_position.y]["occupant"]
		if test_cell:
			occupied_cells.append(test_cell)
	return occupied_cells


func targets_in_range_AI(board_state,character):
	construct_astar()
	var targets:Array=targets_in_range_basic(board_state,character)
	for target in targets:
		if target.faction==character.faction:
			targets.erase(target)
	return targets


func targets_from_space_AI(board_state,character,space):
	construct_astar()
	var targets:Array=targets_from_space(board_state,character,space)
	for target in targets:
		if target.faction==character.faction:
			targets.erase(target)
	return targets

func sa_area_targets(board_state,space,action):
	construct_astar()
	var targets:Array=[]
	var attack_range:int=SpellsAndAbilities.spells_and_abilities_directory[action]['area']
	for row in range(len(board_state)):
		for column in range(len(board_state[0])):
			var range_to_tile=abs(row-space.x)+abs(column-space.y)
			var occupant=board_state[row][column]['occupant']
			if occupant and range_to_tile<=attack_range:
				var path = astar.get_id_path(space,Vector2i(row,column))
				if is_path_clear(board_state,path):
					targets.append(occupant)
	return targets

func cells_in_sa_area(board_state,space,action):
	construct_astar()
	var cells:Array=[]
	var attack_range:int=SpellsAndAbilities.spells_and_abilities_directory[action]['area']
	for row in range(len(board_state)):
		for column in range(len(board_state[0])):
			var range_to_tile=abs(row-space.x)+abs(column-space.y)
			if range_to_tile<=attack_range:
				cells.append(Vector2i(row,column))
	return cells
