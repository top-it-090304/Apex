extends Node2D

func _ready() -> void:
	_spawn_flags()

func _spawn_flags():
	var loaded = SaveManager.load_slot(SaveManager.slot_save)
	
	#region получаем JSON файл c разметкой уровня
	var file = FileAccess.open("res://scenes_and_scripts/levelsJSON/level1.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	#endregion
	
	#region Добаввляем в сейв информацию о флагах
	var scene_num = loaded["level"]["scene_number"]
	var json_key = str(scene_num)
	loaded["level"]["flags_total"] = int(data[json_key]["flags"])
	print(loaded["level"]["flags_total"])
	SaveManager.save_slot(SaveManager.slot_save, loaded)
	#endregion
