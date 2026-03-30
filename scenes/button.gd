extends Button

func _ready():
	# This "plugs in" the button to the function automatically
	self.pressed.connect(_on_pressed)

func _on_pressed():
	SaveManager.current_night = 1
	SaveManager.save_game() # สร้างเซฟใหม่ทับของเดิม
	get_tree().change_scene_to_file("res://scenes/main_1.tscn")
