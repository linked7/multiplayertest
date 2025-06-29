extends RigidBody3D

class_name Item

@export var item_scene : PackedScene

@export var itemID: String
@export var itemName: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite.texture = load("res://assets/apple.png")
	#print("Item ready:", name, " - ", get_path())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func on_use( character: Node ):
	character.heal(20)
	
	
	queue_free()
