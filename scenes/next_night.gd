extends Button


func _on_night_cleared():
	# ทำการบันทึกทันที
	SaveManager.save_game()

func next_night():
	if SaveManager.current_night > 3:
		# ส่งไปหน้าจบเกมแบบ Win ไปแก้พาส
		get_tree().change_scene_to_file("res://scenes/victory.tscn")
	else:
		# ส่งไปหน้าเริ่มคืนใหม่ ไปแก้พาส
		get_tree().change_scene_to_file("res://scenes/main_game1.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveManager.save_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	next_night()
