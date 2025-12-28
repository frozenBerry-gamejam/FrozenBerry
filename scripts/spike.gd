extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Check if it's the player
	if body.name == "Character" or body.is_in_group("player"):
		# Try to find HealthComponent
		var health = body.get_node_or_null("HealthComponent")
		if health:
			health.take_damage(999)
			print("SPIKE: Player touched spike - instant death via HealthComponent!")
		# Instant kill (fallback)
		elif body.has_method("take_damage"):
			# Deal massive damage (instant death)
			body.take_damage(999)
			print("SPIKE: Player touched spike - instant death via method!")
