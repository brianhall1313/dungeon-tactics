extends Node

@onready var spells_and_abilities_directory:Dictionary={
	'Bone Dart':{"type":'attack',"range":5, "power":5,'bonus':0,'area':0,'effect':[]},
	'Elemental Bolt': {"type":'attack',"range":5, "power":8,'bonus':0,'area':0,'effect':[]},
	'Elemental Burst': {"type":'attack',"range":5, "power":5,'bonus':0,'area':1,'effect':[]},
	'Heal':{"type":'heal',"range":5, "power":8,'bonus':0,'area':0,'effect':[]},
	'Heal Burst':{"type":'heal',"range":5, "power":5,'bonus':0,'area':1,'effect':[]},
	'Summon Animal':{"type":'summon',"range":5, "power":0,'bonus':0,'area':0,'effect':['summon animal']},
	
}


@onready var effect_directory:Dictionary={
	'summon animal':func (character,target): summon_animal(character,target)
}


func summon_animal(character,target):
	var summonables=['Bear']
	var job=summonables.pick_random()
	var summon={'character_name':'Harold',
						'default_position':target,
						'experience':0,
						'faction':'player',
						'job':job,
						'spells':[],
						'abilities':[],
						'tags':Bestiary.class_dictionary[job]['tags'],
						'equipment':Bestiary.class_dictionary[job]["equipment"],
						'stats':Bestiary.bestiary[job]
						}
