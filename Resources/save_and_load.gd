extends Node
@export var save_dictionary: Dictionary={}
@export var data_path="user://save_data.save"
# Called when the node enters the scene tree for the first time.
func initialize_data():
	save_dictionary=load_json()
	if save_dictionary:
		print('save dictionary loaded')
	else:
		print('failed to load saves')


func save_game(data):
	var save_file=FileAccess.open(data_path,FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	save_file.store_line(json_string)


func load_game():
	initialize_data()
	var data = load_json()
	if data:
		print(data)
		return data
	else:
		print("Data failed to load")
		return data


func load_json():
	if FileAccess.file_exists(data_path):
		var data_file=FileAccess.open(data_path,FileAccess.READ)
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
