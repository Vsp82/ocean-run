extends Node

var rumble_enabled: bool = true
const SAVE_PATH = "user://settings.cfg"
var config = ConfigFile.new()
var master_volume: float = 0.0
var totaldeaths: int = 0

func _ready():
	config.load(SAVE_PATH)
	rumble_enabled = config.get_value("settings", "rumble", true)
	master_volume = config.get_value("settings", "volume", 0.0)
	totaldeaths = config.get_value("settings", "deaths", 0)
	AudioServer.set_bus_volume_db(0, master_volume)

func save_rumble(value: bool):
	rumble_enabled = value
	config.set_value("settings", "rumble", value)
	config.save(SAVE_PATH)

func save_volume(value: float):
	master_volume = value
	config.set_value("settings", "volume", value)
	config.save(SAVE_PATH)

func add_death():
	totaldeaths += 1
	config.set_value("settings", "deaths", totaldeaths)
	config.save(SAVE_PATH)
