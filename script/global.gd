extends Node 
signal active_slot_changed
var player_name = ""
var active_slot_index: int = 0
signal item_collected(item_name: String)
signal inventory_updated
var inventory: Array[ItemData] = []
var max_inventory_size: int = 10

func add_item(item: ItemData):
	# СНАЧАЛА проверяем на пустоту!
	if item == null:
		print("ОШИБКА: Попытка подобрать пустой предмет (забыл привязать ресурс)!")
		return

	var new_item = item.duplicate() 
	new_item.amount = 1 
	
	for i in inventory:
		if i.name == new_item.name: 
			i.amount += 1
			inventory_updated.emit()
			return
			
	if inventory.size() >= max_inventory_size:
		print("Инвентарь полон!")
		return 

	inventory.append(new_item) 
	inventory_updated.emit()
