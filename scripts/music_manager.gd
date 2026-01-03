extends Node

# ═══════════════════════════════════════════════════════════
# MUSIC MANAGER - Oyun Müziği Yöneticisi
# ═══════════════════════════════════════════════════════════

var music_player: AudioStreamPlayer
var current_track: String = ""
var last_scene_path: String = ""

func _ready() -> void:
	print("╔═══════════════════════════════════════╗")
	print("║   MUSIC MANAGER BAŞLATILIYOR        ║")
	print("╚═══════════════════════════════════════╝")

	# Pause'da bile çalış
	process_mode = PROCESS_MODE_ALWAYS

	# Music player oluştur
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)
	print("  ✓ Music player hazır")

	# Scene değişikliklerini dinle
	get_tree().node_added.connect(_on_scene_changed)

	# İlk sahneyi HEMEN kontrol et (bekleme yok!)
	call_deferred("check_and_play_music")
	print("  ► İlk müzik kontrolü başlatıldı")

func _process(_delta: float) -> void:
	# Her frame scene kontrolü yap (scene değişimi için yedek sistem)
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.scene_file_path != last_scene_path:
		last_scene_path = current_scene.scene_file_path
		print("  ⚡ Scene değişti (process): ", last_scene_path)
		check_and_play_music()

func _on_scene_changed(node: Node) -> void:
	# Eğer root node eklendiyse (yeni scene yüklendi)
	if node == get_tree().current_scene:
		check_and_play_music()

func check_and_play_music() -> void:
	var current_scene = get_tree().current_scene
	if not current_scene:
		print("  ✗ Current scene yok! Tree root:", get_tree().root)
		# Root'dan ilk child'ı al (genelde main scene)
		if get_tree().root.get_child_count() > 0:
			current_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
			print("  ► Root'dan scene alındı: ", current_scene)
		else:
			return

	var scene_name = current_scene.name.to_lower()
	var scene_file = current_scene.scene_file_path.to_lower() if current_scene.scene_file_path else ""

	print("  ► Scene Name: ", scene_name)
	print("  ► Scene File: ", scene_file)

	# Hangi müziği çalacağını belirle
	var track_to_play = ""

	# Title/Menu detection (hem name hem de file path'i kontrol et)
	if ("title" in scene_name or "menu" in scene_name or "main" in scene_name or
		"title" in scene_file or "menu" in scene_file or "main" in scene_file):
		track_to_play = "title_screen"  # Dosya adı: title_screen.wav
		print("  → Title/Menu/Main tespit edildi")
	# Death detection
	elif "death" in scene_name or "death" in scene_file:
		track_to_play = "death"  # Dosya adı: death.wav
		print("  → Death tespit edildi")
	# Level detection
	elif "level" in scene_name or "beta" in scene_name or "level" in scene_file:
		track_to_play = "gameplay"  # Dosya adı: gameplay.wav
		print("  → Level tespit edildi")
	else:
		print("  ⚠ Hiçbir müzik tespit edilemedi!")

	# Eğer farklı bir track çalacaksa değiştir
	if track_to_play != "" and track_to_play != current_track:
		play_music(track_to_play)
	elif track_to_play == current_track:
		print("  ► Aynı müzik zaten çalıyor: ", current_track)

func play_music(track_name: String) -> void:
	var music_path = "res://audio/music/" + track_name + ".wav"
	print("  ► Müzik yükleniyor: ", music_path)

	var stream = load(music_path)
	if stream:
		# Önceki müziği durdur
		if music_player.playing:
			music_player.stop()

		# Yeni müziği yükle ve çal
		music_player.stream = stream
		music_player.volume_db = -16.0
		music_player.play()

		current_track = track_name
		print("✓ Müzik çalıyor: ", track_name, ".wav")
		print("  Volume: ", music_player.volume_db, " dB")
		print("  Playing: ", music_player.playing)
	else:
		print("  ✗ HATA: Müzik yüklenemedi - ", music_path)

func stop_music() -> void:
	if music_player.playing:
		music_player.stop()
		current_track = ""
		print("  ► Müzik durduruldu")
