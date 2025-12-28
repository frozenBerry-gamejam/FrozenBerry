extends AnimatableBody2D

@export var hover_distance: float = 0.0 # 0 ise sabit durur, değer verilirse o kadar yukarı/aşağı oynar
@export var hover_speed: float = 2.0

var time: float = 0.0
var initial_pos: Vector2

func _ready() -> void:
	initial_pos = global_position
	add_to_group("platforms")

func _physics_process(delta: float) -> void:
	if hover_distance > 0:
		time += delta
		var offset = sin(time * hover_speed) * hover_distance
		global_position.y = initial_pos.y + offset
