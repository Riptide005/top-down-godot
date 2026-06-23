extends CharacterBody2D

@export var speed: float = 200.0

@export var fireball_scene: PackedScene = preload("res://scenes/fireball.tscn")

func _ready() -> void:
	add_to_group("player")
	var hearts_ui = get_tree().current_scene.find_child("HeartsUI", true, false)
	if hearts_ui != null:
		hearts_ui.update_hearts(current_lives)
		
func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	if Input.is_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		direction.y += 1.0

	if direction != Vector2.ZERO:
		direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
		cast_fireball()

func cast_fireball() -> void:
	var fireball_instance = fireball_scene.instantiate() as Area2D
	fireball_instance.global_position = global_position
	var mouse_position = get_global_mouse_position()
	var aim_direction = (mouse_position - global_position).normalized()
	fireball_instance.direction = aim_direction
	get_tree().current_scene.add_child(fireball_instance)


@export var max_lives: int = 3
var current_lives: int = max_lives

func take_damage(amount: int) -> void:
	current_lives -= amount
	print("Player hit! Lives left: ", current_lives)
	
	# Fetch the UI container globally and tell it to redraw the hearts!
	var hearts_ui = get_tree().current_scene.find_child("HeartsUI", true, false)
	if hearts_ui != null:
		hearts_ui.update_hearts(current_lives)
	
	if current_lives <= 0:
		die()

func die() -> void:
	print("Player died! Game Over.")
	#Reload for now
	get_tree().reload_current_scene()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		take_damage(1)
		body.queue_free()
