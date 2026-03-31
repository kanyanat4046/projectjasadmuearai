
extends CanvasLayer

@onready var jump_image = $TextureRect
@onready var flash_layer = $ColorRect
@onready var jump_1 = $Jump1
@onready var jump_2 = $Jump2

func test_jump():
	print("!!! JUMP CALLED SUCCESS !!!")

func _ready():
	# ซ่อนทุกอย่างตอนเริ่มเกม
	jump_image.hide()
	flash_layer.modulate.a = 0
	# สำคัญ: ทำให้กดทะลุได้ ไม่ขวางเม้าส์
	jump_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func trigger_jumpscare():
	var count = GameManager.mistakes
	print("--- Jump System: Received mistake count ", count, " ---")
	
	if count == 1:
		print("Playing Shake (Jump1)")
		if jump_1: jump_1.play()
		await apply_shake()
		
	elif count == 2:
		print("Playing Flash (Jump2)")
		if jump_2: jump_2.play()
		await apply_horror_flash()
		
	elif count >= 3:
		print("Playing Death Event")
		if jump_2: jump_2.play()
		await apply_death() # ใส่ await ตรงนี้ด้วย
	
	print("--- Jump System: Finished ---")
	
func apply_shake():

	var tween = create_tween()
	var shake_intensity = 20.0 # ความแรงในการสั่น (ปรับเพิ่ม/ลดได้)
	var shake_duration = 0.05 # ความเร็วในแต่ละจังหวะ
	
	# วนลูปสั่นสุ่มตำแหน่ง 8-10 ครั้ง
	for i in range(10):
		var rand_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity), 
			randf_range(-shake_intensity, shake_intensity)
		)
		tween.tween_property(self, "offset", rand_offset, shake_duration)
	
	# ดึงกลับมาที่ตำแหน่งเดิม (0,0) เพื่อให้หน้าจอไม่เบี้ยวหลังสั่นเสร็จ
	tween.tween_property(self, "offset", Vector2.ZERO, shake_duration)
	
	await tween.finished

func apply_horror_flash():
	jump_image.show()
	var tween = create_tween().set_loops(4)
	tween.tween_property(flash_layer, "modulate:a", 0.7, 0.1)
	tween.tween_property(flash_layer, "modulate:a", 0.0, 0.1)
	
	await get_tree().create_timer(1.5).timeout
	jump_image.hide()

func apply_death():
	jump_image.show()
	print("YOU DIE!")
	# รอสัก 1-2 วินาทีให้ผู้เล่นเห็นภาพความตายก่อนจะเปลี่ยนหน้า Lose
	await get_tree().create_timer(2.0).timeout
