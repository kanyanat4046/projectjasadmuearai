extends Button

	
func _on_button_pressed():
	if SaveManager.save_game() and SaveManager.current_night != 1:

		get_tree().change_scene_to_file("res://scenes/main+continue.tscn")
	else:
		# ถ้ายังไม่ Save ไปหน้าเตือน หรือหน้าแก้ไขข้อมูล
		get_tree().change_scene_to_file("res://scenes/game_menu.tscn")
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _on_pressed() -> void:
	_on_button_pressed()
