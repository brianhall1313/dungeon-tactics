extends Node


var crit_damage_bonus: int =5


func fight(attacker,defender):
	var attack:int
	var defence:int
	var damage:int
	#This next line makes sure that the defender doesn't fight back with a bow
	defender.select_weapon(true) 
	if attacker.faction=='player':
		attack=_dice_roll(2)+attacker.get_attack()
	else:
		attack=_dice_roll()+attacker.get_attack()
	if defender.faction=='player':
		defence=_dice_roll(2)+defender.get_attack()
	else:
		defence=_dice_roll()+defender.get_attack()
	GlobalSignalBus.combat_message.emit('Attack: '+ str(attack)+', Defence: '+ str(defence)) 
	if attack>=defence:
		damage=attack+attacker.get_damage_bonus()
		GlobalSignalBus.combat_message.emit('attacker: '+attacker.character_name+ ' hits defender: '+defender.character_name)
		if attacker.current_weapon=='weapon':
			GlobalSignalBus.play_animation.emit(Weapons.weapons_dictionary[attacker["equipment"][attacker.current_weapon]]["animation"],defender,false)
		else:
			GlobalSignalBus.play_animation.emit(Weapons.weapons_dictionary[attacker["equipment"][attacker.current_weapon]]["animation"],defender,attacker)
		defender.take_damage(damage)
	elif attacker.current_weapon=='weapon':
		damage=defence+defender.get_damage_bonus()
		GlobalSignalBus.play_animation.emit(Weapons.weapons_dictionary[defender["equipment"][defender.current_weapon]]["animation"],attacker,false)
		GlobalSignalBus.combat_message.emit('defender: '+defender.character_name+ ' hits attacker: '+attacker.character_name)
		attacker.take_damage(damage)
	else:
		GlobalSignalBus.combat_message.emit("attack missed:" + str(attack)+ " vs "+str(defence))
		GlobalSignalBus.play_animation.emit(Weapons.weapons_dictionary[attacker["equipment"][attacker.current_weapon]]["animation"],defender,attacker)


func _dice_roll(num_rolls:int=1,advantage:bool=true):
	var rolls:Array=_generate_rolls(num_rolls)
	var result:int
	if num_rolls>1:
		result=_die_result(rolls,advantage)
	else:
		result=rolls[0]
	result=_check_crit(result)
	return result


func _generate_rolls(num_rolls:int):
	var results:Array=[]
	for i in range(num_rolls):
		results.append(randi_range(1,20))
	return results


func _die_result(rolls:Array,advantage:bool):
	if advantage:
		return rolls.max()
	return rolls.min()


func _check_crit(roll:int,crit_range:int=0):
	#if we ever want a bigger crit range range gets used
	if roll >= 20-crit_range:
		GlobalSignalBus.combat_message.emit('Critical Hit!!!!')
		return roll+crit_damage_bonus
	return roll
		


func multi_target_fight(attacker,defenders:Array):
	for defender in defenders:
		fight(attacker,defender)

func special_action(attacker,defender,action):
	var attack:int
	var defence:int
	var damage:int
	if attacker.faction=='player':
		attack=_dice_roll(2)+SpellsAndAbilities.spells_and_abilities_directory[action]['power']
	else:
		attack=_dice_roll()+SpellsAndAbilities.spells_and_abilities_directory[action]['power']
	if defender.faction=='player':
		defence=_dice_roll(2)+defender.get_attack()
	else:
		defence=_dice_roll()+defender.get_attack()
	if attack>=defence:
		damage=attack+SpellsAndAbilities.spells_and_abilities_directory[action]['bonus']
		GlobalSignalBus.combat_message.emit('attacker: '+attacker.character_name+ ' hits defender: '+defender.character_name+" with "+action)
		defender.take_damage(damage)
		if defender.current_health > 0:
			print(defender.current_health)
			if len(SpellsAndAbilities.spells_and_abilities_directory[action]['effect']) > 0:
				for effect in SpellsAndAbilities.spells_and_abilities_directory[action]['effect']:
					SpellsAndAbilities.resolve_effect(effect,attacker,defender)
	else:
		GlobalSignalBus.combat_message.emit("attack missed:" + str(attack)+ " vs "+str(defence))
		
