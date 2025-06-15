### **ACTIVE CONTEXT: "SHATTERED EXPANSE"**

---

### **CURRENT WORK FOCUS**
- Implemented the Relic Reconstruction UI and core mechanics.
- Added debug features for testing relic fragment collection and relic reconstruction.
- Fixed issues related to relic data persistence during save/load and player death.
- Ensured relic system integrates with existing game state and UI rendering.

---

### **RECENT CHANGES**
- **Relic Reconstruction System Implementation:**
    - **`src/rendering/renderer.lua`**: Added `renderRelicReconstructionUI()` to display relic status, required fragments, and player's current fragments. Called this from the main `render()` loop. Used config values for positioning.
    - **`src/config/game_config.lua`**:
        - Added `UI.RELIC_UI_OFFSET_X` and `UI.RELIC_UI_OFFSET_Y` for positioning the relic UI.
        - Added `DEBUG.ADD_FRAGMENTS_KEY` ("f1") and `DEBUG.FRAGMENT_ADD_AMOUNT`.
        - Added `DEBUG.RECONSTRUCT_RELIC_KEY` ("f2").
        - Added `ACTIONS.RECONSTRUCT_ATTEMPT_KEY` ("r").
    - **`src/core/game_manager.lua`**:
        - Implemented `addDebugRelicFragments()` to add a specified number of all relic fragment types to player inventory. Made robust against missing `meta.relics`.
        - Implemented `debugReconstructNextRelic()` to mark the next available relic as reconstructed.
        - Implemented `attemptRelicReconstruction()`:
            - Checks if player has enough fragments for any non-reconstructed relic.
            - Deducts fragments from player inventory.
            - Marks the relic as `reconstructed` in `GameState.meta.relics`.
            - Provides notifications for success/failure/all done.
        - Modified `loadGame()` to correctly merge saved `meta` data, preserving default `meta.relics` if not present in save file, fixing an issue where `meta.relics` could become nil.
        - Modified `onPlayerDeath()` to correctly persist `player.inventory.relic_fragments` to `meta.relic_fragments` by direct assignment (deep copy) instead of additive logic, fixing fragment doubling.
    - **`src/input/input_handler.lua`**:
        - Added key press handlers for `ADD_FRAGMENTS_KEY` (F1), `RECONSTRUCT_RELIC_KEY` (F2), and `RECONSTRUCT_ATTEMPT_KEY` ("r") to call their respective functions in `GameManager`.
- **Previous Refactoring (remains relevant):**
    - Restructured the entire codebase into a modular architecture.
    - Added comprehensive development documentation in `/documentation/ai_development_guide.md`.
    - Created a proper Perlin noise implementation in `lib/perlin.lua`.

### **PREVIOUS DEVELOPMENT**
- Implemented save/load system with serpent serialization (now enhanced for relics).
- Added persistent meta-progression saving (now includes relic status and fragments).
- Created save/load handlers for game state (now enhanced for relics).
- Updated contract system with scroll discovery
- Added contract UI display and progress tracking
- Implemented contract reward distribution
- Added relic system with 4 reconstructible artifacts
- Implemented exploration-focused ability progression system
- Updated contract rewards to include relic fragments and abilities
- Integrated ability effects into gameplay mechanics
- Enhanced death handling to preserve ability progression

### **NEXT STEPS**
1.  **Thoroughly Test Relic System**:
    *   Verify fragment collection from various sources (if applicable beyond debug).
    *   Test Relic Reconstruction UI updates correctly.
    *   Test reconstruction logic (fragment deduction, status change).
    *   Test persistence of fragments and reconstructed status across deaths and game sessions (save/load).
    *   Test all debug keys (F1, F2, r) under various conditions.
2.  **Define Relic Effects/Rewards**:
    *   Currently, reconstructing a relic only marks it as complete.
    *   Decide and implement what benefits or abilities each reconstructed relic provides to the player (e.g., passive buffs, new active abilities). This will likely involve `AbilitySystem`.
3.  **UI Improvements (General)**:
    *   Enhance ability system visuals.
    *   Improve general progression feedback.
4.  **Content Enhancements**:
   - Add more biome types and environmental effects
   - Expand the contract system with additional quest types
   - Add more landmark varieties and special discoveries

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
