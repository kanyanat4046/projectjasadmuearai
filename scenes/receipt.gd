extends Control
# สร้างช่องใน Inspector สำหรับลากรูปมาใส่
@export var texture_normal: Texture2D
@export var texture_blood: Texture2D
@export var texture_veg: Texture2D
@export var texture_organ: Texture2D
# --- Export Nodes สำหรับพัสดุ ---
@onready var parcel_control = $ParcelControl
@onready var parcel_base = $ParcelControl/ParcelBase
@onready var blood_overlay = $ParcelControl/BloodOverlay
@onready var claw_overlay = $ParcelControl/ClawOverlay
@onready var parcel_label = $PacelLabel

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
			{"name": "Carrot", "price": 30.00},
			{"name": "Corn", "price": 20.00},
			{"name": "Broccoli", "price": 40.00},
			{"name": "Cucumber", "price": 35.00},
			{"name": "Garlic", "price": 45.00},
			{"name": "Mushroom", "price": 100.00},
			{"name": "Bean", "price": 25.00},
			{"name": "Beef", "price": 270.00},
			{"name": "Chicken", "price": 135.00},
			{"name": "Fish", "price": 90.00},
			{"name": "Sausage", "price": 140.00},
			{"name": "Bacon", "price": 120.00},
			{"name": "Egg", "price": 120.00}
		] # โหลด ItemData เข้ามาที่นี่
# ... ข้อมูล ของพัสดุ ...
var parcel_correct_list = [{"address": "341A Malaron Senfilent Street"}]
var parcel_fake_list = [{"address":"340A Malaron Senfilent Street"}, 
						{"address":"341A Malaron Senfilant Street"}, 
						{"address":"666A Malaron Hellfilent Street"}, 
						{"address":"013A 131313 131313131 131313"}
						]
var current_task_type: String = "receipt" # "receipt" หรือ "parcel"
var tasks_done: int = 0
var max_tasks: int = 7
var mistakes: int = 0
var actual_total = 0.00
var display_text = ""
var final_correct_total

# --- ระบบสลับ Task ---
func generate_new_task():
	if GameManager.is_game_over: return
	
	# ตัวอย่าง: คืนที่ 1 มีแต่ใบเสร็จ (โอกาสพัสดุ 0%)
	# คืนที่ 2-3 ถึงจะมีพัสดุโผล่มา
	var parcel_chance = 0.3
	#if GameManager.current_night == 2: parcel_chance = 0.3
	#if GameManager.current_night == 3: parcel_chance = 0.5
	# สุ่ม 50/50 ว่าจะได้งานอะไร
	if randf() > parcel_chance:
		current_task_type = "receipt"
		show_receipt_ui(true)
		generate_new_receipt()
	else:
		current_task_type = "parcel"
		show_receipt_ui(false)
		generate_new_parcel()
		
func generate_new_parcel():
	# 1. จัดการ Overlay ตามความผิดพลาด
	blood_overlay.visible = false
	claw_overlay.visible = false
	
	if mistakes >= 1:
		blood_overlay.visible = true
	if mistakes >= 2:
		claw_overlay.visible = true
		
	# 2. สุ่ม Fake (โอกาสเพิ่มตามความผิดพลาด)
	# สุ่ม Fake
	var fake_chance = 0.3 + (mistakes * 0.1)
	is_fake = randf() < fake_chance
	
	# ดึงข้อความมาเก็บไว้ในตัวแปรชั่วคราว (Local Variable) ก่อน
	var selected_text = ""
	var random_address
	if is_fake:
		random_address = parcel_fake_list.pick_random()
		selected_text += random_address.address
	else:
		random_address = parcel_correct_list.pick_random()
		selected_text += random_address.address
	
	# ส่งค่าเข้า Label (ต้องมี .text เสมอ!)
	parcel_label.text = selected_text

