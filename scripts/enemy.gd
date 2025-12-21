extends CharacterBody2D
class_name Enemy

@export var color := Color("ffff00")

@onready var label = $RichTextLabel
@onready var particles = $CPUParticles2D
@onready var sprite_component = $AnimatedSprite2D

var word: String:
	get:
		return word
	set(new_value):
		word = new_value
		label.parse_bbcode("[center]" + word + "[/center]")
var origin_point := Vector2.ZERO:
	get:
		return origin_point
	set(new_value):
		origin_point = new_value
		global_position = origin_point

var state := State.INACTIVE
var target_point := Vector2.ZERO

var speed := 4
var knockback: float = -0.65
var sprite_tween: Tween
var label_tween : Tween

signal destroyed

enum State {
	ACTIVE,
	DISABLING,
	INACTIVE
}

func _physics_process(delta: float) -> void:
	# If it is not activated, skips
	if not state == State.ACTIVE:
		return
	velocity = (target_point - origin_point) * speed * delta
	move_and_slide()

## Removes character from the index.[br]
## [br]
## [param index]: index value to use in [code]substr(index, word.length())[/code].
func remove_character(index: int) -> void:
	var target_word = _color_tag() + word.substr(index, word.length()) + _color_tag(true)
	label.parse_bbcode("[center]" + target_word + "[/center]")
	# Increase label scale briefly to increase feedback
	label_tween = create_tween()
	label_tween.set_ease(Tween.EASE_OUT)
	label_tween.set_trans(Tween.TRANS_CUBIC)
	label_tween.tween_property(label, "scale", Vector2(1,1), 0.3).from(Vector2(1, 1.5))
	
	# Knockbacks enemy when hitted
	velocity += (target_point - origin_point) * knockback
	move_and_slide()
	
	sprite_tween = create_tween()
	sprite_tween.tween_method(_blink_sprite, 1.0, 0.0, 0.2)
	
	# Deactivate enemy when typed whole word
	if index == word.length():
		deactivate()

## Resets enemy to starting state and position
func reset():
	state = State.INACTIVE
	origin_point = Vector2(0, -10)
	word = ""
	sprite_component.show()
	label.show()

## Setup and activate a enemy.[br]
## [br]
## [param origin]: a [Vector2] starting position.[br]
## [param target]: a [Vector2] target position to follow.[br]
## [param new_word]: a [String] word to be displayed on [Enemy].
func activate(origin: Vector2, target: Vector2, new_word: String) -> void:
	origin_point = origin
	target_point = target
	word = new_word
	state = State.ACTIVE

## Hide and Deactivate this [Enemy].[br]
## [br]
## It is gonna reset after particles emittion finished.
func deactivate():
	state = State.DISABLING
	# Hide
	sprite_component.hide()
	label.hide()
	# Emit signal
	destroyed.emit()
	# Show particles
	particles.restart()
	particles.emitting = true
	# Reset
	await particles.finished
	reset()

## Returns [code]True[/code] is current [Enemy] state is [code]State.ACTIVE[/code].
func is_running() -> bool:
	return state == State.ACTIVE

## Returns [code]True[/code] is current [Enemy] state is [code]State.INACTIVE[/code].
func is_inactive() -> bool:
	return state == State.INACTIVE

## Applies blink effect on [AnimatedSprite2D] material by given intensity.
func _blink_sprite(intensity: float) -> void:
	sprite_component.material.set_shader_parameter("blink_intensity", intensity)

func _color_tag(end: bool = false) -> String:
	if end:
		return "[/color]"
	return "[color=#" + color.to_html(false) + "]"
