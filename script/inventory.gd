extends CanvasLayer

@export var grid: GridContainer

func _ready():
	Global.inventory_updated.connect(refresh_ui)
	Global.active_slot_changed.connect(update_selection_visual)
	refresh_ui()

func refresh_ui():
	# Очистка старых слотов
	for child in grid.get_children(): child.queue_free()
	
	# Создание новых на основе данных из Global
	for item in Global.inventory:
		var slot = Button.new()
		slot.icon=item.icon
		var label = Label.new()
		label.text = str(item.amount) # Берем цифру из ресурса
		label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT) # Ставим в угол
		slot.add_child(label) 
		slot.icon_alignment=HORIZONTAL_ALIGNMENT_CENTER
		slot.custom_minimum_size=Vector2(10,10)
		# 2. Создаем текст с количеством
		label.text = str(item.amount)
		label.add_theme_font_size_override("font_size", 10) # Маленький шрифт
		
		# 3. Просто ставим цифру в правый нижний угол кнопки
		label.position = Vector2(1, 1) 
		
		# 4. Добавляем цифру в кнопку и кнопку в сетку
		slot.add_child(label)
		grid.add_child(slot)

func update_selection_visual():
	var slots = grid.get_children()
	for i in range(slots.size()):
		if i == Global.active_slot_index:
			slots[i].grab_focus()
		else:
			slots[i].release_focus()
