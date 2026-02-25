extends Area2D

# Variables
var speed = 400.0
var direction = Vector2.RIGHT


func _ready():
	body_entered.connect(_on_body_entered)


func _process(delta: float):
	position += direction * speed * delta
	
	if position.x < 0 or position.x > 800:
		queue_free()

# Cause player to lose a life if projectile collides with player. Then remove
# projectile from scene		
func _on_body_entered(body):
	if body.is_in_group("player"):
		body._lose_life()
		queue_free()
