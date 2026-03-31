extends Button

func _ready():
	# This "plugs in" the button to the function automatically
	self.pressed.connect(_on_pressed)

func _on_pressed():
	SaveManager.load_game() # ดึงค่าคืนล่าสุดมาจากไฟล์
	
	var night_path = "res://scenes/main_game1.tscn"
	
	# ตรวจสอบว่ามีไฟล์ Scene อยู่จริงไหมก่อนเปลี่ยนฉาก
	if ResourceLoader.exists(night_path):
		get_tree().change_scene_to_file(night_path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
