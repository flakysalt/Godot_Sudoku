extends Label

var mistakes = 0

func set_mistakes(new_mistakes):
	mistakes = new_mistakes
	text = "Mistakes: \n%01d" % [mistakes]


func _ready() -> void:
	text = "Mistakes: \n%01d" % [mistakes]

	
func _on_game_on_mistake() -> void:
	mistakes += 1
	text = "Mistakes: \n%01d" % [mistakes]
