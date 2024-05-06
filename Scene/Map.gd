extends TileMap
@onready var Pointer=$Pointer
@onready var battle_lists=$battle_lists
@onready var players_list
@onready var enemies_list

var action:String=''
var dir:Dictionary={"Down":Vector2i(0,1),"Up":Vector2i(0,-1),"Left":Vector2i(-1,0),"Right":Vector2i(1,0)}
var height:int=10
var width:int=10
var board_state
var current_level_data
var current_character:Character
var selected_character
var targeted_character
var tile: String
var current_cell_id:int
var highlighted_cells:Array
var death_spot:Vector2=map_to_local(Vector2i(-100,-100))

var in_attack_range:Array=[]

var background:int = -1
var terrain:int = 0
var decorations:int = 1
var highlights:int = 2
var reticle:int = 3
var summon_highlight: int = 6
var reticle_sprite: int =3
var move_highlight: int=2
var attack_highlight: int=1
var heal_highlight: int=0



signal update_selected_ui(character)
signal show_selected_ui
signal hide_selected_ui
signal update_targeted_ui(character)
signal show_targeted_ui
signal hide_targeted_ui
signal pass_board_state(board)
signal ai_list_handover(list)
signal finished_placing
# Called when the node enters the scene tree for the first time.
func _ready():
	connected_to_signal_bus()
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
	
	GlobalSignalBus.update_board.emit()
	


func connected_to_signal_bus():
	GlobalSignalBus.connect('update_board',_on_update_board)
	GlobalSignalBus.connect('death',_on_character_death)
	GlobalSignalBus.connect('turn_over',_on_turn_over)
	GlobalSignalBus.connect("movement",_movement_received)
	GlobalSignalBus.connect('place_character_default',_place_default)
	GlobalSignalBus.connect('move_request',_move_request_received)
	GlobalSignalBus.connect("sa_button_pressed",_on_sa_button_pressed)
	GlobalSignalBus.connect("summoning",_on_summoning)
	GlobalSignalBus.connect('save',_save)
	GlobalSignalBus.connect('push_request',_push_request_received)
	GlobalSignalBus.connect("move_selected",_on_fight_menu_movement_selected)
	GlobalSignalBus.connect("fight_selected",_on_fight_menu_fight_selected)
	GlobalSignalBus.connect("turn_end_selected",_on_fight_menu_turn_end_selected)




func get_board_state():
	var map_info=[]
	for row in range(width):
		map_info.append([])
		for column in range(height):
			map_info[row].append([])
			map_info[row][column]={"terrain"=get_cell_source_id(terrain,Vector2i(row,column))#returns a vector2I
			,'occupant'=is_occupied(row,column)}
			
			#We still need to add if the occupant makes this passable, or not
	#print(map_info)
	pass_board_state.emit(map_info)
	return map_info



func draw_path(path):
	for point in path:
		set_cell(highlights,local_to_map(Vector2(point.x,point.y)),move_highlight,Vector2i(0,0))



func is_occupied(row,column):
	for x in players_list.alive_list:
		if x.position==map_to_local(Vector2i(row,column)):
			return x
	for x in enemies_list.alive_list:
		if x.position==map_to_local(Vector2i(row,column)):
			return x
	return false


func display_move_range(character):
	var possible_movement = MovementTools.tiles_in_movement_range(board_state,character)
	for space in possible_movement:
		set_cell(highlights,space,move_highlight,Vector2i(0,0))
	
	
func display_placement_range(spaces):
	for space in spaces:
		set_cell(highlights,space,move_highlight,Vector2i(0,0))



func display_attack_range(character):
	var tiles_in_range:Array
	
	tiles_in_range=RangeFinder.tiles_in_attack_range(board_state,character)
	for t in tiles_in_range:
		if t != character.grid_position:
			set_cell(highlights,t,attack_highlight,Vector2i(0,0))#this displays he attack range to the player

func display_range_sa(character,sa):
	var tiles_in_range:Array
	
	tiles_in_range=RangeFinder.tiles_in_attack_range_of_sa(board_state,character,sa)
	for t in tiles_in_range:
		if t != character.grid_position:
			if SpellsAndAbilities.spells_and_abilities_directory[sa]['type']=='attack' or SpellsAndAbilities.spells_and_abilities_directory[sa]['type']=='ranged_attack':
				set_cell(highlights,t,attack_highlight,Vector2i(0,0))
			if SpellsAndAbilities.spells_and_abilities_directory[sa]['type']=='heal':
				set_cell(highlights,t,heal_highlight,Vector2i(0,0))
			if SpellsAndAbilities.spells_and_abilities_directory[sa]['type']=='summon':
				set_cell(highlights,t,summon_highlight,Vector2i(0,0)) 


