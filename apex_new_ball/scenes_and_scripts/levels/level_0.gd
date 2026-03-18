extends Node2D

var FLAG_SCENE = preload("res://scenes_and_scripts/templates/flag/flags.tscn")

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
	loaded["level"]["flags_total"] = int(data[loaded["level"]["scene_number"]]["flags"])
	SaveManager.save_slot(SaveManager.slot_save, loaded)
	#endregion
