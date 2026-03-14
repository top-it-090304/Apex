extends Node
 
const SAVE_PATH = "user://game_data.cfg"
 
var slot_save
# ─── Сохранение слота ─────────────────────────────────────────────────────────
# slot_id — число (0, 1, 2) или строка ("autosave", "slot_alex")
# Структура файла: секции вида "slot_0/player", "slot_0/level" и т.д.
 
func save_slot(slot_id, data: Dictionary) -> void:
	var config = ConfigFile.new()
	config.load(SAVE_PATH)  # Грузим файл — чтобы не затереть другие слоты
 
	var prefix = "slot_%s" % str(slot_id)
 
	for section in data.keys():
		for key in data[section].keys():
			var value = data[section][key]
			# Vector2 ConfigFile не понимает — конвертируем в словарь
			if value is Vector2:
				value = {"x": value.x, "y": value.y}
			config.set_value("%s/%s" % [prefix, section], key, value)
 
	config.save(SAVE_PATH)
	print("SaveManager: слот '%s' сохранён" % str(slot_id))
 
 
# ─── Загрузка слота ───────────────────────────────────────────────────────────
 
func load_slot(slot_id) -> Dictionary:
	var config = ConfigFile.new()
 
	if config.load(SAVE_PATH) != OK:
		return get_default_data()
 
	var prefix = "slot_%s/" % str(slot_id)
	var data = {}
 
	for full_section in config.get_sections():
		if not full_section.begins_with(prefix):
			continue
		# Убираем префикс: "slot_0/player" → "player"
		var section = full_section.substr(prefix.length())
		data[section] = {}
		for key in config.get_section_keys(full_section):
			data[section][key] = config.get_value(full_section, key)
 
	if data.is_empty():
		return get_default_data()
 
	return data
 
 
# ─── Удаление слота ───────────────────────────────────────────────────────────
 
func delete_slot(slot_id) -> void:
	var config = ConfigFile.new()
 
	if config.load(SAVE_PATH) != OK:
		return
 
	var prefix = "slot_%s/" % str(slot_id)
	for full_section in config.get_sections():
		if full_section.begins_with(prefix):
			config.erase_section(full_section)
 
	config.save(SAVE_PATH)
	print("SaveManager: слот '%s' удалён" % str(slot_id))
 
 
# ─── Список всех слотов ───────────────────────────────────────────────────────
 
func get_all_slots() -> Array:
	var config = ConfigFile.new()
 
	if config.load(SAVE_PATH) != OK:
		return []
 
	var slots = {}
	for full_section in config.get_sections():
		# "slot_0/player" → id "0"
		var parts = full_section.split("/", false, 1)
		if parts.size() == 2 and parts[0].begins_with("slot_"):
			slots[parts[0].substr(5)] = true
 
	return slots.keys()
 
 
func slot_exists(slot_id) -> bool:
	return str(slot_id) in get_all_slots()
 
 
# ─── Данные по умолчанию ──────────────────────────────────────────────────────
 
func get_default_data() -> Dictionary:
	return {
		"player": {
			"id": 0,
			"name": "",
			"score": 0,
			"lives": 3,
			"max_lives": 5
		},
		"level": {
			"current_scene": "res://scenes_and_scripts/levels/level_0.tscn",
			"checkpoint_position": {"x": 0, "y": 0},
			"flags_total": 0,
			"flags_collected": 0
		}
	}
