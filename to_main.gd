extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_button_pressed():
	if SaveManager.current_night != 1:
		get_tree().change_scene_to_file("res://scenes/main+continue.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/game_menu.tscn")

func _on_next_night_pressed() -> void:
	pass # Replace with function body.


func _on_pressed() -> void:
	_on_button_pressed()
