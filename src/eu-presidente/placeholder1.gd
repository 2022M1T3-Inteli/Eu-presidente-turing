extends Button

onready var SelextSfx := $SelectSFX

func _ready():
	SelextSfx.play()

func _on_init_btn_pressed():
	get_tree().change_scene("res://placeholder2.tscn")
