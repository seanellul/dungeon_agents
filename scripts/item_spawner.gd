extends Node2D

@export var spawn_chance: float = 0.3
@export var max_items_per_room: int = 3

func spawn_items(room_rect: Rect2):
	var num_items = randi() % (max_items_per_room + 1)
	
	for i in range(num_items):
		if randf() > spawn_chance:
			continue
			
		var item = preload("res://scenes/item.tscn").instantiate()
		add_child(item)
		
		# Random position within room
		var x = room_rect.position.x + randi() % int(room_rect.size.x)
		var y = room_rect.position.y + randi() % int(room_rect.size.y)
		item.position = Vector2(x, y)
		
		# Random item type and value
		item.item_type = randi() % 4  # 0-3 for our enum values
		match item.item_type:
			0:  # Health potion
				item.value = randi() % 20 + 10
			1:  # Strength potion
				item.value = randi() % 3 + 1
			2:  # Defense potion
				item.value = randi() % 3 + 1
			3:  # Gold
				item.value = randi() % 50 + 10 