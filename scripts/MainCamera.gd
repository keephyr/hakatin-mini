extends Camera3D

@export var follow_speed: float = 8.0 # Скорость следования (чем меньше, тем "резиновее" камера)
var target_node: Node3D
var offset: Vector3

func _ready():
	# 1. Запоминаем изначальное расстояние от камеры до игрока (наши Y=5, Z=8)
	offset = position
	
	# 2. Отвязываем камеру от игрока физически, чтобы она жила своей жизнью
	top_level = true 
	
	# 3. Запоминаем, за кем следить (за родителем, то есть за MainCharacter)
	target_node = get_parent()
	
	# Ставим камеру на стартовую позицию
	global_position = target_node.global_position + offset

func _process(delta):
	# Если игрок жив и существует
	if is_instance_valid(target_node):
		# Точка, где камера ДОЛЖНА БЫТЬ прямо сейчас
		var desired_position = target_node.global_position + offset
		
		# Плавное перемещение (lerp) из текущей точки в нужную
		global_position = global_position.lerp(desired_position, delta * follow_speed)
