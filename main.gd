extends Node3D

@export var player_scene: PackedScene = preload("res://player.tscn")
@export var character_scene: PackedScene = preload("res://character.tscn")

var nextSpawnItem = 0.0
var is_server_ready: bool = false

func _process(delta: float) -> void:
	if multiplayer.is_server() and is_server_ready:
		nextSpawnItem += delta
		if nextSpawnItem >= 3:
			nextSpawnItem = 0
			create_item("carrot", $SpawnPoint.global_position)

func spawn_player(peer_id: int):
	print("Player Spawned!")
	var player = player_scene.instantiate()
	player.name = str("ply_", peer_id)
	player.set_multiplayer_authority(peer_id)
	get_node("Players").add_child(player)
	
	var character = character_scene.instantiate()
	character.name = str("char_", peer_id)
	character.set_multiplayer_authority(1)
	character.get_node("Head").set_multiplayer_authority(peer_id)
	get_node("Players").add_child(character)

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

var createdItems = 0

func create_item(itemID: String, pos: Vector3) -> Node:
	var item_scene = preload("res://item.tscn")
	var item = item_scene.instantiate()
	var source = item_defs[itemID]
	
	createdItems += 1
	item.name = "item_%s" % str(createdItems)
	item.itemID = itemID
	item.itemName = source["itemName"]
	#item.get_node("Sprite").texture = load(source["sprite"])
	item.set_multiplayer_authority(1)
	#item.global_rotation_degrees = ang
	get_node("Items").add_child(item)
	item.position = pos
	
	return item
