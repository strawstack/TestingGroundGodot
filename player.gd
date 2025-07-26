extends CharacterBody3D

var mouse_sens = 0.3

var walkSpeed = 3
var runSpeed = 6
var speed = walkSpeed

var gravity = 1
var jumpImpulse = 0

var playerStart

# Capture mouse when game launches
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Capture player location on start
	playerStart = self.position

func _input(event):

	# Capture mouse on left click
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Free mouse on esc
	if event.is_action_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# https://forum.godotengine.org/t/how-to-make-the-camera-moves-by-the-mouse-in-3d/24201/2
	if event is InputEventMouseMotion:
		$Pivot.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		$Pivot/Camera3D.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))

# Runs every frame
func _process(delta):
	# Return player to start on reset
	if Input.is_action_just_pressed("reset"):
		self.position = playerStart + Vector3.UP * 3.0 

# Runs every physics frame
func _physics_process(delta):

	# Set player direction to Zero 
	var direction = Vector3.ZERO

	# Obtain forward and right directions based on rotation of Camera Pivot
	var forward = -1 * $Pivot.get_global_transform().basis.z
	var right = $Pivot.get_global_transform().basis.x

	# Increase speed when shift is held
	if Input.is_action_pressed("run"):
		speed = runSpeed
	else:
		speed = walkSpeed

	# Add up current player direction based on input 
	if Input.is_action_pressed("right"):
		direction += right

	if Input.is_action_pressed("left"):
		direction += -1 * right

	if Input.is_action_pressed("back"):
		direction += -1 * forward

	if Input.is_action_pressed("forward"):
		direction += forward

	# Based on if player is on the floor allow jump and apply gravity
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			jumpImpulse = 10
		if jumpImpulse < -5: jumpImpulse = -5
	jumpImpulse -= gravity

	# Calculate gravity and normalized speed
	direction = direction.normalized()
	direction = direction * speed
	direction.y = jumpImpulse

	velocity = direction

	# Move the player while respecting physics bounds
	move_and_slide()
