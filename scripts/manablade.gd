extends Area2D

@export var speed: float = 10.0
@export var orbit_distance: float = 120.0
@export var burst_rotations: float = 2.0
@export var cooldown_time: float = 10.0

var parent_player: CharacterBody2D = null
var _is_active: bool = false
var _burst_time_remaining: float = 0.0
var _cooldown_remaining: float = 0.0
var _cooldown_label: Label = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$Sprite2D.position = Vector2(orbit_distance, 0)
	$CollisionShape2D.position = Vector2(orbit_distance, 0)
	visible = false
	monitoring = false
	$CollisionShape2D.disabled = true
	_cooldown_label = _ensure_cooldown_label()
	_update_cooldown_label()

func _process(delta: float) -> void:
	if parent_player != null:
		global_position = parent_player.global_position

	if _cooldown_remaining > 0.0:
		_cooldown_remaining = max(_cooldown_remaining - delta, 0.0)

	if _is_active:
		rotation += speed * delta
		_burst_time_remaining -= delta
		if _burst_time_remaining <= 0.0:
			_end_burst()

	_update_cooldown_label()

func activate() -> bool:
	if _is_active or _cooldown_remaining > 0.0:
		return false

	_is_active = true
	visible = true
	monitoring = true
	$CollisionShape2D.disabled = false
	_burst_time_remaining = (burst_rotations * TAU) / max(speed, 0.001)
	return true

func _end_burst() -> void:
	_is_active = false
	_cooldown_remaining = cooldown_time
	visible = false
	monitoring = false
	$CollisionShape2D.disabled = true
	_update_cooldown_label()

func _ensure_cooldown_label() -> Label:
	var scene := get_tree().current_scene
	if scene == null:
		return null

	var existing_label := scene.find_child("ManabladeCooldown", true, false)
	if existing_label is Label:
		return existing_label

	var canvas_layer := scene.find_child("CanvasLayer", true, false)
	if canvas_layer == null:
		return null

	var cooldown_label := Label.new()
	cooldown_label.name = "ManabladeCooldown"
	cooldown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cooldown_label.text = "Manablade: ready"
	canvas_layer.add_child(cooldown_label)
	cooldown_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT, true)
	cooldown_label.offset_left = -240.0
	cooldown_label.offset_top = -48.0
	cooldown_label.offset_right = -16.0
	cooldown_label.offset_bottom = -16.0
	return cooldown_label

func _update_cooldown_label() -> void:
	if _cooldown_label == null:
		return

	if _cooldown_remaining > 0.0:
		_cooldown_label.text = "Manablade Cooldown: %.1fs" % _cooldown_remaining
	else:
		_cooldown_label.text = "Manablade: Ready"

func _on_body_entered(body: Node2D) -> void:
	if _is_active and body.is_in_group("enemies"):
		body.queue_free()
