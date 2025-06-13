extends Node

var peer: ENetMultiplayerPeer
var host_gets_player := true  # toggleable if needed

var input_ip
var input_port

signal server_started
signal client_connected

func create_server(port: int = 22223, dedicated = false):
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	print("Server started on port %d" % port)
	server_started.emit()

func join_server(ip: String, port: int = 22223):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	print("Joining server at %s:%d" % [ip, port])
	client_connected.emit()

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
