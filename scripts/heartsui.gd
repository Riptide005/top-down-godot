extends HBoxContainer

# Load your clean heart asset blueprint here!
@export var heart_texture: Texture2D = preload("res://assets/hearts.png") 

func update_hearts(current_lives: int) -> void:
	for child in get_children():
		child.queue_free()
	
	for i in range(current_lives):
		var heart_rect = TextureRect.new()
		heart_rect.texture = heart_texture
		
	
		heart_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		

		heart_rect.custom_minimum_size = Vector2(32.0, 32.0) 
		
		heart_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
		add_child(heart_rect)