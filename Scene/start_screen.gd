extends Node2D




func _on_button_button_up():
	get_tree().change_scene_to_file("res://Scene/encounter_manager.tscn")


func _on_quit_button_button_up():
	get_tree().quit()


func _on_new_game_button_up():
	pass # Replace with function body.


func _on_load_game_button_up():
	get_tree().change_scene_to_file("res://Scene/load_game.tscn")
