extends Node

# ═══════════════════════════════════════════════════════════
# GAME MANAGER - Oyun Durumu Yöneticisi
# ═══════════════════════════════════════════════════════════
# Player öldüğünde:
#   1. Player death_flag=true döndürür
#   2. Enemy saldırı animasyonu bitene kadar bekler
#   3. Player ölüm animasyonu bitene kadar bekler
#   4. 1 saniye bekler
#   5. "GAME OVER" gösterir ve oyunu dondurur
# ═══════════════════════════════════════════════════════════

var player: CharacterBody2D = null
var is_game_over: bool = false
var player_death_anim_finished: bool = false
var enemy_attack_anim_finished: bool = false

func _ready() -> void:
	print("╔═══════════════════════════════════════╗")
	print("║   GAME MANAGER BAŞLATILIYOR         ║")
	print("╚═══════════════════════════════════════╝")
	
	# Player'ı bul
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		print("  ✓ Player bulundu:", player.name)
		# Player'ın health component'ini dinle
		if player.has_node("HealthComponent"):
			var health_comp = player.get_node("HealthComponent")
			if not health_comp.died.is_connected(_on_player_died):
				health_comp.died.connect(_on_player_died)
				print("  ✓ Player death sinyali bağlandı")
	else:
		print("  ✗ Player bulunamadı!")

func _on_player_died() -> void:
	if is_game_over:
		return
	
	print("╔═══════════════════════════════════════╗")
	print("║   GAME MANAGER: Player öldü!        ║")
	print("╚═══════════════════════════════════════╝")
	
	is_game_over = true
	
	# Player'dan death_flag al
	if player and player.has_method("get_death_flag"):
		var death_flag = player.get_death_flag()
		print("  ✓ Player death_flag:", death_flag)
		
		if not death_flag:
			print("  ✗ Death flag false, game over iptal")
			return
	
	# Animasyonların bitmesini bekle
	print("  ⏳ Animasyonlar bekleniyor...")
	await _wait_for_animations()
	
	# 1 saniye bekle
	print("  ⏳ 1 saniye bekleniyor...")
	await get_tree().create_timer(1.0).timeout
	
	# Game Over göster
	show_game_over()

func _wait_for_animations() -> void:
	# Player ve enemy animasyonlarını izle
	var player_done = false
	var enemy_done = false
	
	# Player animasyonunu bekle
	if player and player.has_node("AnimatedSprite2D"):
		var player_sprite = player.get_node("AnimatedSprite2D")
		if player_sprite.animation == "die":
			print("    → Player die animasyonu bekleniyor...")
			await player_sprite.animation_finished
			print("    ✓ Player die animasyonu bitti")
			player_done = true
	
	# Enemy'leri bul ve saldırı animasyonlarını bekle
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_node("AnimatedSprite2D"):
			var enemy_sprite = enemy.get_node("AnimatedSprite2D")
			if enemy_sprite.animation == "enemy_attack":
				print("    → Enemy attack animasyonu bekleniyor...")
				await enemy_sprite.animation_finished
				print("    ✓ Enemy attack animasyonu bitti")
				enemy_done = true
	
	print("  ✓ Tüm animasyonlar tamamlandı")

func show_game_over() -> void:
	print("╔═══════════════════════════════════════╗")
	print("║                                       ║")
	print("║          G A M E   O V E R            ║")
	print("║                                       ║")
	print("╚═══════════════════════════════════════╝")
	
	# Oyunu dondur
	get_tree().paused = true
	print("  ✓ Oyun donduruldu")
	
	# TODO: Burada UI ile "GAME OVER" text'i ekrana basılacak
	# Örnek:
	# var game_over_label = Label.new()
	# game_over_label.text = "GAME OVER"
	# add_child(game_over_label)
