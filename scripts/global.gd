extends Node

const SCREEN_RES := 1024

enum BGColorType {LIGHT, DARK, COLORFUL}

const SETTINGS_PATH = "user://settings.json"

# set this to false only during debug
var use_user_settings = true

var settings := {
	"start_amount": 50,
	"group_amount": 8,
	"speed_amount": 100,
	"collision": false,
	"bg_color": BGColorType.LIGHT,
	"show_info_label": true,
}

func _ready() -> void:
	resize_window_to_fit()
	
	if FileAccess.file_exists(SETTINGS_PATH) and use_user_settings:
		var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		settings = JSON.parse_string(file.get_as_text())
		settings.bg_color = int(settings.bg_color)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and use_user_settings:
		var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
		file.store_string(JSON.stringify(settings))

func resize_window_to_fit() -> void:
	var screen_size = DisplayServer.screen_get_size()

	var lowest_dimension = screen_size[screen_size.min_axis_index()]
	get_window().size = Vector2i.ONE * lowest_dimension * 0.75

	DisplayServer.window_set_position(
		DisplayServer.screen_get_position() +
		(DisplayServer.screen_get_size() - DisplayServer.window_get_size())/2
	)

