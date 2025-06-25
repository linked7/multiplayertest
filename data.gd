extends Node3D

@export var hp: int = 1

func _ready():
	set_multiplayer_authority(1)
