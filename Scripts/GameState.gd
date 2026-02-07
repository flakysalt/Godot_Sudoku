class_name GameState
extends RefCounted

#board
var solved_sudoku : Array[int]
var unsolved_sudoku : Array[int]
var current_sudoku_state : Array[int]
var notes : Dictionary = {}
var mistakes = 0

#Meta
var last_sudoku_solved: int
var streak_charges : int
var streak : int



func is_solved() -> bool:
	return solved_sudoku == current_sudoku_state
	
func game_won():
	last_sudoku_solved = Time.get_unix_time_from_system()
	streak += 1
	streak_charges = clampi(streak_charges + 1,0,2)
	
func get_calendar_days_difference() -> int:
	var date1 = Time.get_datetime_dict_from_unix_time(last_sudoku_solved)
	var date2 = Time.get_datetime_dict_from_unix_time(Time.get_unix_time_from_system())
	var day1_start = Time.get_unix_time_from_datetime_dict({
		"year": date1.year,
		"month": date1.month,
		"day": date1.day,
		"hour": 0,
		"minute": 0,
		"second": 0
	})
	
	var day2_start = Time.get_unix_time_from_datetime_dict({
		"year": date2.year,
		"month": date2.month,
		"day": date2.day,
		"hour": 0,
		"minute": 0,
		"second": 0
	})
	
	# Calculate difference in days
	return int(abs(day2_start - day1_start) / 86400)

func compute_metadata():
	var days_since_last_solve = get_calendar_days_difference()
	
	# Don't update charges if played on the same day
	if days_since_last_solve == 0:
		return
	
	var new_approximated_charges = streak_charges - (days_since_last_solve - 1)
	if new_approximated_charges < 0:
		streak = 0
		
	streak_charges = clampi(new_approximated_charges, 0, 2)

func to_dict() -> Dictionary:
	return {
		"solved_sudoku": solved_sudoku,
		"unsolved_sudoku": unsolved_sudoku,
		"current_sudoku_state": current_sudoku_state,
		"notes": notes,
		"mistakes": mistakes,
		"last_sudoku_solved" : last_sudoku_solved,
		"streak_charges" : streak_charges,
		"streak" : streak
	}

# Load from dictionary
func from_dict(data: Dictionary) -> void:
	# Convert untyped arrays back to typed arrays
	var temp_solved = data.get("solved_sudoku", [])
	solved_sudoku.assign(temp_solved)
	
	var temp_unsolved = data.get("unsolved_sudoku", [])
	unsolved_sudoku.assign(temp_unsolved)
	
	var temp_current = data.get("current_sudoku_state", [])
	current_sudoku_state.assign(temp_current)
	
	var loaded_notes = data.get("notes", {})
	notes = {}
	for key in loaded_notes:
		notes[int(key)] = PackedInt32Array(loaded_notes[key])
	
	mistakes = data.get("mistakes",0)
	last_sudoku_solved = data.get("last_sudoku_solved",0)
	streak_charges = data.get("streak_charges",0)
	streak = data.get("streak",0)

	print(mistakes)
