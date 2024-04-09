extends CanvasLayer

@onready var selected=$selected_character_info
@onready var targeted=$targeted_character_info





func _on_map_hide_selected_ui():
	selected.hide()


func _on_map_hide_targeted_ui():
	targeted.hide()


func _on_map_show_selected_ui():
	selected.show()


func _on_map_show_targeted_ui():
	targeted.show()


func _on_map_update_selected_ui(character):
	selected.update(character)


func _on_map_update_targeted_ui(character):
	targeted.update(character)

