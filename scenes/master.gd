extends HSlider

@export var bus_name: String 

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index("Master")
	
	# Connect the signal correctly
	value_changed.connect(_on_value_changed) 
	
	# Set the slider to the current bus volume on startup
	var current_db = AudioServer.get_bus_volume_db(bus_index)
	value = db_to_linear(current_db)

func _on_value_changed(value: float) -> void:
	# Corrected the 'bus' spelling here
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value)
	)
func _process(delta: float) -> void:
	pass
