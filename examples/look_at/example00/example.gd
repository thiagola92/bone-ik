@tool
extends Node2D


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		$Target.global_position = get_global_mouse_position()
	
	var on_the_left: bool = $Target.global_position.x < $Player/BoneIK.global_position.x
	
	if on_the_left:
		$Player.scale.x = -1
	else:
		$Player.scale.x = 1
