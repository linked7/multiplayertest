extends Node3D

class_name Main

@export var player_scene: PackedScene = preload("res://character.tscn")

func spawn_player(peer_id: int):
	print("Player Spawned!")
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	call_deferred("add_child", player)
