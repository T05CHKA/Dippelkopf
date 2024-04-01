extends Node2D

@onready var Player_list = [$Player_at_bottom, $Player_at_left, $Player_at_top, $Player_at_right]
@export var card : PackedScene
var Card_list = []
var A_Team = []
var B_Team = []

signal update_authority

var only_once : bool = true
var Hochzeit : bool = false

var round_counter = 0
var vote_counter = 0

func _ready():
	creat_card_deck()

func _ready_to_start():
	match GameManager.identification:
		1:
			$Camera2D.rotation_degrees = 0
			$Camera2D.offset.x = 0
			$Camera2D.offset.y = 150
			$Field.rotation_degrees = 0
		2:
			$Camera2D.rotation_degrees = 90
			$Camera2D.offset.x = -150
			$Camera2D.offset.y = 0
			$Field.rotation_degrees = 90
		3:
			$Camera2D.rotation_degrees = 180
			$Camera2D.offset.x = 0
			$Camera2D.offset.y = -150
			$Field.rotation_degrees = 180
		4:
			$Camera2D.rotation_degrees = 270
			$Camera2D.offset.x = 150
			$Camera2D.offset.y = 0
			$Field.rotation_degrees = 270



func _ready_to_update():
	for i in len(GameManager.Peer_list):
		Player_list[i].unique_id = GameManager.Peer_list[i]
	
	if multiplayer.is_server() and len(GameManager.Peer_list) == 2 and only_once:
		start_match()
		#var count = 0
		#for c in Card_list:
		#	allocate_player.rpc(count, c.name)
		#	count = count + 1
		
		#for p in Player_list:
		#	p.config.rpc()
		
		only_once = false
		
		%Field.set_ac_flag.rpc(true)

func creat_card_deck():
	for i in range(0, 20): #change the 20 back to 40 pls
		var c = card.instantiate()
		Card_list.insert(0, c)
		%Card_Node.add_child(c)
		
		c.position = Vector2(0, 1000)
	
	var count = 0
	for c in Card_list:
		c.name = str(count)
		c.set_value(count % 20)
		c.get_node("Sprite2D").get_node("AnimatedSprite2D").set_frame_and_progress(c.value, 0)
		count = count + 1


@rpc("call_local", "authority")
func allocate_player(p, c_name):
	var card = Card_list.filter(func (c): return c.name == c_name)[0]
	Player_list[p % 2].Card_list_ref.insert(0, card) #change the 2 back to 4 pls

@rpc("call_local", "authority")
func allocate_team():
	for P in Player_list:
		if P.has_the_queen():
			A_Team.insert(0, P)
		else:
			B_Team.insert(0, P)
	
	if len(A_Team) < 2: %Field.connect_Hochzeit()
		

@rpc("call_local", "any_peer")
func end_round():
	round_counter = round_counter + 1
	
	if round_counter > 1:
		%Field.set_sc_flag.rpc(true)
		round_counter = 0
	
	if round_counter > 3:
		%Field.disconnect_Hochzeit.rpc()
	
	%Field.collect_cards.rpc()

@rpc("call_local", "any_peer")
func on_continue():
	vote_counter = vote_counter + 1
	
	%ScoreBoard.set_label.rpc(str(vote_counter))
	
	if vote_counter == 2: #change the 2 back to 4 pls
		vote_counter = 0
		
		%ScoreBoard.set_label.rpc(str(vote_counter))
		
		start_match()

func start_match():
	reset.rpc()
	
	for P in Player_list:
		P.reset.rpc()
	
	randomize()
	Card_list.shuffle()
	
	var count = 0
	for c in Card_list:
		allocate_player.rpc(count, c.name)
		count = count + 1
	
	allocate_team.rpc()
	
	for p in Player_list:
		p.config.rpc()

@rpc("call_local", "authority")
func reset():
	A_Team.clear()
	B_Team.clear()
	
	%Field.disconnect_Hochzeit()
