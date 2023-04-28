extends Node

signal finished_save

var SAVE_FILE = "user://SaveData.tres"
var save_data = {}
var PD = PlayerData.new()

func create_new_save(cr_new = false):
	if !FileAccess.file_exists(SAVE_FILE):
		ResourceSaver.save(PD, SAVE_FILE)
		load_save()
	elif cr_new:
		ResourceSaver.save(PD, SAVE_FILE)
		load_save()

func load_save():
	if FileAccess.file_exists(SAVE_FILE):
		PD = ResourceLoader.load(SAVE_FILE).duplicate(true)

func save():
	await ResourceSaver.save(PD, SAVE_FILE)
	emit_signal("finished_save")

func get_data():
	PD = ResourceLoader.load(SAVE_FILE).duplicate(true)

