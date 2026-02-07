extends Label

@export var current_time: float

func _process(delta: float) -> void:
	current_time += delta	
	text = "Time: \n%02d:%02d" % [int(current_time)/60,int(current_time) % 60]

func reset():
	current_time = 0
