extends Button

@onready var description = $description
@onready var description_text=$description/VBoxContainer/description_text
@onready var type = $description/VBoxContainer/HBoxContainer/type
@onready var ability_range=$description/VBoxContainer/HBoxContainer/range
@onready var cost = $description/VBoxContainer/HBoxContainer/cost

var offset =15

func _ready():
	description.hide()


func populate_description():
	interpret_position()
	if SpellsAndAbilities.spells_and_abilities_directory.has(text):
		var info: Dictionary = SpellsAndAbilities.spells_and_abilities_directory[text]
		if info["spell"]:
			type.text = "Spell"
			cost.text = " Cast: " + str(info["cost"])
		else:
			type.text = "Ability"
			cost.text = " Cost: " + str(info["cost"])
		ability_range.text = str(info["range"])
		description_text.text = info["description"]
	
	



func interpret_position():
	var xpos = size.x+self.position.x
	description.position = Vector2(xpos + offset,description.position.y)



func _on_button_up():
	get_viewport().set_input_as_handled()
	GlobalSignalBus.sa_button_pressed.emit(text)
	


func _on_focus_entered():
	description.show()


func _on_focus_exited():
	description.hide()
