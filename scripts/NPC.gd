extends Node3D

@onready var sprite = $Sprite3D
@export var start_direction = "front" # Можно менять в инспекторе (front, back, left, right)

# ЗДЕСЬ ВРЕМЯ АНИМАЦИИ (для NPC это просто скорость смены кадров, 
# обычно настраивается в самом SpriteFrames, но для галочки оставляю)
const TIME_IDLE = 0.5 

func _ready():
	# Запускаем анимацию и она будет крутиться по кругу
	sprite.play("idle_" + start_direction)
