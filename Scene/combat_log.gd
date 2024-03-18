extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignalBus.connect('combat_message',_print_combat_message)


func _print_combat_message(message:String):
	self.append_text('\n')
	self.append_text(message)
