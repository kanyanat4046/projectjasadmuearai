extends Button


func _on_pressed():
	start_game()

func start_game():
	print("Button was clicked!") # This will show up in the Output log
	get_tree().change_scene_to_file("res://scenes/main_game1.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
