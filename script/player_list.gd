extends CanvasLayer

@onready var vbox = $Panel/VBoxContainer

func _ready():
	# Скрываем панель при старте
	visible = false
	# Обновляем список каждые 1 секунду (чтобы новые игроки добавлялись)
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(update_list)
	add_child(timer)

func _input(event):
	# Если нажали Tab
	if event.is_action_pressed("ui_focus_next"): # Или создай действие "toggle_list" в настройках ввода
		visible = not visible
		if visible:
			update_list()

func update_list():
	# Очищаем старый список (оставляем только заголовок "Игроки в сети:")
	for child in vbox.get_children():
		if child.get_index() > 0: # Если это не первый Label
			child.queue_free()
			
	# Проходимся по всем игрокам в дереве сцены
	for player in get_tree().get_nodes_in_group("players"):
		var label = Label.new()
		# Если у игрока есть переменная name_label, берем имя оттуда
		if player.name_label:
			label.text = player.name_label.text
		else:
			label.text = "Игрок " + player.name
		vbox.add_child(label)
