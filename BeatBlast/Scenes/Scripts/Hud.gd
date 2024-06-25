extends CanvasLayer

@onready var bar = $bar
@onready var heart1 = $heart
@onready var heart2 = $heart2
@onready var heart3 = $heart3

func _ready():
	bar.set_frame(Playerstats.max_health/10-3)
	
func _physics_process(delta):
	heart1.set_frame(clampf(Playerstats.health ,0,11))
	heart2.set_frame(clampf(Playerstats.health-10,0,11))
	heart3.set_frame(clampf(Playerstats.health-20 ,0,11))
