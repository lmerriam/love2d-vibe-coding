### **ACTIVE CONTEXT: "SHATTERED EXPANSE"**

---

### **CURRENT WORK FOCUS**
- **Biome Distribution Tuning:** Adjusted Perlin noise thresholds within `WORLD_REGIONS` in `src/config/game_config.lua` to improve the variety of biomes generated, addressing an issue where only Plains and Desert were appearing frequently.
- **Previous: World Generation Overhaul (Phase 3 - Strategic Corridors Complete):** Implemented logic to carve strategic corridors.
- **Previous: Debug Feature Implementation:** Added a debug function to reveal the entire map.
- **Previous: World Generation Overhaul (Phase 2 - Chokepoints Complete):** Implemented a simplified chokepoint generation system.

---

### **RECENT CHANGES**
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
1.  **Test New World Generation System (Regions, Palettes, Chokepoints & Strategic Corridors)**:
    *   Verify distinct regions, correct biome palettes, and Tier 1 starting area.
    *   Observe random chokepoints and the newly carved strategic corridors.
    *   Confirm strategic corridors connect safe hubs through non-safe regions.
    *   Assess visual and gameplay impact of all new world generation features.
    *   Check for errors (e.g., in region center calculation, line drawing, corridor carving).
2.  **Refine Corridor & Chokepoint Generation (If Necessary)**:
    *   Adjust corridor width, pathfinding (e.g., A* for multiple hubs), or corridor "naturalness."
    *   Adjust `CHOKEPOINT_CHANCE` or border difficulty logic.
3.  **Thoroughly Test Previous Gameplay Changes (Stamina)**:
>>>>>>> REPLACE
    *   Verify that stamina is no longer lost on every move in non-hazardous biomes.
    *   Confirm that stamina is still correctly lost in hazardous biomes (Jungle, Mountains, Tundra) according to their defined rules, now potentially reduced by the Chrono Prism.
    *   Assess overall game balance with these new stamina rules in conjunction with the new world structure.
4.  **Relic System Review (Post-Stamina Change & Chrono Prism Rework)**:
    *   **Chrono Prism**: Verify its new effect (25% hazard stamina reduction) functions correctly in Jungle and Mountains, and stacks appropriately with Biome Mastery (if applicable).
    *   Test other relic effects (Aether Lens, Void Anchor, Life Spring) to ensure they still function as intended.
5.  **UI Improvements (General)**:
    *   Consider if any UI elements should subtly indicate active relic buffs.
    *   Enhance ability system visuals.
    *   Improve general progression feedback.
6.  **Content Enhancements**:
   - Add more biome types and environmental effects (especially to support distinct region themes).
   - Expand the contract system with additional quest types.
   - Add more landmark varieties and special discoveries.
7.  **Update All Memory Bank Files**: Review and update `progress.md`, `systemPatterns.md`, etc., to reflect these major gameplay changes.

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
