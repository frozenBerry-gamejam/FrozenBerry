extends Node
class_name HurtboxComponent

# Sinyaller
signal damage_received(amount: int)
signal knockback_applied(direction: Vector2)
signal hitstun_started(duration: float)
signal hitstun_ended()

# Export değişkenleri
@export var knockback_force: float = 200.0
@export var knockback_up_force: float = -150.0
@export var hitstun_duration: float = 0.4
@export var can_be_knocked_back: bool = true
@export var health_component_path: NodePath = "../HealthComponent"

# State
var is_in_hitstun: bool = false
var hitstun_timer: float = 0.0

# Referanslar
@onready var health_component: HealthComponent = get_node_or_null(health_component_path)
@onready var entity: CharacterBody2D = get_parent()

func _ready() -> void:
	if health_component:
		print("HurtboxComponent: HealthComponent bağlandı")
	else:
		push_error("HurtboxComponent: HealthComponent bulunamadı! Path: ", health_component_path)

func _process(delta: float) -> void:
	# Hitstun sayacı
	if is_in_hitstun:
		hitstun_timer -= delta
		if hitstun_timer <= 0:
			is_in_hitstun = false
			hitstun_ended.emit()
			print("HurtboxComponent: Hitstun bitti")

func take_damage(amount: int, attacker_position: Vector2 = Vector2.ZERO) -> void:
	# Hitstun'daysa hasar alma
	if is_in_hitstun:
		print("HurtboxComponent: Hitstun'da, hasar ignore")
		return

	# HealthComponent yoksa veya ölüyse hasar alma
	if not health_component or not health_component.is_alive():
		print("HurtboxComponent: Ölü veya HealthComponent yok, hasar ignore")
		return

	# Hasarı HealthComponent'e ilet
	health_component.take_damage(amount)
	damage_received.emit(amount)

	print("HurtboxComponent: %d hasar alındı" % amount)

	# Knockback hesapla
	if can_be_knocked_back:
		var knockback_dir = sign(entity.global_position.x - attacker_position.x)
		if knockback_dir == 0:
			# Attacker position verilmemişse sprite direction'a göre
			if entity.has_node("AnimatedSprite2D"):
				var sprite = entity.get_node("AnimatedSprite2D")
				knockback_dir = -1 if sprite.flip_h else 1
			else:
				knockback_dir = 1

		apply_knockback(knockback_dir, knockback_force, knockback_up_force)

func apply_knockback(direction: float, force: float, up_force: float) -> void:
	if not entity:
		push_error("HurtboxComponent: Entity referansı yok!")
		return

	if not can_be_knocked_back:
		print("HurtboxComponent: Knockback devre dışı")
		return

	# Velocity'yi direkt set et
	entity.velocity.x = direction * force
	entity.velocity.y = up_force

	# Hitstun başlat
	is_in_hitstun = true
	hitstun_timer = hitstun_duration
	hitstun_started.emit(hitstun_duration)

	var knockback_vec = Vector2(direction * force, up_force)
	knockback_applied.emit(knockback_vec)

	print("HurtboxComponent: Knockback uygulandı - vx=%0.1f vy=%0.1f" % [entity.velocity.x, entity.velocity.y])

func get_is_in_hitstun() -> bool:
	return is_in_hitstun
