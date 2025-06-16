# Technical Context

## Technologies Used

- **LÖVE2D (Love)**: A framework for making 2D games in Lua
- **Lua**: The programming language used throughout the project
- **Serpent**: A serialization library for Lua tables
- **Perlin Noise**: Implementation for procedural world generation

## Development Environment

- Love2D version: 11.4
- No additional build tools required
- Uses standard Love2D callback structure (load, update, draw)

## Project Structure

The codebase follows a modular architecture with clear separation of concerns:

```
/
├── lib/                      # External libraries and dependencies
│   ├── perlin.lua            # Perlin noise implementation for procedural generation
│   └── serpent.lua           # Serialization library for save/load
├── src/                      # Source code
│   ├── config/               # Configuration settings
│   │   └── game_config.lua   # Centralized game constants and settings
│   ├── core/                 # Core game systems
│   │   └── game_manager.lua  # Game state and management
│   ├── input/                # Input handling
│   │   └── input_handler.lua # Processes user input
│   ├── rendering/            # Rendering systems
│   │   └── renderer.lua      # Handles all rendering operations
│   ├── systems/              # Game systems
│   │   ├── ability_system.lua # Player abilities and effects
│   │   └── contract_system.lua # Contract generation and management
│   ├── world/                # World-related code
│   │   └── world_generation.lua # Procedural world generation
│   └── ui/                   # User interface components
├── main.lua                  # Entry point and LÖVE callbacks
└── documentation/            # Documentation files
    └── ai_development_guide.md # Developer guide
```

## Technical Implementation Details

### Module System

Each major component is implemented as a Lua module with explicit exports. For example:

```lua
local MyModule = {}

function MyModule.publicFunction()
    -- Implementation
end

local function privateFunction()
    -- Implementation 
end

return MyModule
```

### State Management

Game state is centralized in `GameManager.GameState`, allowing for easy access to the current state of the game from any module. State modifications are done through GameManager functions to ensure consistency.

### Configuration System

All game constants and configuration settings are centralized in `src/config/game_config.lua` to make it easy to find and modify parameters. This includes:

- World dimensions and tile sizes (200x200 grid)
- Player starting values and relic effects
- Hazard probabilities and effects
- UI layout parameters (including Relic UI)
- Save file settings
- Debug keys (f1-f4 for fragments, reconstruction, map reveal, climbing picks)
- Gameplay action keys (r for relic reconstruction)
- MST path system configuration
- Landmark sprite definitions
- Secret passage configurations

### Advanced World Generation

The world generation system uses multiple sophisticated techniques:

- **Region-based biome palettes**: Different areas have thematic biome collections
- **MST Path System**: Minimum Spanning Tree algorithm creates strategic pathways
- **Terrain-aware pathfinding**: Paths consider biome difficulty and avoid obstacles
- **Natural path wobble**: Organic-looking corridors with random variations
- **Environmental barriers**: Impassable terrain requiring specific tools/abilities
- **Strategic chokepoints**: Border areas with pathway connections

### Love2D Callback Structure

The game follows the standard Love2D callback structure:

- `love.load()`: Initializes the game
- `love.update(dt)`: Updates game state
- `love.draw()`: Renders the game
- `love.keypressed(key)`: Handles key presses

These callbacks are kept minimal in main.lua and delegate to the appropriate modules.

## Technical Constraints

- **Performance**: The game uses a 200x200 grid for world representation, which requires careful optimization for rendering and contract checking.
- **Memory Usage**: The world state can become large, especially with explored tile tracking and complex landmark relationships.
- **Save Data**: Uses Lua's serialization through the Serpent library, which has some limitations for complex data structures.
- **MST Path Generation**: Complex pathfinding algorithms may impact world generation performance on larger worlds.

## Dependency Management

The project has minimal external dependencies:

- **serpent.lua**: Used for serialization/deserialization of game state for save/load functionality.
- **perlin.lua**: A custom implementation of Perlin noise for procedural generation.

Both are included directly in the lib/ directory, so no additional installation is required.

## Development Workflow

1. **Run the Game**: Use the Love2D engine to run the game directly
   ```
   love .
   ```

2. **Development Cycle**:
   - Make changes to source files
   - Run the game to test changes
   - Use Ctrl+S in-game to save progress if needed
   - Escape key exits the game

3. **Debugging**:
   - Use print() statements to output to the console
   - Love2D provides error messages with stack traces

## AI Development Approach

For AI-assisted development, the codebase has been structured to be easily comprehensible:

1. **Modular Organization**: Clear separation of concerns makes it easy to focus on specific components
2. **Comprehensive Documentation**: Code comments and a dedicated development guide
3. **Centralized Configuration**: Easy to find and adjust parameters
4. **Consistent Patterns**: Same patterns used throughout the codebase
5. **Memory Bank**: Detailed tracking of project state, decisions, and progress
6. **Advanced System Documentation**: Detailed technical specifications for MST paths, landmark interactions, and relic effects
7. **Visual System**: Landmark sprites defined through data structures rather than hardcoded graphics

## Current Development Focus

**Phase: Finding the Fun**
The project has reached technical maturity with all major systems implemented and working reliably. The current focus has shifted from feature development to gameplay iteration and discovering what makes the game genuinely engaging and fun.

**Current Activities:**
- **Core Gameplay Loop Discovery**: Identifying which mechanics create genuine player engagement
- **Pacing Experimentation**: Adjusting reward frequency, progression speed, and challenge difficulty
- **Player Motivation Research**: Testing whether exploration goals feel meaningful and achievable
- **Feedback Loop Refinement**: Ensuring player actions have clear, satisfying consequences
- **System Balance Testing**: Fine-tuning the interaction between all implemented systems

**Technical Foundation Status:**
All major systems are complete and functional, providing a solid platform for gameplay experimentation. The modular architecture supports rapid iteration and testing of different gameplay approaches.

**Next Phase Preparation:**
Once the core fun factor is established, development will move to content expansion and polish phases.

## Key Technical Features

### Relic System
- **Fragment-based reconstruction**: Players collect fragments to rebuild ancient artifacts
- **Passive effects**: Reconstructed relics provide permanent bonuses
- **Persistent progression**: Relic status saves across game runs
- **Debug support**: Tools for testing reconstruction mechanics

### Landmark Enhancement System
- **Interactive landmarks**: Obelisks reveal springs, levers open passages, totems reveal caches
- **Visual sprite system**: Landmarks rendered using LÖVE2D drawing primitives
- **Complex relationships**: Landmarks can reference and affect other landmark locations
- **Reward diversity**: Different landmark types provide varied progression rewards

### Advanced Pathfinding
- **Minimum Spanning Tree**: Connects all regions with optimal path network
- **Terrain penalties**: Different biomes have different traversal costs
- **Region connectivity**: Ensures all areas remain accessible
- **Natural appearance**: Wobble effects and organic curves prevent grid-like paths
