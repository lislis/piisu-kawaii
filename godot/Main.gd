extends Spatial

var cuts = [Vector3(-15, 120, 0), 
			Vector3(-35, 35, -47),
			Vector3(-18, 145, -8),
			Vector3(-22, 48, 52),
			Vector3(1, -115, -15)]
var current_cut = Vector3()
var cut_index = 0
var rot = Vector3(0, 45, 0)
var controller = Vector3()
export var wiggle = 60

export var websocket_url = "ws://localhost:8088"
var _client = WebSocketClient.new()

func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	current_cut = cuts[cut_index]
	get_node("BackgroundSound").play()

func _process(delta):
	var player = get_node("Player")
	player.rotation = controller
	if (player.rotation.x <= current_cut.x + wiggle
	&& player.rotation.x >= current_cut.x - wiggle
	&& player.rotation.y <= current_cut.y + wiggle
	&& player.rotation.y >= current_cut.y - wiggle):
		print("BINGO")
		get_node("TooCuteSound").play()
		cut_index += 1
		if cut_index == cuts.size():
			print("YOU WIN")
		else:
			current_cut = cuts[cut_index]
		print(player.rotation)

	if cut_index == 0:
		get_node("Cutout/Sprite1").visible = true
		#get_node("Cutout").translate(Vector3(0, 10, 7))
	elif cut_index == 1:
		get_node("Cutout/Sprite1").visible = false
		get_node("Cutout/Sprite2").visible = true
		#get_node("Cutout").translate(Vector3(1, 11, 4))
	elif cut_index == 2:
		get_node("Cutout/Sprite2").visible = false
		get_node("Cutout/Sprite3").visible = true
		#get_node("Cutout").translate(Vector3(2, 11, 2))
	elif cut_index == 3:
		get_node("Cutout/Sprite3").visible = false
		get_node("Cutout/Sprite4").visible = true
		#get_node("Cutout").translate(Vector3(4, 9, 0))
	elif cut_index == 4:
		get_node("Cutout/Sprite4").visible = false
		get_node("Cutout/Sprite5").visible = true
		#get_node("Cutout").translate(Vector3(5, 8, -3))

	_client.poll()

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	print("Connected with protocol: ", proto)
	_client.get_peer(1).put_packet("Test packet".to_utf8())

func _on_data():
	var packet = _client.get_peer(1).get_packet().get_string_from_utf8()
	var data = {}
	data = JSON.parse(packet)
	if data.error == OK:
		controller.x = float(data.result["x"])
		controller.y = - float(data.result["y"])
		controller.z = float(data.result["z"])
		#print("Got data from server: ", data.result) 
