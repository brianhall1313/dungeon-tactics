extends Node2D
@onready var char=$Character
@onready var menus=$menus



func _ready():
	menus.move(Vector2(30.0,30.0))
	menus.update(char)
	menus.show_menu()
	SpellsAndAbilities.do_action(char,'test')
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
