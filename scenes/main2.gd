extends Control
@onready var game_timer = $GameTimer # ลาก Timer Node มาวาง
@onready var end_screen = $EndScreen/Background
@onready var end_label = $EndScreen/Background/Label

func _ready():
	# เริ่มจับเวลา ยังไม่เสร็จดี
	game_timer.wait_time = 120.0 
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
	game_timer.stop() # หยุดเวลา
	end_screen.visible = true # โชว์หน้าจอสีดำ
	
	if status == "win":
		end_label.text = "Night Complete"
		end_label.modulate = Color.GREEN # สีเขียว
	else:
		end_label.text = "Game Over"
		end_label.modulate = Color.RED # สีแดง

	# หยุดการสุ่มใบเสร็จ (คุณอาจจะซ่อน Node ใบเสร็จไปเลยก็ได้)
	$ReceiptControl.visible = false

# Called when the node enters the scene tree for the first time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
