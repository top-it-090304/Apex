extends Node

@onready var label1 = $HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/Label1
@onready var label2 = $HBoxContainer/PanelContainer2/MarginContainer/HBoxContainer/Label2
@onready var label3 = $HBoxContainer2/PanelContainer2/MarginContainer/HBoxContainer/Label3

var flag = false

func _ready() -> void:
	#region Добавляем в статус бар информацию взятую из конфига о жизнях, флагах, и очках
	var _loaded = SaveManager.load_slot(SaveManager.slot_save)
	label1.text = "x " + str(_loaded["player"]["lives"])
	label2.text = str(_loaded["level"]["flags_collected"]) + "/" + str(_loaded["level"]["flags_total"])
	label3.text = str(_loaded["player"]["score"])
	#endregion

func _process(_delta: float) -> void:
	#region Добавляем информацию о флагах в статус бар так как _ready() срабатывает быстрее прочтения .json 
	if flag == false:
		var _loaded = SaveManager.load_slot(SaveManager.slot_save)
		label2.text = str(_loaded["level"]["flags_collected"]) + "/" + str(_loaded["level"]["flags_total"])
		flag = true
	#endregion
	
	#region Обновляем очки счета каждый раз при срабатывании сигнала сбора
	if GameManager.coin > 0:
		var _loaded = SaveManager.load_slot(SaveManager.slot_save)
		label3.text = str(_loaded["player"]["score"])
		GameManager.coin -= 1
	#endregion
	
	#region
	if GameManager.flag > 0:
		var _loaded = SaveManager.load_slot(SaveManager.slot_save)
		label2.text = str(_loaded["level"]["flags_collected"]) + "/" + str(_loaded["level"]["flags_total"])
		GameManager.flag -= 1
	#endregion
