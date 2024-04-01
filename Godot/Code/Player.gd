extends Node2D

var unique_id = 0

@export var spread_curve: Curve
@export var height_curve: Curve
@export var rotation_curve: Curve

var paper_stack = []
var Card_list_ref = []
var points_counter = 0

@rpc("call_local", "authority")
func config():
	for c in Card_list_ref:
		c.parent = self
		c.on_field = false
		c.position = global_position
		c.rotation = rotation
		put_down(c)
		
		c.set_multiplayer_authority(unique_id)
		c.get_node("Sprite2D/AnimatedSprite2D").z_index = -1
		c.fliped = false
		
		if unique_id == multiplayer.get_unique_id():
			c.set_layer(1, true)
			if !c.fliped: c.flip()
			if c.faded: c.fade()
		else:
			c.set_layer(1, false)
			if !c.faded: c.fade()
		
		c.config()
		
		await get_tree().create_timer(0.25).timeout

@rpc("call_local")
func reset():
	Card_list_ref.clear()
	paper_stack.clear()
	points_counter = 0

func sort():
	for c in paper_stack:
		var hand_ratio = 0.5
		
		if c.dragging:
			continue
		
		if len(paper_stack) > 1:
			hand_ratio = float(paper_stack.find(c)) / float(len(paper_stack) - 1)
		
		c.newPosition.x = spread_curve.sample(hand_ratio) * 50 * len(paper_stack)
		c.newPosition.y = height_curve.sample(hand_ratio) * 70
		c.newPosition = global_position + c.newPosition.rotated(rotation)
		c.rotation = rotation - rotation_curve.sample(hand_ratio) * 0.3
		c.returning = true

func locate_target_for(c):
	if not c.on_field:
		put_down(c)
		
		var hand_ratio = 0.5
		
		if len(paper_stack) > 1:
			hand_ratio = float(paper_stack.find(c)) / float(len(paper_stack) - 1)
		
		c.newPosition.x = spread_curve.sample(hand_ratio) * 50 * len(paper_stack) #500
		c.newPosition.y = height_curve.sample(hand_ratio) * 70
		c.newPosition = global_position + c.newPosition.rotated(rotation)
		c.rotation = rotation - rotation_curve.sample(hand_ratio) * 0.3
	else:
		c.newPosition = c.position

func put_down(card):
	if card in paper_stack: return
	
	paper_stack.append(card)
	sort()
	
	var count = 0
	for c in paper_stack:
		c.z_index = count
		
		count += 1

func pick_up(card):
	paper_stack.erase(card)
	sort()

func add_points(points):
	points_counter += points

func has_the_color():
	var has_color = false
	for c in paper_stack:
		if %Field.color == c.CardInfo[0]:
			has_color = true
	return has_color

func has_the_queen():
	for c in Card_list_ref:
		if c.value == 18:
			return true
	return false
