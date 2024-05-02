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
signal push_request(character,new_pos)
signal party_wipe(faction)
signal hide_menu
signal show_pause_menu
signal sa_button_pressed(action:String)
signal summoning(summon)
signal combat_message(message:String)
signal toggle_log
signal save(slot)
signal load_data(slot)
signal game_over(victory)
signal character_selected(character_name)#This is for party management specifically
signal player_team_exhausted()
signal play_animation(animation,target,origin)
signal animation_finished()
signal show_fight_menu()
signal hide_fight_menu()
signal show_sa_menu()
signal hide_sa_menu()
signal fight_selected()
signal move_selected()
signal turn_end_selected()
signal update_menu(character)
signal play_effect(effect)
