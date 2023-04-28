extends Control

enum Buttons {
	New_Game,
	Continue,
	Options,
	Exit
}

var cursor: Control
var currsor_loaction = Buttons.New_Game

func _ready():
	cursor = get_node("Cursor")
	_set_cursor($"Buttons/New Game")
	
	if FileAccess.file_exists(SaveManager.SAVE_FILE):
		var BT = $Buttons
		BT.remove_child($Buttons/Options)
		BT.remove_child($Buttons/Exit)
		
		var button = Label.new()
		button.text = "Continue"
		button.set_meta("ButtonId", Buttons.Continue)
		BT.add_child(button)
		button = Label.new()
		button.text = "Options"
		button.set_meta("ButtonId", Buttons.Options)
		BT.add_child(button)
		button = Label.new()
		button.text = "Exit"
		button.name = "Exit"
		
		button.set_meta("ButtonId", Buttons.Exit)
		BT.add_child(button)
	else:
		pass
	
	_bind()

func _bind():
	for child in $Buttons.get_children():
		child.add_theme_font_override("font", load("res://assets/fonts/Fipps-Regular.otf"))
		child.add_theme_font_size_override("font_size", 24)
		child.mouse_filter = Control.MOUSE_FILTER_PASS
		child.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		child.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		child.mouse_entered.connect(_on_hover.bind(child))
		child.mouse_exited.connect(_off_hover.bind(child))
		child.gui_input.connect(_gui.bind(child))

func _on_hover(button: Label):
	var BID = int(button.get_meta("ButtonId"))
	
	if BID != currsor_loaction:
		currsor_loaction = BID
		_set_cursor(button)

func _set_cursor(button: Label):
	var button_loc = button.global_position
	cursor.global_position = button_loc - Vector2(60, 0)

func _off_hover(button):
	pass

func _gui(event: InputEvent, button):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			match int(button.get_meta("ButtonId")):
				Buttons.New_Game:
					if !FileAccess.file_exists(SaveManager.SAVE_FILE):
						SaveManager.create_new_save()
						_to_new_game()
					else:
						SaveManager.create_new_save(true)
						_to_new_game()
					
				Buttons.Exit:
					get_tree().quit()

func _to_new_game():
	$"../../AnimationPlayer".play("fade_out")
	await $"../../AnimationPlayer".animation_finished
	get_tree().change_scene_to_file("res://src/scenes/chapters/prolouge_intro.tscn")
