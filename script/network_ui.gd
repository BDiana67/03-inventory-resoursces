extends CanvasLayer

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
@export var network_layer: CanvasLayer
@export var ip_input: LineEdit
@export var name_input: LineEdit

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_host_btn_pressed():
	Global.player_name = name_input.text
	peer.create_server(7000)
	multiplayer.multiplayer_peer = peer
	network_layer.hide()
	
	# Хост создает себя
	_spawn_player(1)

func _on_join_btn_pressed():
	Global.player_name = name_input.text 
	var ip = ip_input.text
	peer.create_client(ip, 7000)
	multiplayer.multiplayer_peer = peer
	network_layer.hide()

# Когда клиент подключился, он создает СЕБЯ и ХОСТА
func _on_connected_to_server():
	# 1. Создаем ХОСТА (ID=1) на экране клиента
	var host = player_scene.instantiate()
	host.name = "1"
	host.position = Vector2(100, 50)
	host.set_multiplayer_authority(1)
	get_parent().add_child(host)
	await get_tree().process_frame 
	host.request_name.rpc_id(1) 
	var my_id = multiplayer.get_unique_id()
	var my_player = player_scene.instantiate()
	my_player.name = str(my_id)
	my_player.position = Vector2(150, 50) 
	my_player.set_multiplayer_authority(my_id)
	get_parent().add_child(my_player)
	
	# 3. Говорим серверу создать нас для других
	_request_spawn_on_server.rpc_id(1, my_id)

# Сервер создает игрока, когда к нему подключились
func _on_peer_connected(id: int):
	if multiplayer.is_server():
		_spawn_player(id)

@rpc("any_peer", "call_local", "reliable")
func _request_spawn_on_server(id: int):
	if not multiplayer.is_server(): return
	
	# ПРОВЕРКА: Если игрок с таким ID уже есть на сервере, не создаем его снова!
	if get_parent().has_node(str(id)):
		print("Игрок ", id, " уже существует на сервере, пропускаем.")
		return
		
	_spawn_player(id)

# Единая функция создания игрока
func _spawn_player(id: int):
	# Защита от дубликатов
	if get_parent().has_node(str(id)):
		return
		
	var p = player_scene.instantiate()
	p.name = str(id) 
	p.position = Vector2(100, 50)
	p.set_multiplayer_authority(id)
	get_parent().add_child(p)
