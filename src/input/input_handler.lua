-- src/input/input_handler.lua
-- Handles all user input for Shattered Expanse

local GameManager = require("src.core.game_manager")

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
    end
end

return InputHandler
