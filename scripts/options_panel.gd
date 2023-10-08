extends PanelContainer

signal collision_changed
signal changed_bg_style
signal restart
signal clear

const STATUS := ["Disabled", "Enabled"]

var selectable_buttons := ButtonGroup.new()

func _ready() -> void:
	for node in $Margin/MainVBox/EmojiHBox.get_children():
		if node is Button:
			node.button_group = selectable_buttons
	
	%ColorOptions.selected = Global.settings.bg_color
	
	%CollisionButton.text = STATUS[int(Global.settings.collision)]
	
	%StartSpinBox.value = Global.settings.start_amount
	%GroupSpinBox.value = Global.settings.group_amount
	%SpeedSpinBox.value = Global.settings.speed_amount

func get_selected_emoji() -> String:
	var button := selectable_buttons.get_pressed_button()
	
	if button.name == "Random":
		return Unit.RPS.pick_random()
	
	return button.text
	
func _on_collision_button_pressed() -> void:
	Global.settings.collision = not Global.settings.collision
	%CollisionButton.text = STATUS[int(Global.settings.collision)]
	
	emit_signal("collision_changed")

func _on_color_options_item_selected(index: int) -> void:
	Global.settings.bg_color = index
	emit_signal("changed_bg_style")

func _toggle_controls_panel():
	$ControlsPanel.visible = not $ControlsPanel.visible

func _toggle_amount_changer_panel():
	$AmountChangerPanel.visible = not $AmountChangerPanel.visible
	
func _on_restart_pressed() -> void:
	emit_signal("restart")

func _on_clear_pressed() -> void:
	emit_signal("clear")

func _on_speed_spin_box_value_changed(value: float) -> void:
	Global.settings.speed_amount = value
	for unit in get_tree().get_nodes_in_group("units"):
		unit.speed = value

func _on_start_spin_box_value_changed(value: float) -> void:
	Global.settings.start_amount = value

func _on_group_spin_box_value_changed(value: float) -> void:
	Global.settings.group_amount = value

