extends CharacterBody2D

@onready var animation_sprite = $AnimatedSprite2D
const BASE_SPEED = 250.0
const SPRINT_SPEED = 400.0  # Increased speed when sprinting
const JUMP_VELOCITY = -400.0
var base_animation_name = ""

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
	var speed = SPRINT_SPEED if is_sprinting else BASE_SPEED 

	# Apply movement
	var movement = speed * direction * delta
	# Moves our player around, whilst enforcing collisions so that they come to a stop when colliding with another object.
	move_and_collide(movement)

	#plays animations
	player_animations(direction, is_sprinting, false)

var new_direction = Vector2(0,1) #only move one spaces

func player_animations(direction : Vector2, is_sprinting: bool, is_knight:bool):
#Vector2.ZERO is the shorthand for writing Vector2(0, 0).
	var animation
	var animation_name
	
	#TODO per reskin fantasy
	if is_knight: 
		animation_name = "knight_"
	else:
		animation_name= base_animation_name
	
	if direction != Vector2.ZERO:
		#update our direction with the new_direction
		new_direction = direction
		#play walk animation, because we are moving
		if (is_sprinting):
			animation = animation_name + "run_" + returned_direction(new_direction)
		else:
			animation = animation_name + "walk_" + returned_direction(new_direction)
		animation_sprite.play(animation)
	else:
		#play idle animation, because we are still
		animation  = animation_name + "idle_" + returned_direction(new_direction)
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
