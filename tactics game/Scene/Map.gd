extends TileMap
@onready var Pointer=$Pointer
@onready var state_machine=$FiniteStateMachine
@onready var fight_menu=$fight_menu
@onready var battle_lists=$battle_lists
@onready var players_list=$battle_lists/player_list.alive_list
@onready var enemies_list=$battle_lists/enemy_list.alive_list
@onready var mouse_position=$CanvasLayer/mouse_position
@onready var neighbors=$CanvasLayer/neighbors
@onready var tile_info=$CanvasLayer/tile_info
@onready var free_spaces:Array=[Vector2i(5,0),Vector2i(5,1),Vector2i(6,0),Vector2i(6,1)]
@onready var water_spaces:Array=[]
@onready var flight_spaces:Array=[]
@onready var selected_ui=$CanvasLayer/selected_character_info
@onready var targeted_ui=$CanvasLayer/targeted_character_info


var selected_character
var targeted_character
var astar:AStar2D
var fightstar:AStar2D
var tile: String
var current_cell_id:int
var highlighted_cells:Array
var death_spot:Vector2i=Vector2i(-100,-100)
var debug = true
var test_die:Die=Die.new(4)

# Called when the node enters the scene tree for the first time.
func _ready():
	connected_to_signal_bus()
	Global.set_death_position(death_spot,map_to_local(death_spot))
	
	Pointer.position=map_to_local(Vector2i(0,0))
	$battle_lists/player_list/Character.cMove.move(Vector2i(local_to_map(Pointer.position)),Pointer.position)
	$battle_lists/enemy_list/test_enemy.cMove.move(Vector2i(2,2),map_to_local(Vector2i(2,2)))
	
	astar=AStar2D.new()
	fightstar=AStar2D.new()
	GlobalSignalBus.update_board.emit()
	Global.current_character=$battle_lists/player_list/Character
	construct_astar(Global.current_character)
	ui_update()

# Called every frame. 'delta' is the elapsed time since the previous frame.

@warning_ignore("unused_parameter")
func _process(delta):
	mouse_position.text=str(local_to_map(get_local_mouse_position()))
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		for x in players_list:
			if x.cMove.grid_position==local_to_map(get_local_mouse_position()):
				var hit:int = test_die.roll()
				print('you got hit, man. For ' + str(hit))
				x.cHealth.damage_taken(hit)
		for x in enemies_list:
			if x.cMove.grid_position==local_to_map(get_local_mouse_position()):
				var hit:int = randi_range(1,8)
				print('you got hit, man. For ' + str(hit))
				x.cHealth.damage_taken(hit)
	if (local_to_map(get_local_mouse_position()).x < Global.width and local_to_map(get_local_mouse_position()).x>=0) and (local_to_map(get_local_mouse_position()).y < Global.height and local_to_map(get_local_mouse_position()).y>=0):
		tile=str(Global.board_state[local_to_map(get_local_mouse_position()).x][local_to_map(get_local_mouse_position()).y])
		clear_layer(1)
		track_mouse()
	if Global.board_state[local_to_map(Pointer.position).x][local_to_map(Pointer.position).y]['id']:
		current_cell_id=Global.board_state[local_to_map(Pointer.position).x][local_to_map(Pointer.position).y]['id']
	else:
		current_cell_id=1
		
	tile_info.text=tile
	#neighbors.text=str(astar.get_point_connections(current_cell_id))
	

func connected_to_signal_bus():
	GlobalSignalBus.connect('death',_on_character_death)
	GlobalSignalBus.connect('update_board',_on_update_board)
	GlobalSignalBus.connect('turn_over',_on_turn_over)


func track_mouse():
	if (local_to_map(get_local_mouse_position()).x < Global.width and local_to_map(get_local_mouse_position()).x>=0) and (local_to_map(get_local_mouse_position()).y < Global.height and local_to_map(get_local_mouse_position()).y>=0):
		if Global.board_state[local_to_map(get_local_mouse_position()).x][local_to_map(get_local_mouse_position()).y]['id'] in astar.get_point_ids():
			var path=astar.get_point_path(1,Global.board_state[local_to_map(get_local_mouse_position()).x][local_to_map(get_local_mouse_position()).y]['id'])
			for point in path:
				set_cell(1,local_to_map(Vector2(point.x,point.y)),2,Vector2i(0,0))

func get_board_state():
	var map_info=[]
	var count:int=1
	for row in range(Global.width):
		map_info.append([])
		for column in range(Global.height):
			map_info[row].append([])
			map_info[row][column]={"terrain"=get_cell_atlas_coords(0,Vector2i(row,column))#returns a vector2I
			,'occupant'=is_occupied(row,column),
			'center'=map_to_local(Vector2i(row,column)),
			'id'=count}
			count+=1
			
			#We still need to add if the occupant makes this passable, or not
	#print(map_info)
	return map_info

