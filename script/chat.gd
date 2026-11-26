extends Panel

@onready var chat_log = $VBoxContainer/ChatLog
@onready var input = $VBoxContainer/Input
@onready var send_btn = $VBoxContainer/SendBtn

func _ready():
	send_btn.pressed.connect(_on_send_pressed)
	# Чтобы можно было отправить по нажатию Enter в поле ввода
	input.text_submitted.connect(func(_text): _on_send_pressed())

func _on_send_pressed():
	var text = input.text.strip_edges()
	if text == "": return
	
	# Берем имя нашего игрока
	var my_name = Global.player_name
	# Вызываем RPC, который выполнится у всех
	receive_message.rpc(my_name, text)
	
	input.text = "" # Очищаем поле ввода

@rpc("any_peer", "call_local", "reliable")
func receive_message(sender_name: String, message: String):
	# Создаем текст сообщения
	var msg_label = Label.new()
	msg_label.text = sender_name + ": " + message
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART # Перенос строк
	
	chat_log.add_child(msg_label)
	# Прокручиваем скролл вниз (если он есть)
	var parent = chat_log.get_parent()
	if parent is ScrollContainer:
		await get_tree().process_frame
		parent.scroll_vertical = parent.get_v_scroll_bar().max_value
