Game Concept
MinesweeperGrid is a classic minesweeper game implementation using Godot's TileMap system. The game features a grid-based board where players must uncover safe cells while avoiding hidden mines.

Core Mechanics
Grid System
TileMap-based implementation with customizable dimensions (default 8x8)

Uses a sprite sheet/tileset with predefined cell types:

Numbers 1-8 for mine proximity indicators

Clear (empty) cells

Mine states (normal, red/exploded)

Flag markers

Default (unrevealed) state

Gameplay Loop
Initialization:

Grid is generated with specified rows/columns

Mines are randomly placed (default: 10)

All cells start in "DEFAULT" (hidden) state

Player Interaction:

Left-click: Reveal cell

Right-click: Place/remove flag

Auto-expansion when clicking empty areas

Win/Lose Conditions:

Lose: Clicking on a mine

Win: Correctly flagging all mines

Technical Implementation
Key Components
CELLS Dictionary: Maps cell types to tile coordinates

Game State Tracking:

cells_with_mines: Array of mine positions

cells_with_flags: Array of flagged positions

flags_placed: Current flag count

is_game_finished: Win/lose state

game_lost: Triggered when player hits a mine

game_won: Triggered when all mines are correctly flagged

Methods
Grid Management:

place_mines(): Randomly distributes mines

set_tile_cell(): Helper for cell state changes

Game Logic:

on_cell_clicked(): Handles cell reveals

handle_cells(): Processes cell state changes

get_surrounding_cells_mine_count(): Calculates adjacent mines

place_flag(): Manages flag placement/removal

Game Flow:

lose(): Shows all mines and ends game

win(): Triggers win state and resets

Design Considerations
Scalability
Configurable grid size via rows and columns exports

Adjustable mine count via number_of_mines

User Experience
Visual distinction for exploded mine (red)

Clear numerical indicators

Flagging system with count validation

Performance
Recursive cell handling for empty areas

TileData custom properties for mine tracking

Expansion Ideas
Potential Features
Difficulty levels (predefined grid/mine configurations)

Timer system

High score tracking

Visual themes (alternative tilesets)

Sound effects
