# Progress Tracking

## What Works

- **Core Game Loop**
  - Player movement around the procedurally generated world
  - Exploration and discovery mechanics
  - Hazard interactions based on biome types
  - Contract system for quests/goals
  - Save/load system for meta-progression

- **Architectural Improvements**
  - Modular codebase with clear separation of concerns
  - Centralized configuration in game_config.lua
  - Well-documented code structure
  - Input handling isolated in dedicated module
  - Rendering logic separated from game logic

- **Technical Systems**
  - **Advanced Procedural World Generation:**
    - Multi-layered generation system using Perlin noise
    - Region-based biome palettes and difficulty tiers
    - **MST Path System:** Graph-based path generation using Minimum Spanning Tree algorithm connecting player start, region centers, major landmarks, and strategic nodes
    - Terrain-aware pathfinding with biome penalties and region-crossing bonuses
    - Natural path wobble effects and corridor width control
    - Border chokepoints and strategic corridor integration
  - Contract generation and completion tracking
  - Ability system with passive and active abilities
  - Notification system for player feedback
  - Centralized game state management
  - **Relic System**:
    - Relic definition and fragment tracking in `GameState`.
    - UI for displaying relic reconstruction status and fragment requirements.
    - Player ability to attempt relic reconstruction by spending fragments.
    - Debug tools for adding fragments and auto-reconstructing relics.
    - Robust save/load and death persistence for relic fragments and status.
    - **Implemented Passive Relic Effects**:
        - Chrono Prism: Repurposed to reduce hazard stamina loss by 25%.
        - Aether Lens: Increases exploration radius.
        - Void Anchor: Chance to ignore hazard stamina loss.
        - Life Spring: Increases starting stamina.
        - Effects are configured in `game_config.lua` and integrated into `game_manager.lua`.
  - **Landmark Navigation Enhancement (Obelisk-Spring)**:
    - Added "Ancient Obelisk" and "Hidden Spring" landmark types.
    - Obelisks now reveal the location of a linked Hidden Spring upon discovery.
    - Implemented generation logic for these pairs in `world_generation.lua`.
    - Added `OBELISK_PAIRS_COUNT` to `game_config.lua`.
    - Updated `game_manager.lua` to handle the reveal mechanic (including setting the revealed tile as `explored` for minimap visibility) and notifications.
    - Updated `renderer.lua` to display unique map icons ("O", "H") for these landmarks when discovered but unvisited.
  - **Landmark Navigation Enhancement (Ancient Lever & Secret Passage)**:
    - Added "Ancient Lever" landmark type and `SECRET_PASSAGES` configuration.
    - Levers, when activated, now change predefined impassable tiles to passable ones.
    - Implemented generation logic for Levers and initial state of passage tiles in `world_generation.lua`.
    - Updated `game_manager.lua` to handle Lever activation and passage transformation.
    - Updated `renderer.lua` to display "L" (via `GameConfig.MAP_ICONS.ANCIENT_LEVER`) for discovered Levers.
  - **Landmark Navigation Enhancement (Seer's Totem & Hidden Cache)**:
    - Added "Seer's Totem" and "Hidden Cache" landmark types.
    - Totems reveal linked Caches; Caches provide rewards.
    - Implemented generation logic in `world_generation.lua` (including `SEER_CACHE_PAIRS_COUNT` from config).
    - Added `LANDMARK_CONFIG.HIDDEN_CACHE_REWARD` and map icons ("S", "$") to `game_config.lua`.
    - Updated `game_manager.lua` to handle Totem discovery (revealing Cache, setting tile explored) and Cache discovery (granting reward, marking as looted).
    - Updated `renderer.lua` to display map icons for these new landmarks (this was subsequently replaced by the landmark sprite system).
  - **Landmark Visuals Enhancement**:
    - Replaced character-based map symbols with simple, distinct icons rendered using LÖVE2D's drawing primitives.
    - Added `LANDMARK_SPRITES` table to `game_config.lua`, defining drawing instructions (shape, color, params) for each landmark type.
    - Modified `renderer.lua` to use these sprite definitions for discovered, unvisited landmarks.

## What's Left to Build

1.  **Gameplay Testing & Balancing**:
    *   **Test Landmark Navigation Enhancement (Seer's Totem & Hidden Cache)**:
        *   Verify "Seer's Totem" and "Hidden Cache" landmarks are generated.
        *   Confirm visiting a "Seer's Totem" reveals its linked "Hidden Cache" on the map.
        *   Verify visiting a "Hidden Cache" grants the configured reward and marks it looted.
        *   Check notifications and map symbols ("S", "$").
        *   Assess gameplay impact.
    *   **Test Landmark Navigation Enhancement (Ancient Lever & Secret Passage)**:
        *   Verify "Ancient Lever" landmarks are generated.
        *   Confirm the predefined secret passage area is initially impassable.
        *   Test activating an "Ancient Lever" correctly changes passage tiles to passable and explored.
        *   Check notifications and map symbol ("L") for the lever.
        *   Assess gameplay impact.
    *   **Test Landmark Navigation Enhancement (Obelisk-Spring)**:
        *   Verify Obelisks and Hidden Springs are generated according to `OBELISK_PAIRS_COUNT`.
        *   Confirm visiting an Ancient Obelisk reveals its linked Hidden Spring on the map (landmark `discovered` and tile `explored` are true).
        *   Verify the revealed Hidden Spring is visible on the minimap.
        *   Check notifications and map symbols ("O", "H").
        *   Assess gameplay impact.
    *   Thoroughly test the new stamina system (no default loss, hazard-only loss).
    *   Verify the new biome distribution (Desert most common, Mountains least) and overall world structure (regions, corridors, chokepoints).
    *   Assess overall game difficulty and pacing with these changes.
2.  **Relic System Review & Refinement**:
    *   Consider if any UI indicators are needed for active relic buffs.

3. **UI Improvements (General)**
   - Better visual indicators for abilities (non-relic).
   - Enhanced contract display
   - More informative player status screen

2. **Gameplay Features**
   - More biome types with unique characteristics
   - Additional landmark types with special interactions
   - More ability types and progression paths
   - Victory condition and end-game sequence

3. **Visual and Audio Enhancements**
   - Improved tile graphics for different biomes
   - Sound effects for actions and discoveries
   - Background music for different areas
   - Visual effects for ability activations

4. **Performance Optimizations**
   - Limit rendering to visible area
   - Optimize contract progress checking
   - Cache procedural generation results
   - Reduce memory usage for large worlds

## Future Gameplay Enhancements: World Navigation

This section outlines brainstormed ideas to make world navigation more interesting and structured.

**I. Restructuring World Layout & Biome Distribution**
    *   **Defined Regions/Continents:** Generate larger, distinct landmasses or regions with thematic biome collections.
    *   **Natural Chokepoints & Pathways:** Design world generation to create natural chokepoints (mountain passes, narrow isthmuses) guiding player movement.
    *   **Tiered Biome Progression & "Hub" Zones:** Structure the world so higher-risk/reward biomes are further from the start or soft-gated. Introduce hub biomes or landmarks.

**II. Implementing Navigational Obstacles & Gating Mechanisms**
    *   **Environmental Barriers:** Introduce initially impassable/costly terrain (e.g., dense thickets, deep rivers, sheer cliffs) requiring tools/abilities.
    *   **Severe Hazard Zones:** Design sub-regions with extreme stamina drain or effects, requiring specific countermeasures.
    *   **Ability/Item Gating:** Make areas inaccessible without specific abilities (Glide, Swim, Climb) or consumable items.
    *   **Knowledge Gating:** Require finding map fragments or clues to reveal safe paths or bypass obstacles.
    *   **Dynamic World Events (Advanced):** Temporary events altering paths (sandstorms, floods, magical barriers).

**III. Enhancing Landmark Significance for Navigation**
    *   **Landmarks as Keys/Activators:** Interactive landmarks that trigger world changes (raise bridges, dispel barriers).
    *   **Landmarks Providing Navigational Tools/Info:** Landmarks granting temporary boons (wider map reveal, pointing to hidden locations).
    *   **Chains of Landmarks:** Mini-quests involving sequences of landmarks leading to rewards or new areas.

**IV. Leveraging Existing Mechanics for Structured Navigation**
    *   **Contracts for Guided Progression:** Design contracts requiring navigation through or overcoming new obstacles.
    *   **Relics Granting Navigational Advantages:** Reconstructed Relics offering powerful navigational abilities (teleportation, hazard immunity, revealing hidden paths).
    *   **Stamina as a Strategic Resource for Traversal:** Severe hazard zones requiring careful stamina management, planning, or specific items/abilities.

## Current Status

The refactoring effort has significantly improved the codebase organization and maintainability. The game is now structured in a way that makes it much easier for AI coding agents to comprehend and extend.

**Recent Developments (Post-Refactor):**
- **Landmark Navigation Enhancement (Obelisk-Spring):**
    - **`src/world/world_generation.lua`**: Added "Ancient Obelisk" and "Hidden Spring" to `LANDMARK_TYPES` and implemented paired placement logic. An Obelisk stores coordinates to its linked Spring, which is initially hidden.
    - **`src/config/game_config.lua`**: Added `WORLD.OBELISK_PAIRS_COUNT` (set to 2).
    - **`src/core/game_manager.lua`**: Updated `checkLandmark()` to handle Obelisk discovery, revealing the linked Hidden Spring on the map (setting landmark `discovered = true` and tile `explored = true` for minimap visibility) and providing notifications. Added specific reward for visiting a Hidden Spring.
    - **`src/rendering/renderer.lua`**: Updated `renderWorld()` to display "O" (via `GameConfig.MAP_ICONS.ANCIENT_OBELISK`) for discovered Obelisks and "H" (via `GameConfig.MAP_ICONS.HIDDEN_SPRING`) for discovered Hidden Springs (if unvisited).
- **Landmark Navigation Enhancement (Ancient Lever & Secret Passage):**
    - **`src/config/game_config.lua`**: Added `SECRET_PASSAGES.LEVER_ACTIVATED` configuration.
    - **`src/world/world_generation.lua`**: Added "Ancient Lever" landmark type, updated placement logic, and added a pass to ensure secret passage tiles are initialized correctly.
    - **`src/core/game_manager.lua`**: Updated `checkLandmark()` to handle "Ancient Lever" activation, opening the passage.
    - **`src/rendering/renderer.lua`**: Updated `renderWorld()` to display "L" (via `GameConfig.MAP_ICONS.ANCIENT_LEVER`) for discovered "Ancient Lever" landmarks.
- **Landmark Navigation Enhancement (Seer's Totem & Hidden Cache):**
    - **`src/config/game_config.lua`**: Added `WORLD.SEER_CACHE_PAIRS_COUNT`, `LANDMARK_CONFIG.HIDDEN_CACHE_REWARD`, and map icons for "Seer's Totem" ("S") and "Hidden Cache" ("$") under `MAP_ICONS`.
    - **`src/world/world_generation.lua`**: Added "Seer's Totem" and "Hidden Cache" to `LANDMARK_TYPES`. Implemented paired placement logic, marking Caches as initially hidden and unlooted.
    - **`src/core/game_manager.lua`**: Updated `checkLandmark()` to handle Totem discovery (reveals Cache, marks tile explored) and Cache discovery (grants reward from config, marks looted).
    - **`src/rendering/renderer.lua`**: Updated `renderWorld()` to display configured map icons for discovered Totems and Caches.
- **Impassable Terrain Tuning:**
    - **`src/world/world_generation.lua`**: Increased `IMPASSABLE_CHANCE` to 0.75 for "Impassable Mountain Face" generation to create more solid barriers.
- **UI Bug Fix (Inventory Display):**
    - **`src/rendering/renderer.lua`**: Fixed a bug in `renderUI` where boolean inventory items (e.g., `has_climbing_picks`) would cause a concatenation error. Boolean values are now displayed as "Yes"/"No".
- **Environmental Barriers & Item Gating (Phase 4a - Impassable Mountains):**
    - **`src/config/game_config.lua`**: Added `IMPASSABLE_MOUNTAIN_FACE` to `BIOME_IDS` and `DEBUG_ADD_CLIMBING_PICKS_KEY` ("f4").
    - **`src/world/world_generation.lua`**: Defined "Impassable Mountain Face" biome properties (including `is_impassable = true`) and added a pass to generate these at Mountain/Plains borders.
    - **`src/core/game_manager.lua`**: Updated `movePlayer` to block movement into impassable tiles unless the player has `has_climbing_picks` for mountain faces. Added `debugAddClimbingPicks` function.
    - **`src/input/input_handler.lua`**: Added "f4" key handler for `debugAddClimbingPicks`.
- **Strategic Corridor Refinement (Path Wobble):**
    - **`src/world/world_generation.lua`**: Enhanced strategic corridor generation by adding a "wobble" effect (random perpendicular offsets to path segments) to make them appear more natural. This uses `WOBBLE_FREQUENCY` and `MAX_WOBBLE_OFFSET` constants and re-uses `getLine` to ensure connectivity between wobbled points.
- **Biome Distribution Tuning:**
    - **`src/config/game_config.lua`**: Adjusted `minNoise` and `maxNoise` thresholds in `WORLD_REGIONS` biome palettes to promote more varied biome generation.
- **World Generation Overhaul (Phase 3 - Strategic Corridors Complete):**
    - **`src/config/game_config.lua`**: Added `isSafePassageTarget` flag to region definitions; configured four regions with two marked as safe targets.
    - **`src/world/world_generation.lua`**:
        - Adjusted region noise generation for four regions.
        - Implemented logic to find centers of safe hub regions.
        - Added Bresenham's line algorithm to plot paths between the starting hub and another safe hub.
        - Carves a 3-tile wide corridor of `PATH_BIOME_ID` through intermediate non-safe regions along this path.
        - Marked corridor tiles to be excluded from random chokepoint generation.
- **Debug Feature: Reveal Map:**
    - Added `REVEAL_MAP_KEY = "f3"` to `src/config/game_config.lua`.
    - Implemented `GameManager.debugToggleRevealMap()` in `src/core/game_manager.lua` to explore all tiles and discover landmarks.
    - Updated `src/input/input_handler.lua` to trigger this function on "f3" press.
- **World Generation Overhaul (Phase 2 - Chokepoints Complete):**
    - Building on Phase 1, `src/world/world_generation.lua` now includes a pass to identify border tiles between regions.
    - These border tiles have a `CHOKEPOINT_CHANCE` (10%) to be converted into a `PATH_BIOME_ID` (Rusted Oasis), creating simplified pathways.
- **World Generation Overhaul (Phase 1 - Regions & Palettes Complete):**
    - Implemented a new system in `src/world/world_generation.lua` that divides the world into distinct regions using a new Perlin noise layer (`region_map`).
    - Each region is assigned a `difficultyTier`.
    - Player starting area is now guaranteed to be within a `difficultyTier = 1` region.
    - Biome assignment within each region is now governed by a `biomePalette` defined in `GameConfig.WORLD_REGIONS` (in `src/config/game_config.lua`), allowing for thematic biome collections per region.
    - Added `BIOME_IDS` to `src/config/game_config.lua` for clarity.
- **Previous Major Gameplay Adjustments:**
    - **Stamina System Overhaul**: Removed default stamina cost per move in `game_manager.lua`. Stamina loss now only occurs from biome-specific hazards.
    - **World Generation Changes (Biome Prevalence - Superseded by Regions)**: Modified Perlin noise thresholds in `world_generation.lua` to make Desert (ID 4) the most common biome and Mountains (ID 3) the least common. This specific logic is now part of the region palettes.
- **Relic Reconstruction System & Effects**:
    - Foundational system for relic UI, fragment tracking, reconstruction logic, debug tools, and data persistence is in place.
    - Passive effects for relics were implemented. The Chrono Prism's effect has been repurposed to reduce hazard stamina loss by 25%. Other effects (Aether Lens, Void Anchor, Life Spring) remain.
- Key modules like `GameManager`, `Renderer`, `InputHandler`, `world_generation.lua` and `GameConfig` were updated.

The world generation system has been significantly restructured with regions, thematic biome palettes, random chokepoints, and now strategic corridors connecting safe hubs. The next steps involve thorough testing of this comprehensive new system and potentially refining corridor/chokepoint generation. Previous gameplay balance concerns around stamina also need re-evaluation in light of the new world structure.

## Evolution of Project Decisions

### Initial Approach
- Monolithic design with all code in main.lua
- Hardcoded constants throughout the codebase
- Limited documentation

### Current Approach
- Modular architecture with clear separation of concerns
- Centralized configuration management
- Comprehensive documentation and developer guide
- Well-defined interfaces between modules

### Reasoning
The shift to a modular architecture was motivated by the need to make the codebase more maintainable and comprehensible for AI coding agents. By separating concerns and documenting the structure clearly, we've made it much easier for developers (both human and AI) to understand the code, make changes, and add new features without introducing bugs or inconsistencies.

The centralized configuration approach makes it easier to tweak game parameters without having to search through the codebase for hardcoded values. This will be particularly valuable during the balancing phase of development.

The documentation improvements, including the comprehensive AI development guide, will significantly reduce the learning curve for new developers and make it easier to onboard AI assistants to the project.
