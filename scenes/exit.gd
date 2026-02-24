extends Button

func _ready():
	# This "plugs in" the button to the function automatically
	self.pressed.connect(_on_pressed)

func _on_pressed():
	exit_game()

func exit_game():
	print("Button was clicked!") # This will show up in the Output log
	get_tree().quit()
