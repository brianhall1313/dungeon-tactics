extends Resource
class_name Die


var die_category:Array=[2,3,4,6,8,10,12]

@export var base_category:int=0#this will correlate with the above array
@export var category_modifier:int=0
@export var modified_category:int=0
@export var base_roll_modifier:int=0
@export var roll_modifier:int=0
@export var element:String='none'




func _init(base:int=0,base_modifier:int=0,rollm:int=0,type:String='none'):
	base_category=base
	category_modifier=base_modifier
	base_roll_modifier=rollm
	element=type
	print("I don't fuckin no man")
	update_die_statistics()


func update_die_statistics():
	roll_modifier=base_roll_modifier
	if base_category+category_modifier<0:
		modified_category=0
	elif base_category+category_modifier>6:
		roll_modifier+=base_category+category_modifier-6
		modified_category=6
	else:
		modified_category=base_category+category_modifier


func roll():
	var number:int
	number=randi_range(1,die_category[modified_category])+roll_modifier
	
	return number


func complex_roll():
	var number:int
	var result:Dictionary={"roll":0,'crit':false,'element':'none'}
	number=randi_range(1,die_category[modified_category])
	if number==die_category[modified_category]:
		result['crit']=true
	result['roll']=number+roll_modifier
	result['element']=element
	return result
