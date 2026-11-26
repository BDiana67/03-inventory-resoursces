extends CharacterBody2D
var speed = 40
@export var anim: AnimatedSprite2D
@export var item_resources: ItemData
@export var camera: Camera2D
@export var name_label: Label
@export var hand: Sprite2D
var equipped_tool: ItemData
@export var item_world_scene: PackedScene
var is_sitting = false

func _enter_tree():
	if name.is_valid_int():
		set_multiplayer_authority(name.to_int())

@rpc("any_peer", "call_local", "reliable")
func set_nickname(nick: String):
	if name_label: name_label.text = nick

@rpc("any_peer", "call_local", "reliable")
func request_name():
	if is_multiplayer_authority(): set_nickname.rpc(Global.player_name)

func _ready():
	if is_multiplayer_authority():
		camera.enabled = true
		await get_tree().create_timer(0.5).timeout
		set_nickname.rpc(Global.player_name)
		# Если у хоста уже что-то в руках - он говорит об этом всем
		if equipped_tool:
			sync_hand.rpc(equipped_tool.name, equipped_tool.icon.resource_path)
	else:
		camera.enabled = false
	Global.add_item(item_resources)

func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	var input = Vector2(Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left'), Input.get_action_strength('ui_down') - Input.get_action_strength('ui_up'))
	velocity = input.normalized() * speed
	if is_sitting:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if input.x > 0:
		anim.flip_h = true
		hand.flip_h = true
	elif input.x < 0:
		anim.flip_h = false
		hand.flip_h = false
	if input != Vector2.ZERO:
		anim.play('walk')
	else:
		anim.play('idle')
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event.is_action_pressed('next_item'): change_selection(1)
	if event.is_action_pressed('prev_item'): change_selection(-1)
	
	if event.is_action_pressed('use_tool'):
		if hand.texture != null:
			hand.texture = null
			equipped_tool = null
			sync_hand.rpc("", "")
		else:
			if Global.inventory.size() > 0:
				var item = Global.inventory[Global.active_slot_index]
				if item.is_tool:
					hand.texture = item.icon
					equipped_tool = item
		# Передаем имя И путь к картинке
					sync_hand.rpc(item.name, item.icon.resource_path) 
					
	if event.is_action_pressed('interact'):
		if is_sitting:
			is_sitting = false
			anim.play('idle')
		else:
			is_sitting = true
			anim.play('sit')
	if event.is_action_pressed("drop_item"): drop_item()

# СИНХРОНИЗАЦИЯ КАРТИНКИ В РУКАХ
@rpc("any_peer", "call_local", "reliable")
func sync_hand(tool_name: String, icon_path: String):
	if not is_multiplayer_authority():
		if tool_name == "":
			hand.texture = null
			equipped_tool = null
		else:
			var fake = ItemData.new()
			fake.name = tool_name
			fake.is_tool = true
			equipped_tool = fake
			# Загружаем картинку прямо из файла, который передал клиент
			if icon_path != "":
				hand.texture = load(icon_path)

func drop_item():
	if Global.inventory.size() > 0:
		var item_to_drop = Global.inventory[Global.active_slot_index]
		Global.inventory.remove_at(Global.active_slot_index)
		spawn_dropped_item(item_to_drop)
		Global.active_slot_index = clamp(Global.active_slot_index, 0, Global.inventory.size() - 1)
		Global.inventory_updated.emit()
		update_hand_visual()

func spawn_dropped_item(item_to_drop: ItemData):
	var new_item = item_world_scene.instantiate()
	new_item.item_resources = item_to_drop
	var random_offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
	new_item.position = self.position + random_offset
	get_tree().current_scene.add_child(new_item)

func change_selection(direction: int):
	if Global.inventory.size() == 0: return
	Global.active_slot_index = (Global.active_slot_index + direction) % Global.inventory.size()
	if Global.active_slot_index < 0: Global.active_slot_index = Global.inventory.size() - 1
	update_hand_visual()
	Global.active_slot_changed.emit()
	
func update_hand_visual():
	if Global.inventory.size() == 0:
		hand.texture = null
		equipped_tool = null
		return
	var item = Global.inventory[Global.active_slot_index]
	if item:
		hand.texture = item.icon
		equipped_tool = item if item.is_tool else null
	else:
		hand.texture = null
		equipped_tool = null


func _on_send_btn_pressed() -> void:
	pass # Replace with function body.
