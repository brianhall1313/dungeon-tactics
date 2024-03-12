extends Node

@onready var spells_and_abilities_directory:Dictionary={
	'Bone Dart':{"type":'attack',"range":5, "power":5,'bonus':0,'area':0,'effect':[]
	,'description':'Fire a shard of bone at your opponent'},
	'Elemental Bolt': {"type":'attack',"range":5, "power":8,'bonus':0,'area':0,'effect':[],
	'description':'Fire a bolt of pure energy at your target'},
	'Elemental Burst': {"type":'attack',"range":5, "power":5,'bonus':0,'area':1,'effect':[],
	'description':''},
	'Heal':{"type":'heal',"range":5, "power":8,'bonus':0,'area':0,'effect':[]},
	'Heal Burst':{"type":'heal',"range":5, "power":5,'bonus':0,'area':1,'effect':[]},
	'Summon Animal':{"type":'summon',"range":5, "power":0,'bonus':0,'area':0,'effect':['summon animal']},
	'Summon Undead':{"type":'summon',"range":5, "power":0,'bonus':0,'area':0,'effect':['summon undead']},
	
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
						'experience':0,
						'faction':character.faction,
						'job':job,
						'spells':[],
						'abilities':[],
						'tags':Bestiary.bestiary[job]['tags'],
						'equipment':Bestiary.bestiary[job]["equipment"],
						'stats':Bestiary.bestiary[job]
						}
	GlobalSignalBus.summoning.emit(summon)


func summon_undead(character,target):
	var summonables=['thug','infantryman','ranger','templar']
	var job=summonables.pick_random()
	var summon={'character_name':Names.get_random_name(),#we will try random name gen later
						'default_position':target,
						'experience':0,
						'faction':character.faction,
						'job':job,
						'spells':[],
						'abilities':[],
						'tags':ClassData.class_dictionary[job]['tags'],
						'equipment':ClassData.class_dictionary[job]["equipment"],
						'stats':ClassData.class_dictionary[job]
						}
	summon['tags'].append('undead')
	GlobalSignalBus.summoning.emit(summon)
