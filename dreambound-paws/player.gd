extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


@export var speed := 150

func _process(delta):
	var direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	velocity = direction.normalized() * speed
	move_and_slide()
