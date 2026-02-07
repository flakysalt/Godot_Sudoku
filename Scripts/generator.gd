class_name SudokuGenerator

var solution_grid = [] # Holds the answer to the puzzle
var puzzle = [] # Holds the puzzle
const GRID_SIZE = 9
const BATCH_SIZE = 5  # Process 5 cells before yielding

signal puzzle_generation_progress(current, total)
signal puzzle_generation_complete()


var solution_count = 0 # No. of valid solution to a solution grid, used only for generating valid grid

func generate(difficulty : int, scene_tree : SceneTree):
	_create_empty_grid()
	_fill_grid(solution_grid)
	await _create_puzzle_async(difficulty,scene_tree)

func get_solution_flat():
	var array : Array[int] = []
	for row in solution_grid:
		array.append_array(row)
	return array;
	
func get_puzzle_flat():
	var array : Array[int] = []
	for row in puzzle:
		array.append_array(row)
	return array;

func _create_empty_grid():
	# Start with an empty solution grid where all cells have 0 entry
	solution_grid = []
	for i in range(GRID_SIZE):
		var row = []
		for j in range(GRID_SIZE):
			row.append(0)
		solution_grid.append(row)

func _fill_grid(grid_obj):
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if grid_obj[i][j] == 0:
				var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]
				numbers.shuffle()
				for num in numbers:
					if is_valid(grid_obj, i, j, num):
						grid_obj[i][j] = num
						if _fill_grid(grid_obj):
							return true
						grid_obj[i][j] = 0
				return false
	return true
	
func is_valid(grd, row, col, num):
	# Checks whether the given entry for a number (num)
	# in the grid's [row, col] location is a valid entry.
	# Uses standard Sudoku rules:
	# The numbers from 1-9 should be present in:
	#    1. Row
	#    2. Column
	#    3. Subgrid (3x3)
	return (
		num not in grd[row] and 
		num not in get_column(grd, col) and 
		num not in get_subgrid(grd, row, col)
	)
	
func get_column(grd, col):
	var col_list = []
	for i in range(GRID_SIZE):
		col_list.append(grd[i][col])
	return col_list

func get_subgrid(grd, row, col):
	var subgrid = []
	var start_row = (row / 3) * 3
	var start_col = (col / 3) * 3
	for r in range(start_row, start_row + 3):
		for c in range(start_col, start_col + 3):
			subgrid.append(grd[r][c])
	return subgrid

func _create_puzzle_async(removals: int, scene_tree: SceneTree):
	puzzle = solution_grid.duplicate(true)
	
	var cells = []
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			cells.append(Vector2i(row, col))
	
	cells.shuffle()
	
	var removed = 0
	var batch_count = 0
	var cells_checked = 0
	
	for cell in cells:
		if removed >= removals:
			print("Reached target removals")
			break
		
		cells_checked += 1
		var row = cell.x
		var col = cell.y
		
		if puzzle[row][col] == 0:
			continue
			
		var temp = puzzle[row][col]
		puzzle[row][col] = 0
		
		var puzzle_copy = []
		for r in puzzle:
			puzzle_copy.append(r.duplicate())
		
		if has_unique_solution(puzzle_copy):
			removed += 1
			puzzle_generation_progress.emit(removed, removals)
		else:
			puzzle[row][col] = temp
		
		batch_count += 1
		if batch_count >= BATCH_SIZE:
			batch_count = 0
			await scene_tree.process_frame
	
	# We've gone through all cells
	if removed < removals:
		print("Could only remove ", removed, " cells out of ", removals, " requested")
	else:
		print("Successfully removed ", removed, " cells")
	
	puzzle_generation_complete.emit()

func has_unique_solution(puzzle_grid):
	# Checks whether the given grid puzzle will lead to 1 or more solution
	# We ignore the grids where it leads to more than 1 solution.
	solution_count = 0
	try_to_solve_grid(puzzle_grid)
	return solution_count == 1

func try_to_solve_grid(puzzle_grid):
	# This takes in the grid puzzle and tries to solve it recusively
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			if puzzle_grid[row][col] == 0:
				for num in range(1, 10):
					if is_valid(puzzle_grid, row, col, num):
						puzzle_grid[row][col] = num
						try_to_solve_grid(puzzle_grid)
						puzzle_grid[row][col] = 0
				return
	# We keep track of the solution count generated from the current puzzle
	solution_count += 1
	if solution_count > 1:
		return
