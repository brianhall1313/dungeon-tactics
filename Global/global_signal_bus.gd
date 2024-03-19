class_name SignalBus
extends Node
signal moved(direction:String)
signal interact
signal death(character)
signal cancel
signal update_board
signal turn_over(character)#er when a character's turn is over
signal all_units_activated()#for when a team is done
signal movement(direction:String)#this is so that movement only gets done when I want it to
signal place_character_default(character)
signal change_state(state:String)
signal turn_start(next)
signal move_request(character,space:Vector2i)
signal party_wipe(faction)
signal hide_menu
signal sa_button_pressed(action:String)
signal summoning(summon)
signal combat_message(message:String)
signal toggle_log
