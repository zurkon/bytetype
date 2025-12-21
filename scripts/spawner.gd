extends Node2D

# Remember to setup on editor
@export var player: Player

@onready var timer := $Timer
@onready var enemy_container := $EnemyContainer
@onready var positions := [
	$LeftCorner,
	$Left,
	$Center,
	$Right,
	$RightCorner
]

var _word_list := WordList.new()

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

## Activate a [Enemy] in scene with a random word.
func spawn_new_enemy() -> void:
	var new_word: String = _word_list.get_random_word()
	for enemy: Enemy in enemy_container.get_children():
		if enemy.is_inactive():
			var new_pos = positions[randi() % 5].global_position
			enemy.activate(new_pos, player.global_position, new_word)
			print("enemy selected: " + new_word)
			break

func _on_timer_timeout() -> void:
	spawn_new_enemy()
	timer.wait_time = randi_range(2, 4)
	timer.start()
