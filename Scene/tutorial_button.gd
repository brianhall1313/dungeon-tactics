extends Button
@onready var window = $tutorial_window
@onready var title=$tutorial_window/VBoxContainer/tutorial_page_title
@onready var tutorial_text=$tutorial_window/VBoxContainer/tutorial_text
@onready var back=$tutorial_window/VBoxContainer/tutorial_button_box/back_button
@onready var forward=$tutorial_window/VBoxContainer/tutorial_button_box/forward_button
@onready var page_count=$tutorial_window/VBoxContainer/tutorial_button_box/page_count


var current_page:int=0
var titles:Array[String]=[
	'Intro',
	"Controls",
	'Stats I',
	'Stats II',
	'Combat Introduction',
	'Fighting',
	'Casting and Abilities'
]
var tutorial:Array[String]=[
	'''Oh no!  The evil wizard Galdabog has
	 risen from the dead. He is in the bottom
	 of the dungeon that was his tomb. Erasmus
	 the wizard,his apprentice, and as many 
	adventurers as they could find have formed
	a party to stop Galdabog, but they have to
	hurry. Galdabog has started to regain 
	power will soon be too powerful for them 
	to stop. You must defeat all the enemies
	before you so none may strike you from 
	behind''',
	'''Arrow keys or WASD to move the pointer 
	around the map
	Spacebar to interact and confirm.
	ESC to exit menus and cancel selections''',
	'''Each character in Dungeon Tactics
	 has six stats. 
	Move is how many tiles the character 
	can move. 
	Combat is how good the character is at 
	attacking and dodging.
	Ranged Combat is how good the character 
	is at shooting people with a ranged 
	weapon like a bow.''',
	'''Armor is how  much damage the 
	character can soak.
	Will represents the character's 
	willpower and is the base score for 
	casting spells and resisting mind 
	altering effects
	Health Is how much stamina the character
	has. if this gets to zero the character 
	dies''',
	'''Combat takes place in rounds,  with each 
	side taking their turn before going on the next 
	round. Each character can take a move action and 
	another non move action per turn.(they can also 
	pass at any time). Currently the only goal is to 
	defeat all enemies.
	''',
	'''Combat can be a very dangerous 
	proposition. When engaging in melee combat
	the attacker and the defender both role a
	D20 and add their combat skill. The character
	with the highest total deals that number as 
	damage to the other character, adding any 
	additional bonuses and subtracting the target's
	armor.
	Ranged combat is a far safer bet. The target 
	cannot fight back, though they still roll, 
	 adding their combat to see if they dodge''',
	'''Casting a spell is risky because, while they 
	are powerful, they may also fail to go off. 
	To cast a spell you select the spell from the 
	spell list and the character rolls a D20 plus 
	their will. If the character succeeds the roll 
	they cast the spell( if the spell is an attack 
	it still requires  an attack roll)
	Non casters get abilities, but instead of 
	needing to role to activate, the skill costs a 
	little bit of stamina to use(i.e. health)'''
]
var page_max:int


func _ready():
	window.hide()
	page_max=len(tutorial)
	show_page(current_page)
	

func _on_toggled(toggled_on):
	if toggled_on:
		window.show()
	else:
		window.hide()


func show_page(new):
	#page max is the length of the array so we have to do one less
	if new >= 0 and new < page_max:
		current_page=new
		title.text=titles[current_page]
		tutorial_text.text=tutorial[current_page]
		page_count.text=str(current_page+1)+" / "+str(page_max)




func _on_back_button_button_up():
	show_page(current_page-1)


func _on_forward_button_button_up():
	show_page(current_page+1)
