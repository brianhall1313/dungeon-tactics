extends Control
@onready var interface_title=$"Background/MarginContainer/Interface Frame/Title"
@onready var slot1=$"Background/MarginContainer/Interface Frame/Save Access/Save Slot 1/Save Slot Frame/Save_metadata"
@onready var slot2=$"Background/MarginContainer/Interface Frame/Save Access/Save Slot 2/Save Slot Frame/Save_metadata"
@onready var slot3=$"Background/MarginContainer/Interface Frame/Save Access/Save Slot 3/Save Slot Frame/Save_metadata"
@onready var slot4=$"Background/MarginContainer/Interface Frame/Save Access/Save Slot 4/Save Slot Frame/Save_metadata"
@onready var button1=$"Background/MarginContainer/Interface Frame/Save Access/Save Slot 1/Save Slot Frame/Button"
@onready var button2=$"Background/MarginContainer/Interface Frame/Save Access/Save Slot 2/Save Slot Frame/Button"
@onready var button3=$"Background/MarginContainer/Interface Frame/Save Access/Save Slot 3/Save Slot Frame/Button"
@onready var button4=$"Background/MarginContainer/Interface Frame/Save Access/Save Slot 4/Save Slot Frame/Button"

var slots:Array=[]
var buttons:Array=[]
var interface_type: String = ''
var append_title: String = ' Game'


func _ready():
	slots.append(slot1)
	slots.append(slot2)
	slots.append(slot3)
	slots.append(slot4)
	buttons.append(button1)
	buttons.append(button2)
	buttons.append(button3)
	buttons.append(button4)

func populate_data(title,saves):
	interface_title.text=title+append_title
	interface_type = title
	for slot in range(4):
		buttons[slot].text=title+append_title
		if saves[slot]:
			var raw_time = saves[slot]['last save'].replace('T','\n')
			slots[slot].text = "Wizard: " + saves[slot]['wizard'] +'\nLast Save: ' + raw_time
		else:
			slots[slot].text ="Wizard: None \nLast Save: None"
			if interface_type == "Load":
				buttons[slot].disabled=true



func _on_button_one():
	if interface_type == 'Load':
		GlobalSignalBus.load_data.emit(1)
	elif interface_type == 'Save':
		GlobalSignalBus.save.emit(1)

func _on_button_two():
	if interface_type == 'Load':
		GlobalSignalBus.load_data.emit(2)
	elif interface_type == 'Save':
		GlobalSignalBus.save.emit(2)

func _on_button_three():
	if interface_type == 'Load':
		GlobalSignalBus.load_data.emit(3)
	elif interface_type == 'Save':
		GlobalSignalBus.save.emit(3)

func _on_button_four():
	if interface_type == 'Load':
		GlobalSignalBus.load_data.emit(4)
	elif interface_type == 'Save':
		GlobalSignalBus.save.emit(4)



