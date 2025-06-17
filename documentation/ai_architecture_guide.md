# AI Architecture Guide for Shattered Expanse

## AI-Optimized Architecture Overview

This document provides comprehensive guidance for AI coding agents working with the Shattered Expanse codebase, which has been specifically optimized for AI comprehension, development, and maintenance.

## Project Structure

The codebase follows a highly modular, AI-friendly architecture:

```
/
├── lib/                      # External libraries
│   ├── perlin.lua            # Perlin noise for procedural generation
│   └── serpent.lua           # Serialization library for save/load
├── src/                      # Source code
│   ├── config/               # Configuration settings
│   │   └── game_config.lua   # Centralized constants (400+ parameters)
│   ├── core/                 # AI-Optimized Core Systems
│   │   ├── game_manager.lua  # Central state management & coordination
│   │   ├── movement_system.lua # Player movement logic & validation
│   │   ├── landmark_system.lua # Landmark interaction handlers
│   │   └── data_validation.lua # Data integrity & validation utilities
│   ├── input/                # Input handling
│   │   └── input_handler.lua # User input processing
│   ├── rendering/            # Rendering systems
│   │   └── renderer.lua      # All visual rendering operations
│   ├── systems/              # Game systems
│   │   ├── ability_system.lua # Player abilities and effects
│   │   └── contract_system.lua # Contract generation and management
│   ├── world/                # World-related code
│   │   └── world_generation.lua # Procedural world generation
│   └── ui/                   # User interface components
├── main.lua                  # Entry point and LÖVE callbacks
└── documentation/            # AI-friendly documentation
    └── ai_architecture_guide.md # This comprehensive guide
```

## Module Interface Contracts

### GameManager (src/core/game_manager.lua)
**Purpose**: Central state management and coordination hub
**Dependencies**: WorldGeneration, ContractSystem, AbilitySystem, MovementSystem, LandmarkSystem, DataValidation, serpent, GameConfig

#### Public API
```lua
-- State Management
GameManager.initialize() -> void
GameManager.saveGame() -> void  
GameManager.loadGame() -> void
GameManager.onPlayerDeath() -> void

-- Player Actions
GameManager.movePlayer(dx: number, dy: number) -> void
GameManager.toggleViewMode() -> void
GameManager.moveMinimapCamera(dx: number, dy: number) -> void

-- Game State Queries
GameManager.isRelicReconstructed(relicName: string) -> boolean
GameManager.updateCamera() -> void
GameManager.updateNotifications(dt: number) -> void
GameManager.updateContracts(dt: number) -> void

-- Progression System
GameManager.attemptRelicReconstruction() -> boolean

-- Utility Functions
GameManager.addNotification(text: string) -> void
GameManager.formatReward(reward: table) -> string
GameManager.deepCopy(table) -> table

-- Debug Functions
GameManager.addDebugRelicFragments() -> void
GameManager.debugReconstructNextRelic() -> void
GameManager.debugAddClimbingPicks() -> void
GameManager.debugToggleRevealMap() -> void
```

### MovementSystem (src/core/movement_system.lua)
**Purpose**: Player movement logic, validation, and effects
**Dependencies**: GameConfig, AbilitySystem, WorldGeneration

#### Public API
```lua
-- Movement Validation & Execution
MovementSystem.validateMove(world, player, newX, newY) -> boolean, string|nil
MovementSystem.updatePosition(player, newX, newY) -> void
MovementSystem.applyMovementEffects(player, world) -> void

-- Exploration & Hazards
MovementSystem.exploreAroundPlayer(world, player, isRelicReconstructedFn) -> void
MovementSystem.checkHazard(world, player, x, y, addNotificationFn) -> number
MovementSystem.checkPlayerDeath(player) -> boolean
```

### LandmarkSystem (src/core/landmark_system.lua)
**Purpose**: Landmark interaction logic and type-specific handlers
**Dependencies**: GameConfig, WorldGeneration, ContractSystem

