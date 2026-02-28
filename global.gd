extends Node

var rumble_enabled: bool = true
const SAVE_PATH = "user://settings.cfg"
var config = ConfigFile.new()

func _ready():
	config.load(SAVE_PATH)
	rumble_enabled = config.get_value("settings", "rumble", true)

func save_rumble(value: bool):
	rumble_enabled = value
	config.set_value("settings", "rumble", value)
	config.save(SAVE_PATH)
