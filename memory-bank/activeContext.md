### **ACTIVE CONTEXT: "SHATTERED EXPANSE"**

---

### **CURRENT WORK FOCUS**
- **Finding the Fun Phase:** All technical systems have been implemented, but the core gameplay loop needs refinement to discover what makes the game engaging and enjoyable.
- **Gameplay Iteration:** Experimenting with different mechanics, rewards, and progression pacing to find the optimal player experience.
- **Core Loop Validation:** Testing whether the exploration → discovery → progression cycle creates satisfying gameplay moments.

### **COMPLETED SYSTEMS (Fully Implemented)**
- **✅ Advanced World Generation System:** Complete MST path system with terrain-aware pathfinding, region-based biome palettes, strategic corridors, and environmental barriers
- **✅ Comprehensive Landmark System:** All landmark types implemented with full interaction mechanics (Obelisk-Spring, Ancient Lever, Seer's Totem, Hidden Cache)
- **✅ Visual Enhancement System:** Landmark sprites now rendered using a dedicated sprite sheet and quads, replacing primitive-based drawing for key landmarks.
- **✅ Relic Reconstruction System:** Complete fragment collection, reconstruction mechanics, and passive effect implementation
- **✅ Environmental Interaction System:** Impassable terrain with tool requirements (climbing picks for mountain faces)
- **✅ Enhanced Contract System:** Contract scroll discovery and relic fragment reward integration
- **✅ Save/Load Persistence:** Robust data persistence across gameplay sessions
- **✅ Debug Tool Suite:** Comprehensive debugging tools (f1-f4 keys) for testing all systems

---

### **RECENT CHANGES**
- **MST Path System & Distinct Path Biome:**
    - **`src/config/game_config.lua`**:
        - Added `MST_PATH = 7` to `BIOME_IDS` for distinct path tiles created by MST system.
        - Updated `MST_PATH_SYSTEM.PATH_BIOME_ID` from `1` (RUSTED_OASIS) to `7` (MST_PATH) to use the new distinct biome.
        - Added comprehensive `MST_PATH_SYSTEM` configuration including:
            - `ENABLED = true` - Enable/disable MST path generation
            - `TERRAIN_PENALTIES` - Weight penalties for different biomes when calculating MST edges
            - `REGION_CROSSING_BONUS = 0.8` - Reduce weight when paths cross regions to encourage connectivity
            - `INCLUDE_LANDMARKS_AS_NODES = true` - Include major landmarks as graph nodes
            - `MAJOR_LANDMARK_TYPES` - List of landmark types that become MST nodes
            - `ADD_STRATEGIC_NODES = true` - Add additional strategic nodes for better connectivity
            - `STRATEGIC_NODES_COUNT = 6` - Number of additional strategic nodes
            - `MIN_NODE_DISTANCE = 15` - Minimum distance between nodes
            - `CORRIDOR_WIDTH = 1` - Path width (total = 2*width + 1)
            - `WOBBLE_FREQUENCY = 0.2` - Chance to apply wobble to path segments
            - `MAX_WOBBLE_OFFSET = 2` - Maximum perpendicular offset for wobble
    - **`src/world/world_generation.lua`**:
        - Added new biome definition for "Ancient Path" (ID 7) with sandy/golden brown color `{160, 140, 80}` for visibility.
        - Implemented comprehensive MST-based path generation system:
            - `generateMSTNodes()` - Creates nodes from player start, region centers, major landmarks, and strategic positions
            - `calculatePathWeight()` - Calculates edge weights considering terrain penalties, region crossings, and distance
            - `buildMinimumSpanningTree()` - Uses Prim's algorithm to create MST connecting all nodes
            - `carveMSTCorridors()` - Carves paths with wobble effects and corridor width
        - Updated world generation flow:
            - First pass: Generate biomes based on regions
            - Second pass: MST-based path generation (if enabled)
            - Third pass: Border chokepoints (avoiding MST corridor tiles)
            - Subsequent passes for impassable mountains and landmarks
        - Enhanced path generation with:
            - Terrain-aware pathfinding that considers biome traversal difficulty
            - Region-crossing bonus to encourage inter-region connectivity
            - Natural wobble effects for more organic-looking paths
            - Plus-shaped brush pattern for corridor carving
            - Strategic node placement with distance constraints
        - Added `isCorridorTile` flag to MST path tiles to prevent interference with other generation passes.
- **Landmark Navigation Enhancement (Obelisk-Spring):**
    - **`src/world/world_generation.lua`**:
        - Added "Ancient Obelisk" and "Hidden Spring" to `LANDMARK_TYPES`.
        - Implemented logic to place a configured number of Obelisk-Spring pairs:
            - "Ancient Obelisk" stores coordinates to its linked "Hidden Spring".
            - "Hidden Spring" is marked as `initially_hidden` and `discovered = false`.
    - **`src/config/game_config.lua`**:
        - Added `WORLD.OBELISK_PAIRS_COUNT` (set to 2) to control how many pairs are generated.
    - **`src/core/game_manager.lua`**:
        - Updated `checkLandmark()`:
            - When an "Ancient Obelisk" is visited, it reveals its linked "Hidden Spring" by setting the spring's `discovered` flag to `true` AND the spring's tile `explored` flag to `true` (to ensure minimap visibility).
            - Added notifications for Obelisk discovery and Spring reveal.
            - Added specific reward logic for visiting a Hidden Spring.
    - **`src/rendering/renderer.lua`**:
        - Updated `renderWorld()` to display unique symbols for discovered but unvisited landmarks: "O" for "Ancient Obelisk" and "H" for "Hidden Spring".
- **Landmark Navigation Enhancement (Ancient Lever & Secret Passage):**
    - **`src/config/game_config.lua`**:
        - Added `SECRET_PASSAGES.LEVER_ACTIVATED` configuration, defining passage tile coordinates, initial/revealed biome IDs, and lever count.
    - **`src/world/world_generation.lua`**:
        - Added "Ancient Lever" to `LANDMARK_TYPES`.
        - Updated landmark placement to include "Ancient Lever" landmarks.
        - Added a pass to ensure secret passage tiles are initialized with the `INITIAL_BIOME_ID`.
    - **`src/core/game_manager.lua`**:
        - Updated `checkLandmark()` to handle "Ancient Lever" activation:
            - Changes biome of passage tiles to `REVEALED_BIOME_ID`.
            - Marks passage tiles as explored.
            - Sets lever's `activated` flag.
            - Provides notifications.
    - **`src/rendering/renderer.lua`**:
        - Updated `renderWorld()` to display "L" for discovered but unvisited "Ancient Lever" landmarks (using `GameConfig.MAP_ICONS.ANCIENT_LEVER`).
- **Landmark Navigation Enhancement (Seer's Totem & Hidden Cache):**
    - **`src/config/game_config.lua`**:
        - Added `WORLD.SEER_CACHE_PAIRS_COUNT`.
        - Added `LANDMARK_CONFIG.HIDDEN_CACHE_REWARD` to define rewards.
        - Added `MAP_ICONS.SEER_TOTEM` ("S") and `MAP_ICONS.HIDDEN_CACHE` ("$").
    - **`src/world/world_generation.lua`**:
        - Added "Seer's Totem" and "Hidden Cache" to `LANDMARK_TYPES`.
        - Implemented logic to place Seer's Totem/Hidden Cache pairs:
            - "Seer's Totem" stores coordinates to its linked "Hidden Cache".
            - "Hidden Cache" is marked `initially_hidden`, `discovered = false`, and `looted = false`.
    - **`src/core/game_manager.lua`**:
        - Updated `checkLandmark()`:
            - When a "Seer's Totem" is visited, it reveals its linked "Hidden Cache" (sets `discovered = true`, tile `explored = true`).
            - When a "Hidden Cache" is visited (and not `looted`), it grants rewards based on `LANDMARK_CONFIG.HIDDEN_CACHE_REWARD` and marks itself as `looted = true`.
            - Added appropriate notifications.
    - **`src/rendering/renderer.lua`**:
        - Updated `renderWorld()` to display map icons for "Seer's Totem" (`GameConfig.MAP_ICONS.SEER_TOTEM`) and "Hidden Cache" (`GameConfig.MAP_ICONS.HIDDEN_CACHE`) when discovered but unvisited. (This was later replaced by the landmark sprite system).
- **Landmark Visuals Enhancement:**
    - **`src/config/game_config.lua`**:
        - Added `LANDMARK_SPRITES` table. This table maps landmark type strings to an array of drawing instructions (shape, mode, color, parameters).
        - Defined unique drawing instructions for all existing landmark types, including "Ancient Ruins", "Mystic Shrine", "Crystal Formation", "Abandoned Camp", "Strange Monolith", "Ancient Obelisk", "Hidden Spring", "Ancient Lever", "Seer's Totem", "Hidden Cache", and "Contract_Scroll".
        - Added a `DEFAULT` sprite for any landmark types not explicitly defined.
    - **`src/rendering/renderer.lua`**:
        - Modified `renderWorld()`: Instead of printing a character from `MAP_ICONS` for discovered but unvisited landmarks, it now retrieves the sprite definition from `GameConfig.LANDMARK_SPRITES`.
        - It iterates through the drawing instructions in the sprite definition and uses `love.graphics` functions (rectangle, circle, polygon, line) to render the icon within the tile. Coordinates and sizes are relative to the tile size.
- **Impassable Terrain Tuning:**
    - **`src/world/world_generation.lua`**: Changed `IMPASSABLE_CHANCE` from 0.3 to 0.75 in the "Place Impassable Mountain Faces" pass.
- **UI Bug Fix (Inventory Display):**
    - **`src/rendering/renderer.lua`**: In `renderUI`, modified the inventory loop to check if an item's `value` is a boolean. If so, it displays "Yes" for true and "No" for false, preventing concatenation errors with boolean types. Other types are converted using `tostring()`.
- **Environmental Barriers & Item Gating (Phase 4a - Impassable Mountains):**
    - **`src/config/game_config.lua`**:
        - Added `IMPASSABLE_MOUNTAIN_FACE = 6` to `BIOME_IDS`.
        - Added `DEBUG_ADD_CLIMBING_PICKS_KEY = "f4"` to `DEBUG` table.
    - **`src/world/world_generation.lua`**:
        - Added "Impassable Mountain Face" biome (ID 6) to `WorldGeneration.BIOMES` table, including `is_impassable = true` property.
        - Added a new generation pass to convert some Mountain biome tiles adjacent to Plains into "Impassable Mountain Face" tiles based on `IMPASSABLE_CHANCE`.
    - **`src/core/game_manager.lua`**:
        - Updated `movePlayer()` to check if `target_biome_props.is_impassable` is true.
        - If attempting to move into `IMPASSABLE_MOUNTAIN_FACE`, it now checks for `player.inventory.has_climbing_picks` to allow passage. Otherwise, movement is blocked and a notification is shown.
        - Added `debugAddClimbingPicks()` function to set `player.inventory.has_climbing_picks = true`.
    - **`src/input/input_handler.lua`**:
        - Added key handler for "f4" (`DEBUG_ADD_CLIMBING_PICKS_KEY`) to call `GameManager.debugAddClimbingPicks()`.
- **Strategic Corridor Refinement (Path Wobble):**
    - **`src/world/world_generation.lua`**:
        - Introduced `WOBBLE_FREQUENCY` and `MAX_WOBBLE_OFFSET` constants.
        - Modified the strategic corridor generation to iterate through the base path (from `getLine`).
        - For segments, with a chance based on `WOBBLE_FREQUENCY`, a random perpendicular offset is applied to the target coordinates.
        - `getLine` is then used between the last point and the new (potentially wobbled) target point to ensure path connectivity, and these points form the `wobbled_corridor_path` used for carving.
- **Biome Distribution Tuning:**
    - **`src/config/game_config.lua`**: Modified `minNoise` and `maxNoise` values within the `biomePalette` for several regions in the `WORLD_REGIONS` table to give a broader range for biomes like Jungle, Mountains, and Tundra.
- **World Generation Overhaul (Phase 3 - Strategic Corridors):**
    - **`src/config/game_config.lua`**:
        - Added `isSafePassageTarget` boolean property to each entry in `WORLD_REGIONS`.
        - Updated `WORLD_REGIONS` to include four distinct regions, with two marked as `isSafePassageTarget = true`.
    - **`src/world/world_generation.lua`**:
        - Modified region generation to distribute four regions based on Perlin noise.
        - Added logic to find geometric centers of all regions and identify "safe hub" regions.
        - Selects the player's starting hub and one other random safe hub as targets for a corridor.
        - Implemented `getLine()` (Bresenham's algorithm) to plot a path between these hub centers.
        - Iterates along this path, and if a tile on the path falls into a non-safe-passage-target region, its biome (and a 1-tile perpendicular strip) is overridden to `PATH_BIOME_ID`.
        - Tiles part of this strategic corridor are marked with `isCorridorTile = true` to be skipped by the subsequent random chokepoint pass.
        - Updated final print statement.
- **Debug Feature: Reveal Map:**
    - **`src/config/game_config.lua`**: Added `REVEAL_MAP_KEY = "f3"` to the `DEBUG` table.
    - **`src/core/game_manager.lua`**: Added `GameManager.debugToggleRevealMap()` function, which sets all tiles to `explored = true` and discovers all landmarks.
    - **`src/input/input_handler.lua`**: Added a key handler for "f3" to call `GameManager.debugToggleRevealMap()`.
- **World Generation Overhaul (Phase 2 - Chokepoints):**
    - **`src/world/world_generation.lua`**:
        - Added a new pass after initial biome generation (based on regions).
        - This pass iterates through all tiles to identify `is_border_tile` by checking if neighboring tiles belong to a different `region_id`.
        - For border tiles, there's a `CHOKEPOINT_CHANCE` (currently 10%) to change their biome to `PATH_BIOME_ID` (Rusted Oasis/Plains).
        - Non-chokepoint border tiles currently retain their region-assigned biome.
- **World Generation Overhaul (Phase 1 - Regions & Palettes):**
    - **`src/config/game_config.lua`**:
        - Added `BIOME_IDS` table to centralize biome identification.
        - Added `WORLD_REGIONS` table defining multiple regions, each with an `id`, `name`, `difficultyTier`, and a `biomePalette` (specifying biome IDs and their Perlin noise thresholds for that region).
    - **`src/world/world_generation.lua`**:
        - Introduced a `REGION_SCALE` for Perlin noise to generate a `region_map`.
        - Implemented logic to ensure the player's starting area (defined by `GameConfig.PLAYER.STARTING_X/Y` and a radius) is always assigned a `difficultyTier = 1` region.
        - Modified the biome assignment loop to:
            - Determine the `current_region_id` for each tile.
            - Fetch the corresponding `region_config` from `GameConfig.WORLD_REGIONS`.
            - Use the `biome_noise` (from the existing biome Perlin noise) to select a biome from the `region_config.biomePalette`.
        - Stored `region_id` in each tile's data.
- **Previous Gameplay Balancing Adjustments:**
    - **`src/core/game_manager.lua`**:
        - Removed the default stamina cost for player movement in `movePlayer()`. Stamina loss is now solely handled by `checkHazard()` for hazardous biomes.
        - **Chrono Prism Repurposed**: Its effect now reduces stamina loss from hazardous biomes by 25% (configurable via `CHRONO_PRISM_HAZARD_REDUCTION_PERCENT` in `game_config.lua`). This is applied in `checkHazard()`.
    - **`src/world/world_generation.lua` (Previous Biome Prevalence Change):**
        - Changed Perlin noise thresholds for biome generation to alter biome prevalence (this logic is now superseded by region-based palettes but the biome IDs remain relevant).
- **Previous (Relic Effects Implementation):**
    - **`src/config/game_config.lua`**: Added `RELIC_EFFECTS` table, and updated `CHRONO_PRISM_STAMINA_SAVE` to `CHRONO_PRISM_HAZARD_REDUCTION_PERCENT = 0.25`.
    - **`src/core/game_manager.lua`**: Implemented original passive effects for Aether Lens, Void Anchor, and Life Spring. Chrono Prism's original effect was tied to movement cost.
- **Previous (Relic System Foundation):**
    - **`src/rendering/renderer.lua`**: Added `renderRelicReconstructionUI()`.
    - **`src/config/game_config.lua`**: Added UI and debug keys for relics.
    - **`src/core/game_manager.lua`**: Implemented `addDebugRelicFragments()`, `debugReconstructNextRelic()`, `attemptRelicReconstruction()`, and fixed persistence issues in `loadGame()` and `onPlayerDeath()`.
    - **`src/input/input_handler.lua`**: Added key handlers for relic debug and reconstruction.
- **Previous Refactoring (remains relevant):**
    - Restructured the entire codebase into a modular architecture.
    - Added comprehensive development documentation in `/documentation/ai_development_guide.md`.
    - Created a proper Perlin noise implementation in `lib/perlin.lua`.

### **PREVIOUS DEVELOPMENT**
- Implemented save/load system with serpent serialization.
- Added persistent meta-progression saving.
- Created save/load handlers for game state.
- Updated contract system with scroll discovery.
- Added contract UI display and progress tracking.
- Implemented contract reward distribution.
- Added relic system with 4 reconstructible artifacts (foundation).
- Implemented exploration-focused ability progression system.
- Updated contract rewards to include relic fragments and abilities.
- Integrated ability effects into gameplay mechanics.
- Enhanced death handling to preserve ability progression.

### **NEXT STEPS**
1. **Core Gameplay Loop Discovery**:
   - **Identify Fun Moments:** Determine which current mechanics create genuine player engagement
   - **Experiment with Pacing:** Adjust reward frequency, progression speed, and challenge difficulty
   - **Validate Player Motivation:** Test whether exploration goals feel meaningful and achievable
   - **Refine Feedback Loops:** Ensure player actions have clear, satisfying consequences

2. **Gameplay Iteration & Experimentation**:
   - **Contract System Enhancement:** Explore more engaging quest types and reward structures
   - **Relic System Refinement:** Adjust fragment acquisition rates and reconstruction satisfaction
   - **World Interaction Depth:** Expand meaningful player choices and environmental storytelling
   - **Progression Satisfaction:** Balance short-term discoveries with long-term goals

3. **Content Development** (After Fun is Found):
   - **Meaningful Biome Variety:** Add unique mechanics that change how players approach different areas
   - **Landmark Significance:** Ensure each landmark type provides distinct value and engagement
   - **Narrative Elements:** Develop environmental storytelling that enhances exploration motivation

4. **Polish & Testing** (Final Phase):
   - **Performance Optimization:** Address any technical bottlenecks
   - **User Experience Refinement:** Improve clarity of game systems and feedback
   - **Balance Finalization:** Fine-tune difficulty curves and reward distributions

5. **Documentation & Maintenance**:
   - **Memory Bank Updates:** Keep documentation current with gameplay discoveries
   - **Design Decision Tracking:** Document what works and what doesn't during iteration

---

### **ACTIVE DECISIONS AND CONSIDERATIONS**
- Using a global GameState table in GameManager for centralized state management
- Centralizing configuration in game_config.lua to avoid magic numbers
- Using module pattern for clear separation of concerns
- Maintaining explicit module dependencies for better code navigation
- Providing extensive documentation for AI comprehension
- Keeping consistent formatting and naming conventions
- Separating run-specific state from persistent meta-state
- Using observer pattern for contract events

---

### **IMPORTANT PATTERNS AND PREFERENCES**
- Keep Lua modules focused and single-responsibility
- Use descriptive variable and function names
- Add comments for complex algorithms
- Follow Love2D callback structure (load, update, draw)
- Centralize constants in config file
- Structure code logically by domain (rendering, input, game systems)
- Precompute values where possible for performance
- Document module interfaces clearly

---

### **LEARNINGS AND PROJECT INSIGHTS**
- **Architectural Success:** Modular design proved highly effective for complex feature integration
- **Configuration Strategy:** Centralized config system enabled rapid iteration and balancing
- **Documentation Value:** Comprehensive documentation significantly improved development velocity
- **System Integration:** Complex systems (MST paths, landmark interactions, relic effects) can be successfully integrated with proper planning
- **Performance Considerations:** 200x200 world requires careful optimization, but remains manageable
- **Visual Design:** Data-driven sprite system provides flexibility without requiring art assets
- **Save System Robustness:** Careful save/load design prevents data corruption across feature additions
- **Debug Tool Importance:** Comprehensive debug suite essential for testing complex systems
- **Balance Complexity:** Multiple interconnected systems require careful balance testing
- **User Feedback:** Clear notification system crucial for complex game mechanics
