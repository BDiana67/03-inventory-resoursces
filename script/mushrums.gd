extends Node2D
@export var item_resources: ItemData

func _on_area_2d_body_entered(body):
	if body.name.is_valid_int():
		# Если это хост - он просто собирает
		if multiplayer.is_server():
			Global.add_item(item_resources)
			queue_free()
		else:
			# Если клиент - он просит сервер удалить ЭТОТ КОНКРЕТНЫЙ гриб
			server_collect.rpc_id(1, get_path())

@rpc("any_peer", "call_local", "reliable")
func server_collect(path_to_mushroom: NodePath):
	if not multiplayer.is_server(): return
	
	# Сервер ищет гриб по пути, который ему прислал клиент
	var node = get_tree().current_scene.get_node_or_null(path_to_mushroom)
	if node:
		node.queue_free() # Удаляет у всех
		Global.add_item(item_resources) # Выдает ресурс
