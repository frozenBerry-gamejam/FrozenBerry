# Sınıf başına ekle
var is_attacking = false

func _physics_process(delta: float) -> void:
	# Diğer kodlar...
	
	# Attack kontrolü ekle
	if Input.is_action_just_pressed("ui_select") and is_on_floor() and not is_attacking:
		is_attacking = true
		animated_sprite.play("light_attack")
	
	# Animasyon kontrolü
	if not is_attacking:
		update_animation(direction)

# AnimatedSprite2D'ye bağla (Inspector'da veya kod ile)
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "light_attack":
		is_attacking = false
