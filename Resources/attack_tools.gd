extends Node


var crit_damage_bonus: int =5


func fight(attacker,defender):
	var attack:int
	var defence:int
	var damage:int
	if attacker.faction=='player':
		attack=advantage_roll()+attacker.get_attack()
	else:
		attack=disadvantage_roll()+attacker.get_attack()
	if defender.faction=='player':
		defence=advantage_roll()+defender.get_attack()
	else:
		defence=disadvantage_roll()+defender.get_attack()
	if Global.debug:
		print('Attack: ',attack,', Defence: ',defence)
	if attack>=defence:
		damage=attack+attacker.get_damage_bonus()
		print('attacker: '+attacker.character_name+ ' hits defender: '+defender.character_name)
		defender.take_damage(damage)
	elif attacker.current_weapon=='weapon':
		damage=defence+defender.get_damage_bonus()
		print('defender: '+defender.character_name+ ' hits attacker: '+attacker.character_name)
		attacker.take_damage(damage)
	else:
		print("attack missed:" + str(attack)+ " vs "+str(defence))


func dice_roll():
	var roll:int = 0
	roll = randi_range(1,20)
	if roll==20:
		print('critical hit!!!')
		return roll+crit_damage_bonus
	else:
		return roll


func advantage_roll():
	var roll:int = 0
	var roll1 = randi_range(1,20)
	var roll2 = randi_range(1,20)
	if roll1>roll2:
		roll = roll1
	else:
		roll = roll2
	if roll==20:
		print('critical hit!!!')
		return roll+crit_damage_bonus
	else:
		return roll


func disadvantage_roll():
	var roll:int = 0
	var roll1 = randi_range(1,20)
	var roll2 = randi_range(1,20)
	if roll1<roll2:
		roll = roll1
	else:
		roll = roll2
	if roll==20:
		print('critical hit!!!')
		return roll+crit_damage_bonus
	else:
		return roll



func multi_target_fight(attacker,defenders:Array):
	for defender in defenders:
		fight(attacker,defender)

func special_action(attacker,defender,action):
	var attack:int
	var defence:int
	var damage:int
	if attacker.faction=='player':
		attack=advantage_roll()+SpellsAndAbilities.spells_and_abilities_directory[action]['power']
	else:
		attack=disadvantage_roll()+SpellsAndAbilities.spells_and_abilities_directory[action]['power']
	if defender.faction=='player':
		defence=advantage_roll()+defender.get_attack()
	else:
		defence=disadvantage_roll()+defender.get_attack()
	if attack>=defence:
		damage=attack+SpellsAndAbilities.spells_and_abilities_directory[action]['bonus']
		print('attacker: '+attacker.character_name+ ' hits defender: '+defender.character_name+" with "+action)
		defender.take_damage(damage)
	else:
		print("attack missed:" + str(attack)+ " vs "+str(defence))
