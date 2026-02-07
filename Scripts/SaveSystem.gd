class_name SaveSystem

const SAVE_PATH = "user://sudoku_save.json"

func save_game(data: GameState) -> bool:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("Error opening file: ", FileAccess.get_open_error())
		return false
	
	var json_string = JSON.stringify(data.to_dict())
	file.store_string(json_string)
	file.close()
	return true

func load_game() -> GameState:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Save file doesn't exist")
		return null
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		print("Error opening file: ", FileAccess.get_open_error())
		return null
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Error parsing JSON: ", json.get_error_message())
		return null
	
	var data = GameState.new()
	data.from_dict(json.data)
	return data
