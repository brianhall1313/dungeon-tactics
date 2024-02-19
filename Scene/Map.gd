extends TileMap
@onready var Pointer=$Pointer
@onready var fight_menus=$fight_menus
@onready var fight_menu=$fight_menus/fight_menu
@onready var battle_lists=$battle_lists
@onready var players_list
@onready var enemies_list
@onready var mouse_position=$CanvasLayer/mouse_position
@onready var neighbors=$CanvasLayer/neighbors
@onready var tile_info=$CanvasLayer/tile_info
@onready var selected_ui=$CanvasLayer/selected_character_info
@onready var targeted_ui=$CanvasLayer/targeted_character_info
@onready var action:String=''

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
var rangedfightstar:AStarGrid2D
var tile: String
var current_cell_id:int
var highlighted_cells:Array
var death_spot:Vector2=map_to_local(Vector2i(-100,-100))

var in_attack_range:Array=[]


signal pass_board_state(board)
signal ai_list_handover(list)
# Called when the node enters the scene tree for the first time.
func _ready():
	connected_to_signal_bus()
	RangeFinder.setup(height,width)
	MovementTools.setup(height,width)
	Global.set_death_position(death_spot)
	Pointer.movement(Vector2i(0,0),map_to_local(Vector2i(0,0)))
	enemies_list=battle_lists.get_enemies()
	players_list=battle_lists.get_player()
	for x in enemies_list.alive_list:
		GlobalSignalBus.place_character_default.emit(x)
		x.select_weapon(false)
	for x in players_list.alive_list:
		GlobalSignalBus.place_character_default.emit(x)
		x.select_weapon(false)
	
	astar=AStar2D.new()
	fightstar=AStar2D.new()
	rangedfightstar=AStarGrid2D.new()
	
	GlobalSignalBus.update_board.emit()
	ui_update()
	
	var test_character={'character_name':'Buster',
						'default_position':Vector2i(9,9),
						'experience':0,
						'faction':'enemy',
						'job':'templar',
						'spells':[],
						'abilities':[],
						'equipment':ClassData.class_dictionary['templar']["equipment"],
						'stats':ClassData.class_dictionary['templar']
						}
	
	var test_character2={'character_name':'Franklin',
						'default_position':Vector2i(3,7),
						'experience':0,
						'faction':'enemy',
						'job':'templar',
						'spells':[],
						'abilities':[],
						'equipment':ClassData.class_dictionary['templar']["equipment"],
						'stats':ClassData.class_dictionary['templar']
						}
	var test_character3={'character_name':'Ohmanny',
						'default_position':Vector2i(0,1),
						'experience':0,
						'faction':'player',
						'job':'templar',
						'spells':[],
						'abilities':[],
						'equipment':ClassData.class_dictionary['templar']["equipment"],
						'stats':ClassData.class_dictionary['templar']
						}
	var test_character4={'character_name':'Daroupty',
						'default_position':Vector2i(0,3),
						'experience':0,
						'faction':'player',
						'job':'ranger',
						'spells':[],
						'abilities':[],
						'equipment':ClassData.class_dictionary['ranger']["equipment"],
						'stats':ClassData.class_dictionary['ranger']
						}
	
	
	
	
	battle_lists.add_character(test_character)
	battle_lists.add_character(test_character2)
	battle_lists.add_character(test_character3)
	battle_lists.add_character(test_character4)
# Called every frame. 'delta' is the elapsed time since the previous frame.


func _process(delta):
	mouse_position.text=str(local_to_map(get_local_mouse_position()))
	if board_state[local_to_map(Pointer.position).x][local_to_map(Pointer.position).y]['id']:
		current_cell_id=board_state[local_to_map(Pointer.position).x][local_to_map(Pointer.position).y]['id']
	else:
		current_cell_id=1
		
	tile_info.text=tile
	#neighbors.text=Global.current_state.name

