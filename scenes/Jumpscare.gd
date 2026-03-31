
extends CanvasLayer

@onready var jump_image = $TextureRect
@onready var flash_layer = $ColorRect

func _ready():
	# ซ่อนทุกอย่างตอนเริ่มเกม
	jump_image.hide()
	flash_layer.modulate.a = 0
	# สำคัญ: ทำให้กดทะลุได้ ไม่ขวางเม้าส์
	jump_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func trigger_jumpscare():
	# เช็คจำนวนพลาดจาก GameManager
	var count = GameManager.mistakes
	
	if count == 1:
		apply_shake()
	elif count == 2:
		apply_horror_flash()
	elif count >= 3:
		apply_death()

func apply_shake():
	jump_image.show()
	var original_pos = jump_image.position
	var tween = create_tween()
	
	# สั่งสั่นที่ตัวภาพ
	for i in range(10):
		var rand_pos = original_pos + Vector2(randf_range(-30, 30), randf_range(-30, 30))
		tween.tween_property(jump_image, "position", rand_pos, 0.05)
	
	tween.tween_property(jump_image, "position", original_pos, 0.05)
	
	# สั่นเสร็จแล้วซ่อน (สำหรับครั้งแรก)
	await tween.finished
	jump_image.hide()

func apply_horror_flash():
	jump_image.show()
	var tween = create_tween().set_loops(4)
	tween.tween_property(flash_layer, "modulate:a", 0.7, 0.1)
	tween.tween_property(flash_layer, "modulate:a", 0.0, 0.1)
	
	await get_tree().create_timer(1.5).timeout
	jump_image.hide()

func apply_death():
	jump_image.show()
	# อาจจะใส่เสียงกรี๊ด หรือเปลี่ยน Scene ไปหน้า Game Over
	print("YOU DIE!")
