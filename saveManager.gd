extends Node

var last_scene_path: String = "res://scenes/maim.tscn"
const SAVE_PATH = "user://save_game.dat"
var current_night = 1


func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data = {
		"current_night": current_night
	}
	file.store_var(data)
	file.close()
	print("Game Saved at Night: ", current_night)


func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		current_night = data["current_night"]
		file.close()

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
