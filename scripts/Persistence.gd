extends Node

export var save_game_path = "user://savegame.bin"

func save_game():
	var f = File.new()
	# TODO(indutny): encrypt saves before release
	# var err = save_game.open_encrypted_with_pass(
	# 	"user://savegame.bin", File.WRITE, "5Z7YVf8t2Lw")
	var err = f.open(save_game_path, File.WRITE)
	assert(err == OK)

	var nodes = get_tree().get_nodes_in_group("Persist")
	for node in nodes:
		var path = node.get_path()
		var data = node.serialize()
		
		f.store_line(to_json({
			"path": path,
			"data": data
		}))
	f.close()

func load_game():
	var f = File.new()
	
	var err = f.open(save_game_path, File.READ)
	if err == ERR_FILE_NOT_FOUND:
		return
	
	assert(err == OK)
	while f.get_position() < f.get_len():
		var line = parse_json(f.get_line())
		get_node(line["path"]).deserialize(line["data"])
	f.close()
