extends Node2D

var timer = 0
@export var flag1 = false

func _ready():
	print("=== MENU STARTED ===")
	$black_canvas.modulate = Color.BLACK
	

func _process(_delta):
	if flag1 != true:
		timer += 10
		if timer >= 40 && $black_canvas.modulate.a > 0:
			$black_canvas.modulate.a -= 0.02
			timer = 0

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_1_pressed() -> void:
	SaveManager.slot_save = 0
	Events.BUTTON_PLAY_PRESSED.emit(Events.BUTTON_PLAY.Play1)

func _on_play_2_pressed() -> void:
	SaveManager.slot_save = 1
	Events.BUTTON_PLAY_PRESSED.emit(Events.BUTTON_PLAY.Play2)

func _on_play_3_pressed() -> void:
	SaveManager.slot_save = 2
	Events.BUTTON_PLAY_PRESSED.emit(Events.BUTTON_PLAY.Play3)
