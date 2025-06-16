-- src/input/input_handler.lua
-- Handles all user input for Shattered Expanse

local GameManager = require("src.core.game_manager")
local GameConfig = require("src.config.game_config") -- Add GameConfig require

local InputHandler = {}

-- Process a key press event
function InputHandler.handleKeyPress(key)
    -- Escape key - quit game
    if key == "escape" then
        love.event.quit()
    
    -- Movement keys (context-sensitive: player movement in zoomed mode, minimap navigation in minimap mode)
    elseif key == "up" then
        if GameManager.GameState.viewMode == "minimap" then
            GameManager.moveMinimapCamera(0, -10)
        else
            GameManager.movePlayer(0, -1)
        end
    elseif key == "down" then
        if GameManager.GameState.viewMode == "minimap" then
            GameManager.moveMinimapCamera(0, 10)
        else
            GameManager.movePlayer(0, 1)
        end
    elseif key == "left" then
        if GameManager.GameState.viewMode == "minimap" then
            GameManager.moveMinimapCamera(-10, 0)
        else
            GameManager.movePlayer(-1, 0)
        end
    elseif key == "right" then
        if GameManager.GameState.viewMode == "minimap" then
            GameManager.moveMinimapCamera(10, 0)
        else
            GameManager.movePlayer(1, 0)
        end
    
    -- Toggle map view mode
    elseif key == "m" then
        GameManager.toggleViewMode()
    
    -- Save game (for testing/debugging)
    elseif key == "s" and love.keyboard.isDown("lctrl") then
        GameManager.saveGame()
        GameManager.addNotification("Game saved!")
        
    -- Debug: Add relic fragments
    elseif key == GameConfig.DEBUG.ADD_FRAGMENTS_KEY then
        GameManager.addDebugRelicFragments()
    -- Debug: Reconstruct next relic
    elseif key == GameConfig.DEBUG.RECONSTRUCT_RELIC_KEY then
        GameManager.debugReconstructNextRelic()
    -- Debug: Toggle map reveal
    elseif key == GameConfig.DEBUG.REVEAL_MAP_KEY then
        GameManager.debugToggleRevealMap()
    -- Debug: Add Climbing Picks
    elseif key == GameConfig.DEBUG.DEBUG_ADD_CLIMBING_PICKS_KEY then
        GameManager.debugAddClimbingPicks()
    -- Attempt Relic Reconstruction
    elseif key == GameConfig.ACTIONS.RECONSTRUCT_ATTEMPT_KEY then
        GameManager.attemptRelicReconstruction()
    end
end

return InputHandler
