extends Control
# สร้างช่องใน Inspector สำหรับลากรูปมาใส่
@export var texture_normal: Texture2D
@export var texture_blood: Texture2D
@export var texture_veg: Texture2D
@export var texture_organ: Texture2D

#@onready var receipt_display = $ReceiptImage # ตัว TextureRect ที่ใช้แสดงผล ไม่ใช้ละ
@onready var label_content = $ContentLabel # แสดงรายการสินค้า
@onready var label_vat = $VatLabel # แสดงภาษี
@onready var label_total = $TotalLabel     # แสดงราคารวม
@onready var receipt_sprite = $ReceiptImage
@onready var task_label = $"../TaskLabel" # อ้างอิงไปที่ Label นับ Task (ปรับ Path ให้ตรงตาม Scene)
@export var record_row_scene: PackedScene
@onready var record_list = $ScrollContainer/RecordList

var is_fake: bool = false
var items_list = [
			{"name": "Tomato", "price": 60.00},
			{"name": "Pork", "price": 180.00},
			{"name": "Onion", "price": 50.00},
			{"name": "Potato", "price": 56.00},
			{"name": "Shrimp", "price": 280.00},
			{"name": "Crab", "price": 250.00},
			{"name": "carrot", "price": 30.00},
			{"name": "Corn", "price": 20.00},
			{"name": "broccoli", "price": 40.00},
			{"name": "cucumber", "price": 35.00},
			{"name": "garlic", "price": 45.00},
			{"name": "mushroom", "price": 100.00},
			{"name": "bean", "price": 25.00},
			{"name": "beef", "price": 270.00},
			{"name": "chicken", "price": 135.00},
			{"name": "fish", "price": 90.00},
			{"name": "sausage", "price": 140.00},
			{"name": "bacon", "price": 120.00},
			{"name": "egg", "price": 120.00}
		] # โหลด ItemData เข้ามาที่นี่

var tasks_done: int = 0
var max_tasks: int = 7
var mistakes: int = 0
var actual_total = 0.0
var display_text = ""
var final_correct_total
func generate_new_receipt():
	# ถ้าเกมจบแล้ว ไม่ต้องทำอะไรต่อ
	if GameManager.is_game_over:
		return
	# 1. สุ่มรูปแบบใบเสร็จ (สลับรูปภาพ)
	var visual_type = randi() % 4
	match visual_type:
		0: receipt_sprite.texture = texture_normal
		1: receipt_sprite.texture = texture_blood
		2: receipt_sprite.texture = texture_veg
		3: receipt_sprite.texture = texture_organ

	# 2. สุ่มข้อมูลสินค้า
	actual_total = 0.0
	final_correct_total = 0.0
	display_text = ""
	
	# สุ่มรายการ 1-3 อย่าง
	for i in range(randi_range(1, 3)):
		var item = items_list.pick_random()
		display_text += item.name + "   " + str(item.price) + "\n"
		actual_total += item.price
	
	# คำนวณ VAT 7%
	var vat = actual_total * 0.07
	final_correct_total = actual_total + vat
	
	# 3. สุ่มว่าจะเป็นใบเสร็จหลอก (Fake) หรือไม่
	is_fake = randf() < 0.4 # โอกาส 40% ที่จะหลอก คืนแรกอาจเริ่มที10%
	
	label_content.text = display_text
	label_vat = "VAT 7%"
	
	if is_fake:
		# สุ่มเลขมั่วๆ ให้ไม่ตรงกับความจริง
		label_total.text = "Total: " + str(final_correct_total + randi_range(10, 100))
	else:
		label_total.text = "Total: " + str(final_correct_total)

func check_answer(is_correct: bool):
	if is_correct:
		tasks_done += 1
		update_task_ui()
		if tasks_done >= max_tasks:
			get_tree().change_scene_to_file("res://scenes/you_win.tscn")
	else:
		mistakes += 1
		print("ทำพลาดครั้งที่: ", mistakes)
		if mistakes >= 3:
			get_tree().change_scene_to_file("res://scenes/you_lose.tscn")
			# ใส่โค้ดเปลี่ยนไปหน้า Game Over ที่นี่
	
	# เล่น Animation เปลี่ยนใบเสร็จ
	slide_receipt()

func setup_initial_position():
	# วางตำแหน่งเริ่มต้นไว้ทางขวานอกจอ (สมมติว่าจอ กว้าง 1152)
	receipt_sprite.position.x = 80
	receipt_sprite.position.y = 310  

func update_task_ui():
	task_label.text = "Task: " + str(tasks_done) + "/" + str(max_tasks)

# --- ฟังก์ชัน Animation เลื่อนใบเสร็จ ---
func slide_receipt():
	var tween = create_tween()
	# 1. เลื่อนใบเสร็จเก่าออกไปทางซ้าย
	tween.tween_property(receipt_sprite, "position:x", -600, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	# 2. เมื่อเลื่อนออกเสร็จ ให้สุ่มข้อมูลใหม่และวาร์ปไปรอทางขวา
	tween.tween_callback(func():
		generate_new_receipt()
		receipt_sprite.position.x = 80 
	)
	
	# 3. เลื่อนใบเสร็จใหม่ออกมาจากทางขวามาที่:ซ้ายจอ (สมมติกลางจอคือ x=270)
	tween.tween_property(receipt_sprite, "position:x", 80, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_task_ui()
	# เริ่มต้นโดยการดึงใบเสร็จเข้ามาในจอ
	setup_initial_position()
	generate_new_receipt()
# เอาข้อมูลโชว์บนหนังสือ
func add_record_to_book():
	# สร้างแถวข้อมูล
	var new_row = record_row_scene.instantiate()
	record_list.add_child(new_row)
	# เอาข้อมูลมา
	var current_date = "Day 1"
	var current_description =  "Ingredients"
	var current_actual_total =  actual_total
	var current_vat = "VAT 7%"
	var current_final_total = final_correct_total
	new_row.set_data(
		current_date,
		current_description,
		actual_total,
		current_vat,
		final_correct_total
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_approve_pressed() -> void:
	add_record_to_book()
	check_answer(not is_fake) # Replace with function body.


func _on_reject_pressed() -> void:
	check_answer(is_fake) # Replace with function body.
