extends Node

var peer = ENetMultiplayerPeer.new()

var input_ip
var input_port
const MAX_CONNECTIONS = 20

func _ready():
	pass

# NETWORKING CALLS
func create_server(port: int = 22223):
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port, MAX_CONNECTIONS)
	multiplayer.multiplayer_peer = peer
	var _peer_id = peer.get_unique_id()
	multiplayer.peer_connected.connect($"..".spawn_player)

	print("Server started on port %d" % port)
	get_parent().is_server_ready = true

func join_server(ip: String, port: int = 22223):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	print("Joining server at %s:%d" % [ip, port])
	
# UI ELEMENTS
func _on_host_server_pressed() -> void:
	input_port = $"../MainMenu/Sprite2D/InputPort".text.to_int()
	create_server(input_port)
	$"../MainMenu".hide()

func _on_connect_pressed() -> void:
	input_ip = $"../MainMenu/Sprite2D/InputIP".text
	input_port = $"../MainMenu/Sprite2D/InputPort".text.to_int()
	join_server(input_ip, input_port)
	$"../MainMenu".hide()
