class_name Movable_Object
extends CharacterBody2D

var mouse_in = false
var chosen = false

var parent
var distance
var direction
var dragging
var returning
var newPosition = Vector2()

func _input(event):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		
		if event is InputEventMouseButton:
			
			if chosen and mouse_in and event.is_pressed():
				distance = position.distance_to(get_global_mouse_position())
				direction = (get_global_mouse_position() - position).normalized()
				newPosition = get_global_mouse_position() - direction * distance
				returning = false
				dragging = true
				pressed()
			
			if dragging and event.is_released():
				returning = true
				dragging = false
				chosen = false
				released()
		
		elif event is InputEventMouseMotion:
			if dragging:
				newPosition = get_global_mouse_position() - direction * distance

func _physics_process(_delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		if dragging:
			velocity = ((newPosition - position) * Vector2(30, 30))#.rotated(get_parent().rotation)
			move_and_slide()
		if returning:
			velocity = ((newPosition - position) * Vector2(10, 10))#.rotated(get_parent().rotation)
			move_and_slide()

func pressed():
	pass

func released():
	pass

func set_chosen():
	chosen = true

func set_layer(bit, b):
	set_collision_layer_value(bit, b)

func mouse_entered():
	mouse_in = true

func mouse_exited():
	mouse_in = false
