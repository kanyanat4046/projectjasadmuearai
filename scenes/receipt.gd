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

# --- ตัวแปรสำหรับจำตำแหน่งเริ่มต้น ---
var pos_receipt_default: float
var pos_parcel_default: float
var pos_label_content_default: float
var pos_label_vat_default: float
var pos_label_total_default: float
var pos_parcel_label_default: float

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
						{"address":"013A 131313 131313131"},
						{"address":"ARE YOU HAPPY? :) "},
						{"address":"Hello :) "},
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
	parcel_label.visible = !active
	
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
			# ใช้ call_deferred เพื่อความปลอดภัยในการเปลี่ยนฉาก
			get_tree().change_scene_to_file("res://scenes/you_win.tscn")
	else:
		mistakes += 1
		print("ทำพลาดครั้งที่: ", mistakes)
		if mistakes == 1:
			Jumpscare.jump_1.play()
			await Jumpscare.apply_shake()
			
		elif mistakes == 2:
			Jumpscare.jump_2.play()
			await Jumpscare.apply_horror_flash()
			
		elif mistakes >= 3:
			Jumpscare.jump_2.play()
			await Jumpscare.apply_death()
			# เปลี่ยนไปหน้า Lose ทันทีหลังจากทำ Death Animation เสร็จ
			get_tree().change_scene_to_file("res://scenes/you_lose.tscn")
	
	# เล่น Animation เปลี่ยนใบเสร็จ
	slide_receipt()

func setup_initial_position():
	# วางตำแหน่งเริ่มต้นไว้ทางขวานอกจอ (สมมติว่าจอ กว้าง 1152)
	receipt_sprite.position.x = 80
	receipt_sprite.position.y = 310  

func update_task_ui():
	task_label.text = "Task: " + str(tasks_done) + "/" + str(max_tasks)

# --- ฟังก์ชันช่วยเปิด/ปิด UI ทั้งหมด (เพื่อความคลีนในช่วงรอยต่อ) ---
func show_all_ui(active: bool):
	receipt_sprite.visible = active
	label_content.visible = active
	label_vat.visible = active
	label_total.visible = active
	parcel_control.visible = active
	parcel_label.visible = active
# --- ฟังก์ชัน Animation เลื่อนพร้อมช่วงหยุดรอ ---
func slide_receipt():
	# 1. เตรียม Node ชุดปัจจุบันที่จะสไลด์ออก
	var current_node: Control
	var current_labels: Array = []
	
	if current_task_type == "receipt":
		current_node = receipt_sprite
		current_labels = [label_content, label_vat, label_total]
	else:
		current_node = parcel_control
		current_labels = [parcel_label]
	
	# สไลด์ออกทางซ้าย (-700)
	var tween_out = create_tween().set_parallel(true)
	tween_out.tween_property(current_node, "position:x", -700, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	for lbl in current_labels:
		tween_out.tween_property(lbl, "position:x", -700, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	# 2. รอให้สไลด์ออกเสร็จ
	await tween_out.finished
	
	# ซ่อนทุกอย่าง และหยุดรอ 1.5 วินาที
	show_all_ui(false)
	await get_tree().create_timer(1.5).timeout
	
	# 3. สุ่ม Task ใหม่
	generate_new_task()
	
	# 4. เตรียมข้อมูลสำหรับสไลด์เข้า
	var next_node: Control
	var target_x: float
	var labels_to_slide: Array = [] # เก็บเป็น [ [node, target], ... ]
	
	if current_task_type == "receipt":
		next_node = receipt_sprite
		target_x = pos_receipt_default
		labels_to_slide = [
			[label_content, pos_label_content_default],
			[label_vat, pos_label_vat_default],
			[label_total, pos_label_total_default]
		]
		show_receipt_ui(true)
	else:
		next_node = parcel_control
		target_x = pos_parcel_default
		labels_to_slide = [
			[parcel_label, pos_parcel_label_default]
		]
		show_receipt_ui(false)

	# เซ็ตไปรอที่ตำแหน่ง 900
	next_node.position.x = 900
	for item in labels_to_slide:
		item[0].position.x = 900
		item[0].visible = true
	
	# 5. สไลด์เข้า (สร้าง Tween ใหม่ตรงนี้เลย จะไม่ติด Scope error)
	var tween_in = create_tween().set_parallel(true)
	tween_in.tween_property(next_node, "position:x", target_x, 0.6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	for item in labels_to_slide:
		var lbl_node = item[0]
		var lbl_target = item[1]
		# ประกาศ tween_in ไว้ในฟังก์ชันเดียวกัน เย้! ตรงนี้จะไม่เออเร่อแล้ว
		tween_in.tween_property(lbl_node, "position:x", lbl_target, 0.6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
func _ready() -> void:
	# จดตำแหน่งที่วางไว้ใน Editor เก็บใส่ตัวแปรไว้
	pos_receipt_default = receipt_sprite.position.x
	pos_parcel_default = parcel_control.position.x
	pos_label_content_default = label_content.position.x
	pos_label_vat_default = label_vat.position.x
	pos_label_total_default = label_total.position.x
	pos_parcel_label_default = parcel_label.position.x
	# เริ่มต้นโดยการดึงใบเสร็จเข้ามาในจอ
	update_task_ui()
	setup_initial_position()
	generate_new_task() # เปลี่ยนจากเรียกใบเสร็จอย่างเดียวเป็นสุ่ม Task
	#generate_new_receipt()

# เอาข้อมูลโชว์บนหนังสือ
func add_record_to_book():
	# 1.สร้างแถวข้อมูล
	var new_row = record_row_scene.instantiate()
	record_list.add_child(new_row)
	
	# 2.เอาข้อมูลมา
	new_row.set_data("Date XX", "Ingredients", actual_total, "VAT 7%", final_correct_total)

func _on_approve_pressed() -> void:
	if current_task_type == "receipt":
		add_record_to_book()
		check_answer(not is_fake)
	else :
		check_answer(not is_fake)


func _on_reject_pressed() -> void:
	check_answer(is_fake)
