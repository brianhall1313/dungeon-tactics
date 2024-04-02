extends Node
@export var save_dictionary: Dictionary={}
@export var data_path="user://save_data_"



func save_game(data, slot):
	var full_path = data_path + str(slot) + '.save'
	var save_file=FileAccess.open(full_path,FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	save_file.store_line(json_string)


func load_game(slot:int):
	var data = load_json(slot)
	if data:
		print(data)
		return data
	else:
		print("Data failed to load")
		return data


func load_json(slot:int):
	var full_path = data_path + str(slot) + '.save'
	if FileAccess.file_exists(full_path):
		var data_file=FileAccess.open(full_path,FileAccess.READ)
		var parsed_data=JSON.parse_string(data_file.get_as_text())
		if parsed_data is Dictionary:
			#print(parsed_data)
			return parsed_data
		else:
			print('parsed data is not a dictionary')
			return false
	else:
		print('Json parse error:file does not exist')
		return false


func load_metadata(slot:int):
	var full_path = data_path + str(slot) + '.save'
	if FileAccess.file_exists(full_path):
		var data_file=FileAccess.open(full_path,FileAccess.READ)
		var parsed_data=JSON.parse_string(data_file.get_as_text())
		if parsed_data is Dictionary:
			print(parsed_data)
			return parsed_data['metadata']
		else:
			return false
	else:
		return false
