extends Node2D

const GRID_SIZE = Vector2(20, 20)
const CELL_SIZE = 16
const MIN_ROOM_SIZE = 4
const MAX_ROOM_SIZE = 8

var tilemap: TileMap
var rooms = []
var corridors = []

class Branch:
	var x: int
	var y: int
	var width: int
	var height: int
	var left: Branch = null
	var right: Branch = null
	
	func _init(x: int, y: int, width: int, height: int):
		self.x = x
		self.y = y
		self.width = width
		self.height = height

func _ready():
	tilemap = $TileMap
	
	# Set up tilemap physics layers
	# tilemap.set_collision_layer_value(1, true)  # Layer 1: Walls
	# tilemap.set_collision_mask_value(2, true)   # Mask 2: Player
	# tilemap.set_collision_mask_value(4, true)   # Mask 4: Monsters
	
	generate_dungeon()

func generate_dungeon():
	# Clear existing tiles
	tilemap.clear()
	rooms.clear()
	corridors.clear()
	
	# Create root branch
	var root = Branch.new(0, 0, GRID_SIZE.x, GRID_SIZE.y)
	
	# Split recursively
	split_branch(root, 5)  # Depth of 5 for ~32 rooms
	
	# Create rooms
	create_rooms(root)
	
	# Create corridors
	create_corridors(root)
	
	# Place player and monsters
	place_entities()

func split_branch(branch: Branch, depth: int):
	# Don't split if we've reached max depth or the branch is too small
	if depth <= 0:
		return
		
	if branch.width < MIN_ROOM_SIZE * 2 or branch.height < MIN_ROOM_SIZE * 2:
		return
	
	# Randomly choose split direction
	var horizontal = randf() > 0.5
	
	if horizontal and branch.height >= MIN_ROOM_SIZE * 2:
		# Split horizontally
		var min_split = MIN_ROOM_SIZE + 1
		var max_split = branch.height - MIN_ROOM_SIZE - 1
		
		# Check if we have enough space to split
		if max_split <= min_split:
			return
			
		var split = min_split + (randi() % (max_split - min_split))
		branch.left = Branch.new(branch.x, branch.y, branch.width, split)
		branch.right = Branch.new(branch.x, branch.y + split, branch.width, branch.height - split)
	elif not horizontal and branch.width >= MIN_ROOM_SIZE * 2:
		# Split vertically
		var min_split = MIN_ROOM_SIZE + 1
		var max_split = branch.width - MIN_ROOM_SIZE - 1
		
		# Check if we have enough space to split
		if max_split <= min_split:
			return
			
		var split = min_split + (randi() % (max_split - min_split))
		branch.left = Branch.new(branch.x, branch.y, split, branch.height)
		branch.right = Branch.new(branch.x + split, branch.y, branch.width - split, branch.height)
	
	# Recursively split children if they were created
	if branch.left != null:
		split_branch(branch.left, depth - 1)
	if branch.right != null:
		split_branch(branch.right, depth - 1)

func create_rooms(branch: Branch):
	if branch.left == null and branch.right == null:
		# Ensure minimum dimensions
		if branch.width <= MIN_ROOM_SIZE or branch.height <= MIN_ROOM_SIZE:
			return
			
		# Calculate room size within the branch
		var max_room_width = min(branch.width - 2, MAX_ROOM_SIZE)
		var max_room_height = min(branch.height - 2, MAX_ROOM_SIZE)
		
		# Ensure we have valid room dimensions
		if max_room_width <= MIN_ROOM_SIZE or max_room_height <= MIN_ROOM_SIZE:
			return
		
		# Calculate room size
		var room_width = MIN_ROOM_SIZE
		if max_room_width > MIN_ROOM_SIZE:
			room_width += randi() % (max_room_width - MIN_ROOM_SIZE + 1)
			
		var room_height = MIN_ROOM_SIZE
		if max_room_height > MIN_ROOM_SIZE:
			room_height += randi() % (max_room_height - MIN_ROOM_SIZE + 1)
		
		# Calculate room position (ensure we have space for the room)
		var max_x_offset = branch.width - room_width
		var max_y_offset = branch.height - room_height
		
		var room_x = branch.x
		if max_x_offset > 0:
			room_x += randi() % (max_x_offset + 1)
			
		var room_y = branch.y
		if max_y_offset > 0:
			room_y += randi() % (max_y_offset + 1)
		
		# Add room to list
		rooms.append({
			"x": room_x,
			"y": room_y,
			"width": room_width,
			"height": room_height
		})
		
		# Create walls and floor
		for x in range(room_x, room_x + room_width):
			for y in range(room_y, room_y + room_height):
				if x == room_x or x == room_x + room_width - 1 or y == room_y or y == room_y + room_height - 1:
					tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))  # Wall tile
				else:
					tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))  # Floor tile
	
	if branch.left != null:
		create_rooms(branch.left)
	if branch.right != null:
		create_rooms(branch.right)

func create_corridors(branch: Branch):
	if branch.left == null or branch.right == null:
		return
	
	# Find room centers
	var left_center = Vector2(
		branch.left.x + branch.left.width / 2,
		branch.left.y + branch.left.height / 2
	)
	var right_center = Vector2(
		branch.right.x + branch.right.width / 2,
		branch.right.y + branch.right.height / 2
	)
	
	# Create corridor
	create_corridor(left_center, right_center)
	
	# Recursively create corridors in children
	create_corridors(branch.left)
	create_corridors(branch.right)

func create_corridor(start: Vector2, end: Vector2):
	# Create horizontal corridor
	var x_start = min(start.x, end.x)
	var x_end = max(start.x, end.x)
	for x in range(x_start, x_end + 1):
		tilemap.set_cell(0, Vector2i(x, start.y), 0, Vector2i(0, 0))  # Floor tile
	
	# Create vertical corridor
	var y_start = min(start.y, end.y)
	var y_end = max(start.y, end.y)
	for y in range(y_start, y_end + 1):
		tilemap.set_cell(0, Vector2i(end.x, y), 0, Vector2i(0, 0))  # Floor tile

func place_entities():
	# Place player in first room
	if rooms.size() > 0:
		var first_room = rooms[0]
		var player_pos = Vector2(
			(first_room.x + first_room.width / 2) * CELL_SIZE,
			(first_room.y + first_room.height / 2) * CELL_SIZE
		)
		get_node("../Player").position = player_pos
	
	# Place monsters in other rooms
	for i in range(1, rooms.size()):
		var room = rooms[i]
		var monster_count = randi() % 3 + 1  # 1-3 monsters per room
		
		for _j in range(monster_count):
			var monster_pos = Vector2(
				(room.x + randi() % (room.width - 1) + 1) * CELL_SIZE,  # Avoid walls
				(room.y + randi() % (room.height - 1) + 1) * CELL_SIZE  # Avoid walls
			)
			spawn_monster(monster_pos)

func spawn_monster(pos: Vector2):
	var monster = preload("res://scenes/monster.tscn").instantiate()
	monster.position = pos
	get_node("../Monsters").add_child(monster) 
