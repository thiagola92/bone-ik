@tool
@icon("res://icon.svg")
class_name BoneShapeIK2D
extends Polygon2D


func _init() -> void:
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX
