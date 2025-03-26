extends Control

@onready var new_game_button = $CenterContainer/VBoxContainer/NewGameButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton

func _ready():
	new_game_button.pressed.connect(_on_new_game_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_pressed():
	get_tree().quit() 
