extends Control
@onready var game_timer = $GameTimer # ลาก Timer Node มาวาง


func _ready():
	# เริ่มจับเวลา ยังไม่เสร็จดี
	game_timer.wait_time = 300.0 
	game_timer.one_shot = true
	game_timer.start()
	
	# เชื่อมต่อ Signal
	GameManager.game_finished.connect(_on_game_finished)
	game_timer.timeout.connect(_on_timer_timeout)

# เมื่อเวลาหมด
func _on_timer_timeout():
	if not GameManager.is_game_over:
		GameManager.finish_game("lose")

# จัดการหน้าจอตอนจบเกม
func _on_game_finished(status):
	game_timer.stop()
	
	if status == "win":
		get_tree().change_scene_to_file("res://scenes/you_win.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/you_lose.tscn")

	# หยุดการสุ่มใบเสร็จ (คุณอาจจะซ่อน Node ใบเสร็จไปเลยก็ได้)
	$ReceiptControl.visible = false
