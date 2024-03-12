extends Node2D
@onready var char=$Character
@onready var menus=$menus



func _ready():
	print(Names.get_random_name('girls'))
	print(Names.get_random_name('boys'))
	print(Names.get_random_name())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
