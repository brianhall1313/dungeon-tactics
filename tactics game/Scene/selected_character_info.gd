extends FlowContainer

#all dice will come in an array[number of sides,number of dice that are being used/we need to display]
@onready var character_name_label=$character_name
@onready var toughness_label=$GridContainer/toughness
@onready var strength_label=$GridContainer/strength
@onready var reflexes_label=$GridContainer/reflexes
@onready var will_label=$GridContainer/will
@onready var armor_label=$GridContainer/armor
@onready var weapon_label=$GridContainer/weapon

func _ready():
	hide()


func update(character):
	character_name_label.text=character.character_name
	toughness_label.text='toughness'+str(character.stats['toughness'][1])+"D"+str(character.stats['toughness'][0])
	strength_label.text='strength'+str(character.stats['strength'][1])+"D"+str(character.stats['strength'][0])
	reflexes_label.text='reflexes'+str(character.stats['reflexes'][1])+"D"+str(character.stats['reflexes'][0])
	will_label.text='will'+str(character.stats['will'][1])+"D"+str(character.stats['will'][0])
	armor_label.text='armor'+str(character.armor['current_armor'])+'/'+str(character.armor['armor'][1])+"D"+str(character.armor['armor'][0])
	weapon_label.text='weapon'+str(character.weapon['die'][1])+"D"+str(character.weapon['die'][0])
