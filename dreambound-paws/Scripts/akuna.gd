extends CharacterBody2D

@onready var animation_sprite = $AnimatedSprite2D
@onready var player = get_node("../Player")
const BASE_SPEED = 250.0
const SPRINT_SPEED = 400.0  # Increased speed when sprinting
const JUMP_VELOCITY = -400.0

@onready var behind_sprite = $YourSpriteNode  # Replace with the actual node path

# Offsets to position the sprite behind the player
var offsets = {
	"up": Vector2(0, 60),     # Behind when facing up
	"down": Vector2(0, -60),  # Behind when facing down
	"right": Vector2(-60, 0),   # Behind when facing sideways
	"left": Vector2(60,0)
}

func update_behind_sprite():
	var dir = returned_direction_detailed(new_direction)  # Get player's facing direction
	animation_sprite.global_position = animation_sprite.global_position.move_toward((player.global_position + offsets.get(dir, Vector2.ZERO)), 5)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get player input (left, right, up/down)
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") -Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	# Check if sprinting
	var is_sprinting = Input.is_action_pressed("ui_sprint")
	var speed
	if is_sprinting:
		speed = SPRINT_SPEED
		animation_sprite.set_speed_scale(1.8)
	else:
		speed = BASE_SPEED
		animation_sprite.set_speed_scale(1.0)
		
	# Apply movement
	var movement = speed * direction * delta
	# Moves our player around, whilst enforcing collisions so that they come to a stop when colliding with another object.
	move_and_collide(movement)

	#plays animations
	get_animations(direction, is_sprinting)
	update_behind_sprite()

var new_direction = Vector2(0,1) #only move one spaces

func get_animations(direction : Vector2, is_sprinting: bool):
#Vector2.ZERO is the shorthand for writing Vector2(0, 0).
	var animation
	if direction != Vector2.ZERO:
		#update our direction with the new_direction
		new_direction = direction
		#play walk animation, because we are moving
		if (is_sprinting):
			animation = "walk_" + returned_direction(new_direction)
		else:
			animation = "walk_" + returned_direction(new_direction)
		animation_sprite.play(animation)
	else:
		#play idle animation, because we are still
		animation  = "idle_" + returned_direction(new_direction)
		animation_sprite.play(animation)



# Animation Direction
func returned_direction(direction : Vector2):
	#it normalizes the direction vector 
	var normalized_direction  = direction.normalized()
	var default_return = "side"

	if normalized_direction.y > 0:
		return "down"
	elif normalized_direction.y < 0:
		return "up"
	elif normalized_direction.x > 0:
		#(right)
		$AnimatedSprite2D.flip_h = false
		return "side"
	elif normalized_direction.x < 0:
		#flip the animation for reusability (left)
		$AnimatedSprite2D.flip_h = true
		return "side"

	#default value is empty
	return default_return

func returned_direction_detailed(direction : Vector2):
	#it normalizes the direction vector 
	var normalized_direction  = direction.normalized()
	var default_return = "down"

	if normalized_direction.y > 0:
		return "down"
	elif normalized_direction.y < 0:
		return "up"
	elif normalized_direction.x > 0:
		#(right)
		$AnimatedSprite2D.flip_h = false
		return "right"
	elif normalized_direction.x < 0:
		#flip the animation for reusability (left)
		$AnimatedSprite2D.flip_h = true
		return "left"

	#default value is empty
	return default_return
