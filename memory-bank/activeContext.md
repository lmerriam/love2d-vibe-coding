### **ACTIVE CONTEXT: "SHATTERED EXPANSE"**

---

### **CURRENT WORK FOCUS**
- **MST Path System & Distinct Path Biome:** Implemented a graph-based path generation system using Minimum Spanning Tree algorithm and created a distinct "Ancient Path" biome for better visual clarity of the generated pathways.
- **Previous: Landmark Visuals Enhancement:** Implemented a system to render simple, distinct icons for each landmark type using LÖVE2D's drawing primitives, replacing character-based map symbols.
- **Previous: Landmark Navigation Enhancement (Seer's Totem & Hidden Cache):** Implementing "Seer's Totem" landmarks that, when activated, reveal the location of a "Hidden Cache" which provides a reward.
- **Previous: Landmark Navigation Enhancement (Ancient Lever & Secret Passage):** Implemented "Ancient Lever" landmarks that, when activated, open a predefined secret passage by changing impassable tiles to passable ones.
- **Previous: Landmark Navigation Enhancement (Obelisk-Spring):** Implemented a system where "Ancient Obelisks" reveal the locations of "Hidden Springs," enhancing landmark interaction for navigation.
- **Previous: Impassable Terrain Tuning:** Increased `IMPASSABLE_CHANCE` to 0.75 in `src/world/world_generation.lua` to make "Impassable Mountain Face" barriers more consistent and less sparse.
- **Previous: UI Bug Fix (Inventory Display):** Fixed UI rendering for boolean inventory items.
- **Previous: Environmental Barriers & Item Gating (Phase 4a - Impassable Mountains):** Implemented "Impassable Mountain Face" biome and "Climbing Picks" item.
- **Previous: Strategic Corridor Refinement (Path Wobble):** Enhanced strategic corridor generation.
- **Previous: Biome Distribution Tuning:** Adjusted Perlin noise thresholds for better biome variety.
- **Previous: World Generation Overhaul (Phase 3 - Strategic Corridors Complete):** Implemented logic to carve strategic corridors.
- **Previous: Debug Feature Implementation:** Added a debug function to reveal the entire map.
- **Previous: World Generation Overhaul (Phase 2 - Chokepoints Complete):** Implemented a simplified chokepoint generation system.

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
1.  **Test Landmark Visuals Enhancement**:
    *   Verify that all discovered but unvisited landmarks now render using their defined sprites from `GameConfig.LANDMARK_SPRITES` instead of text characters.
    *   Check that the sprites are correctly scaled and positioned within the tiles in both "zoomed" and "minimap" views.
    *   Confirm that the `DEFAULT` sprite is used if a landmark type is missing a specific definition (though all current types should be defined).
    *   Assess visual clarity and distinctiveness of the new icons.
2.  **Test Landmark Navigation Enhancement (Seer's Totem & Hidden Cache)**:
    *   Verify "Seer's Totem" and "Hidden Cache" landmarks are generated according to `SEER_CACHE_PAIRS_COUNT`.
    *   Confirm visiting a "Seer's Totem" reveals its linked "Hidden Cache" on the map (landmark `discovered = true`, tile `explored = true`).
    *   Check that the revealed "Hidden Cache" is visible on the minimap.
    *   Verify visiting a "Hidden Cache" grants the configured reward and marks it as looted.
    *   Check notifications.
    *   Assess gameplay impact.
3.  **Test Landmark Navigation Enhancement (Ancient Lever & Secret Passage)**:
    *   Verify "Ancient Lever" landmarks are generated.
    *   Confirm the predefined secret passage area is initially impassable.
    *   Test activating an "Ancient Lever" correctly changes passage tiles to passable and explored.
    *   Check notifications and map symbol ("L") for the lever.
    *   Assess gameplay impact.
3.  **Test Landmark Navigation Enhancement (Obelisk-Spring)**:
    *   Verify Obelisks and Hidden Springs are generated according to `OBELISK_PAIRS_COUNT`.
    *   Confirm visiting an Ancient Obelisk reveals its linked Hidden Spring on the map (sets landmark `discovered = true` and tile `explored = true`).
    *   Check that the revealed Hidden Spring is now visible on the minimap.
    *   Check that appropriate notifications are displayed for Obelisk discovery and Spring reveal.
    *   Verify the new map symbols ("O" for Obelisk, "H" for revealed Spring) appear correctly.
    *   Assess the gameplay impact of this new mechanic.
4.  **Test New World Generation System (Regions, Palettes, Chokepoints & Strategic Corridors)**:
    *   Verify distinct regions, correct biome palettes, and Tier 1 starting area.
    *   Observe random chokepoints and the newly carved strategic corridors.
    *   Confirm strategic corridors connect safe hubs through non-safe regions.
    *   Assess visual and gameplay impact of all new world generation features.
    *   Check for errors (e.g., in region center calculation, line drawing, corridor carving).
3.  **Refine Corridor & Chokepoint Generation (If Necessary)**:
    *   Adjust corridor width, pathfinding (e.g., A* for multiple hubs), or corridor "naturalness."
    *   Adjust `CHOKEPOINT_CHANCE` or border difficulty logic.
4.  **Thoroughly Test Previous Gameplay Changes (Stamina)**:
    *   Verify that stamina is no longer lost on every move in non-hazardous biomes.
    *   Confirm that stamina is still correctly lost in hazardous biomes (Jungle, Mountains, Tundra) according to their defined rules, now potentially reduced by the Chrono Prism.
    *   Assess overall game balance with these new stamina rules in conjunction with the new world structure.
5.  **Relic System Review (Post-Stamina Change & Chrono Prism Rework)**:
    *   **Chrono Prism**: Verify its new effect (25% hazard stamina reduction) functions correctly in Jungle and Mountains, and stacks appropriately with Biome Mastery (if applicable).
    *   Test other relic effects (Aether Lens, Void Anchor, Life Spring) to ensure they still function as intended.
6.  **UI Improvements (General)**:
    *   Consider if any UI elements should subtly indicate active relic buffs.
    *   Enhance ability system visuals.
    *   Improve general progression feedback.
7.  **Content Enhancements**:
   - Add more biome types and environmental effects (especially to support distinct region themes).
   - Expand the contract system with additional quest types.
   - Add more landmark varieties and special discoveries (continue "Enhancing Landmark Significance").
8.  **Update All Memory Bank Files**: Review and update `progress.md`, `systemPatterns.md`, etc., to reflect these major gameplay changes.

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
- Modular architecture significantly improves maintainability
- Centralized configuration makes tweaking game parameters much easier
- Clear separation of concerns helps with debugging and feature development
- Comprehensive documentation enables faster onboarding for AI assistants
- Save/load implementation is crucial for roguelite progression
- Contract system provides clear player direction
- Scroll discovery mechanic encourages exploration
- UI space is limited - need to design compact information displays
- Reward distribution needs balancing
- Contract progress tracking impacts performance - needs optimization
