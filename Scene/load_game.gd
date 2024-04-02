extends Node2D
var saves :Array=[]
@onready var save_interface=$"Save Interface"
# Called when the node enters the scene tree for the first time.
func _ready():
	populate_slots()
	save_interface.populate_data("Load",saves)
	GlobalSignalBus.connect('load_data',_load_data)

func populate_slots():
	saves = []
	for slot in range(1,5):
		var save_metadata = SaveAndLoad.load_metadata(slot)
		saves.append(save_metadata)


func _load_data(slot):
	var data:Dictionary=SaveAndLoad.load_game(slot)
	World.load_data(data)
