extends Node

var current_night: int = 1
var is_game_over: bool = false

func reset_game():
	current_night = 1
	is_game_over = false
signal task_updated(current, total)
signal game_finished(status) # status: "win" หรือ "lose"

var total_tasks_goal: int = 7
var current_tasks_done: int = 0
var mistakes: int = 0
var max_mistakes: int = 3
#var is_game_over: bool = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"): # ลองกด Spacebar ตอนรันเกม
		print("--- Manual Test: Calling Jump ---")
		if Jumpscare:
			Jumpscare.trigger_jumpscare()
		else:
			print("--- Jump is NULL! ---")
			
func record_success():
	if is_game_over: return
	
	current_tasks_done += 1
	task_updated.emit(current_tasks_done, total_tasks_goal)
	
	if current_tasks_done >= total_tasks_goal:
		finish_game("win")

func record_fail():
	if is_game_over:
		return
		 
	mistakes += 1 
	var scaring = get_tree().root.get_node_or_null("Jumpscare")
	if scaring:
		print("เจอโหนด Jump แล้ว! กำลังสั่งรัน...")
		scaring.trigger_jumpscare()
	else:
		print("หาโหนดชื่อ Jump ใน Root ไม่เจอเลย (เช็คตัวพิมพ์ใหญ่-เล็กด้วย)")
	if mistakes >= max_mistakes:
		finish_game("lose")
		
func finish_game(status):
	if is_game_over: return # ถ้าจบไปแล้ว ไม่ต้องทำข้างล่างซ้ำ
	is_game_over = true
	game_finished.emit(status)
