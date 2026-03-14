extends Node

func _ready() -> void:
	Events.GAME_ON_PAUSE.connect(_pause)
	Events.TOUCHING_THE_FLAG.connect(_touch)
	Events.COLLECTING_COINS.connect(_collect)
	Events.OPEN_THE_CHEST.connect(_chest)
	Events.OPEN_THE_DOOR.connect(_door)
	Events.BUTTON_PLAY_PRESSED.connect(_button)
	
	for i in range(3):
		if SaveManager.slot_exists(i):
			print("существует ", i)
		else: 
			print("не существует ", i)
			var data = SaveManager.get_default_data()
			data["player"]["id"] = i+1
			data["player"]["name"] = ""
			data["player"]["score"] = 0
			SaveManager.save_slot(i, data)

func _pause():
	get_tree().paused = true
	if get_tree().paused:
		print(52)

func _touch(sprite):
	sprite.animation = "flag"
	print("flag")

func _collect(sprite):
	sprite.modulate.a = 0
	print("coin")

func _chest(sprite):
	sprite.animation = "chest"
	print("chest")

func _door(sprite):
	sprite.animation = "open"
	print("door")

func _button(number_button: Events.BUTTON_PLAY):
	var loading = SaveManager.load_slot(number_button)
	get_tree().change_scene_to_file(loading["level"]["current_scene"])
		
