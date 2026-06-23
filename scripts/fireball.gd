extends Area2D

@export var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		body.queue_free()
		queue_free()
