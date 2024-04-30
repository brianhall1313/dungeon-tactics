extends Node

@onready var spells_and_abilities_directory:Dictionary={
	'Bone Dart':{"type":'ranged_attack',"animation":"",'cost':8,"range":5, "power":5,'bonus':0,'area':0,'effect':[],
	'description':'Fire a shard of bone at your opponent'},
	'Elemental Bolt': {"type":'ranged_attack',"animation":"fireball",'cost':10,"range":5, "power":8,'bonus':0,'area':0,'effect':[],
	'description':'Fire a bolt of pure energy at your target'},
	'Elemental Blast': {"type":'ranged_attack',"animation":["fireball","elemental_explosion"],'cost':10,"range":5, "power":5,'bonus':0,'area':1,'effect':[],
	'description':'Fire an unstable elemental bolt, which explodes upon contact'},
	'Heal':{"type":'heal',"animation":"heal",'cost':8,"range":5, "power":8,'bonus':0,'area':0,'effect':[]},
	'Heal Burst':{"type":'heal',"animation":"heal",'cost':10,"range":5, "power":5,'bonus':0,'area':1,'effect':[]},
	'Summon Animal':{"type":'summon',"animation":"summon_circle",'cost':10,"range":5, "power":0,'bonus':0,'area':0,'effect':['summon animal']},
	'Summon Undead':{"type":'summon',"animation":"summon_circle",'cost':10,"range":5, "power":0,'bonus':0,'area':0,'effect':['summon undead']},
	'Heavy Strike':{"type":"attack","animation":"","cost":1,"range":1,"power":4,"bonus":0,"area":0,"effect":['push back']},
	
}


@onready var effect_directory:Dictionary={
	'summon animal':func (character,target): summon_animal(character,target),
	'summon undead':func (character,target): summon_undead(character,target),
	'push back':func (character,target): push(character,target),
}


func resolve_effect(effect,character,target):
	if effect in effect_directory:
		effect_directory[effect].call(character,target)
	


func summon_animal(character,target):
	var summonables=['Bear','Wolf']
	var job=summonables.pick_random()
	var summon={'character_name':Names.get_random_name(),#we will try random name gen later
						'default_position':target,
						'faction':character.faction,
						'job':job,
						}
	GlobalSignalBus.summoning.emit(summon)


func summon_undead(character,target):
	var summonables=['thug','infantryman','ranger','templar']
	var job=summonables.pick_random()
	var summon={'character_name':Names.get_random_name(),#we will try random name gen later
						'default_position':target,
						'faction':character.faction,
						'job':job,
						'tags':ClassData.class_dictionary[job]['tags']
						}
	summon['tags'].append('undead')
	GlobalSignalBus.summoning.emit(summon)

func push(character:Character,target:Character):
	var new_pos=target.grid_position-(character.grid_position-target.grid_position)
	print('step two')
	GlobalSignalBus.push_request.emit(target,new_pos)
	print('step three')
