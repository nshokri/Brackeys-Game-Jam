extends Node3D

@export var animation_path: NodePath
@onready var gun_animation: AnimationPlayer = get_node(animation_path)

@export var barrel_explosion_path: NodePath
@onready var barrel_explosion: Node3D = get_node(barrel_explosion_path)

@export var barrel_light_path: NodePath
@onready var barrel_light: Node3D = get_node(barrel_light_path)

@export var gunshot_path: NodePath
@onready var gun_shot: AudioStreamPlayer2D = get_node(gunshot_path)

@export var explosion_particle_path: NodePath
@onready var explosion_particles: GPUParticles3D = get_node(explosion_particle_path)

var bullet = load("res://Scenes/Ammo/Bullet.tscn")
var bullet_instance

@export var raycast_path: NodePath
@onready var raycast: RayCast3D = get_node(raycast_path)

var can_shoot = true
@onready var timer: Timer = $Timer

func _process(delta: float):
	if gun_animation.is_playing():
		barrel_explosion.visible = true
		barrel_light.visible = true
	else:
		barrel_explosion.visible = false
		barrel_light.visible = false

func _play_recoil_animation_if_not_already_playing():
	if !gun_animation.is_playing():
		gun_animation.play("Shoot")
		gun_shot.play()

func _on_player_shooting():
	if can_shoot:
		if (explosion_particles.emitting):
			explosion_particles.restart()
			_shoot_bullet()
		else:
			_shoot_bullet()

		_play_recoil_animation_if_not_already_playing()
		explosion_particles.emitting = true

		can_shoot = false
		timer.start()

func _shoot_bullet():
	bullet_instance = bullet.instantiate()
	bullet_instance.position = raycast.global_position
	bullet_instance.transform.basis = raycast.global_transform.basis
	get_parent().get_parent().get_parent().get_parent().add_child(bullet_instance)


func _on_timer_timeout():
	can_shoot = true