func ui_update():
	var is_character=is_occupied(Pointer.grid_position.x,Pointer.grid_position.y)
	if is_character:
		if current_character:
			if is_character==current_character:
				selected_character=is_character
				update_selected_ui.emit(selected_character)
				show_selected_ui.emit()
				hide_targeted_ui.emit()
			
			else:
				targeted_character=is_character
				update_targeted_ui.emit(targeted_character)
				show_targeted_ui.emit()
		else:
			selected_character=is_character
			update_selected_ui.emit(selected_character)
			show_selected_ui.emit()
			hide_targeted_ui.emit()
	else:
		hide_targeted_ui.emit()
		if Global.current_state and Global.current_state.name != 'movement_selection':
			hide_selected_ui.emit()
	if Global.current_state:
		if Global.current_state.name == 'fight_selection':
			clear_layer(reticle)
			set_cell(reticle,Pointer.grid_position,reticle_sprite,Vector2i(0,0))
		elif Global.current_state.name =='sa_resolution':
			var cells:Array=RangeFinder.cells_in_sa_area(board_state,Pointer.grid_position,action)
			clear_layer(reticle)
			for cell in cells:
				set_cell(reticle,cell,reticle_sprite,Vector2i(0,0))


func play_sa_animation(character,defender,act):
	var sprite = SpellsAndAbilities.spells_and_abilities_directory[act]["animation"]
	#sprite can be either a string or an array for type of 4=string,28=array
	if SpellsAndAbilities.spells_and_abilities_directory[act]['type'] == 'ranged_attack':
		if typeof(sprite) == 4:
			Animator.ranged_animation(character,defender,sprite)
		elif typeof(sprite) == 28:
			Animator.ranged_animation(character,defender,sprite[0],sprite[1])
	elif SpellsAndAbilities.spells_and_abilities_directory[act]['type'] == 'heal':
		if typeof(sprite) == 4:
			heal_animation(character,defender,sprite)
		elif typeof(sprite) == 28:
			heal_animation(character,defender,sprite[0],sprite[1])
	
	
	



func heal_animation(_character,target,sprite,ending=false):
	#including character for now because I might want to set off a character animation too
	GlobalSignalBus.change_state.emit('animation_state')
	print("the sprite is ",sprite)
	var animate: AnimatedSprite2D = Animator.effects[sprite].instantiate()
	var ending_sprite: AnimatedSprite2D
	if ending:
		ending_sprite = Animator.effects[ending].instantiate()
	add_child(animate)
	animate.position = target
	animate.play()
	await animate.animation_looped
	animate.queue_free()
	if ending:
		add_child(ending_sprite)
		ending_sprite.position = target
		ending_sprite.play()
		await ending_sprite.animation_looped
		ending_sprite.queue_free()



func sa_attack():
	var defenders:Array=[]
	var tiles_in_range:Array
	tiles_in_range=RangeFinder.tiles_in_attack_range_of_sa(board_state,current_character,action)
	if Pointer.grid_position in tiles_in_range:
		defenders=RangeFinder.sa_area_targets(board_state,Pointer.grid_position,action)
		if defenders:
			if current_character.cast(action): 
				var animated:bool=false
				for defender in defenders:
					if SpellsAndAbilities.spells_and_abilities_directory[action]["area"] >0 and animated == false:
						play_sa_animation(current_character,Pointer.position,action)
						animated=true
					elif SpellsAndAbilities.spells_and_abilities_directory[action]["area"] == 0:
						play_sa_animation(current_character,defender.position,action)
					AttackTools.special_action(current_character,defender,action)
			GlobalSignalBus.change_state.emit('grid_interact')
			current_character.turn('action')
			action=''
			GlobalSignalBus.update_board.emit()
			clear_layer(highlights)
			clear_layer(reticle)


func sa_heal():
	var targets:Array=[]
	var tiles_in_range:Array
	tiles_in_range=RangeFinder.tiles_in_attack_range_of_sa(board_state,current_character,action)
	if Pointer.grid_position in tiles_in_range:
		targets=RangeFinder.sa_area_targets(board_state,Pointer.grid_position,action)
		if targets:
			if current_character.cast(action):
				for target in targets:
					print(target.character_name)
					play_sa_animation(current_character,target.position,action)
					target.heal(SpellsAndAbilities.spells_and_abilities_directory[action]["power"])
			GlobalSignalBus.change_state.emit('grid_interact')
			current_character.turn('action')
			action=''
			GlobalSignalBus.update_board.emit()
			clear_layer(highlights)
			clear_layer(reticle)



