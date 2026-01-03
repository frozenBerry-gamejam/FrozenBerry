extends Area2D
class_name Collectable

# ═══════════════════════════════════════════════════════════
# COLLECTABLE - Toplanabilir Enerji Kristali
# ═══════════════════════════════════════════════════════════
# Player temas ettiğinde rewind enerjisini artırır.
# %20 enerji verir (max_energy'nin %20'si)
# ═══════════════════════════════════════════════════════════

signal collected(collector: Node2D)

# Ayarlar
@export var energy_restore_percentage: float = 20.0  # %20 enerji verir
@export var auto_destroy: bool = true  # Toplandıktan sonra otomatik yok ol
@export var collect_sound: AudioStream = null  # Toplama sesi (opsiyonel)
@export var collect_effect_scene: PackedScene = null  # Efekt (opsiyonel, partiküller vs.)

# State
var is_collected: bool = false

func _ready() -> void:
	# Body entered sinyalini bağla
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	# Collision setup
	collision_layer = 8  # Layer 4 (2^3 = 8)
	collision_mask = 1   # Player layer (1)

	# Load default collect sound if none is set
	if collect_sound == null:
		collect_sound = load("res://audio/ui/collect.wav")
		print("  ✓ Default collect sound loaded")

	print("✓ Collectable hazır: ", name)

func _on_body_entered(body: Node2D) -> void:
	# Zaten toplandıysa ignore
	if is_collected:
		return

	# Player mı kontrol et
	if not (body.is_in_group("player") or body.name == "Character"):
		return

	print("╔═══════════════════════════════════════╗")
	print("║   COLLECTABLE TOPLANDI!             ║")
	print("╚═══════════════════════════════════════╝")

	# Player'ın RewindEnergyComponent'ini bul
	var energy_component: RewindEnergyComponent = null
	if body.has_node("RewindEnergyComponent"):
		energy_component = body.get_node("RewindEnergyComponent")
	else:
		print("  ✗ Player'da RewindEnergyComponent yok!")
		return

	# Enerji artışını hesapla (%20 of max_energy)
	var energy_amount = energy_component.max_energy * (energy_restore_percentage / 100.0)
	var old_energy = energy_component.current_energy

	# Enerjiyi artır
	energy_component.add_energy(energy_amount)

	var new_energy = energy_component.current_energy
	var actual_gain = new_energy - old_energy

	print("  ✓ Enerji artırıldı: +", actual_gain, "s")
	print("  ► Yeni enerji: ", new_energy, "/", energy_component.max_energy, "s")

	# Sinyal gönder
	collected.emit(body)

	# Toplama efekti (ses, partiküller vs.)
	play_collect_effect()

	# Yok et
	is_collected = true
	if auto_destroy:
		# Görsel olarak hemen yok et ama sinyal ve efekt için biraz bekle
		visible = false
		set_deferred("monitoring", false)  # Deferred kullan (sinyal içinde olduğumuz için)

		# Efekt bitene kadar bekle (veya kısa bir süre)
		await get_tree().create_timer(0.1).timeout
		queue_free()
		print("  ✓ Collectable silindi")

# Toplama efekti (ses, partiküller)
func play_collect_effect() -> void:
	# Ses çal
	if collect_sound:
		var audio_player = AudioStreamPlayer2D.new()
		audio_player.stream = collect_sound
		audio_player.autoplay = true
		get_parent().add_child(audio_player)
		audio_player.finished.connect(audio_player.queue_free)

	# Efekt spawn et
	if collect_effect_scene:
		var effect = collect_effect_scene.instantiate()
		effect.global_position = global_position
		get_parent().add_child(effect)
		print("  ✓ Toplama efekti oynatıldı")
