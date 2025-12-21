extends CharacterBody2D
class_name Player

const BULLET := preload("res://scenes/bullet.tscn")

@onready var particles = $CPUParticles2D
@onready var sprite_component = $Sprite2D
@onready var hurtbox_component := $HurtBox

var running := true
var tween: Tween

signal destroyed

func _ready() -> void:
	hurtbox_component.body_entered.connect(_on_body_entered)

## Fires a [Bullet] instance to target direction. [br]
## That instance holds the [code]current_index[/code] to be removed [br]
## and [code]target_word[/code] for collision checking.
func fire(target: Enemy, index: int, word: String) -> void:
	# You should not fire when not running
	if not running:
		return
	var bullet_instance = BULLET.instantiate()
	bullet_instance.global_position = global_position
	bullet_instance.current_index = index
	bullet_instance.target_word = word
	get_parent().add_child(bullet_instance)
	bullet_instance.look_at(target.global_position)

## Rotates player to target direction.
func aim(target: Vector2) -> void:
	var target_rotation = global_position.angle_to_point(target)
	tween = create_tween()
	tween.tween_property(self, "rotation", target_rotation, 0.1)   

func destroy() -> void:
	running = false
	# Emit Signal
	destroyed.emit()
	# Hide Sprite
	sprite_component.hide()
	# Disable Hurtbox to avoid other collisions
	hurtbox_component.set_deferred("monitoring", false)
	# Start particles
	particles.restart()
	particles.emitting = true

func _on_body_entered(body: Node2D):
	if body is Enemy:
		destroy()
		Engine.time_scale = 0.5
		particles.speed_scale = 0.5
		await get_tree().create_timer(1.0).timeout
		Engine.time_scale = 1.0
		# After 3 seconds, reload level
		await get_tree().create_timer(3.0).timeout
		get_tree().reload_current_scene()
