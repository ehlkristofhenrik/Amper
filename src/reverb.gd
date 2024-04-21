extends GraphNode

var classes = [
	AudioEffectAmplify,
	AudioEffectChorus, 
	AudioEffectCompressor, 
	AudioEffectDelay, 
	AudioEffectDistortion, 
	AudioEffectEQ, 
	AudioEffectFilter, 
	AudioEffectLimiter, 
	AudioEffectPanner, 
	AudioEffectPhaser, 
	AudioEffectPitchShift,
	AudioEffectReverb, 
	AudioEffectSpectrumAnalyzer,
	AudioEffectStereoEnhance
]

var instance = null

func _ready():
	
	set_slot_enabled_left(get_input_port_slot(0), true)
	set_slot_enabled_right(get_output_port_slot(0), true)
	for i in classes:
		$Options.add_item( i.new().get_class().replace("AudioEffect","") )
	_on_options_item_selected(0)

func _on_options_item_selected(index):
	
	instance = classes[index].new()
	
	for i in get_children():
		if i.is_class("Label") or i.is_class("SpinBox") or i.is_class("CheckBox") or i.is_class("LineEdit"):
			if i.name != "Name":
				i.queue_free()
	
	for i in instance.get_property_list():
		var input = null
		if "resource" in i.name or i.name.to_lower() != i.name:
			continue
		elif i.type == TYPE_FLOAT or i.type == TYPE_INT:
			input = SpinBox.new()
		elif i.type == TYPE_BOOL:
			input = CheckBox.new()
		elif i.type == TYPE_STRING:
			input = LineEdit.new()
		else:
			continue
		
		input.set_meta("propname", i.name)
		
		var label = Label.new()
		label.text = i.name
		
		if input is SpinBox:
			if i.type == TYPE_FLOAT:
				input.step = 0.01
			input.value = instance.get(i.name)
			input.value_changed.connect(update_instance)
		elif input is CheckBox:
			input.button_pressed = instance.get(i.name)
			input.toggled.connect(update_instance)
		elif input is LineEdit:
			input.text = instance.get(i.name)
			input.text_changed.connect(update_instance)
		
		add_child( label )
		add_child( input )

func update_instance(_v):
	print(instance)
	for i in get_children():
		if i.is_class("SpinBox"):
			var _name = i.get_meta("propname")
			instance.set(_name, i.value)
			print(_name, i.value)
		elif i.is_class("CheckBox"):
			var _name = i.get_meta("propname")
			instance.set(_name, i.button_pressed)
			print(_name, i.button_pressed)
		elif i.is_class("LineEdit"):
			var _name = i.get_meta("propname")
			instance.set(_name, i.text)
			print(_name, i.text)

func get_instance():
	return instance

func _on_delete_pressed():
	queue_free()

func _on_name_text_changed(new_text):
	title = new_text

func _on_button_button_down():
	pass # Replace with function body.


func _on_button_button_up():
	pass # Replace with function body.
