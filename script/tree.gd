extends Node2D
@export var item_resources: ItemData

func _on_area_2d_body_entered(body):
	if body.name.is_valid_int():
		if multiplayer.is_server():
			_try_chop(body)
		else:
			# Клиент просит сервер проверить топор и срубить
			server_chop.rpc_id(1, body.name.to_int(), get_path())

@rpc("any_peer", "call_local", "reliable")
func server_chop(player_id: int, path_to_self: NodePath):
	if not multiplayer.is_server(): return
	
	# Ищем игрока, который стукнул
	var player = get_tree().current_scene.get_node_or_null(str(player_id))
	
	if player and player.equipped_tool and player.equipped_tool.name == 'axe':
		# Удаляем дерево
		var node = get_tree().current_scene.get_node_or_null(path_to_self)
		if node:
			node.queue_free()
		# Выдаем дрова всем
		add_wood_to_all.rpc()

@rpc("any_peer", "call_local", "reliable")
func add_wood_to_all():
	Global.add_item(item_resources)

func _try_chop(player_node):
	if player_node.equipped_tool and player_node.equipped_tool.name == 'axe':
		Global.add_item(item_resources)
		queue_free()
