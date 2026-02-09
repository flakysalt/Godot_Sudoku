extends VBoxContainer

@export var charge_full:  Texture2D 
@export var today_charge_full:  Texture2D 

func set_streak_data(data : GameState):
	for i in data.streak_charges:
		$StreakChargesContainer.get_child(i-1).texture = charge_full
	
	$HBoxContainer/StreakLabel.text = str(data.streak)
	if(data.get_calendar_days_difference() == 0):
		$HBoxContainer/CurrentDayCharge.texture = today_charge_full
