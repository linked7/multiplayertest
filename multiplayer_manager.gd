extends Node

var peer = ENetMultiplayerPeer.new()
@export var dedicated := false  # toggleable if needed

var input_ip
var input_port
const MAX_CONNECTIONS = 20

signal server_started
signal client_connected

func _ready():
	pass
	
# NETWORKING CALLS
func create_server(port: int = 22223, is_dedicated = false):
	dedicated = is_dedicated
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port, MAX_CONNECTIONS)
	multiplayer.multiplayer_peer = peer
	var peer_id = peer.get_unique_id()
	multiplayer.peer_connected.connect($"..".spawn_player)

		
	print("Server started on port %d" % port)
	server_started.emit()

func join_server(ip: String, port: int = 22223):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	print("Joining server at %s:%d" % [ip, port])
	client_connected.emit()

# UI ELEMENTS
func _on_host_player_pressed() -> void:
	input_port = $"../MainMenu/Sprite2D/InputPort".text.to_int()
	create_server(input_port, false)
	$"../MainMenu".hide()

func _on_host_server_pressed() -> void:
	input_port = $"../MainMenu/Sprite2D/InputPort".text.to_int()
	create_server(input_port, true)
	$"../MainMenu".hide()

func _on_connect_pressed() -> void:
	input_ip = $"../MainMenu/Sprite2D/InputIP".text
	input_port = $"../MainMenu/Sprite2D/InputPort".text.to_int()
	join_server(input_ip, input_port)
	$"../MainMenu".hide()
