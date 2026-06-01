@tool
class_name ShapeGizmo
extends Node2D


@export var inner_color: Color = Color.WEB_GRAY:
	set(c):
		inner_color = c
		_refresh_color()

@export var inner_width: float = 5.0:
	set(w):
		inner_width = w
		_refresh_shape()

@export var outline_color: Color = Color.DIM_GRAY:
	set(c):
		outline_color = c
		_refresh_color()

@export var outline_width: float = 2.0:
	set(w):
		outline_width = w
		_refresh_shape()

@export var modified_color: Color = Color.DARK_KHAKI:
	set(c):
		modified_color = c
		_refresh_color()

@export var selected_color: Color = Color.CORAL:
	set(c):
		selected_color = c
		_refresh_color()

var _cached_modified: bool = false

var _cached_selected: bool = false

var _cached_target: Vector2 = Vector2(16, 0)

var _inner_shape := Polygon2D.new()

var _outline_shape := Polygon2D.new()


func _init() -> void:
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	_outline_shape.modulate.a = 0.5
	_inner_shape.modulate.a = 0.5
	
	# Order matter.
	add_child(_outline_shape, false, Node.INTERNAL_MODE_BACK)
	add_child(_inner_shape, false, Node.INTERNAL_MODE_BACK)
	
	_refresh_shape()
	_refresh_color()


## Update diamond shape by putting the point of the diamond at [param target] (global position).
func update_shape(target: Vector2) -> void:
	var direction = to_local(target)
	var normal = direction.rotated(PI/2).normalized() * inner_width
	
	_inner_shape.polygon = [
		Vector2.ZERO,
		direction * 0.2 + normal,
		direction,
		direction * 0.2 - normal
	]
	
	var direction_n = direction.normalized()
	var normal_n = normal.normalized()
	
	_outline_shape.polygon = [
		(-direction_n - normal_n) * outline_width,
		(-direction_n + normal_n) * outline_width,
		(direction * 0.2 + normal) + normal_n * outline_width,
		direction + (direction_n + normal_n) * outline_width,
		direction + (direction_n - normal_n) * outline_width,
		(direction * 0.2 - normal) - normal_n * outline_width,
	]
	
	# Prevent recursion.
	if target != _cached_target:
		_cached_target = target


## Update diamond color depending on conditions (is being [param modified], is [param selected]).
func update_color(modified: bool, selected: bool) -> void:
	var color: Color = modified_color if modified else inner_color
	
	_inner_shape.vertex_colors = [
		color,
		color,
		color,
		color.lightened(0.5),
	]
	
	color = selected_color if selected else outline_color
	
	_outline_shape.vertex_colors = [
		color,
		color,
		color,
		color,
		color,
		color,
	]
	
	# Prevent recursion.
	if modified != _cached_modified:
		_cached_modified = modified
	
	# Prevent recursion.
	if selected != _cached_selected:
		_cached_selected = selected


func _refresh_shape() -> void:
	update_shape(_cached_target)


func _refresh_color() -> void:
	update_color(_cached_modified, _cached_selected)