func connected_to_signal_bus():
	GlobalSignalBus.connect('update_board',_on_update_board)
	GlobalSignalBus.connect('death',_on_character_death)
	GlobalSignalBus.connect('turn_over',_on_turn_over)
	GlobalSignalBus.connect("movement",_movement_received)
	GlobalSignalBus.connect('place_character_default',_place_default)
	GlobalSignalBus.connect('move_request',_move_request_received)
	GlobalSignalBus.connect("sa_button_pressed",_on_sa_button_pressed)

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
	pass_board_state.emit(map_info)
	return map_info
	
	
func track_mouse():
	if (local_to_map(get_local_mouse_position()).x < width and local_to_map(get_local_mouse_position()).x>=0) and (local_to_map(get_local_mouse_position()).y < height and local_to_map(get_local_mouse_position()).y>=0):
		if board_state[local_to_map(get_local_mouse_position()).x][local_to_map(get_local_mouse_position()).y]['id'] in astar.get_point_ids():
			var path=astar.get_point_path(1,board_state[local_to_map(get_local_mouse_position()).x][local_to_map(get_local_mouse_position()).y]['id'])
			for point in path:
				set_cell(1,local_to_map(Vector2(point.x,point.y)),2,Vector2i(0,0))


func draw_path(path):
	for point in path:
		set_cell(1,local_to_map(Vector2(point.x,point.y)),2,Vector2i(0,0))



func is_occupied(row,column):
	for x in players_list.alive_list:
		if x.position==map_to_local(Vector2i(row,column)):
			return x
	for x in enemies_list.alive_list:
		if x.position==map_to_local(Vector2i(row,column)):
			return x
	return false


func occupant_faction_same(row,column,character):
	if board_state[row][column]['occupant']:
		return board_state[row][column]['occupant'].faction==character.faction
	return true



func display_move_range(character):
	var possible_movement = MovementTools.tiles_in_movement_range(board_state,character)
	for space in possible_movement:
		set_cell(1,space,2,Vector2i(0,0))
	
	


func display_attack_range(character):
	var tiles_in_range:Array
	
	tiles_in_range=RangeFinder.tiles_in_attack_range(board_state,character)
	for t in tiles_in_range:
		if t != character.grid_position:
			set_cell(1,t,1,Vector2i(0,0))#this displays he attack range to the player

func display_range_sa(character,sa):
	var tiles_in_range:Array
	
	tiles_in_range=RangeFinder.tiles_in_attack_range_of_sa(board_state,character,sa)
	for t in tiles_in_range:
		if t != character.grid_position:
			if SpellsAndAbilities.spells_and_abilities_directory[sa]['type']=='attack':
				set_cell(1,t,1,Vector2i(0,0))


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



func range_finder(origin:Vector2i,target:Vector2i):
	var origin_id=board_state[origin.x][origin.y]['id']
	var target_id=board_state[target.x][target.y]['id']
	var shortest_path=astar.get_point_path(origin_id,target_id)
	return shortest_path



func _on_grid_interact_grid_interaction():#I don't know if this should go here
	for x in players_list.alive_list:
		if local_to_map(x.position)==local_to_map(Pointer.position):
			current_character=x
			if Global.debug == true:#we only have this like this so that we can test stuff effectively for now
				current_character.turn_start()
			GlobalSignalBus.change_state.emit('character_interaction')
			fight_menu.show_menu()
			fight_menus.move(Pointer.position)
			GlobalSignalBus.update_board.emit()
			var possible_targets=RangeFinder.targets_from_space(board_state,current_character,current_character.grid_position)
			if len(possible_targets)>0:
				for char in possible_targets:
					print(char.character_name)
			return



func _on_movement_selection_grid_interaction():
	var possible_movement=MovementTools.tiles_in_movement_range(board_state,current_character)
	if Vector2i(local_to_map(Pointer.position)) in possible_movement:
		possible_movement=[]
		current_character.movement(Pointer.position,Pointer.grid_position)
		clear_layer(1)
		GlobalSignalBus.change_state.emit('character_interaction')
		fight_menu.show_menu()
		#TODO:Remember, when we change the final state of the turn this needs to move to that one
		GlobalSignalBus.update_board.emit()
		



func _on_fight_menu_movement_selected():
	GlobalSignalBus.change_state.emit('movement_selection')
	
	display_move_range(current_character)


