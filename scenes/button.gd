extends Button

func _ready():
	# This "plugs in" the button to the function automatically
	self.pressed.connect(_on_pressed)

func _on_pressed():
	start_game()

func start_game():
	print("Button was clicked!") # This will show up in the Output log
	get_tree().change_scene_to_file("res://main_1.tscn")
