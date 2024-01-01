extends Node2D

@onready var test_die=Die.new(4,0)
@onready var other_die=Die.new(4,1)
# Called when the node enters the scene tree for the first time.
func _ready():
	if test_die:
		print(test_die.die_category[test_die.modified_category])
	print('check')


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_variable")
func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print(str(test_die.die_category[test_die.modified_category])+":die size,rolled: "+ str(test_die.roll()))
		print(str(other_die.die_category[other_die.modified_category])+":die size,rolled: "+ str(other_die.roll()))

