extends Node

@onready var spells_and_abilities_directory:Dictionary={
	'Bone Dart':{"type":'ranged_attack',"animation":"",'cost':8,"range":5, "power":5,'bonus':0,'area':0,'effect':[],
	'description':'Fire a shard of bone at your opponent'},
	'Elemental Bolt': {"type":'ranged_attack',"animation":"fireball",'cost':10,"range":5, "power":8,'bonus':0,'area':0,'effect':[],
	'description':'Fire a bolt of pure energy at your target'},
	'Elemental Burst': {"type":'ranged_attack',"animation":'','cost':10,"range":5, "power":5,'bonus':0,'area':1,'effect':[],
	'description':'Fire an unstable elemental bolt, which explodes upon contact'},
	'Heal':{"type":'heal',"animation":"",'cost':8,"range":5, "power":8,'bonus':0,'area':0,'effect':[]},
	'Heal Burst':{"type":'heal',"animation":"",'cost':10,"range":5, "power":5,'bonus':0,'area':1,'effect':[]},
	'Summon Animal':{"type":'summon',"animation":"",'cost':10,"range":5, "power":0,'bonus':0,'area':0,'effect':['summon animal']},
	'Summon Undead':{"type":'summon',"animation":"",'cost':10,"range":5, "power":0,'bonus':0,'area':0,'effect':['summon undead']},
	
}


@onready var effect_directory:Dictionary={
	'summon animal':func (character,target): summon_animal(character,target),
	'summon undead':func (character,target): summon_undead(character,target)
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
						}
	summon['tags'].append('undead')
	GlobalSignalBus.summoning.emit(summon)
