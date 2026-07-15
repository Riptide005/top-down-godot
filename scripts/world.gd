extends Node2D

@export var torch_scene: PackedScene = preload("res://scenes/torch.tscn")
@export var torch_count: int = 48
@export var torch_spacing: float = 260.0
@export var torch_spawn_attempts_per_cell: int = 6
@export var spawn_area: Rect2 = Rect2(Vector2(-2500.0, -2500.0), Vector2(5000.0, 5000.0))
@export var bat_enemy_scene: PackedScene = preload("res://scenes/bat.tscn")


func _ready() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()

	var occupied_positions: Array[Vector2] = _get_existing_torch_positions()
	var grid_size: Vector2i = _get_grid_size()
	var cells: Array[Vector2i] = _build_spawn_cells(grid_size)
	cells.shuffle()

	for cell in cells:
		if occupied_positions.size() >= torch_count:
			break

		for attempt in range(torch_spawn_attempts_per_cell):
			var cell_position := _random_position_in_cell(rng, cell, grid_size)
			if _has_clearance(cell_position, occupied_positions):
				_spawn_torch(cell_position, occupied_positions)
				occupied_positions.append(cell_position) # <-- Lock it in right here!
				break


func _get_grid_size() -> Vector2i:
	var aspect_ratio: float = spawn_area.size.x / max(spawn_area.size.y, 1.0)
	var columns: int = max(1, int(ceil(sqrt(float(torch_count) * aspect_ratio))))
	var rows: int = max(1, int(ceil(float(torch_count) / float(columns))))

	return Vector2i(columns, rows)


func _build_spawn_cells(grid_size: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []

	for y in range(grid_size.y):
		for x in range(grid_size.x):
			cells.append(Vector2i(x, y))

	return cells


func _random_position_in_cell(rng: RandomNumberGenerator, cell: Vector2i, grid_size: Vector2i) -> Vector2:
	var cell_size: Vector2 = Vector2(spawn_area.size.x / float(grid_size.x), spawn_area.size.y / float(grid_size.y))
	var cell_origin: Vector2 = spawn_area.position + Vector2(cell.x * cell_size.x, cell.y * cell_size.y)

	return Vector2(
		rng.randf_range(cell_origin.x, cell_origin.x + cell_size.x),
		rng.randf_range(cell_origin.y, cell_origin.y + cell_size.y)
	)


func _has_clearance(candidate: Vector2, occupied_positions: Array[Vector2]) -> bool:
	for occupied_position in occupied_positions:
		if candidate.distance_to(occupied_position) < torch_spacing:
			return false

	return true


func _spawn_torch(position: Vector2, occupied_positions: Array[Vector2]) -> void:
	var torch: Node2D = torch_scene.instantiate() as Node2D
	var torch_layer: Node = get_node_or_null("World/TorchLayer")
	if torch_layer != null:
		torch_layer.add_child(torch)
	else:
		add_child(torch)
	torch.global_position = position
	occupied_positions.append(position)


func _get_existing_torch_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []

	for child in get_children():
		if child is Node2D and child.name.begins_with("Torch"):
			positions.append((child as Node2D).position)

	return positions

func _on_timer_timeout() -> void:
	var player = get_tree().current_scene.get_node_or_null("World/Player") as CharacterBody2D

	if player != null:
		var random_direction = Vector2.RIGHT.rotated(randf_range(0, 2 * PI))

		var spawn_distance = randf_range(200.0, 300.0)
		
		var spawn_position = player.global_position + (random_direction * spawn_distance)
		
		spawn_bat_enemy(spawn_position)

func spawn_bat_enemy(position: Vector2) -> void:
	var bat_enemy_instance = bat_enemy_scene.instantiate() as CharacterBody2D
	bat_enemy_instance.global_position = position

	add_child(bat_enemy_instance)