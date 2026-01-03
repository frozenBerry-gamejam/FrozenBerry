extends Node

# Tüm seviyelerin sırası
const LEVELS = [
	"res://scene/level1Big.tscn",
	"res://scene/level2_beta.tscn"
]

# End screen yolu
const END_SCENE_PATH = "res://scene/end_screen.tscn"

# Mevcut seviye index'i
var current_level_index: int = 0

func _ready() -> void:
	print("✓ LevelManager hazır")

# Oyunu başlat (ilk seviyeye git)
func start_game() -> void:
	current_level_index = 0
	load_current_level()

# Mevcut seviyeyi yükle
func load_current_level() -> void:
	if current_level_index < LEVELS.size():
		print("Seviye yükleniyor: ", LEVELS[current_level_index])
		get_tree().change_scene_to_file(LEVELS[current_level_index])
	else:
		print("Hata: Geçersiz seviye index'i!")

# Bir sonraki seviyeye geç
func next_level() -> void:
	current_level_index += 1

	if is_last_level_completed():
		# Son seviye bitti, end screen'e git
		print("╔════════════════════════════════════╗")
		print("║   TÜM SEVİYELER TAMAMLANDI!       ║")
		print("╚════════════════════════════════════╝")
		get_tree().change_scene_to_file(END_SCENE_PATH)
	else:
		# Bir sonraki seviyeye git
		print("Sonraki seviyeye geçiliyor...")
		load_current_level()

# Son seviye tamamlandı mı?
func is_last_level_completed() -> bool:
	return current_level_index >= LEVELS.size()

# Belirli bir seviyeye git
func load_level(level_index: int) -> void:
	if level_index >= 0 and level_index < LEVELS.size():
		current_level_index = level_index
		load_current_level()
	else:
		print("Hata: Geçersiz seviye index'i: ", level_index)

# Mevcut seviye numarasını al (1'den başlar)
func get_current_level_number() -> int:
	return current_level_index + 1

# Toplam seviye sayısı
func get_total_levels() -> int:
	return LEVELS.size()
