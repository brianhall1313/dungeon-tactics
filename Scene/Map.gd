extends TileMap
@onready var Pointer=$Pointer
@onready var fight_menu=$fight_menu
@onready var battle_lists=$battle_lists
@onready var players_list
@onready var enemies_list
@onready var mouse_position=$CanvasLayer/mouse_position
@onready var neighbors=$CanvasLayer/neighbors
@onready var tile_info=$CanvasLayer/tile_info
@onready var free_spaces:Array=[4]
@onready var water_spaces:Array=[]
@onready var flight_spaces:Array=[]
@onready var selected_ui=$CanvasLayer/selected_character_info
@onready var targeted_ui=$CanvasLayer/targeted_character_info


var dir:Dictionary={"Down":Vector2i(0,1),"Up":Vector2i(0,-1),"Left":Vector2i(-1,0),"Right":Vector2i(1,0)}
var input_timer:float=0.0
var height:int=10
var width:int=10
var board_state
var current_character
var selected_character
var targeted_character
var astar:AStar2D
var fightstar:AStar2D
var tile: String
var current_cell_id:int
var highlighted_cells:Array
var death_spot:Vector2=map_to_local(Vector2i(-100,-100))
var possible_movement:Array=[]
var possible_targets:Array=[]
var in_attack_range:Array=[]
var crit_damage_bonus: int =5

signal change_state(state_name:String)

# Called when the node enters the scene tree for the first time.
func _ready():
	connected_to_signal_bus()
	Global.set_death_position(death_spot)
	Pointer.movement(Vector2i(0,0),map_to_local(Vector2i(0,0)))
	enemies_list=battle_lists.get_enemies()
	players_list=battle_lists.get_player()
	$battle_lists/player_list/Character.position=map_to_local($battle_lists/player_list/Character.default_position)
	$battle_lists/enemy_list/test_enemy.position=map_to_local($battle_lists/enemy_list/test_enemy.default_position)
	
	astar=AStar2D.new()
	fightstar=AStar2D.new()
	GlobalSignalBus.update_board.emit()
	ui_update()
	print(Vector2i(1,0)+Vector2i(1,1))

# Called every frame. 'delta' is the elapsed time since the previous frame.


func _process(delta):
	mouse_position.text=str(local_to_map(get_local_mouse_position()))
	if input_timer>.4:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			for x in players_list:
				if local_to_map(x.position)==local_to_map(get_local_mouse_position()):
					var hit:int = dice_roll()
					print('you got hit, man. For ' + str(hit))
					x.take_damage(hit)
					input_timer=0.0
			for x in enemies_list:
				if local_to_map(x.position)==local_to_map(get_local_mouse_position()):
					var hit:int = dice_roll()
					print('you got hit, man. For ' + str(hit))
					x.take_damage(hit)
					input_timer=0.0
	input_timer+=delta
				
	if (local_to_map(get_local_mouse_position()).x < width and local_to_map(get_local_mouse_position()).x>=0) and (local_to_map(get_local_mouse_position()).y < height and local_to_map(get_local_mouse_position()).y>=0):
		tile=str(board_state[local_to_map(get_local_mouse_position()).x][local_to_map(get_local_mouse_position()).y])
		clear_layer(1)
		track_mouse()
	if board_state[local_to_map(Pointer.position).x][local_to_map(Pointer.position).y]['id']:
		current_cell_id=board_state[local_to_map(Pointer.position).x][local_to_map(Pointer.position).y]['id']
	else:
		current_cell_id=1
		
	tile_info.text=tile
	#neighbors.text=str(astar.get_point_connections(current_cell_id))

func connected_to_signal_bus():
	GlobalSignalBus.connect('update_board',_on_update_board)
	GlobalSignalBus.connect('death',_on_character_death)
	GlobalSignalBus.connect('turn_over',_on_turn_over)
	GlobalSignalBus.connect("movement",movement_received)

