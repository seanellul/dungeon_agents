extends Node2D

@onready var player = $Player
@onready var dungeon_generator = $DungeonGenerator
@onready var health_label = $UI/Stats/VBoxContainer/HealthLabel
@onready var attack_label = $UI/Stats/VBoxContainer/AttackLabel

func _ready():
	# Connect player signals
	player.health_changed.connect(_on_player_health_changed)
	player.attack_changed.connect(_on_player_attack_changed)
	
	# Generate dungeon
	dungeon_generator.generate_dungeon()
	
	# Place player at starting position
	var start_pos = dungeon_generator.get_player_start_position()
	player.position = start_pos

func _on_player_health_changed(new_health):
	health_label.text = "Health: " + str(new_health)

func _on_player_attack_changed(new_attack):
	attack_label.text = "Attack: " + str(new_attack)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn") 