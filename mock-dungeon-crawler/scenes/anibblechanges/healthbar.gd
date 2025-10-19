extends CanvasLayer

@onready var damage_bar = $DamageBar
@onready var rigid_body_3d: Player = $".."

func _ready() -> void:
	rigid_body_3d.health_changed.connect(_on_value_changed)
	
func _on_value_changed(value: float) -> void:
	print("nigga balls")
	damage_bar.value = value
