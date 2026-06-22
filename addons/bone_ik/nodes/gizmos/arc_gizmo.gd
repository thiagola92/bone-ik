@tool
class_name ArcGizmo
extends GizmoIK


@export var color: Color = Color.DARK_KHAKI:
	set(c):
		color = c
		queue_redraw()

@export var inverted: bool = false:
	set(i):
		inverted = i
		queue_redraw()

@export_range(0, 360, 0.01, "degrees") var start: float = 0:
	set(b):
		# Wrap around 0 and 360 degrees.
		start = fposmod(b, 360) if b != 360 else 360
		
		# Make sure that is the min bound.
		if start > end:
			var temporary = start
			start = end
			end = temporary
		
		queue_redraw()

@export_range(0, 360, 0.01, "degrees") var end: float = 360:
	set(b):
		# Wrap around 0 and 360 degrees.
		end = fposmod(b, 360) if b != 360 else 360
		
		# Make sure that is the max bound.
		if end < start:
			var temporary = end
			end = start
			start = temporary
		
		queue_redraw()

@export var radius: float = 16:
	set(r):
		radius = r
		queue_redraw()

@export var width: float = -1.0:
	set(w):
		width = w
		queue_redraw()


func _draw() -> void:
	var start_angle: float = deg_to_rad(start)
	var end_angle: float = deg_to_rad(end)
	
	# The arc is draw from the smallest angle to the biggest angle,
	# so to invert we just have to make the start_angle the biggest
	# without changing the location.
	if inverted:
		start_angle += TAU
	
	# The arc operates in clockwise direction instead of counter-clockwise. This means that:
	# - 90º will be at Vector2.DOWN (instead of Vector2.UP)
	# - 270º will be at Vector2.UP (instead of Vector2.DOWN)
	# - The angle 0º -> 90º would be 270º -> 360º
	# This probably happens because in screens axis Y is down.
	draw_arc(Vector2.ZERO, radius, start_angle, end_angle, 32, color, width)
