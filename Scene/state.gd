class_name State
extends Node

signal state_finished

func _enter_state():
	pass
	
func _exit_state():
	pass


func movement(_direction):
	pass
	
func interact():
	pass
	
func cancle():
	pass


func test():
	print('test touched')


'''
 the exit state function will only be called once if there is anything it needs to be resolved
at the end of he state( Such as flipping a switch to true or false).
 the enter state function will be inherited and overwritten to call the parent states  global 
current state and change it to the name of the state that inherited11.!
'''
