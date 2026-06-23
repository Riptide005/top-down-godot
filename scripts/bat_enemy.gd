extends CharacterBody2D

@export var speed: float = 80.0
var player: CharacterBody2D = null

func _ready() -> void:
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player == null:
		player = get_tree().get_first_node_in_group("Player") as CharacterBody2D

func _physics_process(delta: float) -> void:
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed

		if direction.x < 0:
			$Sprite2D.flip_h = true
		elif direction.x > 0:
			$Sprite2D.flip_h = false

		move_and_slide()



func _on_timer_timeout() -> void:
	pass # Replace with function body.
