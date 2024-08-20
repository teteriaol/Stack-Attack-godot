extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const PUSH_FORCE = 20.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var screen_size = Vector2(480, 720)

func _ready():
	pass

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta*2

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction and direction == 1:
		$AnimationMovement.visible = true
		$SpriteIdle.visible = false
		$AnimationMovement.play("move_right")
		velocity.x = direction * SPEED
		velocity.x = clamp(velocity.x, 0, screen_size.x - 100)
	elif direction and direction == -1:
		$AnimationMovement.visible = true
		$SpriteIdle.visible = false
		$AnimationMovement.play("move_left")
		velocity.x = direction * SPEED
	else:
		$AnimationMovement.stop()
		$AnimationMovement.visible = false
		$SpriteIdle.visible = true
		velocity.x = move_toward(velocity.x, 0, SPEED)


	move_and_slide()


	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			var normal = collision.get_normal()
			if abs(normal.x) > abs(normal.y):
				var impulse = Vector2(-normal.x * PUSH_FORCE, 0)
				collision.get_collider().apply_central_impulse(impulse)

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if (collision.get_collider().name == 'Crate' 
		or 'RigidBody2D@' in collision.get_collider().name) \
		and (collision.get_normal().y == 1 \
		and collision.get_normal().x == 0):
			get_parent().get('game_over').visible = true
			get_tree().paused = true
