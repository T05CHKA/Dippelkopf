extends Movable_Object

var value: int = 20
var fliped: bool = false
var faded: bool = false
var on_field: bool = false

var r_flag: bool = false
var u_flag: bool = false

var CardDatabase = preload("res://Code/Database.gd")
var CardInfo

func config():
	set_value(name.to_int() % 20)

func set_value(newValue):
	value = newValue
	CardInfo = CardDatabase.DATA[value]

func _process(delta):
	if r_flag:
		if returning:
			reveal.rpc()
			r_flag = false
	if u_flag:
		un_reveal.rpc()
		u_flag = false

func reset():
	on_field = false

@rpc("any_peer")
func flip():
	if !fliped:
		$AnimationPlayer.play("Flip")
		fliped = true
	else:
		$AnimationPlayer.play("Unflip")
		fliped = false

@rpc("any_peer")
func fade():
	if !faded:
		$AnimationPlayer.play("Fade")
		faded = true
	else:
		$AnimationPlayer.play("Unfade")
		faded = false

@rpc("any_peer")
func reveal():
	if parent.unique_id != multiplayer.get_unique_id():
		if !fliped: flip()

@rpc("any_peer")
func un_reveal():
	if parent.unique_id != multiplayer.get_unique_id():
		if fliped: flip()

func pressed():
	if !on_field:
		fade.rpc()

func released():
	if !on_field:
		fade.rpc()
	
	parent.locate_target_for(self)
