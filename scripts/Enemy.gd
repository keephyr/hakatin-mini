extends CharacterBody3D

class_name Enemy

@export var SPEED: float = 2.0
@export var AGGRO_RANGE: float = 5.0 # Дистанция реакции на игрока
@export var ATTACK_RANGE: float = 1.0 # Дистанция удара

@onready var sprite = $Sprite3D
var player: CharacterBody3D

var health = 5
var current_dir = "front"
var is_locked = false

# ==========================================
# ЗДЕСЬ МОЖНО ПОМЕНЯТЬ ВРЕМЯ ПРОИГРЫВАНИЯ АНИМАЦИЙ ВРАГА (в секундах)
const TIME_ATTACK = 1.0       # Время атаки
const TIME_TAKE_DAMAGE = 0.05 # Время стана от урона
const TIME_DEATH = 1.0        # Время анимации смерти
# ==========================================

func _ready():
	# Находим игрока на сцене по имени (или используй группы)
	player = get_tree().get_first_node_in_group("Player") 
	# ПРИМЕЧАНИЕ: добавь узел MainCharacter в группу "Player" во вкладке Node

func _physics_process(_delta):
	if is_locked or not is_instance_valid(player):
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= ATTACK_RANGE:
		# Игрок рядом - бьем
		perform_attack()
	elif distance <= AGGRO_RANGE:
		# Игрок в зоне видимости - бежим к нему
		var direction = global_position.direction_to(player.global_position)
		# Враги не умеют летать, обнуляем Y
		direction.y = 0 
		direction = direction.normalized()
		
		velocity = direction * SPEED
		update_direction_string(direction)
		sprite.play("run_" + current_dir)
		move_and_slide()
	else:
		# Игрок далеко - стоим
		sprite.play("idle_" + current_dir)

func update_direction_string(dir: Vector3):
	if abs(dir.x) > abs(dir.z):
		current_dir = "right" if dir.x > 0 else "left"
	else:
		current_dir = "back" if dir.z < 0 else "front"

func perform_attack():
	is_locked = true
	# Поворачиваемся к игроку перед ударом
	update_direction_string(global_position.direction_to(player.global_position))
	sprite.play("attack_" + current_dir)
	
	# Наносим урон игроку (если у него есть функция take_damage)
	if player.has_method("take_damage"):
		player.take_damage()
		
	await get_tree().create_timer(TIME_ATTACK).timeout
	if health > 0:
		is_locked = false

# Эту функцию должен вызывать игрок при попадании по врагу
func take_damage():
	if is_locked and health <= 0: return
	
	health -= 1
	is_locked = true
	
	if health <= 0:
		die()
	else:
		sprite.play("takeDamage_" + current_dir)
		await get_tree().create_timer(TIME_TAKE_DAMAGE).timeout
		is_locked = false

func die():
	is_locked = true
	sprite.play("death_" + current_dir)
	await get_tree().create_timer(TIME_DEATH).timeout
	queue_free() # Удаляем врага со сцены после смерти
