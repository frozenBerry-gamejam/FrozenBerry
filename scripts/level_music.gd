extends Node

# Bu script level scene'lerine eklenir ve müziği çalar

var music_player: AudioStreamPlayer

func _ready():
	print("╔═══════════════════════════════════════╗")
	print("║   LEVEL MUSIC BAŞLATILIYOR          ║")
	print("╚═══════════════════════════════════════╝")

	# Müzik player'ı oluştur
	music_player = AudioStreamPlayer.new()
	music_player.stream = load("res://audio/music/gameplay.wav")
	music_player.volume_db = -10.0
	music_player.bus = "Master"
	add_child(music_player)

	# Müziği çal
	music_player.play()
	print("✓ Frozen Hearts çalıyor (Level Music - WAV)")
	print("  Volume: ", music_player.volume_db, " dB")
	print("  Playing: ", music_player.playing)
