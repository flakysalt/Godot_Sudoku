extends ColorRect
class_name Cell

@export var light_color : Color
@export var dark_Color : Color

@export var prefilled_text_color : Color
@export var normal_text_color : Color

var notes : PackedInt32Array

var is_light_cell
var absolute_coordinate : Vector2i

var is_pre_filled: bool
signal cell_clicked(cell: Cell) 

func _on_gui_input(event: InputEvent) -> void:
	if(event.is_action_pressed("Click")):
		cell_clicked.emit(self)

func set_initial_color(_is_light_cell: bool, _light_color: Color, _dark_color: Color):
	light_color = _light_color
	dark_Color = _dark_color
	is_light_cell = _is_light_cell
	reset_color()
	pass
	
func change_color(color : Color):
	$".".color = color
	pass
	
func reset_color():
	$".".color = light_color if is_light_cell else dark_Color
	
func set_number(number):
	$Label.text = str(number)
	$GridContainer.visible = false
	pass
	
func set_cell_coordinate(coordinate : Vector2i):
	absolute_coordinate = coordinate
	pass
	
func set_prefilled(is_prefilled:bool):
	is_pre_filled = is_prefilled
	var color = prefilled_text_color if is_prefilled else normal_text_color
	if is_pre_filled:
		$Label.add_theme_color_override("font_color",color)

func edit_note(note : PackedInt32Array):
	notes = note
	update_notes()
	
func update_notes():
	for i in 9:
		$GridContainer.get_child(i).visible = notes.has(i+1)

func show_notes(show: bool):
	if(is_pre_filled):
		return
	update_notes()
	$GridContainer.visible = show
	$Label.visible = !show
