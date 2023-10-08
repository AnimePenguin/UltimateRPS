extends CharacterBody2D
class_name Unit

signal unit_converted

const RPS := ["🪨", "📄", "✂️"]

const SHAKE_SPEED := 5

const URGE_TO_HUNT := 1
const FEAR_FACTOR := 0.75

var speed: int = Global.settings.speed_amount

@export_enum("🪨", "📄", "✂️") var emoji := "✂️"
var prey := "📄"
var predator := "🪨"

func _ready() -> void:
	$CollisionShape.set_deferred("disabled", not Global.settings.collision)
	
	add_to_group("units")
	add_to_group(emoji)
	$Emoji.text = emoji
	
	prey = RPS[(RPS.find(emoji) - 1) % len(RPS)]
	predator = RPS[(RPS.find(emoji) + 1) % len(RPS)]

func _process(_delta: float) -> void:
	velocity = get_direction() * speed
	move_and_slide()
	
	position = position.clamp(Vector2.ZERO, Vector2.ONE * Global.SCREEN_RES)
	
	if not $Cooldown.is_stopped():
		return
	
	if $CollisionShape.disabled:
		area2D_detection()
	else:
		characterbody2D_detection()

func area2D_detection() -> void:
	var collisons: Array[Area2D] = $Area2D.get_overlapping_areas()

	for area2d in collisons:
		var collider = area2d.get_parent()
		if collider is Unit and collider.emoji == prey:
			convert_unit(collider)
			break

func characterbody2D_detection() -> void:
	var collison := get_last_slide_collision()

	if not collison:
		return

	var collider := collison.get_collider()

	if collider is Unit and collider.emoji == prey:
		convert_unit(collider)

func find_distance_to_closest(emoji_to_find: String) -> Vector2:
	var units := get_tree().get_nodes_in_group(emoji_to_find)
	
	if not len(units):
		return position
	
	var closest_unit := units[0]
	var smallest_dist := position.distance_squared_to(closest_unit.position)
	
	for unit in units.slice(1):
		var dist := position.distance_squared_to(unit.position)
		
		if dist < smallest_dist:
			closest_unit = unit
			smallest_dist = dist
	
	return closest_unit.position

func get_direction() -> Vector2:
	var random_dir := Vector2(randf() - 0.5, randf() - 0.5) * SHAKE_SPEED
	
	if not len(get_tree().get_nodes_in_group(prey)):
		return random_dir

	var prey_pos := find_distance_to_closest(prey)
	var pred_pos := find_distance_to_closest(predator)
	
	var dir := position.direction_to(prey_pos) * URGE_TO_HUNT # Move to prey
	dir += pred_pos.direction_to(position) * FEAR_FACTOR # away from predator
	
	return dir + random_dir

func convert_unit(unit: Unit) -> void:
	unit.remove_from_group(unit.emoji)
	unit.add_to_group(emoji)
	
	unit.emoji = emoji
	unit.get_node("Emoji").text = emoji
	unit.prey = prey
	
	$Cooldown.start()
	unit.get_node("Cooldown").start()
	
	$MunchSound.play()
	
	emit_signal("unit_converted")
