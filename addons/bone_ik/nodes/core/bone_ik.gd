@tool
class_name BoneIK
extends Node2D


var modified: bool = false:
	set(m):
		modified = m
		update_configuration_warnings()

# Default value is important because gives you a cache at scene start.
var _cached_pose: Transform2D = transform

var _diamond_gizmo := DiamondGizmo.new()


func _init() -> void:
	add_child(_diamond_gizmo, false, Node.INTERNAL_MODE_BACK)


func _get_configuration_warnings() -> PackedStringArray:
	if modified:
		return [
			"""This bone is being target by an inverseke kinemtic, \
			so any modifications to it transform will be reverted \
			once stop being target.
			"""
		]
	
	return []


## Cache the current pose so the bone can be reverted later.
## [br][br]
## Passing [param modify] as [code]true[/code] will set [member modified] to [code]true[/code].
## Useful if you already had intent to modify it pose.
func cache_pose(modify: bool = false) -> void:
	# Do not cache a modified pose.
	if modified:
		return
	
	_cached_pose = transform
	modified = modify


func restore_pose() -> void:
	transform = _cached_pose
	modified = false
