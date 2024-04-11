extends Control

#I may or may not need these, I should be able to modulate the portrait. 
@onready var frame=$PanelContainer/portrait_frame
@onready var picture=$PanelContainer/MarginContainer/portrait_picture

var color_tints: Dictionary = {'player':Color("blue"),
								'enemy':Color('red')}
func _ready():
	hide()


func update(character: Character):
	modulate=color_tints[character.faction]