#### Public API
```lua
-- Main Interaction Handler
LandmarkSystem.processLandmarkInteraction(landmark, tile, player, world, contracts, addNotificationFn) -> void

-- Type-Specific Handlers
LandmarkSystem.handleContractScroll(landmark, tile, player, world, contracts, addNotificationFn) -> void
LandmarkSystem.handleAncientObelisk(landmark, tile, player, world, addNotificationFn) -> void
LandmarkSystem.handleHiddenSpring(landmark, tile, player, world, addNotificationFn) -> void
LandmarkSystem.handleAncientLever(landmark, tile, player, world, addNotificationFn) -> void
LandmarkSystem.handleSeerTotem(landmark, tile, player, world, addNotificationFn) -> void
LandmarkSystem.handleHiddenCache(landmark, tile, player, world, addNotificationFn) -> void
LandmarkSystem.handleGenericLandmark(landmark, tile, player, world, addNotificationFn) -> void

-- Utility Functions
LandmarkSystem.activateSecretPassage(world, addNotificationFn) -> void
LandmarkSystem.isValidCoordinate(world, x, y) -> boolean
```

### DataValidation (src/core/data_validation.lua)
**Purpose**: Data structure validation and integrity checking
**Dependencies**: GameConfig

#### Public API
```lua
-- Individual Structure Validation
DataValidation.validatePlayer(player) -> boolean, string|nil
DataValidation.validateWorld(world) -> boolean, string|nil
DataValidation.validateTile(tile) -> boolean, string|nil
DataValidation.validateLandmark(landmark) -> boolean, string|nil
DataValidation.validateGameState(gameState) -> boolean, string|nil
DataValidation.validateMetaProgression(meta) -> boolean, string|nil
DataValidation.validateCoordinates(world, x, y) -> boolean, string|nil

-- Comprehensive Validation
DataValidation.performFullValidation(gameState) -> boolean, table
DataValidation.logValidationErrors(errors, context) -> void
```

### WorldGeneration (src/world/world_generation.lua)
**Purpose**: Procedural world generation with MST pathfinding
**Dependencies**: GameConfig, perlin

#### Public API
```lua
WorldGeneration.generateWorld(width: number, height: number) -> World
WorldGeneration.isInBounds(world: World, x: number, y: number) -> boolean
```

### Renderer (src/rendering/renderer.lua)
**Purpose**: All visual rendering operations
**Dependencies**: GameManager, GameConfig

#### Public API
```lua
Renderer.render() -> void
```

### InputHandler (src/input/input_handler.lua)
**Purpose**: User input processing and command routing
**Dependencies**: GameManager

#### Public API
```lua
InputHandler.handleKeyPress(key: string) -> void
```

## Data Structure Contracts

### GameState Structure
```lua
GameState = {
    world: World,           -- Generated world data
    player: Player,         -- Player state and position
    meta: MetaProgression,  -- Persistent progression data
    viewMode: ViewMode,     -- "zoomed" | "minimap"
    camera: Camera,         -- Camera position
    minimap_camera: Camera, -- Minimap camera position
    contracts: Contracts,   -- Active and completed contracts
    notifications: Notification[] -- UI notifications
}
```

### World Structure
```lua
World = {
    width: number,
    height: number,
    tiles: Tile[][]  -- 2D array [x][y]
}
```

### Tile Structure
```lua
Tile = {
    biome: {
        id: number,
        name: string,
        color: [number, number, number],
        traversal_difficulty: number,
        hazard: string,
        is_impassable: boolean
    },
    explored: boolean,
    landmark: Landmark | nil,
    region_id: number,
    isCorridorTile: boolean
}
```

### Landmark Structure
```lua
Landmark = {
    type: string,
    discovered: boolean,
    visited: boolean,
    activated: boolean,
    looted: boolean,
    initially_hidden: boolean,
    reveals_landmark_at: {x: number, y: number} | nil
}
```

