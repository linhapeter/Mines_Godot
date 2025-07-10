extends TileMap

class_name MinesGrid

signal flag_change(number_of_flags)
signal game_lost
signal game_won

const CELLS = {
	"1": Vector2i(0, 0),
	"2": Vector2i(1, 0),
	"3": Vector2i(2, 0),
	"4": Vector2i(3, 0),
	"5": Vector2i(4, 0),
	"6": Vector2i(0, 1),
	"7": Vector2i(1, 1),
	"8": Vector2i(2, 1),
	"CLEAR": Vector2i(3, 1),
	"MINE_RED": Vector2i(4, 1),
	"FLAG": Vector2i(0, 2),
	"MINE": Vector2i(1, 2),
	"DEFAULT": Vector2i(2, 2)
}

@export var columns = 8
@export var rows = 8
@export var number_of_mines = 10

const TILE_SET_ID = 0
const DEFAULT_LAYER = 0

var cells_with_mines = []
var cells_with_flags = []
var flags_placed = 0
var cells_checked_recursively = []
var is_game_finished = false

func _ready():
	clear_layer(DEFAULT_LAYER)
	
	for i in rows:
		for j in columns:
			var cell_coord = Vector2(i - rows / 2, j - columns / 2)
			set_tile_cell(cell_coord, "DEFAULT")
	place_mines()

func set_tile_cell(cell_coord, cell_type):
	set_cell(DEFAULT_LAYER, cell_coord, TILE_SET_ID, CELLS[cell_type])

func place_mines():
	for i in number_of_mines:
		var cell_coordinates = Vector2i(randi_range(- rows / 2, rows / 2 - 1), randi_range(- columns / 2, columns / 2 - 1))
		
		while cells_with_mines.has(cell_coordinates):
			cell_coordinates = Vector2i(randi_range(- rows / 2, rows / 2 - 1), randi_range(- columns / 2, columns / 2 - 1))
		cells_with_mines.append(cell_coordinates)
		
	for cell in cells_with_mines:
		erase_cell(DEFAULT_LAYER, cell)
		set_cell(DEFAULT_LAYER, cell, TILE_SET_ID, CELLS.DEFAULT, 1)
		var tile_data = get_cell_tile_data(DEFAULT_LAYER, cell)
		tile_data.set_custom_data("has_mine", true)
		
func _input(event: InputEvent):
	
	if is_game_finished:
		return
	
	if event is not InputEventMouseButton || !event.pressed:
		return
	
	var clicked_cell_coord = local_to_map(get_local_mouse_position())
	
	if event.button_index == 1:
		on_cell_clicked(clicked_cell_coord)
	elif event.button_index == 2:
		place_flag(clicked_cell_coord)

func on_cell_clicked(cell_coord):
	
	if cells_with_flags.any(func (cell): return cell.x == cell_coord.x && cell.y == cell_coord.y):
		return
	if cells_with_mines.any(func (cell): return cell.x == cell_coord.x && cell.y == cell_coord.y):
		
		lose(cell_coord)
		return
	
	cells_checked_recursively.append(cell_coord)
	handle_cells(cell_coord, true)
	
	if cells_with_flags.has(cell_coord):
		flags_placed -= 1
		flag_change.emit (flags_placed)
		cells_with_flags.erase(cell_coord)
func handle_cells(cell_coord, should_stop_after_mine = false):
	var tile_data = get_cell_tile_data(DEFAULT_LAYER, cell_coord)
	
	if tile_data == null:
		return
		
	var cell_has_mine = tile_data.get_custom_data("has_mine")
	
	if cell_has_mine && should_stop_after_mine:
		return
	
	var mine_count = get_surrounding_cells_mine_count(cell_coord)
	
	if mine_count == 0:
		set_tile_cell(cell_coord, "CLEAR")
		var surrounding_cells = get_surrounding_cells_to_check(cell_coord)
		for cell in surrounding_cells:
			handle_surrounding_cell(cell)
	else:
		set_tile_cell(cell_coord, "%d" % mine_count)
	
	
	
func get_surrounding_cells_mine_count(cell_coord):
	var mine_count = 0
	var surrounding_cells = get_surrounding_cells_to_check(cell_coord)
	
	for cell in surrounding_cells:
		var tile_data = get_cell_tile_data(DEFAULT_LAYER, cell)
		
		if cells_with_mines.has(cell):
			mine_count += 1
			
	return mine_count

func handle_surrounding_cell(cell_coord):
	if cells_checked_recursively.has(cell_coord) or cells_with_flags.any(func (cell): return cell.x == cell_coord.x && cell.y == cell_coord.y):
		return
		
	cells_checked_recursively.append(cell_coord)
	handle_cells(cell_coord)
	
func lose(cell_coord):
	game_lost.emit()
	is_game_finished = true 
	
	for cell in cells_with_mines:
		set_tile_cell(cell, "MINE")
		
	set_tile_cell(cell_coord, "MINE_RED")
	await get_tree().create_timer(1).timeout
	get_tree().reload_current_scene()
func place_flag(cell_coord):
	var tile_data = get_cell_tile_data(DEFAULT_LAYER, cell_coord)
	var atlas_coordinates = get_cell_atlas_coords(DEFAULT_LAYER, cell_coord)
	var is_empty_cell = atlas_coordinates == Vector2i(2,2)
	var is_flag_cell = atlas_coordinates == Vector2i(0,2)
	
	if !is_empty_cell && !is_flag_cell:

		return
		
	if is_flag_cell:
		set_tile_cell(cell_coord, "DEFAULT")
		cells_with_flags.erase(cell_coord)
		flags_placed -= 1

	elif is_empty_cell:
		if flags_placed == number_of_mines:
			return
			
		flags_placed += 1
		set_tile_cell(cell_coord, "FLAG")
		cells_with_flags.append(cell_coord)
		
	flag_change.emit(flags_placed)
		
	var count = 0
	for flag_cell in cells_with_flags:
		for mine_cell in cells_with_mines:
			if flag_cell.x == mine_cell.x && flag_cell.y == mine_cell.y:
				count += 1
				
	if count == cells_with_mines.size():
		win()
		
func win():
	is_game_finished = true
	game_won.emit()
	await get_tree().create_timer(1).timeout
	get_tree().reload_current_scene()
func get_surrounding_cells_to_check(current_cell:Vector2i):
	var target_cell
	var surrounding_cells = []
	
	for y in 3:
		for x in 3:
			if x == 1 and y == 1:
				continue
			target_cell = current_cell + Vector2i(x - 1, y - 1)
			surrounding_cells.append(target_cell)
	
	return surrounding_cells
