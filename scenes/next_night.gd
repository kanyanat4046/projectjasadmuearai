extends Button

func _on_night_cleared():
	# เพิ่มค่าคืนถัดไป
	GameManager.current_night += 1
	
	# ทำการบันทึกทันที
	GameManager.save_game()
	
	# เปลี่ยนไป Scene คืนถัดไป หรือหน้าเมนู
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	pass # Replace with function body.
