extends Node

@onready var main: String = ""

func _ready():
	main = str(get_parent().get_path())

func get_ply_from_id(id: int) -> Node:
	if !main: return null
	var ply: Node = get_node_or_null( main + "/Players/ply_" + str(id) )
	return ply

func get_char_from_id(id: int) -> Node:
	if !main: return null
	var character: Node = get_node_or_null( main + "/Players/char_" + str(id) )
	return character
	# TODO: make characters not depend on their name (so they can have their player swapped etc)
