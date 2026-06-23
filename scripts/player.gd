extends CharacterBody2D

@export var speed: float = 200.0

@export var fireball_scene: PackedScene = preload("res://scenes/fireball.tscn")


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

