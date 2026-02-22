
extends Node

# --- ต้องมีกลุ่มนี้อยู่บนสุดของไฟล์ ห้ามลืมเด็ดขาด! ---
var mistakes: int = 0
var current_tasks_done: int = 0
var total_tasks_goal: int
var max_mistakes: int = 3
var is_game_over: bool = false
signal game_finished(status) 
signal task_updated(current, total)
# -----------------------------------------------

func record_success():
	if is_game_over: 
		return
	current_tasks_done += 1
	# หมายเหตุ: อย่าลืมประกาศ signal task_updated และตัวแปร total_tasks_goal ไว้ด้านบนด้วยนะครับ
	task_updated.emit(current_tasks_done, total_tasks_goal)
	
	if current_tasks_done >= total_tasks_goal:
		finish_game("win") # <--- ตรงนี้ต้องมี Tab (ย่อหน้า) เข้ามาครับ!

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
	
