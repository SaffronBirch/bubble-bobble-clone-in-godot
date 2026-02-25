extends CharacterBody2D

# References
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var projectile_scene = preload("res://scenes/projectile.tscn")
@onready var enemy_timer: Timer = $enemyTimer

# Window dimensions
var WIDTH = 800
var HEIGHT = 480

# Enemy variables
const SPEED = 200.0
var direction = 1

# Projectile variables
var shoot_timer = 0.0
var shoot_interval = randf_range(1.0, 5.0)
var is_shooting = false

# Enemy state
enum State {ACTIVE, TRAPPED}
var current_state = State.ACTIVE


func _ready():
	enemy_timer.timeout.connect(_on_timer_timeout)
	enemy_timer.start()


func _physics_process(delta: float):
	if current_state != State.ACTIVE:
		return
	else:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		# If raycast collides with wall, move the enemy in the opposite direction
		if ray_cast_right.is_colliding():
			direction = -1
		if ray_cast_left.is_colliding():
			direction = 1
		
		velocity.x = direction * SPEED

		if not is_shooting:
			if direction == 1:
				animated_sprite.play("moveRight")
			elif direction == -1:
				animated_sprite.play("moveLeft")
			
	move_and_slide()


# Enemy shoots projecile in the direction they are facing
func start_projectile():
	is_shooting = true
	
	if direction == 1:
		animated_sprite.play("shootRight")
	elif direction == -1:
		animated_sprite.play("shootLeft")
		
	await animated_sprite.animation_finished
	
	_shoot_projectile()
	
	is_shooting = false
	
# Initialize projectole and shoot it from enemy
func _shoot_projectile():	
	var projectile = projectile_scene.instantiate()
	
	# Position the prjectile at the enemy location
	projectile.global_position = global_position
	
	# Shoot in the same direction the enemy is facing/moving
	if direction == 1:
		projectile.direction = Vector2.RIGHT
	elif direction == -1:
		projectile.direction = Vector2.LEFT
		
	# Add to root scene
	get_tree().root.add_child(projectile)
		

# If enemy is trapped in a bubble, set velocity to zero and pause physics process
func _bubble_trap():
	current_state = State.TRAPPED
	velocity = Vector2.ZERO
	set_physics_process(false)
	

# Returns true if an enemy falls off the map
func _out_of_bounds()-> bool:
	return global_position.y > 480
	
	
# Respawn enemy at the top of the map, using their current horizontal position
func _reset_enemy():
	var x = global_position.x
	var y = global_position.y - 500
	position = Vector2(x, y)
	

# Enemy shoots a projectile every 2 seconds (set in Timer Node)
func _on_timer_timeout():
	if current_state == State.ACTIVE and not is_shooting:
		start_projectile()
		
	enemy_timer.start()
	
	
	
	
	
	
