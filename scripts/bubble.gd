extends Area2D

# References
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Variables
var speed = 400.0
var direction = Vector2.RIGHT
var deceleration = 300.0
var max_distance = 200.0
var distance_traveled = 0.0
var is_stopped = false
var is_popping = false
var is_shooting = true
var is_trapping = false
var trapped_enemy = null
var bubble_timer = 0.0
var bubble_interval = 2.0


func _ready():
	body_entered.connect(_on_body_entered)
	_start_bubble()


func _process(delta: float):
	if is_shooting: # Do nothing
		return
	if is_trapping: # Start moving upwards up an enemy is trapped
		position += Vector2.UP * 80.0 * delta
		
		# Set the trapped enemy position to the bubble position
		if trapped_enemy and is_instance_valid(trapped_enemy):
			trapped_enemy.global_position = global_position
		return
	
	# After the bubble has been shot, move foward at a decelerating rate
	if not is_stopped:
		var movement = direction * speed * delta
		position += movement
		distance_traveled += movement.length()
		speed -= deceleration * delta
	
		# Stop moving when either max distance has been reached, or speed reaches 0
		if speed <= 0 or distance_traveled >= max_distance:
			is_stopped = true
			_bubble_stopped()
	elif is_stopped and not is_popping: # Start moving upwards
		position += Vector2.UP * 50.0 * delta
	
	
# Play animation when bubble first enters the scene		
func _start_bubble():
	animated_sprite.play("shootBubble")
	animated_sprite.play("movingBubble")
	is_shooting = false

	
# After 2 seconds of moving upwards, the bubble pops
func _bubble_stopped():
	await get_tree().create_timer(2.0).timeout
	_pop_bubble()


# play bubble popping animation when bubble pops
func _pop_bubble():
	is_popping = true
	animated_sprite.play("popBubble")
		
	# If an enemy was trapped inside when the bubble pops, remove enemy from scene
	if trapped_enemy and is_instance_valid(trapped_enemy):
		trapped_enemy.queue_free()
		
	# Remove bubble from scene once popping animation is finished	
	await animated_sprite.animation_finished
	queue_free()
	

# Trap enemy in bubble upon collision	
func _trap_enemy(enemy):
	trapped_enemy = enemy
	is_trapping = true
	is_stopped = false
	
	enemy._bubble_trap()
	enemy.visible = false
	
	animated_sprite.play("trappedEnemy")
	

# Bubble pops with enemy inside when it collides with player
func _pop_bubble_with_player():
	is_popping = true
	animated_sprite.play("popBubble")
	
	# increase the player's score if bubble with enemy is popped
	if trapped_enemy and is_instance_valid(trapped_enemy):
		var main_scene = get_tree().root.get_node("Main")
		if main_scene and main_scene.has_method("_add_score"):
			main_scene._add_score(1)
		
		# Remove enemy from scene
		trapped_enemy.queue_free()
	
	# Remove bubble from scene after animation
	await animated_sprite.animation_finished
	queue_free()


func _on_body_entered(body):
	# If enemy is trapped in bubble, call _trap_enemy() function
	if body.is_in_group("enemy") and not is_trapping:
		_trap_enemy(body)
			
	elif body.is_in_group("player") and is_trapping:
		_pop_bubble_with_player()
	

			
			
			
		
