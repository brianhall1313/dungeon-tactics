extends Node
var board_state
var list_manager

signal update_enemy_list

func begin_turn():
	#determine who should go first:the person with the least targets (but for now just going through the list is enough)
	update_enemy_list.emit()
	print(list_manager)
	for character in list_manager.alive_list:
		GlobalSignalBus.update_board.emit()
		ai_character_turn(character)
	GlobalSignalBus.all_units_activated.emit()


func ai_character_turn(character):
	print("my turn! ", character.character_name)
	#first we see if we don't have to move
	character.possible_targets=[]#I probably don't need this
	var is_in_combat:bool=RangeFinder.in_combat(board_state,character)
	character.select_weapon(is_in_combat)
	character.possible_targets=RangeFinder.targets_in_range_AI(board_state,character)
	var possible_movement=MovementTools.tiles_in_movement_range(board_state,character)
	var target
	var enemey_in_range:bool
	for dude in character.possible_targets:
		if dude.faction != 'enemy':
			if is_in_combat:
				#the character is already in combat so do attack stuff, then maybe move and end turn
				AttackTools.fight(character,dude)
				print("there is an enemy next to me!!!!!")
				#TODO maybe do move stuff?
				return
			elif len(character.possible_targets)>0 and character.equipment.has('ranged_weapon'):
				#do shooty stuff, then maybe move and end turn
				AttackTools.fight(character,dude)
				#TODO maybe do move stuff?
				return
		#no valid initial targets
	#print('poke from After initial target finder')
	var full_range_target_list=[]
	#print(possible_movement)
	for space in possible_movement:
		var targets= RangeFinder.targets_from_space_AI(board_state,character,space)
		if len(targets)>0:
			full_range_target_list.append([space,targets])
	print(full_range_target_list, character.character_name)
	if len(full_range_target_list)>=1:
		if character.combat>character.ranged_combat:
			#if an enemy isn't within one move stand still, otherwise rush
			var acceptable_ranged_targets=[]
			for maybe_space in full_range_target_list:
				if RangeFinder.would_put_in_combat(board_state,character.faction,maybe_space[0]):
					acceptable_ranged_targets.append(maybe_space)
			if len(acceptable_ranged_targets)>=0:
				target=acceptable_ranged_targets.pick_random()
				print(target,"this is who I want to hit ")
				GlobalSignalBus.move_request.emit(character,target[0])
				AttackTools.fight(character,target[1][0])
				return
		else:
			#ranged attack is a better option
			#for now ranged attacks will be against a random target that will not put you in combat
			var acceptable_ranged_targets=[]
			for maybe_space in full_range_target_list:
				if !RangeFinder.would_put_in_combat(board_state,character.faction,maybe_space[0]):
					acceptable_ranged_targets.append(maybe_space)
			if len(acceptable_ranged_targets)>=1:
				target=acceptable_ranged_targets.pick_random()
				print(target,"this is who I want to hit ")
				GlobalSignalBus.move_request.emit(character,target[0])
				AttackTools.fight(character,target[1][0])
				return
	else:
		#maintain position
		character.turn('turn_complete')




func _on_map_pass_board_state(board):
	board_state=board
	print('the AI sees all')


func _on_enemies_ai_list_handover(list_pointer):
	list_manager=list_pointer


func _on_map_ai_list_handover(list):
	list_manager=list
