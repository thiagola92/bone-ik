@tool
@abstract
class_name ModifierIK
extends Node2D
## Abstract base class for all IK modifiers.


@export var enabled: bool = true:
	set(e):
		enabled = e
		
		set_process(enabled)
		
		if not enabled:
			_undo_modification()


func _process(_delta: float) -> void:
	_process_modification()


@abstract func _process_modification() -> void


@abstract func _undo_modification() -> void
