extends CharacterBody3D

class_name Player

@onready var sprite = $Sprite3D
@onready var attack_ray = $AttackRay # <--- Ссылка на наш узел луча

const SPEED = 5.0
var health = 10
var current_dir = "front" 
var is_locked = false 
var is_invulnerable = false # Временная бессмертность
var face_direction = Vector3(0, 0, 1) # Куда мы сейчас смотрим
const ATTACK_RANGE = 2.0 # Дальность удара

# ==========================================
const TIME_ATTACK = 0.5       # Время атаки
const TIME_TAKE_DAMAGE = 0.2 # Время стана от урона
const TIME_DEATH = 1.0        # Время смерти
# ==========================================

func _physics_process(_delta):
	if is_locked:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# Атака
	if Input.is_action_just_pressed("attack"):
		perform_attack()
		return

	# Получаем нажатия клавиш
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# Поворачиваем луч атаки в ту сторону, куда идем
		face_direction = direction
		attack_ray.target_position = face_direction * ATTACK_RANGE
		
		update_direction_string(direction)
		sprite.play("run_" + current_dir)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		sprite.play("idle_" + current_dir)

	move_and_slide()

# Вычисление направления для анимации
func update_direction_string(dir: Vector3):
	if abs(dir.x) > abs(dir.z):
		current_dir = "right" if dir.x > 0 else "left"
	else:
		current_dir = "back" if dir.z < 0 else "front"

# ==========================================
# ВОТ ТА САМАЯ ФУНКЦИЯ АТАКИ
# ==========================================
func perform_attack():
	is_locked = true
	sprite.play("attack_" + current_dir)
	
	attack_ray.force_raycast_update()
	
	if attack_ray.is_colliding(): 
		var target = attack_ray.get_collider()
		print("ЛУЧ ВРЕЗАЛСЯ В: ", target.name) # Смотрим, куда попали
		
		if target.has_method("take_damage"):
			target.take_damage()
			print("И УДАРИЛ ВРАГА!") 
		else:
			print("Но у этого объекта нет функции take_damage (это стена/пол?)")
	else:
		print("Луч рассек пустоту (ни в кого не попал)...")
			
	await get_tree().create_timer(TIME_ATTACK).timeout 
	if health > 0:
		is_locked = false

# Получение урона игроком
func take_damage():
	# Если мы мертвы ИЛИ у нас активна неуязвимость - игнорируем удар
	if is_invulnerable or health <= 0: 
		return 
	
	health -= 1
	is_locked = true
	is_invulnerable = true # Включаем щит неуязвимости!
	
	if health <= 0:
		die()
	else:
		sprite.play("takeDamage_" + current_dir)
		
		# 1. Ждем время стана (TIME_TAKE_DAMAGE)
		await get_tree().create_timer(TIME_TAKE_DAMAGE).timeout
		is_locked = false # Стан прошел, ТЕПЕРЬ ТЫ МОЖЕШЬ БИТЬ
		
		# 2. Ждем еще полсекунды, пока враг машет руками сквозь нас
		await get_tree().create_timer(0.5).timeout 
		is_invulnerable = false # Неуязвимость спала, теперь снова можно получить урон

# Смерть игрока
func die():
	is_locked = true
	sprite.play("death_" + current_dir)
	await get_tree().create_timer(TIME_DEATH).timeout
	print("Игрок умер")
