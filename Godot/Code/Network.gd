extends Control

@export var Adress = "127.0.0.1"
@export var port = 7895

var peer
var count = 1

signal ready_to_start
signal ready_to_update

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
	$MarginContainer/VBoxContainer/Host.grab_focus()

func peer_connected(_id):
	pass #print("Player Connected " + str(id))

func peer_disconnected(_id):
	pass #print("Player Disconnected " + str(id))

func connected_to_server():
	print("Server Connected")
	SendInformation.rpc_id(1, multiplayer.get_unique_id())

func connection_failed():
	pass #print("Connection failed")

@rpc("any_peer")
func SendInformation(id):
	if !GameManager.Peer_list.has(id):
		GameManager.Peer_list.append(id)
	
		ReceiveInformation.rpc_id(id, count)
		count = count + 1
	
		for i in GameManager.Peer_list:
			UpdateInformation.rpc(GameManager.Peer_list)

@rpc("any_peer", "call_local")
func ReceiveInformation(id):
	GameManager.identification = id
	emit_signal("ready_to_start")
	
@rpc("any_peer", "call_local")
func UpdateInformation(list):
	GameManager.Peer_list = list
	emit_signal("ready_to_update")

func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 3)
	if error != OK:
		print("cannot host: " + str(error))
		return
	
	multiplayer.set_multiplayer_peer(peer)
	SendInformation(multiplayer.get_unique_id())
	
	self.hide()

func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Adress, port)
	multiplayer.set_multiplayer_peer(peer)
	
	self.hide()
