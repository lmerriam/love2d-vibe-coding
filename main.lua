-- main.lua
-- Entry point for Shattered Expanse game
-- This file has been refactored to follow a modular structure
-- for better AI comprehension and maintainability

-- Load core modules
local GameManager = require("src.core.game_manager")
local InputHandler = require("src.input.input_handler")
local Renderer = require("src.rendering.renderer")

-- LÖVE callback for initialization
function love.load()
    -- Initialize game state and systems
    GameManager.initialize()
    Renderer.initialize() -- Initialize the Renderer to load assets
    print("Shattered Expanse initialized successfully")
end

-- LÖVE callback for update logic (runs every frame)
function love.update(dt)
    -- Update camera position
    GameManager.updateCamera()
    
    -- Update notifications
    GameManager.updateNotifications(dt)
    
    -- Update contracts
    GameManager.updateContracts(dt)
end

-- LÖVE callback for rendering (runs every frame after update)
function love.draw()
    -- Render everything through our renderer module
    Renderer.render()
end

-- LÖVE callback for key presses
function love.keypressed(key)
    -- Handle key presses through our input handler
    InputHandler.handleKeyPress(key)
end

-- LÖVE callback for game exit
function love.quit()
    -- Save game before exiting
    GameManager.saveGame()
    print("Saving game before exit")
    return false -- Don't prevent the game from closing
end
