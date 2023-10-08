extends Control

var screen_res := Global.SCREEN_RES

func _ready() -> void:
	randomize()
	
	if Global.settings.show_info_label:
		$InfoLabel.show()
	
	spread_randomly()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().paused = not get_tree().paused
		
	elif event.is_action_pressed("left_click"):
		add_unit(event.position, $OptionsPanel.get_selected_emoji())
		change_bg_color()
		
	elif event.is_action_pressed("right_click"):
		create_group(event.position, $OptionsPanel.get_selected_emoji())
		change_bg_color()
		
	elif event.is_action_pressed("restart"):
		clear_all_units()
		spread_randomly()
	
	elif event.is_action_pressed("clear"):
		clear_all_units()
		
	elif event.is_action_pressed("mute"):
		AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))
	
	elif event.is_action_pressed("show_options"):
		$OptionsPanel.visible = not $OptionsPanel.visible
		
		if Global.settings.show_info_label:
			$InfoLabel/AnimationPlayer.play_backwards("move_up")
			Global.settings.show_info_label = false
		
		if not $OptionsPanel.visible:
			$InfoLabel.hide()

func add_unit(pos: Vector2i, emoji: String) -> void:
	var new_unit := preload("res://scenes/unit.tscn").instantiate()
	new_unit.position = pos
	new_unit.emoji = emoji
	
	$Units.add_child(new_unit)
	
	new_unit.connect("unit_converted", change_bg_color)

func create_group(pos: Vector2, emoji: String) -> void:
	for __ in range(Global.settings.group_amount):
		var offset = Vector2(randf() - 0.5, randf() - 0.5) * screen_res/12
		add_unit(pos + offset, emoji)

func spread_randomly():
	for i in range(Global.settings.start_amount):
		var emoji: String = Unit.RPS[i % len(Unit.RPS)]
		var pos := Vector2(randf(), randf()) * screen_res
		add_unit(pos, emoji)
	
	change_bg_color()

func clear_all_units():
	for unit in $Units.get_children():
		unit.remove_from_group(unit.emoji)
		unit.queue_free()

func change_bg_color() -> void:
	var num_of_rocks := len(get_tree().get_nodes_in_group("🪨"))
	var num_of_papers := len(get_tree().get_nodes_in_group("📄"))
	var num_of_scissors := len(get_tree().get_nodes_in_group("✂️"))
	
	var total_units: int = num_of_rocks + num_of_papers + num_of_scissors
	
	if not total_units: return
	
	var new_color := Color(num_of_scissors, num_of_papers, num_of_rocks)
	new_color /= total_units
	new_color.a = 1

	match Global.settings.bg_color:
		Global.BGColorType.LIGHT:
			new_color = new_color.lightened(0.85)
		Global.BGColorType.DARK:
			new_color = new_color.darkened(0.9)
		Global.BGColorType.COLORFUL:
			new_color = new_color.clamp(Color.BLACK, Color.DARK_GRAY)
	
	$Background.color = new_color

func _on_options_panel_changed_bg_style() -> void:
	change_bg_color()
	
func _on_options_panel_clear() -> void:
	clear_all_units()

func _on_options_panel_restart() -> void:
	clear_all_units()
	spread_randomly()
