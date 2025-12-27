extends CharacterBody2D

const SPEED = 170.0
const JUMP_VELOCITY = -250.0

@onready var animated_sprite = $AnimatedSprite2D

var is_attacking = false
var combo_queued = false  # E tuşu spam için

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Saldırı kontrolü (E tuşu)
	if Input.is_action_just_pressed("attack") and is_on_floor():
		if not is_attacking:
			# İlk saldırı
			perform_attack()
		else:
			# Saldırı sırasında basıldı, combo için kaydet
			combo_queued = true
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	
	# Saldırı sırasında hareket etme
	if not is_attacking:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 2)
	
	move_and_slide()
	
	# Animasyon kontrolü
	if not is_attacking:
		update_animation(direction)

func perform_attack() -> void:
	is_attacking = true
	combo_queued = false
	animated_sprite.play("light_attack_1")

func update_animation(direction: float) -> void:
	# Havadaysa jump animasyonu
	if not is_on_floor():
		animated_sprite.play("jump")
	# Hareket ediyorsa run animasyonu
	elif direction != 0:
		animated_sprite.play("run")
		animated_sprite.flip_h = direction < 0
	# Duruyorsa idle animasyonu
	else:
		animated_sprite.play("idle")

func _on_animated_sprite_2d_animation_finished() -> void:
	var anim_name = animated_sprite.animation
	
	if anim_name == "light_attack_1":
		# Eğer spam yapıldıysa combo yap
		if combo_queued:
			animated_sprite.play("light_attack_2")
			combo_queued = false
		else:
			# Tek basım, finisher oyna
			animated_sprite.play("light_attack1.2")
	
	elif anim_name == "light_attack1.2":
		# Finisher bitti
		is_attacking = false
	
	elif anim_name == "light_attack_2":
		# Combo bitti
		is_attacking = false
