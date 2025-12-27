extends CharacterBody2D

const SPEED = 170.0
const JUMP_VELOCITY = -250.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea

var is_attacking = false
var combo_queued = false

func _ready():
	attack_area.monitoring = false
	print("Character ready! AttackArea monitoring: ", attack_area.monitoring)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("attack") and is_on_floor():
		if not is_attacking:
			perform_attack()
		else:
			combo_queued = true
	
	var direction := Input.get_axis("move_left", "move_right")
	
	if not is_attacking:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 2)
	
	move_and_slide()
	
	if not is_attacking:
		update_animation(direction)

func perform_attack() -> void:
	is_attacking = true
	combo_queued = false
	animated_sprite.play("light_attack_1")
	print("ATTACK: Saldırı başladı - light_attack_1")

func update_animation(direction: float) -> void:
	if not is_on_floor():
		animated_sprite.play("jump")
	elif direction != 0:
		animated_sprite.play("run")
		animated_sprite.flip_h = direction < 0
	else:
		animated_sprite.play("idle")

func _on_animated_sprite_2d_frame_changed() -> void:
	var current_anim = animated_sprite.animation
	var current_frame = animated_sprite.frame
	
	print("FRAME_CHANGED: Anim=", current_anim, " Frame=", current_frame)
	
	if current_anim == "light_attack_1" and current_frame == 2:
		activate_attack()
	elif current_anim == "light_attack_2" and current_frame == 2:
		activate_attack()
	else:
		deactivate_attack()

func activate_attack() -> void:
	attack_area.monitoring = true
	print("ATTACK_AREA: Aktif edildi!")

func deactivate_attack() -> void:
	if attack_area.monitoring:
		print("ATTACK_AREA: Kapatıldı")
	attack_area.monitoring = false

func _on_animated_sprite_2d_animation_finished() -> void:
	var anim_name = animated_sprite.animation
	print("ANIMATION_FINISHED: ", anim_name)
	
	deactivate_attack()
	
	if anim_name == "light_attack_1":
		if combo_queued:
			animated_sprite.play("light_attack_2")
			combo_queued = false
		else:
			animated_sprite.play("light_attack1.2")
	elif anim_name == "light_attack1.2":
		is_attacking = false
	elif anim_name == "light_attack_2":
		is_attacking = false

func _on_attack_area_body_entered(body):
	print("COLLISION: Body entered - ", body.name, " | Has take_damage: ", body.has_method("take_damage"))
	if body.has_method("take_damage"):
		body.take_damage(10)
		print("HASAR VERİLDİ: ", body.name)
	else:
		print("UYARI: ", body.name, " take_damage metoduna sahip değil!")
