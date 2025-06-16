extends Node3D

class_name Main

@export var player_scene: PackedScene = preload("res://character.tscn")

func spawn_player(peer_id: int):
	print("Player Spawned!")
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	player.global_position = $SpawnPoint.global_position
	call_deferred("add_child", player)
	var carrot = create_item("carrot", $SpawnPoint.global_position)
	print("Spawnplayer My peer ID is:", multiplayer.get_unique_id())
	print("Am I the server?", multiplayer.is_server())
	print(carrot.name)

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
	var item_scene = preload("res://item.tscn") # your base item scene
	var item = item_scene.instantiate()
	var source = item_defs[itemID]
	
	item.itemID = itemID
	item.itemName = source["itemName"]
	item.get_node("Sprite").texture = load(source["sprite"])
	
	item.global_position = pos
	#item.global_rotation_degrees = ang
	add_child(item)
	
	return item
