@tool
extends Node2D


func _process(_delta: float) -> void:
	var on_the_left: bool = $Target.global_position.x < $BoneIK.global_position.x
	
	if on_the_left:
		scale.x = -1
	else:
		scale.x = 1
