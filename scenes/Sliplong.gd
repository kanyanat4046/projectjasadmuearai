extends Control
# ลากรูปใบเสร็จทั้ง 4 แบบมาใส่ใน Array นี้ใน Inspector

@onready var visual = $TextureRect
@onready var total_label = $ContentLabels/Total

var is_fake = false
var actual_total = 0.0

# สมมติว่ารูปภาพใบเสร็จแต่ละใบกว้าง 200px (คุณต้องแก้เลขตามขนาดจริงของภาพคุณ)
const RECEIPT_WIDTH = 249.31 

func generate_receipt():
	# 1. สุ่มดัชนีภาพ (0 ถึง 3)
	var index = randi() % 4
	
	# 2. ขยับ Region เพื่อเลือกรูปใบเสร็จใบที่ต้องการ
	# สมมติว่าวางเรียงกันแนวนอน: ใบที่ 1 เริ่มที่ x=0, ใบที่ 2 เริ่มที่ x=250...
	visual.region_rect = Rect2(index * RECEIPT_WIDTH, -5.59, RECEIPT_WIDTH, visual.texture.get_height())
	
	# 3. สุ่มข้อมูลตัวเลข (Logic เดิม)
	var base_price = randi_range(100, 1000)
	var vat = base_price * 0.07
	actual_total = base_price + vat
	var is_fake = randf() < 0.1
	
	# เช็คถ้าเป็นใบสุดท้าย (อวัยวะ - index 3) ให้มีโอกาสเลขผิดสูงขึ้น หรือ Error แปลกๆ
	if index == 3:
		is_fake = true # บังคับให้เป็นใบเสร็จผีสิง
		$TotalLabel.text = "666" 
	else:
		# คำนวณเลขปกติ
		var total = base_price * 1.07
		$TotalLabel.text = str(total if !is_fake else total + 13)
		
	var displayed_total = actual_total
	if is_fake:
		# ถ้าหลอก ให้เลขเพี้ยนไปจากความจริง
		displayed_total += randi_range(-50, 50)
		modulate = Color(1, 0.9, 0.9) # แอบเปลี่ยนสีจางๆ ให้ดูน่าสงสัย (ตัวเลือกเสริม)
	
	# แสดงผลบน UI
	total_label.text = str(displayed_total)
	# (ทำแบบเดียวกันกับ Label อื่นๆ เช่น ชื่อร้าน หรือรายการ)

func spawn_new_receipt():
	var new_r = load("res://main_game2.tscn").instance()
	add_child(new_r)
	
	# วางไว้นอกจอทางขวาก่อน
	new_r.rect_position = Vector2(1500, 200) 
	
	# สุ่มหน้าตาและข้อมูล
	new_r.generate_receipt()
	
	# สไลด์เข้ามากลางจอ
	var tween = create_tween()
	tween.tween_property(new_r, "rect_position:x", 56, 0.7).set_trans(Tween.TRANS_SINE)
	
func end_night():
	get_tree().change_scene_to_file("res://scenes/you_lose.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Timer > 0:
		Timer -= delta
		update_timer_ui()
	else:
		end_night()
