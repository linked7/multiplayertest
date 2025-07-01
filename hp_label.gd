extends ProgressBar

var PlyFuncs: Node
var character: Node
var last_hp := 0

func _ready():
	PlyFuncs = get_node("/root/Main/PlayerFuncs")
	SignalBus.attack_clicked.connect(self._hide_hp_label)
	
func _process(_delta: float) -> void:
	if multiplayer.is_server(): return
	if not character:
		character = PlyFuncs.get_char_from_id(multiplayer.get_unique_id())
		get_parent().show()
		return
		
	if last_hp != character.hp:
		value = character.hp
		last_hp = character.hp
		show()


func _hide_hp_label():
	hide()
