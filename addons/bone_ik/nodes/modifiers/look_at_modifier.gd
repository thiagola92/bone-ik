@tool
class_name LookAtModifier
extends ModifierIK


## The bone that will receive modifications to look at [member target].[br][br]
# TODO: link gizmo when selecting bone.
@export var bone: BoneIK

## Node which [member bone] will look at.
@export var target: Node2D


func _process_modification() -> void:
	if not bone:
		return
	
	if not target:
		return
	
	# When you delete a node, they still exist inside the UndoRedo
	# but we don't want process anymore.
	if not bone.is_inside_tree():
		return
	
	if not target.is_inside_tree():
		return
	
	bone.cache_pose(true)
	bone.rotate(bone.get_angle_to(target.global_position))


func _undo_modification() -> void:
	if bone:
		bone.restore_pose()