func show_receipt_ui(active: bool):
	# เปิด/ปิด การแสดงผลของแต่ละชุด
	receipt_sprite.visible = active
	label_content.visible = active
	label_vat.visible = active
	label_total.visible = active
	
	parcel_control.visible = !active
	
func generate_new_receipt():
	# ถ้าเกมจบแล้ว ไม่ต้องทำอะไรต่อ
	if GameManager.is_game_over:
		return
	# 1. สุ่มรูปแบบใบเสร็จ (สลับรูปภาพ) เพิ่มโอกาสเจอ
	# ตั้งค่าน้ำหนักเริ่มแรก
	var weight_normal = 15.0
	var weight_veg = 0.0
	var weight_blood = 0.0
	var weight_organ = 0.0
	
	# ปรับน้ำหนักตามความผิดพลาด
	weight_blood = mistakes * 6.0 
	weight_veg = mistakes * 4.0
	weight_organ = mistakes * 2.0
	
	var total_weight = weight_normal + weight_veg + weight_blood + weight_organ
	var roll = randf() * total_weight
	
	if roll < weight_normal:
		receipt_sprite.texture = texture_normal
	elif roll < weight_normal + weight_veg:
		receipt_sprite.texture = texture_veg
	elif roll < weight_normal + weight_veg + weight_blood:
		receipt_sprite.texture = texture_blood
	else:
		receipt_sprite.texture = texture_organ
	#OLD CODE
	#var visual_type = randi() % 4
	#match visual_type:
	#	0: receipt_sprite.texture = texture_normal
	#	1: receipt_sprite.texture = texture_blood
	#	2: receipt_sprite.texture = texture_veg
	#	3: receipt_sprite.texture = texture_organ

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
	# เริ่มต้นที่ 10% (0.1) และเพิ่มขึ้นครั้งละ 15% ตามจำนวนความผิดพลาด(ข้อดูอีกที)
	#var fake_chance = 0.1 + (mistakes * 0.15) 
	#is_fake = randf() < fake_chance
	
	label_content.text = display_text
	label_vat.text = "VAT 7%"
	
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
	# เลือกตัวที่จะเลื่อนออก (ตัวที่กำลังโชว์อยู่)
	var current_node = receipt_sprite if current_task_type == "receipt" else parcel_control
	
	# 1. เลื่อนออกทางซ้าย
	tween.tween_property(current_node, "position:x", -700, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	# 2. เมื่อเลื่อนออกเสร็จ
	tween.tween_callback(func():
		# สุ่ม Task ใหม่ก่อน
		generate_new_task()
		
		# รีเซ็ตตำแหน่ง Node ทั้งสองอย่างให้ไปรอทางขวา (ข้างนอกจอ)
		receipt_sprite.position.x = 800
		parcel_control.position.x = 800
		
		# เลือก Node ตัวใหม่ที่จะเลื่อนเข้า
		var next_node = receipt_sprite if current_task_type == "receipt" else parcel_control
		
		# 3. เลื่อนกลับเข้ามาที่ตำแหน่งเดิม (x = 80)
		var tween_in = create_tween()
		tween_in.tween_property(next_node, "position:x", 80, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	)
func _ready() -> void:
	# เริ่มต้นโดยการดึงใบเสร็จเข้ามาในจอ
	update_task_ui()
	setup_initial_position()
	generate_new_task() # เปลี่ยนจากเรียกใบเสร็จอย่างเดียวเป็นสุ่ม Task
	#generate_new_receipt()

# เอาข้อมูลโชว์บนหนังสือ
func add_record_to_book():
	# สร้างแถวข้อมูล
	var new_row = record_row_scene.instantiate()
	record_list.add_child(new_row)
	# เอาข้อมูลมา
	new_row.set_data("Day 1", "Ingredients", actual_total, "VAT 7%", final_correct_total)

func _on_approve_pressed() -> void:
	if current_task_type == "receipt":
		add_record_to_book()
		check_answer(not is_fake)
	else :
		check_answer(not is_fake)


func _on_reject_pressed() -> void:
	check_answer(is_fake)
