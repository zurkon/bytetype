extends TextureButton

@export var code := 0

func _ready() -> void:
	pressed.connect(_emit_keyinput)

func _emit_keyinput() -> void:
	var event = InputEventKey.new()
	event.keycode = code
	event.unicode = 1
	event.pressed = true
	Input.parse_input_event(event)
