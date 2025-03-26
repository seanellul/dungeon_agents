extends CharacterBody2D

enum State { IDLE, CHASE, ATTACK }

const SPEED = 100
const ATTACK_DAMAGE = 1
const ATTACK_COOLDOWN = 1.0
const CHASE_RANGE = 200
const ATTACK_RANGE = 32

var state = State.IDLE
var player = null
var attack_timer = 0.0
var health = 5

func _ready():
	player = get_node("/root/Game/Player")

func _physics_process(delta):
	if player == null:
		return
	
	match state:
		State.IDLE:
			# Check if player is in range
			if position.distance_to(player.position) < CHASE_RANGE:
				state = State.CHASE
		
		State.CHASE:
			# Move towards player
			var direction = (player.position - position).normalized()
			move_and_collide(direction * SPEED * delta)
			
			# Check if in attack range
			if position.distance_to(player.position) < ATTACK_RANGE:
				state = State.ATTACK
				attack_timer = ATTACK_COOLDOWN
			
			# Check if player is out of range
			if position.distance_to(player.position) > CHASE_RANGE:
				state = State.IDLE
		
		State.ATTACK:
			attack_timer -= delta
			
			if attack_timer <= 0:
				# Deal damage to player
				if player.has_method("take_damage"):
					player.take_damage(ATTACK_DAMAGE)
				attack_timer = ATTACK_COOLDOWN
			
			# Check if player is out of attack range
			if position.distance_to(player.position) > ATTACK_RANGE:
				state = State.CHASE

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free() 