extends Node
signal task_updated(current, total)
signal game_finished(status) # status: "win" หรือ "lose"

var total_tasks_goal: int = 10
var current_tasks_done: int = 0
var mistakes: int = 0
var max_mistakes: int = 3
var is_game_over: bool = false

func record_success():
	if is_game_over: return
	
	current_tasks_done += 1
	task_updated.emit(current_tasks_done, total_tasks_goal)
	
	if current_tasks_done >= total_tasks_goal:
		finish_game("win")

func record_fail():
	if is_game_over: return
	
	mistakes += 1
	if mistakes >= max_mistakes:
		finish_game("lose")

func finish_game(status):
	if is_game_over: return # ถ้าจบไปแล้ว ไม่ต้องทำข้างล่างซ้ำ
	is_game_over = true
	game_finished.emit(status)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