func _on_grid_interact_grid_interaction():#I don't know if this should go here
	for x in players_list.alive_list:
		if local_to_map(x.position)==local_to_map(Pointer.position):
			current_character=x
			print(current_character.grid_position, "current grid pos")
			for row in range(len(board_state)):
				for column in range(len(board_state[0])):
					if board_state[row][column]["occupant"]:
						print(board_state[row][column]["occupant"].character_name," is at ",row,", ",column)
			if Global.debug == true:#we only have this like this so that we can test stuff effectively for now
				current_character.turn_start()
			GlobalSignalBus.change_state.emit('character_interaction')
			GlobalSignalBus.show_fight_menu.emit()
			GlobalSignalBus.update_board.emit()
			var possible_targets=RangeFinder.targets_from_space(board_state,current_character,current_character.grid_position)
			if len(possible_targets)>0:
				for chara in possible_targets:
					print(chara.character_name)
			return



func _on_movement_selection_grid_interaction():
	var possible_movement=MovementTools.tiles_in_movement_range(board_state,current_character)
	if Vector2i(local_to_map(Pointer.position)) in possible_movement:
		GlobalSignalBus.change_state.emit('animation_state')
		var path = MovementTools.get_path_list(board_state,current_character,Pointer.grid_position)
		var tween = get_tree().create_tween()
		var previous_spot = current_character.position
		for spot in path:
			if spot != current_character.grid_position:
				tween.tween_property(current_character,"position",map_to_local(spot),.25).from(previous_spot)
				previous_spot=map_to_local(spot)
		await tween.finished
		current_character.tween_movement(current_character.previous_position,Pointer.grid_position)
		clear_layer(highlights)
		GlobalSignalBus.change_state.emit('character_interaction')
		GlobalSignalBus.show_fight_menu.emit()
		#TODO:Remember, when we change the final state of the turn this needs to move to that one
		GlobalSignalBus.update_board.emit()
		



func _on_fight_menu_movement_selected():
	GlobalSignalBus.change_state.emit('movement_selection')
	
	display_move_range(current_character)


func _on_movement_selection_escape_pressed():
	Pointer.movement(current_character.grid_position,current_character.position)
	GlobalSignalBus.show_fight_menu.emit()
	GlobalSignalBus.update_board.emit()
	clear_layer(highlights)
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
		clear_layer(highlights)
		clear_layer(reticle)
	
	
func _on_update_board():
	print('updating')
	board_state=get_board_state()
	if current_character:
		GlobalSignalBus.update_menu.emit(current_character)

func _on_turn_over(character):
	board_state=get_board_state()
	current_character=null
	if character.faction == "player":
		if players_list.is_turn_over():
			GlobalSignalBus.player_team_exhausted.emit()
	ui_update()
	
	


func _on_character_interaction_escape_pressed():
		GlobalSignalBus.change_state.emit("grid_interact")
		GlobalSignalBus.hide_sa_menu.emit()
		GlobalSignalBus.hide_fight_menu.emit()



func _on_fight_selection_escape_pressed():
	Pointer.position=current_character.position
	
	clear_layer(highlights)
	clear_layer(reticle)
	GlobalSignalBus.show_fight_menu.emit()
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
	for x in players_list.alive_list:
		if local_to_map(x.position)==local_to_map(Pointer.position):
			current_character=x
			if current_character.turn_tracker['moved'] and current_character.turn_tracker['turn_complete']==false:
				current_character.undo_movement()
				Pointer.movement(local_to_map(current_character.position),current_character.position)
				GlobalSignalBus.update_menu.emit(current_character)
				return
	GlobalSignalBus.change_state.emit("pause_menu")


func _on_fight_menu_turn_end_selected():
	current_character.turn('turn_complete')
	GlobalSignalBus.change_state.emit("grid_interact")


func space_in_bounds(space:Vector2i):
	if space.x <= width and space.x >=0:
		if space.y <= height and space.y >=0:
			return true
	return false


func _move_request_received(character,space:Vector2i):
	if space_in_bounds(space):
		character.movement(map_to_local(space),space)
	GlobalSignalBus.update_board.emit()

func _push_request_received(character,space):
	if space_in_bounds(space):
		if MovementTools.can_move_to(board_state,character,space):
			character.movement(map_to_local(space),space)
		elif MovementTools.will_fall(board_state,character,space):
			GlobalSignalBus.combat_message.emit(character.character_name + " has fallen down a hole!!")
			character.take_damage(9999999)
	GlobalSignalBus.update_board.emit()


