@tool
class_name LineGizmo
extends GizmoIK


@export var color: Color = Color.DARK_KHAKI:
	set(c):
		color = c
		queue_redraw()

@export var length: float = 16:
	set(l):
		length = l
		queue_redraw()

@export var width: float = -1.0:
	set(w):
		width = w
		queue_redraw()


func _draw() -> void:
	# If we need to point to a different location, we rotate the node itself.
	draw_line(Vector2.ZERO, Vector2.RIGHT * length, color, width)
