extends Node2D

var current_party: Array
var current_inventory: Array
var current_gold: int

# Called when the node enters the scene tree for the first time.
func _ready():
	update_data()
	update_ui()
	

func update_data():
	current_party=World.player_party
	current_gold=World.player_gold
	current_inventory=World.player_inventory
	
func update_ui():
	pass
