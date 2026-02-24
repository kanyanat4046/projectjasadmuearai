extends Node

func _ready():
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node):
	if node is BaseButton:
		node.pressed.connect(_play_click_sound)
	

func _play_click_sound():
	if has_node("ClickPlayer"):
		$ClickPlayer.play()
	else:
		print("หาโหนด ClickPlayer ไม่เจอ! เช็กชื่อโหนดอีกที")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
