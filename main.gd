extends Node3D

@export var player_scene: PackedScene = preload("res://character.tscn")

func spawn_player(peer_id: int):
	print("Main path is:", get_path())

	print("Player Spawned!")
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	add_child(player, true)
	player.global_position = $SpawnPoint.global_position

	await get_tree().create_timer(3.0).timeout
	var carrot = create_item("carrot", player.global_position)
	print("Spawnplayer My peer ID is:", multiplayer.get_unique_id())
	print("Am I the server?", multiplayer.is_server())
	print(carrot.itemID)

@export var item_defs = {
	"apple": {
		"itemID": "apple",
		"itemName": "Apple",
		"sprite": "res://assets/apple.png"
	},
	"carrot": {
		"itemID": "carrot",
		"itemName": "Carrot",
		"sprite": "res://assets/carrot.png"
	}
}

func create_item(itemID: String, pos: Vector3) -> Node:
	var item_scene = preload("res://item.tscn") # your base item sceccne
	var item = item_scene.instantiate()
	var source = item_defs[itemID]
	
	item.itemID = itemID
	item.itemName = source["itemName"]
	#item.get_node("Sprite").texture = load(source["sprite"])
	item.set_multiplayer_authority(1)
	#item.global_rotation_degrees = ang
	call_deferred("add_child", item, true)
	item.position = pos
	
	return item
