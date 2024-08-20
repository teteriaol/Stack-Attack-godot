extends Node2D

@export var crate_scene: PackedScene
@onready var score_label: Label = $HUD/Score
var score: int = 0

@onready var spawn_timer: Timer = $SpawnTimer
@onready var log_timer: Timer = $LogTimer
@onready var game_over: Label = $HUD/GameOver	

func _ready():
	game_over.visible = false
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	spawn_timer.start()
	log_timer.connect("timeout", Callable(self, "_on_log_timer_timeout"))
	log_timer.start()
		

func _on_spawn_timer_timeout():
	if crate_scene:
		var step = 48
		var start = 189
		var end = 576

		var values = []
		for i in range(start, end + step, step):
			values.append(i)
		var random_x = values[randi() % values.size()]
		var crate_instance = crate_scene.instantiate()

		crate_instance.position = Vector2(random_x, 0)
		add_child(crate_instance)

func _on_log_timer_timeout():
	var children = get_children()
	var height_counts = {}
	var crates_to_remove = []
	
	for child in children:
		if child is RigidBody2D and (child.name == "Crate" or "RigidBody2D@" in child.name):
			var height = round(child.position.y)
			var found = false
			for key in height_counts.keys():

				if key == height:
					height_counts[height] += 1
					found = true
					break
			if not found:
				height_counts[height] = 1
	for height in height_counts.keys():
		if height_counts[height] >= 10:
			for child in children:
				if child is RigidBody2D and (child.name == "Crate" or "RigidBody2D@" in child.name) and round(child.position.y) == height:
					crates_to_remove.append(child)
			increase_score(1000)
	if len(height_counts.keys())>10:
		game_over.visible = true
		get_tree().paused = true
				
	for crate in crates_to_remove:
		crate.queue_free()
	increase_score(1)

func update_score():
	score_label.text = str(score)
	
func increase_score(amount: int):
	score += amount
	update_score()
