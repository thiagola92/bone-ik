## Abstract base class for all 2D inverse kinematic.
@abstract
@icon("../icons/ik_mod.svg")
class_name IKMod
extends Node2D


enum ExecutionMode {
	PROCESS,
	PHYISIC_PROCESS,
}

## Enable/disable inverse kinematic over bones.[br]
## [br]
## When enabled, bones will [b]not[/b] save changes and will have the transform restore when disabled
## or the scene is saved.[br]
## [br]
## [b]Note[/b]: Moving bones that are children from bones affected by inverse kinematic
## can bring unexpected behaviors, this happens because bones may use a child bone to
## calculate their length and angle.
@export var enabled: bool = false:
	set(e):
		enabled = e
		update_configuration_warnings()
		
		if not enabled:
			_undo_modifications()

@export var execution_mode: ExecutionMode = ExecutionMode.PROCESS:
	set(e):
		execution_mode = e
		set_process(e == ExecutionMode.PROCESS)
		set_physics_process(e == ExecutionMode.PHYISIC_PROCESS)


func _ready() -> void:
	tree_exiting.connect(_undo_modifications)
	execution_mode = execution_mode


func _process(delta: float) -> void:
	_apply_modifications(delta)
	
	# Lock transform, this way we can draw lines/arcs without the user interfere.
	global_transform = Transform2D.IDENTITY


func _physics_process(delta: float) -> void:
	_apply_modifications(delta)
	
	# Lock transform, this way we can draw lines/arcs without the user interfere.
	global_transform = Transform2D.IDENTITY


func _get_configuration_warnings() -> PackedStringArray:
	if not enabled:
		return ["""Inverse Kinematic is disabled.
		When disabled, modifications to bone transformers are saved. Remember to disable when modificaitons are needed."""]
	
	return []


@abstract
func _undo_modifications() -> void


@abstract
func _apply_modifications(_delta: float) -> void


func _clamp_angle(angle: float, min_bound: float, max_bound: float, invert: bool) -> float:
	# Wrap around 0 and 360 degrees.
	min_bound = fposmod(min_bound, TAU)
	max_bound = fposmod(max_bound, TAU)
	angle = fposmod(angle, TAU)
	
	# Make sure that is in the right order.
	if max_bound < min_bound:
		var temporary = max_bound
		max_bound = min_bound
		min_bound = temporary
	
	# Easiest case, angle is within bounds.
	if (angle <= max_bound and angle >= min_bound) and not invert:
		return angle
	
	# Second easiest case, angle is beyond bounds but invert is true.
	if (angle > max_bound or angle < min_bound) and invert:
		return angle
	
	# Difference between angles to know each is closer.
	var min_diff = abs(angle_difference(angle, min_bound))
	var max_diff = abs(angle_difference(angle, max_bound))
	
	if min_diff < max_diff:
		return min_bound
	return max_bound


func _draw_angle_constraints(
	main_bone: BoneIK,
	min_bound: float,
	max_bound: float,
	constraint_enabled: bool,
	localspace: bool,
	inverted: bool,
) -> void:
	if not main_bone:
		return
	
	if not EditorInterface.has_method("get_editor_settings"):
		queue_redraw()
		return
	
	# Wrap around 0 and 360 degrees.
	min_bound = fposmod(min_bound, TAU)
	max_bound = fposmod(max_bound, TAU)
	
	# Make sure that is in the right order.
	if max_bound < min_bound:
		var temporary = max_bound
		max_bound = min_bound
		min_bound = temporary
	
	min_bound += main_bone.get_bone_angle()
	max_bound += main_bone.get_bone_angle()
	
	var editor_settings = EditorInterface.get_editor_settings()
	var bone_ik_color: Color = editor_settings.get_setting("editors/2d/bone_ik_color")
	
	# Easiest case, constraint disabled means a complete arc at the bone.
	if not constraint_enabled:
		draw_set_transform(main_bone.global_position, 0, main_bone.global_scale)
		draw_line(Vector2.ZERO, Vector2(main_bone.get_bone_length(), 0), bone_ik_color, 1.0)
		draw_arc(Vector2.ZERO, main_bone.get_bone_length(), 0, TAU, 32, bone_ik_color, 1.0)
		return
	
	var parent: Node = main_bone.get_parent()
	
	if localspace and parent:
		# Include the parent global angle to know how would be locally.
		draw_set_transform(
			main_bone.global_position,
			parent.global_rotation,
			main_bone.global_scale
		)
	else:
		draw_set_transform(
			main_bone.global_position,
			0,
			main_bone.global_scale
		)
	
	if inverted:
		# The arc is draw in clockwise direction from the lowest to highest value.
		#	min=90º max=180º => will draw from 90º to 180º in clockwise direction.
		# Adding 360º to the min will maintain the direction of the min but change the start value.
		#	min=450º max=180º => will draw from 180º to 450º in clockwise direction.
		draw_arc(
			Vector2.ZERO, main_bone.get_bone_length(),
			min_bound + TAU, max_bound, 32, bone_ik_color, 1.0
		)
	else:
		draw_arc(
			Vector2.ZERO, main_bone.get_bone_length(),
			min_bound, max_bound, 32, bone_ik_color, 1.0
		)

	draw_line(
		Vector2.ZERO,
		Vector2(cos(min_bound), sin(min_bound)) * main_bone.get_bone_length(),
		bone_ik_color, 1.0
	)
	
	draw_line(
		Vector2.ZERO,
		Vector2(cos(max_bound), sin(max_bound)) * main_bone.get_bone_length(),
		bone_ik_color, 1.0
	)
