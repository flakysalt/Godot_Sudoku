extends Control

@export var light_color: Color
@export var darl_color : Color
@export var selected_color : Color
@export var highlight_color : Color
@export var same_number_color : Color
@export var mistake_color : Color

@export var note_button_on_color : Color
var note_button_off_color : Color


var cells : Array[Cell]
var selected_cell : Cell

var is_note_mode = false
signal on_mistake

var gamestate : GameState

func _ready() -> void:
	
	gamestate = SaveSystem.new().load_game()
	$"Main Layout group/Stats/Mistakes".set_mistakes(gamestate.mistakes)
	
	attach_to_number_buttons()
	
	for grid_index in $"Main Layout group/Game Grid/GridContainer".get_child_count():
		var grid = $"Main Layout group/Game Grid/GridContainer".get_child(grid_index)
		grid.set_color(grid_index,light_color,darl_color)
		
		#set cell coordinates
		var x = grid_index % 3
		var y = grid_index / 3
		
		grid.set_coordinate(Vector2i(x,y))
		
		for cell in grid.get_cells():
			var currentCell : Cell = cell
			cells.append(currentCell)
			currentCell.cell_clicked.connect(cell_tapped)
	cells.sort_custom(sort_cells)
	
	#set base sudoku state
	for i in 81:
		cells[i].set_prefilled(gamestate.unsolved_sudoku[i] == gamestate.solved_sudoku[i])
		if(gamestate.current_sudoku_state[i] != 0):
			cells[i].set_number(gamestate.current_sudoku_state[i])
			
	#set notes
	for j in gamestate.notes:
		cells[j].edit_note(gamestate.notes[j])
	recolor_board()

func sort_cells(a: Cell, b : Cell) -> bool:
	if a.absolute_coordinate.y != b.absolute_coordinate.y:
		return a.absolute_coordinate.y < b.absolute_coordinate.y
	return a.absolute_coordinate.x < b.absolute_coordinate.x

func cell_tapped(cell: Cell):
	reset_colors()
	selected_cell = cell if cell != selected_cell else null
	recolor_board()

func recolor_board():
	if selected_cell:
		#highlight row and column
		for i in 9:
			cells[selected_cell.absolute_coordinate.y * 9 + i].change_color(highlight_color)
			cells[selected_cell.absolute_coordinate.x + 9 * i].change_color(highlight_color)
		var selected_number = gamestate.current_sudoku_state[get_index_of_selected_cell()]
		#color same number
		for i in 81:
			if selected_number == gamestate.current_sudoku_state[i] && gamestate.current_sudoku_state[i] != 0:
				cells[i].change_color(same_number_color)
		
		selected_cell.change_color(selected_color)
	#color errors
	for i in 81:
		if gamestate.solved_sudoku[i] != gamestate.current_sudoku_state[i] && gamestate.current_sudoku_state[i] != 0:
			cells[i].change_color(mistake_color)

func reset_colors():
	for cell in cells:
		cell.reset_color()
		
func get_index_of_selected_cell():
	var index = cells.find(selected_cell)
	print(index)
	return index

func attach_to_number_buttons():
	for button_index in $"Main Layout group/NumberButtons".get_child_count():
		var button : Button = $"Main Layout group/NumberButtons".get_child(button_index)
		button.button_down.connect(func(): number_button_down(button_index+1))
	pass
	
func number_button_down(number : int):
	if(selected_cell && !selected_cell.is_pre_filled && !is_note_mode):
		selected_cell.set_number(number)
		gamestate.current_sudoku_state[get_index_of_selected_cell()] = number
		if(gamestate.solved_sudoku[get_index_of_selected_cell()] != number):
			gamestate.mistakes += 1
			on_mistake.emit()
		reset_colors()
		recolor_board()
		if(gamestate.is_solved()):
			gamestate.game_won()
			$WinScreen.visible = true
			
		
	elif (selected_cell && !selected_cell.is_pre_filled && is_note_mode):
		if !gamestate.notes.has(get_index_of_selected_cell()):
			gamestate.notes[get_index_of_selected_cell()] = PackedInt32Array([number])
		else:
			if gamestate.notes[get_index_of_selected_cell()].has(number) :
				gamestate.notes[get_index_of_selected_cell()].erase(number)
			else:
				gamestate.notes[get_index_of_selected_cell()].append(number)
		selected_cell.edit_note(gamestate.notes[get_index_of_selected_cell()])
	
	SaveSystem.new().save_game(gamestate)

func _on_notes_button_pressed() -> void:
	is_note_mode = !is_note_mode

func _on_hint_button_pressed() -> void:
	pass # Replace with function body.

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_back_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_check_button_toggled(toggled_on: bool) -> void:
	is_note_mode = toggled_on
	pass # Replace with function body.
