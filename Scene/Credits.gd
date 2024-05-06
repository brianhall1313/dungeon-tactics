extends Node2D

var credits_array:Array[String]=[
	'''Based loosely on the game Frostgrave
	 by Joseph A. McCullough
	
	Design and Programming
	(where to send complaints =p)
	Brian Hall
	(https://pr0t34n.itch.io/)
	''','''Art and Assets
	https://bdragon1727.itch.io/
	https://the-outlander.itch.io/
	https://0x72.itch.io/
	https://pixel-poem.itch.io/
	https://mounirtohami.itch.io
	
	''',
	'''Music and Sound
	https://sonatina.itch.io/
	
	Sound Effects
	Mixkit
	Used under Mixkit Sound Effects Free License
	'''
]


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://Scene/start_screen.tscn")

func _on_quit_button_up():
	get_tree().change_scene_to_file("res://Scene/start_screen.tscn")
