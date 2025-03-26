extends CharacterBody2D

const SPEED = 200
const ATTACK_DAMAGE = 2
const ATTACK_COOLDOWN = 0.5
const ATTACK_RANGE = 32

var attack_timer = 0.0
var health = 10
var attack_power = 2

signal health_changed(new_health)
signal attack_changed(new_attack)

@onready var attack_area = $AttackArea
@onready var attack_shape = $AttackArea/CollisionShape2D

func _ready():
	emit_signal("health_changed", health)
	emit_signal("attack_changed", attack_power)
	
	# Set up attack area
	var shape = CircleShape2D.new()
	shape.radius = ATTACK_RANGE
	attack_shape.shape = shape

func _physics_process(delta):
	# Get input direction
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED
	else:
		velocity = Vector2.ZERO
	
	# Move and handle collisions
	move_and_slide()
	
	# Handle attack
	attack_timer -= delta
	if Input.is_action_just_pressed("ui_accept") and attack_timer <= 0:
		attack()
		attack_timer = ATTACK_COOLDOWN

func attack():
	# Enable attack area briefly
	attack_shape.disabled = false
	
	# Get overlapping bodies
	await get_tree().create_timer(0.1).timeout
	
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(attack_power)
	
	attack_shape.disabled = true

func take_damage(amount):
	health -= amount
	emit_signal("health_changed", health)
	
	if health <= 0:
		die()

func die():
	# Change to game over scene
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func increase_attack(amount):
	attack_power += amount
	emit_signal("attack_changed", attack_power)

func heal(amount):
	health = min(health + amount, 10)
	emit_signal("health_changed", health) 