extends Node2D

func initiate_dialog():
	DialogueManager

func change_scene():
	SaveManager.PD.SE.progress_chapter()
	await SaveManager.save()
	print("cutscene finished!")

func _ready():
	Global._change_title("ES - Prolouge")
	$AnimationPlayer.play("egg_cracking")