func is_occupied(row,column):
	for x in players_list:
		if x.position==map_to_local(Vector2i(row,column)):
			return x
	for x in enemies_list:
		if x.position==map_to_local(Vector2i(row,column)):
			return x
	return false


func occupant_faction_same(row,column,character):
	if Global.board_state[row][column]['occupant']:
		return Global.board_state[row][column]['occupant'].faction==character.faction
	return true


func occupiable(row,column,character):
	var space =Global.board_state[row][column]['terrain']
	if is_occupied(row,column) == false:
		if space in free_spaces:
			return true
		elif space in water_spaces and "swim" in character.traits:
			return true
		elif space in flight_spaces and "flight" in character.traits:
			return true
	return false
	
func move_throughable(row,column,character):
	var space =Global.board_state[row][column]['terrain']
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
	for row in range(Global.width):
		for column in range(Global.height):
			#We want the player to be able to move  through allies but not their enemies.
			if move_throughable(row,column,character):
				astar.add_point(Global.board_state[row][column]['id'],Global.board_state[row][column]['center'])
	var ids = astar.get_point_ids()
	#then we fill in neighbors
	for row in range(Global.width):
		for column in range(Global.height):
			var cell=Global.board_state[row][column]
			if cell['id'] in ids:
				if column-1>=0 and Global.board_state[row][column-1]['id']in ids:
					astar.connect_points(cell['id'],Global.board_state[row][column-1]['id'])
				if column+1<Global.height and Global.board_state[row][column+1]['id']in ids:
					astar.connect_points(cell['id'],Global.board_state[row][column+1]['id'])
				if row-1>=0 and Global.board_state[row-1][column]['id']in ids:
					astar.connect_points(cell['id'],Global.board_state[row-1][column]['id'])
				if row+1<Global.width and Global.board_state[row+1][column]['id']in ids:
					astar.connect_points(cell['id'],Global.board_state[row+1][column]['id'])



func construct_fightstar():
	fightstar.clear()
	#fils in the board with ids,Probably Need to Be Expanded to Include Other terrain Types if People can fly
	for row in range(Global.width):
		for column in range(Global.height):
			fightstar.add_point(Global.board_state[row][column]['id'],Global.board_state[row][column]['center'])
	var ids = fightstar.get_point_ids()
	#then we fill in neighbors
	for row in range(Global.width):
		for column in range(Global.height):
			var cell=Global.board_state[row][column]
			if cell['id'] in ids:
				if column-1>=0 and Global.board_state[row][column-1]['id']in ids:
					fightstar.connect_points(cell['id'],Global.board_state[row][column-1]['id'])
				if column+1<Global.height and Global.board_state[row][column+1]['id']in ids:
					fightstar.connect_points(cell['id'],Global.board_state[row][column+1]['id'])
				if row-1>=0 and Global.board_state[row-1][column]['id']in ids:
					fightstar.connect_points(cell['id'],Global.board_state[row-1][column]['id'])
				if row+1<Global.width and Global.board_state[row+1][column]['id']in ids:
					fightstar.connect_points(cell['id'],Global.board_state[row+1][column]['id'])
				
				#this is for diagonals just in case
#				if row+1<Global.width and column+1<Global.height and Global.board_state[row+1][column+1]['id']in ids:
#					fightstar.connect_points(cell['id'],Global.board_state[row+1][column+1]['id'])
#				if row+1<Global.width and column-1>0 and Global.board_state[row+1][column-1]['id']in ids:
#					fightstar.connect_points(cell['id'],Global.board_state[row+1][column-1]['id'])
#				if row-1>0 and column+1<Global.height and Global.board_state[row-1][column+1]['id']in ids:
#					fightstar.connect_points(cell['id'],Global.board_state[row-1][column+1]['id'])
#				if row-1>0 and column-1>0 and Global.board_state[row-1][column-1]['id']in ids:
#					fightstar.connect_points(cell['id'],Global.board_state[row-1][column-1]['id'])




func display_move_range(character):
	var move_range:int=character.cMove.modified_move+1
	var tiles_in_range:Array=[]
	var player_position = character.cMove.grid_position
	var player_position_id=Global.board_state[player_position.x][player_position.y]['id']
	for row in range(Global.width):
		if abs(row-move_range)>=0:
			for column in range(Global.height):
				if player_position != Vector2i(row,column):
					if abs(column-move_range)>=0 and Global.board_state[row][column]['id'] in astar.get_point_ids():
						var shortest_path=astar.get_point_path(player_position_id,Global.board_state[row][column]['id'])
						if len(shortest_path)<=move_range:
							tiles_in_range.append(Vector2i(row,column))
							set_cell(1,Vector2i(row,column),2,Vector2i(0,0))
	character.cMove.set_possible_movement(tiles_in_range)
	


