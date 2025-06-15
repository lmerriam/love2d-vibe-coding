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
    
    -- Movement keys
    elseif key == "up" then
        GameManager.movePlayer(0, -1)
    elseif key == "down" then
        GameManager.movePlayer(0, 1)
    elseif key == "left" then
        GameManager.movePlayer(-1, 0)
    elseif key == "right" then
        GameManager.movePlayer(1, 0)
    
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
    -- Attempt Relic Reconstruction
    elseif key == GameConfig.ACTIONS.RECONSTRUCT_ATTEMPT_KEY then
        GameManager.attemptRelicReconstruction()
    end
end

return InputHandler
