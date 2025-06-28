extends Label

var PlyFuncs: Node
var character: Node
var last_hp := 0
@onready var progress_bar: ProgressBar = $"../ProgressBar"

# Called when the node enters the scene tree for the first time.

func _ready():
	PlyFuncs = get_node("/root/Main/PlayerFuncs")
	
func _process(_delta: float) -> void:
	if multiplayer.is_server(): return
	if not character:
		character = PlyFuncs.get_char_from_id(multiplayer.get_unique_id())
		get_parent().show()
		return
		
	if last_hp != character.hp:
		text = str(character.hp)
		progress_bar.value = character.hp
