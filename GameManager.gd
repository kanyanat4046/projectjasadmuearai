
extends Node

# --- ต้องมีกลุ่มนี้อยู่บนสุดของไฟล์ ห้ามลืมเด็ดขาด! ---
var mistakes: int = 0
var max_mistakes: int = 3
var is_game_over: bool = false
signal game_finished(status) 
# -----------------------------------------------

func record_fail():
	if is_game_over: 
		return
	
	mistakes += 1
	print("ทำพลาดครั้งที่: ", mistakes)
	
	if mistakes >= max_mistakes:
		print("GAME OVER")
		finish_game("lose")

func finish_game(status):
	if is_game_over:
		return
	is_game_over = true
	
	print("!!! บังคับเปลี่ยนฉากไปที่: ", status, " !!!")
	
	var target_path = ""
	if status == "win":
		target_path = "res://scenes/you_win.tscn" # แก้ Path ให้ตรงกับที่คุณ Copy มา
	else:
		target_path = "res://scenes/you_lose.tscn" # แก้ Path ให้ตรงกับที่คุณ Copy มา

	# ใช้คำสั่งเปลี่ยนฉากแบบรอให้ระบบว่างก่อน (Safe Mode)
	get_tree().call_deferred("change_scene_to_file", target_path)
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
