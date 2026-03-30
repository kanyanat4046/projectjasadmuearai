extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _on_pressed():
	SaveManager.last_scene_path = get_tree().current_scene.scene_file_path
	
	if "game" in SaveManager.last_scene_path.to_lower():
		if not get_tree().current_scene.has_node("SettingScene"):
			var setting_scene = load("res://scenes/setting.tscn").instantiate()
			setting_scene.name = "SettingScene"
			get_tree().current_scene.add_child(setting_scene)
	else:
		get_tree().change_scene_to_file("res://scenes/setting.tscn")
