extends Control


func set_color(grid_number: int, light_color: Color, dark_color: Color):
	for child_index in $AspectRatioContainer/GridContainer.get_child_count():
		var is_light_color = (grid_number + child_index) % 2 == 0
		$AspectRatioContainer/GridContainer.get_child(child_index).set_initial_color(is_light_color,light_color,dark_color)
		pass
		
func set_coordinate(position : Vector2i):
	for child_index in $AspectRatioContainer/GridContainer.get_child_count():
		var local_x = child_index % 3
		var local_y = child_index / 3
		var absolute_x = position.x * 3 + local_x
		var absolute_y = position.y * 3 + local_y
		$AspectRatioContainer/GridContainer.get_child(child_index).set_cell_coordinate(Vector2i(absolute_x,absolute_y))
		pass
	pass
	
func get_cells():
	return $AspectRatioContainer/GridContainer.get_children()
