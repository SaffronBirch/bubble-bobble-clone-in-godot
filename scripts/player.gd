extends CharacterBody2D

# References
@onready var bubble_scene = preload("res://scenes/bubble.tscn")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var right_marker: Marker2D = $rightMarker
@onready var left_marker: Marker2D = $leftMarker

# Window dimensions
var WIDTH = 800
var HEIGHT = 480

# variables
const SPEED = 300.0
const JUMP_VELOCITY = -700.0
var lives = 3
var last_direction = 1
var is_shooting = false

func _physics_process(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		last_direction = 1 if direction > 0 else -1  # Remember direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# play sprite animations
	if not is_shooting:
		if direction < 0:
			animated_sprite.play("runLeft")
		elif direction > 0:
			animated_sprite.play("runRight")
		else:
			animated_sprite.play("idle")
	
	# Fire a bubble when corresponding key is pressed and player isn't actively shooting
	if Input.is_action_just_pressed("fire") and not is_shooting:
		_start_shoot()

	move_and_slide()


# Returns true if player falls off the map
func _out_of_bounds()-> bool:
		return global_position.y > 480


# Respawn player at the top of the map, using their current horizontal position
func _reset_player():
	var x = global_position.x
	var y = global_position.y - 500
	position = Vector2(x, y)


# Lose a life if player is hit by an enemy projectile
func _lose_life():
	lives -= 1


# Shoot a bubble in the direction that player or direction that player was last
# facing, if idle
func _start_shoot():
	is_shooting = true
	
	if last_direction < 0:
		animated_sprite.play("blowLeft")
	elif last_direction > 0:
		animated_sprite.play("blowRight")
	
	await animated_sprite.animation_finished
	_shoot_bubble()
	
	is_shooting = false


# Initialize bubble and add to scene
func _shoot_bubble():
	var bubble = bubble_scene.instantiate()
	bubble.global_position = global_position
	
	if last_direction == 1:
		bubble.global_position = right_marker.global_position
		bubble.direction = Vector2.RIGHT
	else:
		bubble.global_position = left_marker.global_position
		bubble.direction = Vector2.LEFT
	
	get_tree().root.add_child(bubble)
	
	
		
		
	
	
