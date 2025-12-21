extends CanvasLayer

func _unhandled_key_input(event: InputEvent) -> void:
	var key = OS.get_keycode_string(event.keycode)
	print("Key " + key + " pressed")
