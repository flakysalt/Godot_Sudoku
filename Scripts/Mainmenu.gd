extends Control

var gamestate : GameState

func _on_easy_pressed() -> void:
	generate_and_save(25)
func _on_normal_pressed() -> void:
	generate_and_save(35)
func _on_hard_pressed() -> void:
	generate_and_save(45)
func _on_very_hard_pressed() -> void:
	generate_and_save(55)

func _ready() -> void:
	gamestate = SaveSystem.new().load_game()
	gamestate.compute_metadata()
	$MainScreen/VBoxContainer/Continue.disabled = gamestate.is_solved()
	$MainScreen/StreakLabel.text = "Current Streak: %s\nCharges: %s" % [gamestate.streak,gamestate.streak_charges]

func generate_and_save(tiles_to_remove: int):
	$Loading.visible = true
	$Choose.visible = false
	$Loading/ProgressBar.max_value = 100

	var generator = SudokuGenerator.new()
	generator.puzzle_generation_progress.connect(on_progress)
	await generator.generate(tiles_to_remove, get_tree())
	gamestate.unsolved_sudoku.resize(81)
	gamestate.unsolved_sudoku.fill(0)
	gamestate.solved_sudoku.resize(81)
	gamestate.solved_sudoku.fill(-1)
	gamestate.current_sudoku_state.resize(81)
	gamestate.current_sudoku_state.fill(-1)
	gamestate.mistakes = 0
	gamestate.notes = {}
	
	gamestate.solved_sudoku = generator.get_solution_flat()
	gamestate.unsolved_sudoku = generator.get_puzzle_flat()
	gamestate.current_sudoku_state = generator.get_puzzle_flat()
	
	SaveSystem.new().save_game(gamestate)
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func on_progress(current : int, total: int):
	var linear_progress = float(current) / total
	# Adjustable exponential: change the exponent to control steepness
	# 2.0 = quadratic, 3.0 = cubic, 1.5 = gentler
	var exponent = 2.5
	var exponential_progress = pow(linear_progress, exponent)
	$Loading/ProgressBar.value = exponential_progress * 100

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	
func _on_new_game_pressed() -> void:
	$MainScreen.visible = false
	$Choose.visible = true
func _on_settings_pressed() -> void:
	pass # Replace with function body.
func _on_quit_pressed() -> void:
	get_tree().quit()
