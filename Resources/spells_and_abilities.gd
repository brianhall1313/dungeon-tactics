extends Node

@onready var spells_and_abilities_directory:Dictionary={
	'Elemental Bolt': {"type":'attack',"range":5, "power":8,'bonus':0,'area':0},
	'Elemental Burst': {"type":'attack',"range":5, "power":5,'bonus':0,'area':1},
	'Heal':{"type":'heal',"range":5, "power":5,'bonus':0,'area':0},
}

func elemental_bolt(character):
	print('the thing has been done')
