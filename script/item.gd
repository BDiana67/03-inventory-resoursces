extends Node2D

@export var item_resources: ItemData
@export var sprite: Sprite2D

func _ready() -> void:
	sprite.texture = item_resources.icon
# Если в Area2D находиться любое body, вызывается данная функция
func _on_area_2d_body_entered(body):
	# Если мы НЕ сервер - мы не имеем права удалять гриб
	if not multiplayer.is_server(): return
	
	if body.name.is_valid_int(): # Если это игрок (у него имя - числовой ID)
		# Вызов add_item с ресурсом ItemData
		Global.add_item(item_resources)
		# Удаление предмета
		queue_free()
