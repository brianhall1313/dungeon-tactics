extends FlowContainer

#all dice will come in an array[number of sides,number of dice that are being used/we need to display]
@onready var character_name_label=$character_name
@onready var character_job_label=$character_job
@onready var move_label=$GridContainer/move
@onready var combat_label=$GridContainer/combat
@onready var ranged_combat_label=$GridContainer/ranged_combat
@onready var will_label=$GridContainer/will
@onready var armor_label=$GridContainer/armor
@onready var health_label=$GridContainer/health


func _ready():
	hide()


func update(character):
	character_name_label.text=character.character_name
	if 'undead' in character.tags:
		character_job_label.text='Undead '+character.job
	else:
		character_job_label.text=character.job
	move_label.text='move: '+str(character.move)
	combat_label.text='combat: '+str(character.combat)
	ranged_combat_label.text='ranged combat: '+str(character.ranged_combat)
	will_label.text='will: '+str(character.will)
	armor_label.text='armor: '+str(character.armor)
	health_label.text='health: '+str(character.current_health)+"/"+str(character.health)
