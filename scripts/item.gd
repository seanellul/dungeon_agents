extends Area2D

enum ItemType {
	HEALTH_POTION,
	STRENGTH_POTION,
	DEFENSE_POTION,
	GOLD
}

@export var item_type: ItemType
@export var value: int = 1

func _ready():
	# Connect to body_entered signal
	body_entered.connect(_on_body_entered)
	
	# Set up collision shape
	var collision_shape = $CollisionShape2D
	var shape = CircleShape2D.new()
	shape.radius = 8.0
	collision_shape.shape = shape

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Apply item effect
		match item_type:
			ItemType.HEALTH_POTION:
				body.heal(value)
			ItemType.STRENGTH_POTION:
				body.increase_strength(value)
			ItemType.DEFENSE_POTION:
				body.increase_defense(value)
			ItemType.GOLD:
				body.add_gold(value)
		
		# Play pickup sound and animation
		queue_free() 