extends CharacterBody3D

@onready var sync = $MultiplayerSynchronizer

func _ready():
	if is_multiplayer_authority():
		print("I control this player.")
	else:
		set_physics_process(false)
