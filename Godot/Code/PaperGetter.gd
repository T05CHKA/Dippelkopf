extends Area2D

func _ready():
	pass

func _process(_delta):
	position = get_global_mouse_position()
	var count = len(get_overlapping_bodies())
	
	if count == 0:
		pass
	
	elif count == 1:
		get_overlapping_bodies()[0].set_chosen()
		if (Input.is_action_just_pressed("mouse_click")):
			get_overlapping_bodies()[0].parent.pick_up(get_overlapping_bodies()[0])
	
	else:
		var max_index = -1
		var top_card = null
		for b in get_overlapping_bodies():
			if (b.z_index > max_index):
				max_index = b.z_index
				top_card = b
		
		top_card.set_chosen()
		for P in get_parent().Player_list:
			for c in P.Card_list_ref:
				if c != top_card:
					c.chosen = false
		if (Input.is_action_just_pressed("mouse_click")):
			get_overlapping_bodies()[0].parent.pick_up(top_card)
