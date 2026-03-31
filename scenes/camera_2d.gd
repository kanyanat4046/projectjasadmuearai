extends Camera2D

# ฟังก์ชันนี้สั่งให้กล้องสั่น
func shake(duration: float = 0.4, intensity: float = 15.0):
	var tween = create_tween()
	
	# วนลูปสุ่มตำแหน่ง offset ไปมา
	for i in range(8):
		var target_offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(self, "offset", target_offset, duration / 8.0)
	
	# จบด้วยการคืนค่ากลับไปที่ 0,0 (กึ่งกลางปกติ)
	tween.tween_property(self, "offset", Vector2.ZERO, 0.05)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
