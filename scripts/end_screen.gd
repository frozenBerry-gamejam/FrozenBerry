extends Control

@onready var message_label: Label = $CenterContainer/VBoxContainer/MessageLabel
@onready var subtitle_label: Label = $CenterContainer/VBoxContainer/SubtitleLabel

func _ready() -> void:
	# Mesajı tek seferde set et (overwriting bug fixed)
	message_label.text = "I can finally go back to how things\nwere before the 'light bulb'."
	subtitle_label.text = "- The End -"

	# Fade-in efekti
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 2.0)

	print("╔════════════════════════════════════╗")
	print("║         OYUN BİTTİ!               ║")
	print("╚════════════════════════════════════╝")

func _input(event: InputEvent) -> void:
	# Herhangi bir tuşa basınca ana menüye dön
	if event is InputEventKey or event is InputEventMouseButton:
		if event.pressed:
			get_tree().change_scene_to_file("res://scene/title_screen.tscn")