func get_board_state():
	var map_info=[]
	var count:int=1
	for row in range(width):
		map_info.append([])
		for column in range(height):
			map_info[row].append([])
			map_info[row][column]={"terrain"=get_cell_source_id(0,Vector2i(row,column))#returns a vector2I
			,'occupant'=is_occupied(row,column),
			'center'=map_to_local(Vector2i(row,column)),
			'id'=count}
			count+=1
			
			#We still need to add if the occupant makes this passable, or not
	#print(map_info)
	return map_info
	
	
func track_mouse():
	if (local_to_map(get_local_mouse_position()).x < width and local_to_map(get_local_mouse_position()).x>=0) and (local_to_map(get_local_mouse_position()).y < height and local_to_map(get_local_mouse_position()).y>=0):
		if board_state[local_to_map(get_local_mouse_position()).x][local_to_map(get_local_mouse_position()).y]['id'] in astar.get_point_ids():
			var path=astar.get_point_path(1,board_state[local_to_map(get_local_mouse_position()).x][local_to_map(get_local_mouse_position()).y]['id'])
			for point in path:
				set_cell(1,local_to_map(Vector2(point.x,point.y)),2,Vector2i(0,0))


func is_occupied(row,column):
	for x in players_list:
		if x.position==map_to_local(Vector2i(row,column)):
			return x
	for x in enemies_list:
		if x.position==map_to_local(Vector2i(row,column)):
			return x
	return false


func occupant_faction_same(row,column,character):
	if board_state[row][column]['occupant']:
		return board_state[row][column]['occupant'].faction==character.faction
	return true


func occupiable(row,column,character):
	var space =board_state[row][column]['terrain']
	if is_occupied(row,column) == false:
		if space in free_spaces:
			return true
		elif space in water_spaces and "swim" in character.status:
			return true
		elif space in flight_spaces and "flight" in character.status:
			return true
	return false
	
func move_throughable(row,column,character):
	var space =board_state[row][column]['terrain']
	if occupant_faction_same(row,column,character):
		if space in free_spaces:
			return true
		elif space in water_spaces and "swim" in character.traits:
			return true
		elif space in flight_spaces and "flight" in character.traits:
			return true
	return false

func construct_astar(character):
	astar.clear()
	#fils in the board with ids,Probably Need to Be Expanded to Include Other terrain Types if People can fly
	for row in range(width):
		for column in range(height):
			#We want the player to be able to move  through allies but not their enemies.
			if move_throughable(row,column,character):
				astar.add_point(board_state[row][column]['id'],board_state[row][column]['center'])
	var ids = astar.get_point_ids()
	#then we fill in neighbors
	for row in range(width):
		for column in range(height):
			var cell=board_state[row][column]
			if cell['id'] in ids:
				if column-1>=0 and board_state[row][column-1]['id']in ids:
					astar.connect_points(cell['id'],board_state[row][column-1]['id'])
				if column+1<height and board_state[row][column+1]['id']in ids:
					astar.connect_points(cell['id'],board_state[row][column+1]['id'])
				if row-1>=0 and board_state[row-1][column]['id']in ids:
					astar.connect_points(cell['id'],board_state[row-1][column]['id'])
				if row+1<width and board_state[row+1][column]['id']in ids:
					astar.connect_points(cell['id'],board_state[row+1][column]['id'])



func construct_fightstar():
	fightstar.clear()
	#fils in the board with ids,Probably Need to Be Expanded to Include Other terrain Types if People can fly
	for row in range(width):
		for column in range(height):
			fightstar.add_point(board_state[row][column]['id'],board_state[row][column]['center'])
	var ids = fightstar.get_point_ids()
	#then we fill in neighbors
	for row in range(width):
		for column in range(height):
			var cell=board_state[row][column]
			if cell['id'] in ids:
				if column-1>=0 and board_state[row][column-1]['id']in ids:
					fightstar.connect_points(cell['id'],board_state[row][column-1]['id'])
				if column+1<height and board_state[row][column+1]['id']in ids:
					fightstar.connect_points(cell['id'],board_state[row][column+1]['id'])
				if row-1>=0 and board_state[row-1][column]['id']in ids:
					fightstar.connect_points(cell['id'],board_state[row-1][column]['id'])
				if row+1<width and board_state[row+1][column]['id']in ids:
					fightstar.connect_points(cell['id'],board_state[row+1][column]['id'])
				
				#this is for diagonals just in case
