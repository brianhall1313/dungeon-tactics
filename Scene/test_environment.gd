extends Node2D
@onready var char=$Character
@onready var menus=$menus



func _ready():
	pass
	
func test_dice():
	var results:Dictionary={'player':0,'enemy':0,'tie':0}
	var player:int
	var enemy:int
	for i in range(100000):
		player = AttackTools._dice_roll(2)
		enemy = AttackTools._dice_roll()
		if player>enemy:
			results['player']+=1
		elif player == enemy:
			results['tie']+=1
		else:
			results['enemy']+=1
	print(results)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
