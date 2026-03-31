extends Button

func _on_night_cleared():
	# เพิ่มค่าคืนถัดไป
	SaveManager.current_night += 1
	
	# ทำการบันทึกทันที
	SaveManager.save_game()

	get_tree().change_scene_to_file("res://scenes/main+continue.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveManager.current_night += 1
	SaveManager.save_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	_on_night_cleared()
