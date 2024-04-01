extends Area2D

var field_stack = []

signal check

var Hochzeit = func(p):
	if %The_Game.A_Team.has(p): return
	%The_Game.A_Team.insert(0, p)
	%The_Game.B_Team.erase(p)
	disconnect_Hochzeit()

var scorboard_flag : bool = false
var action_flag : bool = false
var wait_flag : bool = false

var color = ""

func _process(delta):
	if wait_flag:
		if len(get_overlapping_bodies()) < 1:
			action_flag = true
			wait_flag = false
	
	if !action_flag: return
	
	if len(field_stack) == 4:
		if Input.is_action_pressed("Space"):
			set_ac_flag.rpc(false)
			%The_Game.end_round.rpc_id(1) 


func _on_body_entered(body):
	if !action_flag: return
	if body.parent.unique_id != multiplayer.get_unique_id(): body.parent.pick_up(body)
	
	if field_stack.is_empty():
		field_stack.append(body)
		body.on_field = true
		set_color.rpc(body.CardInfo[0])
		body.r_flag = true
	
	elif len(field_stack) < 4:
		if body.CardInfo[0] == color or !body.parent.has_the_color():
			field_stack.append(body)
			body.on_field = true
			body.r_flag = true
	

func _on_body_exited(body):
	if !action_flag: return
	if body.parent.unique_id != multiplayer.get_unique_id(): body.parent.put_down(body)
	
	body.on_field = false
	body.u_flag = true
	if body in field_stack: field_stack.erase(body)
	if field_stack.is_empty(): set_color.rpc("")

@rpc("call_local", "any_peer")
func set_color(newColor):
	color = newColor

@rpc("call_local", "authority")
func set_sc_flag(b : bool):
	scorboard_flag = b

@rpc("call_local", "any_peer")
func set_ac_flag(b : bool):
	action_flag = b

@rpc("call_local")
func connect_Hochzeit():
	if !check.is_connected(Hochzeit):
		check.connect(Hochzeit)

@rpc("call_local")
func disconnect_Hochzeit():
	if check.is_connected(Hochzeit):
		check.disconnect(Hochzeit)


@rpc("call_local", "authority")
func collect_cards():
	await get_tree().create_timer(0.25).timeout
	
	var max_value = -1
	var win_card = null
	for c in field_stack:
		if c.value > max_value and (c.CardInfo[0] == color or c.CardInfo[0] == "Trump"):
			max_value = c.value
			win_card = c
	
	var win_player = win_card.parent
	
	emit_signal("check", win_player)
	
	for c in field_stack:
		c.newPosition = global_position
	
	await get_tree().create_timer(2).timeout
	
	for c in field_stack:
		c.newPosition = (1.5 * win_player.global_position - global_position)
		win_player.add_points(c.CardInfo[1])
	
	field_stack.clear()
	
	wait_flag = true
	
	if scorboard_flag: 
		%ScoreBoard.add_score()
		set_sc_flag(false)
		
