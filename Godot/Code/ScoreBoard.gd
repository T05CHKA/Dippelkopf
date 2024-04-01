extends Control

var score_row = preload("res://Scene/score_row.tscn")

var score_table = []

func add_score():
	
	var A_score = 0
	for a in %The_Game.A_Team:
		A_score = A_score + a.points_counter
	
	var B_score = 0
	for b in %The_Game.B_Team:
		B_score = B_score + b.points_counter
	
	var new_score = score_row.instantiate()
	if score_table.is_empty():
		for i in range(0, 4):
			if %The_Game.A_Team.has(%The_Game.Player_list[i]): 
				new_score.get_node(str(i+1)).text = str(A_score)
			else: 
				new_score.get_node(str(i+1)).text = str(B_score)
	else:
		for i in range(0, 4):
			if %The_Game.A_Team.has(%The_Game.Player_list[i]): 
				new_score.get_node(str(i+1)).text = str(A_score + int(score_table[-1].get_node(str(i+1)).text))
			else: 
				new_score.get_node(str(i+1)).text = str(B_score + int(score_table[-1].get_node(str(i+1)).text))
	
	$Panel/VBoxContainer.add_child(new_score)
	
	score_table.append(new_score)
	
	self.show()

func _on_continue_button_pressed():
	self.hide()
	%The_Game.on_continue.rpc_id(1)

@rpc ("call_local", "authority")
func set_label(text):
	$MarginContainer/HBoxContainer/Label.text = "   Votes " + text + "/2   "
