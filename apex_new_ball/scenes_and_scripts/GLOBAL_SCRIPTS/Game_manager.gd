extends Node

var coin = 0
var flag = 0
var live = 0
var resp = 0
var pause_scene

func _ready() -> void:
	Events.TOUCHING_THE_FLAG.connect(_touch)
	Events.COLLECTING_COINS.connect(_collect)
	Events.OPEN_THE_CHEST.connect(_chest)
	Events.OPEN_THE_DOOR.connect(_door)
	Events.BUTTON_PLAY_PRESSED.connect(_button)
	Events.PLAYER_RESPAWN.connect(_respa)
	
	for i in range(3):
		var loaded = SaveManager.load_slot(i)
		if loaded["player"]["lives"] < 1:
			SaveManager.delete_slot(i)
			print("Сейв слота ", i, " удален (0 жизней)")
			if SaveManager.slot_exists(i):
				print("существует ", i)
			else: 
				print("не существует ", i)
				var data = SaveManager.get_default_data()
				data["player"]["id"] = i+1
				data["player"]["name"] = "Player" + str(i)
				data["player"]["score"] = 0
				SaveManager.save_slot(i, data)

func _touch(sprite):
	sprite.animation = "flag"
	flag += 1
	print("flag")

func _respa():
	resp += 1
	print(resp)

func _collect(sprite):
	sprite.modulate.a = 0
	coin += 1
	print("coin")

func _chest(sprite):
	sprite.animation = "chest"
	coin += 1
	print("chest")

func _door(sprite):
	sprite.animation = "open"
	print("door")

func _button(number_button):
	var loading = SaveManager.load_slot(number_button)
	get_tree().change_scene_to_file(loading["level"]["current_scene"])
		