## AI Development Patterns

### Function Decomposition Strategy
1. **Single Responsibility**: Each function should have one clear purpose
2. **Predictable Inputs/Outputs**: Clear parameter types and return values
3. **Side Effect Documentation**: Document all state changes
4. **Error Handling**: Consistent error handling patterns

### Naming Conventions
- **Modules**: PascalCase (GameManager, WorldGeneration)
- **Functions**: camelCase (movePlayer, checkLandmark)
- **Constants**: UPPER_SNAKE_CASE (WORLD_WIDTH, PLAYER_STAMINA)
- **Local Variables**: snake_case (current_tile, new_position)

### Code Organization Patterns
1. **Public API First**: Public functions at top of module
2. **Private Helpers**: Internal functions at bottom
3. **Validation Functions**: Input validation near public API
4. **Constants**: At top of file or in GameConfig

### Task-Oriented Entry Points

#### Movement & Exploration Tasks
- Primary: `GameManager.movePlayer()`
- Supporting: Movement subsystem functions
- Configuration: `GameConfig.PLAYER`, `GameConfig.WORLD`

#### World Generation Tasks  
- Primary: `WorldGeneration.generateWorld()`
- Configuration: `GameConfig.WORLD`, `GameConfig.MST_PATH_SYSTEM`

#### UI & Rendering Tasks
- Primary: `Renderer.render()`
- Configuration: `GameConfig.UI`, `GameConfig.LANDMARK_SPRITES`

#### Progression & Meta-game Tasks
- Primary: `GameManager.attemptRelicReconstruction()`
- Supporting: Relic system functions
- Configuration: `GameConfig.RELIC_EFFECTS`

## AI Agent Development Guidelines

This section provides general best practices, common tasks, and debugging tips for AI coding agents working on Shattered Expanse.

### Best Practices for AI Development

1.  **Keep Module Boundaries Clear**: When adding new features, respect the separation of concerns. For example, don't put rendering code in the game manager.
2.  **Use the Config Module**: When adding new constants or magic numbers, place them in the appropriate section of `game_config.lua` rather than hardcoding values.
3.  **Document Complex Logic**: When implementing complex algorithms or game mechanics, include clear comments that explain the logic.
4.  **Follow Existing Patterns**: Match the coding style and patterns already in use to maintain consistency.
5.  **Update Documentation**: When making significant changes to the codebase structure, update this guide to help future developers.

### Common Tasks

#### Adding a New Feature

1.  Identify which module(s) need to be modified.
2.  Add any new configuration constants to `game_config.lua`.
3.  Implement the core logic in the appropriate module.
4.  Add any rendering code to `renderer.lua`.
5.  Add any input handling to `input_handler.lua`.
6.  Update the documentation if needed.

#### Debugging Tips

1.  Use `print()` statements to output debug information to the LÖVE console.
2.  Check the state structure in `GameManager.GameState` to verify values.
3.  Verify configuration values in `game_config.lua`.
4.  Test input handling through the `InputHandler` module.

### When Adding New Features (Specific to this Architecture)
1. **Identify Module**: Determine which module owns the feature
2. **Check Interfaces**: Ensure new functions follow API contracts
3. **Update Documentation**: Add to interface definitions
4. **Test Integration**: Verify with other modules

### When Debugging Issues (Specific to this Architecture)
1. **State Inspection**: Check GameManager.GameState structure
2. **Configuration Values**: Verify GameConfig parameters
3. **Module Boundaries**: Ensure proper separation of concerns
4. **Error Propagation**: Follow error handling patterns

### When Optimizing Performance (Specific to this Architecture)
1. **Profile First**: Identify actual bottlenecks
2. **Cache Frequently Used**: Store computed values appropriately
3. **Reduce Allocations**: Reuse objects where possible
4. **Batch Operations**: Group similar operations together
