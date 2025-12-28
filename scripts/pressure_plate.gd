extends Node2D

@export var target_platform: AnimatableBody2D # The moving platform to control
@onready var sprite = $Sprite2D

# To detect when something is on the plate
func _on_area_2d_body_entered(body):
	if body.name == "Character" or body.is_in_group("Player"): # Check if it's the player
		if target_platform and target_platform.has_method("activate"):
			target_platform.activate()
			sprite.modulate = Color(0.5, 1.0, 0.5) # Turn green to show active
			# Visual feedback: push down slightly
			sprite.position.y += 2

func _on_area_2d_body_exited(body):
	if body.name == "Character" or body.is_in_group("Player"):
		if target_platform and target_platform.has_method("deactivate"):
			target_platform.deactivate()
			sprite.modulate = Color(1.0, 1.0, 1.0) # Reset color
			# Visual feedback: pop back up
			sprite.position.y -= 2
