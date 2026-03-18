extends Node2D

var FLAG_SCENE = preload("res://scenes_and_scripts/templates/flag/flags.tscn")

func _ready() -> void:
	_spawn_flags()

func _spawn_flags():
	var loaded = SaveManager.load_slot(SaveManager.slot_save)
	
	#region получаем JSON файл c разметкой уровня
	var scene_number = loaded["level"]["scene_number"]
	var file = FileAccess.open("res://scenes_and_scripts/levelsJSON/level" + str(scene_number) + ".json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	#endregion
	
	#region Добаввляем в сейв информацию о флагах
	loaded["level"]["flags_total"] = data["flags"].size()
	SaveManager.save_slot(SaveManager.slot_save, loaded)
	#endregion
	
	#region Расставляем флаги по сцене уровня
	for flag_num in data["flags"]:
		var flag = FLAG_SCENE.instantiate()
		flag.position = Vector2(flag_num["x"], flag_num["y"])
		flag.flag_id = flag_num["id"]
		$Flags.add_child(flag)
	#endregion
