extends Node 
signal active_slot_changed
var player_name: String = "Player"
var active_slot_index: int = 0
# Сигнал передает имя предмета 
signal item_collected(item_name: String)
# Сигнал уведомления об обновлении инвентаря (удаляем старый сигнал)
signal inventory_updated
var inventory: Array[ItemData] = []
var max_inventory_size: int=10
func add_item(item: ItemData):
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

	# И здесь тоже добавляем копию
	inventory.append(new_item) 
	inventory_updated.emit()
# Если предмет null (пустой), выходим, чтобы не было ошибки
	if item == null:
		print("ОШИБКА: Попытка подобрать пустой предмет (забыл привязать ресурс)!")
		return

# Проверка на стакинг (если такой уже есть)
	for i in inventory:
		if i.name == item.name:
			i.amount += item.amount
			inventory_updated.emit()
			return

# Проверка лимита
	if inventory.size() >= max_inventory_size:
		print("Инвентарь полон!")
		return

# Добавление нового
	inventory.append(item)
	inventory_updated.emit()
