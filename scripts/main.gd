extends Node

@export var player: Player

@onready var enemy_container = $Gameplay/EnemySpawner/EnemyContainer
@onready var camera: Camera = $Camera2D

var current_enemy: Enemy  = null
var current_index: int = 0
var current_word: String = ""
var running = true

func _ready() -> void:
	player.destroyed.connect(camera.screen_shake.bind(10.0, 0.5))
	for enemy: Enemy in enemy_container.get_children():
		# Connect Signal to Camera Screen Shake
		enemy.destroyed.connect(camera.screen_shake)
		enemy.destroyed.connect(reset_aim)

func _unhandled_key_input(event: InputEvent) -> void:
	# Stop listening keys on game over
	if not running:
		return
	
	# We only care about key‑press events (not releases)
	if event.is_echo() or not event.is_pressed():
		return
	
	# Get the Unicode character produced by the key press.
	# `unicode` is 0 for non‑printable keys (Enter, Arrow, etc.).
	if event.unicode == 0:
		return   # non‑printable, ignore
	
	var key_typed: String = OS.get_keycode_string(event.keycode).to_lower()
	
	if current_enemy == null:
		# Find new enemy
		var enemies = enemy_container.get_children()
		# Sort them by global_position.y (closest to player first)
		enemies.sort_custom(func(a, b): return a.global_position.y > b.global_position.y)
		for enemy: Enemy in enemies:
			if enemy.is_running():
				var first_char = enemy.word.substr(0,1)
				if first_char == key_typed:
					current_enemy = enemy
					current_word = enemy.word
					player.aim(current_enemy.global_position)
					break
				
	# Compare typed letter with current word is first letter
	var next_char: String = current_word.substr(current_index, 1)
	if key_typed == next_char and current_index < current_word.length():
		current_index += 1
		player.fire(current_enemy, current_index, current_word)

func reset_aim() -> void:
	current_index = 0
	current_enemy = null
	current_word = ""
