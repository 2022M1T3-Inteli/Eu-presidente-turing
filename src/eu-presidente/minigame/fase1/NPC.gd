extends StaticBody2D

export(Texture) var sprite_image setget set_sprite

func set_sprite(texture):
	get_node("Sprite").texture = texture
