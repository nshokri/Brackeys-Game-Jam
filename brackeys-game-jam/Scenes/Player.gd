extends CharacterBody3D

signal shooting

var speed
var speed_multiplier = 1.0
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.004

const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var gravity = 15

@onready var head = $Head

@onready var camera = $Head/Camera3D
@onready var spotlight = $Head/SpotLight3D

#@export var gun_shoot_animation_path: NodePath
#@onready var gun_shoot_animation: AnimationPlayer = get_node(gun_shoot_animation_path + "/")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		var x_offset = -event.relative.y * SENSITIVITY
		camera.rotate_x(x_offset)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		spotlight.rotate_x(x_offset)
		spotlight.rotation.x = clamp(spotlight.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED * speed_multiplier
	else:
		speed = WALK_SPEED * speed_multiplier

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	if _check_if_shooting():
		_shoot()

	move_and_slide()


func _shoot():
	# Plays shooting animation
	shooting.emit()

func _check_if_shooting():
	if Input.is_action_pressed("shoot"):
		return true

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
func _on_coin_coin_collected():
	speed_multiplier = 1.5
	await get_tree().create_timer(10.0).timeout
	speed_multiplier = 1.0