func _on_pause_menu_escape_pressed():
	print('back to the game')
	if $"../FiniteStateMachine".previous_state.name=='party_placement':
		GlobalSignalBus.change_state.emit("party_placement")
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
	if action in SpellsAndAbilities.spells_and_abilities_directory:
		var current_action=SpellsAndAbilities.spells_and_abilities_directory[action]
		if current_action['type']=='attack' or current_action['type'] == 'ranged_attack':
			sa_attack()
		elif current_action['type']=='heal':
			sa_heal()
		elif current_action['type']=='summon':
			SpellsAndAbilities.resolve_effect(current_action['effect'][0],current_character,Pointer.grid_position)


func animate_summon(summon):
	GlobalSignalBus.change_state.emit('animation_state')
	var animate: AnimatedSprite2D = Animator.effects["summon_circle"].instantiate()
	add_child(animate)
	animate.position = map_to_local(summon.default_position)
	animate.play()
	await animate.animation_looped
	animate.queue_free()



func _on_summoning(summon):
	var ok_to_summon=MovementTools.can_move_to(board_state,summon,summon.default_position)
	print('time to summon')
	if ok_to_summon:
		if current_character.cast(action): 
			animate_summon(summon)
			battle_lists.add_character(summon)
		GlobalSignalBus.change_state.emit('grid_interact')
		current_character.turn('action')
		action=''
		GlobalSignalBus.update_board.emit()
		clear_layer(highlights)
		clear_layer(reticle)
	


func _on_sa_resolution_escape_pressed():
	Pointer.movement(current_character.grid_position,current_character.position)
	clear_layer(highlights)
	clear_layer(reticle)
	GlobalSignalBus.hide_sa_menu.emit()
	GlobalSignalBus.change_state.emit("character_interaction")


#this is only for testing delete this later
func _save():
	var data: Dictionary ={}
	var wizard:String=battle_lists.get_wizard()
	data['metadata']={"wizard":wizard,"last save":Time.get_datetime_string_from_system()}
	data['party']= battle_lists.save_party('player')
	data['inventory']= World.player_inventory.duplicate(true)
	data['gold']=World.player_gold
	data['progress']=World.level_progress.duplicate()
	SaveAndLoad.save_game(data,1)
	#SaveAndLoad.load_game(1)

func spawn_characters(data):
	if Global.debug:
		World.load_default_data()
	for character in World.player_party:
		character["faction"]="player"
		character["default_position"]=data[character["job"]]
		battle_lists.add_character(character)
		if character["job"] == "wizard":
			var temp_pos = Vector2i(character["default_position"][0],character["default_position"][1])
			Pointer.movement(temp_pos,map_to_local(temp_pos))


func setup_level(level):
	current_level_data = level
	var layout:Array=level['grid_layout'].split(':')
	height=len(layout)
	width=len(layout[0])
	print("height(y) = "+str(height)+",width(x) = "+str(width))
	#this information is relevant to their function
	MovementTools.setup(height,width)
	RangeFinder.setup(height,width)
	#we need to tell the camera how far it can go
	clear_layer(terrain)
	clear_layer(-1)
	var row:int = 0
	var column:int = 0
	for r in layout:
		row = 0
		for c in r.split(''):
			if c == 'c':
				set_cell(terrain,Vector2i(row,column),Global.cap_stone,Vector2i(0,0))
			elif c == '4':
				set_cell(terrain,Vector2i(row,column),Global.free_spaces.pick_random(),Vector2i(0,0))
			elif c == 'd':
				var x = Global.decorations.pick_random()
				if x == 24:
					set_cell(decorations,Vector2i(row,column-1),x,Vector2i(0,0))
					set_cell(terrain,Vector2i(row,column),x,Vector2i(0,1))
				else:
					set_cell(terrain,Vector2i(row,column),x,Vector2i(0,0))
			elif c == 'w':
				set_cell(terrain,Vector2i(row,column),Global.wall_spaces.pick_random(),Vector2i(0,0))
			elif c == 's':
				set_cell(terrain,Vector2i(row,column),Global.stairs,Vector2i(0,0))
			else:
				set_cell(terrain,Vector2i(row,column),int(c),Vector2i(0,0)) 
			row+=1
		column +=1
	for character in level['enemies']:
		battle_lists.add_character(character)
	#TODO we will do custom placement later
	#party_placement()
	spawn_characters(level["default_placements"])
	GlobalSignalBus.update_board.emit()
	


func party_placement():
	var area:Array=get_placement_area()
	GlobalSignalBus.change_state.emit("party_placement")
	display_placement_range(area)
	


func get_placement_area():
	var spaces = current_level_data["placement_spaces"]
	var area:Array=[]
	for space in spaces:
		area.append(Vector2i(space[0],space[1]))
	return area



func _on_party_placement_escape_pressed():
	GlobalSignalBus.change_state.emit("pause_menu")


func _on_party_placement_grid_interaction():
	var area = get_placement_area()
	if Pointer.grid_position in area:
		pass
		#place char
