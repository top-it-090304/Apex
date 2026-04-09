extends Node2D

const _REF_W := 1280.0
const _REF_H := 720.0

@onready var root: Control = $SettingsRoot
@onready var panel: PanelContainer = $SettingsRoot/PanelContainer
@onready var parallax: Parallax2D = $Parallax
@onready var title_label: Label = $SettingsRoot/PanelContainer/MarginContainer/VBoxContainer/Title
@onready var music_slider: HSlider = $SettingsRoot/PanelContainer/MarginContainer/VBoxContainer/MusicRow/Controls/MusicSlider
@onready var music_value: Label = $SettingsRoot/PanelContainer/MarginContainer/VBoxContainer/MusicRow/Controls/MusicValue
@onready var sfx_slider: HSlider = $SettingsRoot/PanelContainer/MarginContainer/VBoxContainer/SfxRow/Controls/SfxSlider
@onready var sfx_value: Label = $SettingsRoot/PanelContainer/MarginContainer/VBoxContainer/SfxRow/Controls/SfxValue
@onready var sensitivity_slider: HSlider = $SettingsRoot/PanelContainer/MarginContainer/VBoxContainer/SensitivityRow/Controls/SensitivitySlider
@onready var sensitivity_value: Label = $SettingsRoot/PanelContainer/MarginContainer/VBoxContainer/SensitivityRow/Controls/SensitivityValue
@onready var back_button: Button = $SettingsRoot/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/BackButton

func _ready() -> void:
	music_slider.set_value_no_signal(GameManager.music_volume_percent)
	sfx_slider.set_value_no_signal(GameManager.sfx_volume_percent)
	sensitivity_slider.set_value_no_signal(GameManager.control_sensitivity)
	get_viewport().size_changed.connect(_reflow_layout)
	call_deferred("_reflow_layout")
	_update_slider_value(music_slider, music_value)
	_update_slider_value(sfx_slider, sfx_value)
	_update_slider_value(sensitivity_slider, sensitivity_value)

func _reflow_layout() -> void:
	var rect := get_viewport().get_visible_rect()
	var w := rect.size.x
	var h := rect.size.y
	if w <= 0.0 or h <= 0.0:
		return

	var scale_ref := minf(w / _REF_W, h / _REF_H)
	var panel_w := clampf(640.0 * scale_ref, 360.0, minf(760.0, w - 32.0))
	var panel_h := clampf(340.0 * scale_ref, 280.0, h - 32.0)
	var font_title := int(clampf(34.0 * scale_ref, 24.0, 42.0))
	var font_label := int(clampf(24.0 * scale_ref, 16.0, 30.0))
	var slider_h := clampf(24.0 * scale_ref, 18.0, 28.0)
	var button_h := clampf(58.0 * scale_ref, 42.0, 70.0)
	var bottom_extent: float = parallax.get_anchor_bottom_extent()

	parallax.position = Vector2(rect.position.x, rect.position.y + rect.size.y - bottom_extent)
	panel.custom_minimum_size = Vector2(panel_w, panel_h)
	panel.size = Vector2(panel_w, panel_h)
	panel.position = rect.position + (rect.size - panel.size) * 0.5
	title_label.add_theme_font_size_override("font_size", font_title)
	back_button.custom_minimum_size = Vector2(0.0, button_h)
	back_button.add_theme_font_size_override("font_size", font_label)

	for label_path in [
		"PanelContainer/MarginContainer/VBoxContainer/MusicRow/Name",
		"PanelContainer/MarginContainer/VBoxContainer/MusicRow/Controls/MusicValue",
		"PanelContainer/MarginContainer/VBoxContainer/SfxRow/Name",
		"PanelContainer/MarginContainer/VBoxContainer/SfxRow/Controls/SfxValue",
		"PanelContainer/MarginContainer/VBoxContainer/SensitivityRow/Name",
		"PanelContainer/MarginContainer/VBoxContainer/SensitivityRow/Controls/SensitivityValue"
	]:
		var label: Label = root.get_node(label_path)
		label.add_theme_font_size_override("font_size", font_label)

	for slider in [music_slider, sfx_slider, sensitivity_slider]:
		slider.custom_minimum_size = Vector2(0.0, slider_h)

func _update_slider_value(slider: HSlider, label: Label) -> void:
	label.text = _format_slider_value(slider)

func _format_slider_value(slider: HSlider) -> String:
	if slider == sensitivity_slider:
		return String.num(slider.value, 1)
	return str(int(round(slider.value)))

func _on_music_slider_value_changed(value: float) -> void:
	GameManager.set_music_volume_percent(value)
	music_value.text = str(int(round(value)))

func _on_sfx_slider_value_changed(value: float) -> void:
	GameManager.set_sfx_volume_percent(value)
	sfx_value.text = str(int(round(value)))

func _on_sensitivity_slider_value_changed(value: float) -> void:
	GameManager.set_control_sensitivity(value)
	sensitivity_value.text = String.num(value, 1)

func _on_back_button_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	get_tree().change_scene_to_file("res://scenes_and_scripts/ui_and_ux/menu/menu.tscn")