func display_attack_range(character):
	var tiles_in_range:Array=find_tiles_in_attack_range(character)
	for t in tiles_in_range:
		
		set_cell(1,t,1,Vector2i(0,0))#this displays he attack range to the player

func find_targets(character):
	var tiles_in_range:Array=find_tiles_in_attack_range(character)
	var targets:Array=[]

	for t in tiles_in_range:
		
		if is_occupied(t.x,t.y):
			targets.append(is_occupied(t.x,t.y))
	character.cCombat.set_potential_targets(targets)



func find_tiles_in_attack_range(character):
	construct_fightstar()
	var attack_range:int=character.weapon['range']+1
	var tiles_in_range:Array=[]
	var player_position = character.cMove.grid_position
	var player_position_id=Global.board_state[player_position.x][player_position.y]['id']
	for row in range(Global.width):
		if abs(row-attack_range)>=0:
			for column in range(Global.height):
				if player_position != Vector2i(row,column):
					if abs(column-attack_range)>=0 and Global.board_state[row][column]['id'] in fightstar.get_point_ids():
						var shortest_path=fightstar.get_point_path(player_position_id,Global.board_state[row][column]['id'])
						if len(shortest_path) <= attack_range:
							tiles_in_range.append(Vector2i(row,column))
	return tiles_in_range


func ui_update():
	var is_character=is_occupied(Pointer.grid_position.x,Pointer.grid_position.y)
	if is_character:
		if Global.current_character:
			if is_character==Global.current_character:
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
		if Global.current_state != $FiniteStateMachine/movement_selection:
			selected_ui.hide()


func resolve_attack(attacker,defender):
	var attack_rolls:Array
	var defense_rolls:Array
	print('have at thee')
	attack_rolls=Global.current_character.cCombat.attack()
	defender.cHealth.attack_resolution(attack_rolls)


func _on_pointer_pointer_position(pos):
	Pointer.position=map_to_local(pos)
	ui_update()


func _on_grid_interact_grid_interaction():#I don't know if this should go here
	for x in players_list:
		if x.position==Pointer.position:
			Global.current_character=x
			if debug == true:#we only have this like this so that we can test stuff effectively for now
				Global.current_character.turn_start()
			state_machine.change_state($FiniteStateMachine/character_interaction)
			GlobalSignalBus.update_board.emit()
			return



func _on_movement_selection_grid_interaction():
	if Vector2i(local_to_map(Pointer.position)) in Global.current_character.cMove.possible_movement:
		Global.current_character.cMove.move(Vector2i(local_to_map(Pointer.position)),Pointer.position)
		clear_layer(1)
		Global.current_character.turn('moved')
		state_machine.change_state($FiniteStateMachine/character_interaction)
		#TODO:Remember, when we change the final state of the turn this needs to move to that one
		GlobalSignalBus.update_board.emit()
		



func _on_fight_menu_movement_selected():
	state_machine.change_state($FiniteStateMachine/movement_selection)
	construct_astar(Global.current_character)
	display_move_range(Global.current_character)


func _on_movement_selection_escape_pressed():
	Pointer.go_to(Global.current_character.cMove.grid_position)
	clear_layer(1)
	state_machine.change_state($FiniteStateMachine/character_interaction)


func _on_fight_menu_fight_selected():
	state_machine.change_state($FiniteStateMachine/fight_selection)
	#TODO the rest of the fight stuff
	#show fight range
	display_attack_range(Global.current_character)
	#get target information
	find_targets(Global.current_character)
	#TODO get confirmation on attack
	#do the attack rolls
	#passing target the attack to resolve it

func _on_character_death(character):
	battle_lists.remove_character(character)
	print('removing character')
	ui_update()


func _on_fight_selection_grid_interaction():
	var defender

	defender=is_occupied(local_to_map(Pointer.position).x,local_to_map(Pointer.position).y )
	if defender and defender in Global.current_character.cCombat.potential_targets:
		resolve_attack(Global.current_character,defender)
		Global.current_character.turn('action')
		state_machine.change_state($FiniteStateMachine/GridInteract)
		GlobalSignalBus.update_board.emit()
		clear_layer(1)
		clear_layer(2)
	
	
func _on_update_board():
	print('updating')
	Global.board_state=get_board_state()
	fight_menu.position=Pointer.position
	fight_menu.update_menu(Global.current_character)

func _on_turn_over():
	Global.board_state=get_board_state()
	Global.current_character=false
	ui_update()
	
	


func _on_character_interaction_escape_pressed():
	state_machine.change_state($FiniteStateMachine/GridInteract)
	fight_menu.hide()


func _on_fight_selection_escape_pressed():
	Pointer.go_to(Global.current_character.cMove.grid_position)
	
	clear_layer(1)
	clear_layer(2)
	state_machine.change_state($FiniteStateMachine/character_interaction)
