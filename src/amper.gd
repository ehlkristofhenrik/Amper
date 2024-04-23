extends Control

var is_playing = false
var effect = preload("res://scn/effect.tscn")
var mics = []

func _ready():
	mics = AudioServer.get_input_device_list()
	$VBox/HBox/Mic.clear()
	for i in mics:
		$VBox/HBox/Mic.add_item(i)

func _on_button_pressed():
	if is_playing:
		$Player.stop()
		$VBox/HBox/Record.text = "🔴 Record "
		is_playing = false
	else:
		$Player.play()
		$VBox/HBox/Record.text = "🔴 Recording... "
		is_playing = true


func _on_add_effect_pressed():
	$VBox/GraphEdit.add_child(effect.instantiate())

func _on_graph_edit_connection_request(from_node, from_port, to_node, to_port):
	if to_node == from_node:
		return
	for i in ($VBox/GraphEdit as GraphEdit).get_connection_list():
		if to_node == i["to_node"] or from_node == i["from_node"]:
			return
	($VBox/GraphEdit as GraphEdit).connect_node(from_node, from_port, to_node, to_port)
	update_audiobus(0)
	
func _on_graph_edit_disconnection_request(from_node, from_port, to_node, to_port):
	($VBox/GraphEdit as GraphEdit).disconnect_node(from_node, from_port, to_node, to_port)
	update_audiobus(0)

func update_audiobus(id):
	for i in range( AudioServer.get_bus_effect_count(id) ):
		AudioServer.remove_bus_effect(id, 0)
	var list = ($VBox/GraphEdit as GraphEdit).get_connection_list()
	var last = list.filter(func(x): return x['to_node'] == 'Master')
	if last == []:
		return
	var fx = []
	fx.append(last[0]['from_node'])
	while last != []:
		last = list.filter(func(x): return x['to_node'] == last[0]['from_node'])
		if last != []:
			fx.append(last[0]['from_node'])
	fx.reverse()
	for i in fx:
		var effect = $VBox/GraphEdit.get_node(NodePath(i)).get_instance()
		AudioServer.add_bus_effect(id, effect)
		print(effect)
	print(AudioServer.get_bus_effect_count(id))


func _on_rebuild_pressed():
	update_audiobus(0)


func _on_mic_item_selected(index):
	AudioServer.input_device = mics[index]
