extends Node

var peer: ENetMultiplayerPeer
@export var dedicated := false  # toggleable if needed

var input_ip
var input_port
const MAX_CONNECTIONS = 20

signal server_started
signal client_connected
signal peer_connected

@onready var player_scene = preload("res://character.tscn")

func _ready():
	peer_connected.connect(_on_peer_connected)
	server_started.connect(_on_server_started)
	client_connected.connect(_on_client_connected)
	
@rpc("authority", "call_local")
func spawn_player(peer_id: int):
	print("Player Spawned!")
	var player = player_scene.instantiate()
	player.name = str(peer_id)  # ✅ THIS IS CRUCIAL
	player.set_multiplayer_authority(peer_id)
	$"..".call_deferred("add_child", player)

	player.set_multiplayer_authority(peer_id)
	$"../MainMenu".hide()

# NETWORKING CALLS
func create_server(port: int = 22223, is_dedicated = false):
	dedicated = is_dedicated
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port, MAX_CONNECTIONS)
	multiplayer.multiplayer_peer = peer
	print("Server started on port %d" % port)
	server_started.emit()

func join_server(ip: String, port: int = 22223):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	print("Joining server at %s:%d" % [ip, port])
	client_connected.emit()
		
# NETWORKING POSTCALLS
func _on_server_started():
	print("On Server Started")
	if not dedicated:
		spawn_player(multiplayer.get_unique_id())
	else:
		$"../MainMenu".hide()

func _on_client_connected():
	print("On Client Connected")
	# The server will handle spawning and assign authority

func _on_peer_connected(peer_id: int):
	print("Peer connected: ", peer_id)
	if multiplayer.is_server():
		spawn_player(peer_id)

# UI ELEMENTS
func _on_host_player_pressed() -> void:
	input_port = $"../MainMenu/Sprite2D/InputPort".text.to_int()
	create_server(input_port, false)
	pass # Replace with function body.

func _on_host_server_pressed() -> void:
	input_port = $"../MainMenu/Sprite2D/InputPort".text.to_int()
	create_server(input_port, true)
	pass # Replace with function body.

func _on_connect_pressed() -> void:
	input_ip = $"../MainMenu/Sprite2D/InputIP".text
	input_port = $"../MainMenu/Sprite2D/InputPort".text.to_int()
	join_server(input_ip, input_port)
	pass # Replace with function body.
