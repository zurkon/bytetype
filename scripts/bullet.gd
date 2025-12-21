extends Area2D
class_name Bullet

var current_index: int = 0
var target_word: String = ""
var speed := 500

func _ready() -> void:
	body_entered.connect(_on_bullet_body_entered)

func _physics_process(delta: float) -> void:
	global_position += Vector2(1,0).rotated(rotation) * speed * delta

func _on_bullet_body_entered(body: Node2D) -> void:
	if body is Enemy:
		if body.word == target_word:
			body.remove_character(current_index)
			queue_free()
