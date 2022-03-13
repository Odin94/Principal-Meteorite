extends Node

const save_path = "user://savegame.save"

var coming_from_door = ""

var player_direction = 1

var collected_health_powerups: Array = []
var collected_jump_powerups: Array = []
var collected_beam_powerups: Array = []
var player_health = 99


func save():
    var save_game = File.new()
    save_game.open(save_path, File.WRITE)
    var root = get_tree().get_root()
    
    var save_data = {
        "collected_health_powerups": collected_health_powerups,
        "collected_jump_powerups": collected_jump_powerups,
        "collected_beam_powerups": collected_beam_powerups,
        "player_health": player_health,
        "player_direction": player_direction,
        "coming_from_door": coming_from_door,
        "current_level": "res://Levels/" + root.get_child(root.get_child_count() - 1).name + ".tscn"
       }
    save_game.store_line(to_json(save_data))
    
    
func load():
    var save_game = File.new()
    if not save_game.file_exists(save_path):
        push_error("save file not found")
        return
        
    save_game.open(save_path, File.READ)
    var save_data = parse_json(save_game.get_line())
    
    print(save_data)
    
    collected_health_powerups = save_data["collected_health_powerups"]
    collected_jump_powerups = save_data["collected_jump_powerups"]
    collected_beam_powerups = save_data["collected_beam_powerups"]
    player_health = save_data["player_health"]
    player_direction = save_data["player_direction"]
    coming_from_door = save_data["coming_from_door"]
    var level_to_load = save_data["current_level"]
    
    #var root = get_tree().get_root()
    #var current_scene = root.get_child(root.get_child_count() - 1)
    #current_scene.free()
    
    get_tree().change_scene(level_to_load)
    
    
    
