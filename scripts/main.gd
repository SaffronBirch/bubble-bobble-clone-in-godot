extends Node2D

# References
@onready var player: CharacterBody2D = $Player
@onready var title: Sprite2D = $CanvasLayer/Menu/title
@onready var press_space: AnimatedSprite2D = $CanvasLayer/Menu/pressSpace
@onready var game_over: Sprite2D = $CanvasLayer/GameOver/gameOver
@onready var timer: Timer = $Timer
@onready var enemy_scene = preload("res://scenes/enemy.tscn")
@onready var player_scene = preload("res://scenes/player.tscn")
@onready var heart_1: Sprite2D = $CanvasLayer/Health/heart1
@onready var heart_2: Sprite2D = $CanvasLayer/Health/heart2
@onready var heart_3: Sprite2D = $CanvasLayer/Health/heart3
@onready var score_container: HBoxContainer = $CanvasLayer/Score/HBoxContainer

# Sprites to update the player's score
var score_sprites = {
	0: preload("res://assets/images/font048.png"),
	1: preload("res://assets/images/font049.png"),
	2: preload("res://assets/images/font050.png"),
	3: preload("res://assets/images/font051.png"),
	4: preload("res://assets/images/font052.png"),
	5: preload("res://assets/images/font053.png")
}

# Player score
var score = 0

# Screen dimensions
var WIDTH = 800
var HEIGHT = 480

#Game States
enum State{
	MENU,
	PLAY,
	GAME_OVER 
}
# current game state
var current_state:State = State.MENU

# Array to store and manage enemies in the scene
var enemies: Array = [];


func _ready():
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	_update_score_display()


func _process(delta: float):
	if current_state == State.MENU:
		_menu_screen()
		if Input.is_action_just_pressed("start"):
			_start_game()	
	elif current_state == State.PLAY:
		_play_game()
			# Restart game
	elif current_state == State.GAME_OVER:
		if Input.is_action_just_pressed("restart"):
			_restart_game()


# Set current state to MENU and only show menu/game over displays			
func _menu_screen():
	current_state = State.MENU
	title.show()
	press_space.show()
	game_over.hide()


# Set current state to PLAY and hide menu/game over displays
func _start_game():
	current_state = State.PLAY
	title.hide()
	press_space.hide()	
	timer.start()
	
	# Update the player's score and score display
	score = 0
	_update_score_display()
	
	# Reset life count
	player.lives = 3
	
	# Reset health display
	heart_1.show()
	heart_2.show()
	heart_3.show()


# Respawn player if they fall off of the map
func _play_game():
	if player._out_of_bounds():
		player._reset_player()
	
	# Filters enemies array to enemies that have been popped/destroyed are removed from array
	enemies = enemies.filter(func(e): return is_instance_valid(e))
	
	# Respawn enemy if they fall off of the map
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy._out_of_bounds():
			enemy._reset_enemy()
	
	# Remove hearts as player loses lives
	if player.lives == 2:
		heart_3.hide()
	elif player.lives == 1:
		heart_2.hide()
	elif player.lives == 0:
		heart_1.hide()
		_game_over()
		

# Set current state to GAME_OVER and only show game over display	
func _game_over():
	current_state = State.GAME_OVER
	game_over.show()
	timer.stop()
	
	# Remove player from scene
	if is_instance_valid(player):
		player.queue_free()
	
	# Remove enemies from scene and clear the enemies storage array
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
		enemies.clear()

# Restart the game 
func _restart_game():
	# Remove remaining enemies from the scene
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
		enemies.clear()
	
	# Initialize a new player
	if not is_instance_valid(player):
		player = player_scene.instantiate()
		player.position = Vector2(400, 190)
		add_child(player)
	
	# Return to menu screen
	_menu_screen()
	

# Spawn a new enemy up to a maximum of 5	
func _on_timer_timeout():
	# Check if number of active enemies exceeds 5. If it does, stop spawning
	if enemies.size() >= 5:
		timer.stop()
		return 
		
	# Spawn enemy every 2 seconds
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(randf_range(170, 270), 0)
	enemy.direction = [-1, 1][randi() % 2]
	
	# Add enemy to scene and storage array
	add_child(enemy)
	enemies.append(enemy)
	

# Update player's score
func _add_score(points: int):
	score += points
	_update_score_display()

# Update score display 
func _update_score_display():
	# If the player reaches 5 points, end game
	if score == 5:
		_game_over()
	else:
		for child in score_container.get_children():
			child.queue_free()
			
		var score_string = str(score)
		
		# Update the score display with the sprite that corresponds to the score number
		for score_char in score_string:
			var digit = int(score_char)
			var sprite = Sprite2D.new()
			sprite.texture = score_sprites[digit]
			score_container.add_child(sprite)
	
		

	
	