#				if row+1<width and column+1<height and board_state[row+1][column+1]['id']in ids:
#					fightstar.connect_points(cell['id'],board_state[row+1][column+1]['id'])
#				if row+1<width and column-1>0 and board_state[row+1][column-1]['id']in ids:
#					fightstar.connect_points(cell['id'],board_state[row+1][column-1]['id'])
#				if row-1>0 and column+1<height and board_state[row-1][column+1]['id']in ids:
#					fightstar.connect_points(cell['id'],board_state[row-1][column+1]['id'])
#				if row-1>0 and column-1>0 and board_state[row-1][column-1]['id']in ids:
#					fightstar.connect_points(cell['id'],board_state[row-1][column-1]['id'])




func display_move_range(character):
	var move_range:int=character.move+1
	var tiles_in_range:Array=[]
	var player_position = local_to_map(character.position)
	var player_position_id=board_state[player_position.x][player_position.y]['id']
	for row in range(width):
		if abs(row-move_range)>=0:
			for column in range(height):
				if player_position != Vector2i(row,column):
					if abs(column-move_range)>=0 and board_state[row][column]['id'] in astar.get_point_ids():
						var shortest_path=astar.get_point_path(player_position_id,board_state[row][column]['id'])
						if len(shortest_path)<=move_range:
							tiles_in_range.append(Vector2i(row,column))
							set_cell(1,Vector2i(row,column),2,Vector2i(0,0))
	possible_movement=tiles_in_range
	


func display_attack_range(character):
	var tiles_in_range:Array=find_tiles_in_attack_range(character)
	for t in tiles_in_range:
		
		set_cell(1,t,1,Vector2i(0,0))#this displays he attack range to the player

func find_targets(character):
	in_attack_range=find_tiles_in_attack_range(character)
	var targets:Array=[]

	for t in in_attack_range:
		
		if is_occupied(t.x,t.y):
			targets.append(is_occupied(t.x,t.y))
	possible_targets=targets



func find_tiles_in_attack_range(character):
	construct_fightstar()
	var attack_range:int=character.equipment['weapon']['range']+1
	var tiles_in_range:Array=[]
	var player_position = local_to_map(character.position)
	var player_position_id=board_state[player_position.x][player_position.y]['id']
	for row in range(width):
		if abs(row-attack_range)>=0:
			for column in range(height):
				if player_position != Vector2i(row,column):
					if abs(column-attack_range)>=0 and board_state[row][column]['id'] in fightstar.get_point_ids():
						var shortest_path=fightstar.get_point_path(player_position_id,board_state[row][column]['id'])
						if len(shortest_path) <= attack_range:
							tiles_in_range.append(Vector2i(row,column))
	return tiles_in_range


func ui_update():
	var is_character=is_occupied(Pointer.grid_position.x,Pointer.grid_position.y)
	if is_character:
		if current_character:
			if is_character==current_character:
				selected_character=is_character
				selected_ui.update(selected_character)
				selected_ui.show()
				targeted_ui.hide()
			
			else:
				targeted_character=is_character
				targeted_ui.update(targeted_character)
				targeted_ui.show()
		else:
			selected_character=is_character
			selected_ui.update(selected_character)
			selected_ui.show()
			targeted_ui.hide()
	else:
		targeted_ui.hide()
		if Global.current_state.name != 'movement_selection':
			selected_ui.hide()


func dice_roll():
	var roll:int = 0
	roll = randi_range(1,20)
	if roll==20:
		print('critical hit!!!')
		return roll+crit_damage_bonus
	else:
		return roll


