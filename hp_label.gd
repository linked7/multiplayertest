extends Label

var ply: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ply_id = multiplayer.get_unique_id()
	ply = get_node_or_null("/root/Main/Players/" + str(ply_id))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if ply != null:
		text = str(ply.hp)