func _on_movement_selection_escape_pressed():
	current_character.undo_movement()
	clear_layer(1)
	GlobalSignalBus.change_state.emit('character_interaction')


func _on_fight_menu_fight_selected():
	GlobalSignalBus.change_state.emit('fight_selection')
	#TODO the rest of the fight stuff
	#show fight range
	current_character.select_weapon(RangeFinder.in_combat(board_state,current_character))
	display_attack_range(current_character)
	#get target information
	current_character.possible_targets = RangeFinder.targets_in_range_basic(board_state,current_character)
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
	if defender and defender in current_character.possible_targets:
		AttackTools.fight(current_character,defender)
		GlobalSignalBus.change_state.emit('grid_interact')
		current_character.turn('action')
		GlobalSignalBus.update_board.emit()
		clear_layer(1)
		clear_layer(2)
	
	
func _on_update_board():
	print('updating')
	board_state=get_board_state()
	fight_menus.position=Pointer.position
	fight_menu.update_menu(current_character)

func _on_turn_over(_character):
	board_state=get_board_state()
	current_character=false
	ui_update()
	
	


func _on_character_interaction_escape_pressed():
	if fight_menus.sa_open==false:
		GlobalSignalBus.change_state.emit("grid_interact")
		fight_menu.hide()
	else:
		fight_menus.sa_close()


func _on_fight_selection_escape_pressed():
	Pointer.position=current_character.position
	
	clear_layer(1)
	clear_layer(2)
	fight_menu.show()
	fight_menu.fight_button.grab_focus()
	GlobalSignalBus.change_state.emit("character_interaction")


func _movement_received(direction):
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


func _place_default(character):
	character.movement(map_to_local(character.default_position),character.default_position)


func _on_grid_interact_escape_pressed():
	var is_pause:bool = true
	for x in players_list.alive_list:
		if local_to_map(x.position)==local_to_map(Pointer.position):
			if current_character.turn_tracker['moved'] and current_character.turn_tracker['turn_complete']==false:
				is_pause = false
				current_character.undo_movement()
				Pointer.movement(local_to_map(current_character.position),current_character.position)
				fight_menus.move(Pointer.position)
				fight_menu.update_menu(current_character)
	if is_pause:
		GlobalSignalBus.change_state.emit("pause_menu")


func _on_fight_menu_turn_end_selected():
	current_character.turn('turn_complete')
	GlobalSignalBus.change_state.emit("grid_interact")


func _move_request_received(character,space:Vector2i):
	character.movement(map_to_local(space),space)
	GlobalSignalBus.update_board.emit()


func _on_pause_menu_escape_pressed():
	print('back to the game')
	GlobalSignalBus.change_state.emit("grid_interact")
	get_viewport().set_input_as_handled()


func _on_field_menu_continue_pressed():
	print('back to the game')
	GlobalSignalBus.change_state.emit("grid_interact")


func _on_field_menu_end_turn_pressed():
	print("end turn pressed")
	GlobalSignalBus.all_units_activated.emit()


func _on_ai_manager_update_enemy_list():
	var list = battle_lists.get_enemies()
	ai_list_handover.emit(list)


func _on_sa_button_pressed(action_name):
	GlobalSignalBus.change_state.emit("sa_resolution")
	action=action_name
	display_range_sa(current_character,action_name)
	current_character.possible_targets=RangeFinder.targets_in_range_sa(board_state,current_character,action_name)
	


func _on_sa_resolution_grid_interaction():
	var defenders:Array=[]
	var tiles_in_range:Array
	tiles_in_range=RangeFinder.tiles_in_attack_range_of_sa(board_state,current_character,action)
	if Pointer.grid_position in tiles_in_range:
		defenders=RangeFinder.sa_area_targets(board_state,Pointer.grid_position,action)
		for defender in defenders:
			print(defender.character_name)
			AttackTools.special_action(current_character,defender,action)
		GlobalSignalBus.change_state.emit('grid_interact')
		current_character.turn('action')
		GlobalSignalBus.update_board.emit()
		clear_layer(1)
		clear_layer(2)
		
