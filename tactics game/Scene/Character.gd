extends AnimatedSprite2D
@export var character_name:String='Gobbo'
@export var faction:String='player'
@export var turn_tracker:Dictionary={'turn_complete':false,'moved':false,'action':false}
@onready var cMove:Node=$Move
@onready var cHealth:Node=$Health
@onready var cCombat:Node=$Combat
@onready var cReflexes:Node=$Reflexes
@onready var cWill:Node=$Will
@onready var stats:Dictionary={'toughness':[8,1],'strength':[8,1],'reflexes':[8,1],'will':[8,1]}#[dice rank,number of dice]
@onready var weapon:Dictionary={'range':1,'die':[8,2]}#[dice rank,number of dice]
@onready var armor:Dictionary={'current_armor':2,'armor':[8,2]}#[dice rank,number of dice]
@onready var traits:Array=[]


signal turn_over
signal dead(character)

func _ready():
	cHealth.setup()
	cCombat.setup()
	cReflexes.setup()
	
	

func turn_start():
	for point in turn_tracker:
		turn_tracker[point] = false
	print("turn start")
	#we will add updates for start of turn stuff here




func turn(turn_action):
	if turn_action=='turn_complete':
		turn_tracker[turn_action]=true
	if turn_action=='moved':
		turn_tracker[turn_action]=true
	if turn_action=='action':
		turn_tracker[turn_action]=true
	if turn_tracker['action'] and turn_tracker['moved']:
		turn_tracker['turn_complete']=true
		GlobalSignalBus.turn_over.emit()
		print("turn is over")






func _on_health_lethal_hit():
	GlobalSignalBus.death.emit(self)


