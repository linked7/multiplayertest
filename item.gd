extends RigidBody3D

class_name Item

@export var item_scene : PackedScene

@export var itemID: String
@export var itemName: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func on_use( ply ):
	#ply.inventory_add_item(self.itemID)
	queue_free()