func resolve_attack(attacker,defender):
	var attack:int
	var defence:int
	var damage:int
	attack=dice_roll()+attacker.get_attack()
	defence=dice_roll()+defender.get_attack()
	if attack>=defence:
		damage=attack+attacker.get_damage_bonus()
		defender.take_damage(damage)
		print('attacker: '+attacker.character_name+ ' hits defender: '+defender.character_name+'for '+str(damage))
	else:
		damage=defence+defender.get_damage_bonus()
		attacker.take_damage(damage)
		print('defender: '+defender.character_name+ ' hits attacker: '+attacker.character_name+'for '+str(damage))


func _on_grid_interact_grid_interaction():#I don't know if this should go here
	for x in players_list:
		if local_to_map(x.position)==local_to_map(Pointer.position):
			current_character=x
			if Global.debug == true:#we only have this like this so that we can test stuff effectively for now
				current_character.turn_start()
			change_state.emit('character_interaction')
			fight_menu.show_menu()
			GlobalSignalBus.update_board.emit()
			return



func _on_movement_selection_grid_interaction():
	if Vector2i(local_to_map(Pointer.position)) in possible_movement:
		possible_movement=[]
		current_character.movement(Pointer.position)
		clear_layer(1)
		change_state.emit('character_interaction')
		fight_menu.show_menu()
		#TODO:Remember, when we change the final state of the turn this needs to move to that one
		GlobalSignalBus.update_board.emit()
		



func _on_fight_menu_movement_selected():
	change_state.emit('movement_selection')
	construct_astar(current_character)
	display_move_range(current_character)


func _on_movement_selection_escape_pressed():
	current_character.undo_movement()
	possible_movement=[]
	clear_layer(1)
	change_state.emit('character_interaction')


func _on_fight_menu_fight_selected():
	change_state.emit('fight_selection')
	#TODO the rest of the fight stuff
	#show fight range
	display_attack_range(current_character)
	#get target information
	find_targets(current_character)
	#TODO get confirmation on attack
	#do the attack rolls
	#passing target the attack to resolve it

func _on_character_death(character):
	battle_lists.remove_character(character)
	character.position=map_to_local(death_spot)
	print('removing character')
	ui_update()


func _on_fight_selection_grid_interaction():
	var defender

	defender=is_occupied(local_to_map(Pointer.position).x,local_to_map(Pointer.position).y )
	if defender and defender in possible_targets:
		resolve_attack(current_character,defender)
		current_character.turn('action')
		change_state.emit('grid_interact')
		GlobalSignalBus.update_board.emit()
		clear_layer(1)
		clear_layer(2)
	
	
func _on_update_board():
	print('updating')
	board_state=get_board_state()
	fight_menu.position=Pointer.position
	fight_menu.update_menu(current_character)

func _on_turn_over():
	board_state=get_board_state()
	current_character=false
	ui_update()
	
	


func _on_character_interaction_escape_pressed():
	if current_character.turn_tracker['moved']:
		current_character.undo_movement()
		Pointer.movement(local_to_map(current_character.position),current_character.position)
		fight_menu.move(Pointer.position)
		fight_menu.update_menu(current_character)
	else:
		change_state.emit("grid_interact")
		fight_menu.hide()


func _on_fight_selection_escape_pressed():
	Pointer.position=current_character.position
	
	clear_layer(1)
	clear_layer(2)
	change_state.emit("character_interaction")


func movement_received(direction):
	var y:int = Pointer.grid_position.y
	var x:int = Pointer.grid_position.x
	if direction == 'Down' and y+1<height:
		Pointer.movement(Pointer.grid_position+dir[direction],map_to_local(Pointer.grid_position+dir[direction]))
	elif direction == 'Up' and y-1>=0:
		Pointer.movement(Pointer.grid_position+dir[direction],map_to_local(Pointer.grid_position+dir[direction]))
	elif direction == 'Right' and x+1<width:
		Pointer.movement(Pointer.grid_position+dir[direction],map_to_local(Pointer.grid_position+dir[direction]))
	elif direction == 'Left' and x-1>=0:
		Pointer.movement(Pointer.grid_position+dir[direction],map_to_local(Pointer.grid_position+dir[direction]))
	ui_update()


func _on_grid_interact_escape_pressed():
	pass # Replace with function body.
