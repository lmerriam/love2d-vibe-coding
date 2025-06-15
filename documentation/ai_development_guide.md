# AI Development Guide for Shattered Expanse

This document provides a comprehensive overview of the code structure and patterns used in Shattered Expanse, specifically designed to make it easier for AI coding agents to comprehend, develop, and maintain the codebase.

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
    └── ai_development_guide.md # This file
```

## Core Design Patterns

### Module Pattern

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

### Centralized Configuration

All game constants and configuration settings are centralized in `src/config/game_config.lua` to make it easy to find and modify parameters.

### State Management

Game state is centralized in `GameManager.GameState`, allowing for easy access to the current state of the game from any module. This approach simplifies state management and ensures consistency.

## Key Components

### GameManager (src/core/game_manager.lua)

The central module that manages game state, initialization, saving/loading, player movement, and game mechanics. It maintains the global `GameState` table that tracks the world, player, and meta-progression.

### Renderer (src/rendering/renderer.lua)

Handles all drawing operations with specialized functions for different aspects of the game (world, player, UI, notifications, contracts).

### InputHandler (src/input/input_handler.lua)

Processes all user input and translates key presses into game actions.

### World Generation (src/world/world_generation.lua)

Handles procedural world generation using Perlin noise from `lib/perlin.lua`.

### Contract System (src/systems/contract_system.lua)

Manages the generation, tracking, and completion of player contracts/quests.

### Ability System (src/systems/ability_system.lua)

Manages player abilities, their effects, and upgrade paths.

## Best Practices for AI Development

1. **Keep Module Boundaries Clear**: When adding new features, respect the separation of concerns. For example, don't put rendering code in the game manager.

2. **Use the Config Module**: When adding new constants or magic numbers, place them in the appropriate section of `game_config.lua` rather than hardcoding values.

3. **Document Complex Logic**: When implementing complex algorithms or game mechanics, include clear comments that explain the logic.

4. **Follow Existing Patterns**: Match the coding style and patterns already in use to maintain consistency.

5. **Update Documentation**: When making significant changes to the codebase structure, update this guide to help future developers.

## Common Tasks

### Adding a New Feature

1. Identify which module(s) need to be modified
2. Add any new configuration constants to `game_config.lua`
3. Implement the core logic in the appropriate module
4. Add any rendering code to `renderer.lua`
5. Add any input handling to `input_handler.lua`
6. Update the documentation if needed

### Debugging Tips

1. Use `print()` statements to output debug information to the LÖVE console
2. Check the state structure in `GameManager.GameState` to verify values
3. Verify configuration values in `game_config.lua`
4. Test input handling through the `InputHandler` module

## Future Improvements

Areas that could benefit from further modularization:

1. Split large systems into smaller, more focused modules
2. Create dedicated entity classes for complex game objects
3. Implement a proper event system for communication between modules
4. Add more comprehensive error handling and validation

By following this guide, AI coding agents should be able to navigate, understand, and modify the codebase effectively.
