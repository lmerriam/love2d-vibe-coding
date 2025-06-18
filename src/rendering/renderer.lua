-- src/rendering/renderer.lua
-- Handles all rendering operations for Shattered Expanse

local GameManager = require("src.core.game_manager")
local GameConfig = require("src.config.game_config")
local WorldGeneration = require("src.world.world_generation")
local ContractSystem = require("src.systems.contract_system")

local Renderer = {}

local landmarkSpriteSheet = nil
local landmarkQuads = {} -- To store love.graphics.newQuad objects

-- Initialize the Renderer, loading assets
function Renderer.initialize()
    if love.filesystem.getInfo(GameConfig.LANDMARK_SPRITE_SHEET_PATH) then
        landmarkSpriteSheet = love.graphics.newImage(GameConfig.LANDMARK_SPRITE_SHEET_PATH)
        if landmarkSpriteSheet then
            for name, params in pairs(GameConfig.LANDMARK_SPRITES) do
                landmarkQuads[name] = love.graphics.newQuad(
                    params.x, params.y,
                    params.width, params.height,
                    GameConfig.LANDMARK_SPRITE_SHEET_WIDTH, GameConfig.LANDMARK_SPRITE_SHEET_HEIGHT
                )
            end
            print("Landmark sprite sheet and quads loaded.")
        else
            print("ERROR: Could not load landmark sprite sheet: " .. GameConfig.LANDMARK_SPRITE_SHEET_PATH)
        end
    else
        print("ERROR: Landmark sprite sheet file not found: " .. GameConfig.LANDMARK_SPRITE_SHEET_PATH)
    end
end

-- Main rendering function called every frame
function Renderer.render()
    love.graphics.clear(0, 0, 0) -- Clear screen to black
    
    Renderer.renderWorld()
    Renderer.renderPlayer()
    Renderer.renderUI()
    Renderer.renderNotifications()
    Renderer.renderContracts()
    Renderer.renderRelicReconstructionUI() -- Add call to new UI function
end

-- Render the game world (tiles and landmarks)
function Renderer.renderWorld()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local gameState = GameManager.GameState
    local tileSize = gameState.viewMode == "zoomed" and GameConfig.WORLD.TILE_SIZE or GameConfig.WORLD.MINI_TILE_SIZE
    local viewSize = GameConfig.WORLD.VIEW_RADIUS
    
    local startX, endX, startY, endY
    
    if gameState.viewMode == "zoomed" then
        -- Zoomed: render tiles around camera
        startX = gameState.player.x - viewSize
        endX = gameState.player.x + viewSize
        startY = gameState.player.y - viewSize
        endY = gameState.player.y + viewSize
    else
        -- Minimap: show navigable portion of world
        local tilesPerScreenX = math.floor(screenWidth / tileSize)
        local tilesPerScreenY = math.floor(screenHeight / tileSize)
        
        startX = math.max(1, gameState.minimap_camera.x)
        endX = math.min(gameState.world.width, startX + tilesPerScreenX - 1)
        startY = math.max(1, gameState.minimap_camera.y)
        endY = math.min(gameState.world.height, startY + tilesPerScreenY - 1)
        
        -- Adjust startX/startY if we hit world boundaries
        if endX == gameState.world.width then
            startX = math.max(1, endX - tilesPerScreenX + 1)
        end
        if endY == gameState.world.height then
            startY = math.max(1, endY - tilesPerScreenY + 1)
        end
    end
    
    -- Render world grid
    for x = startX, endX do
        for y = startY, endY do
            -- Skip out-of-bounds tiles
            if x < 1 or x > gameState.world.width or y < 1 or y > gameState.world.height then
                goto continue
            end
            
            local tile = gameState.world.tiles[x][y]
            local screenX, screenY
            
            if gameState.viewMode == "zoomed" then
                -- Center around camera
                screenX = (x - startX) * tileSize + (screenWidth - (endX - startX + 1) * tileSize) / 2
                screenY = (y - startY) * tileSize + (screenHeight - (endY - startY + 1) * tileSize) / 2
            else
                -- Minimap view - position relative to minimap camera
                screenX = (x - startX) * tileSize
                screenY = (y - startY) * tileSize
            end
            
            if tile.explored then
                -- Draw biome color
                love.graphics.setColor(tile.biome.color[1]/255, tile.biome.color[2]/255, tile.biome.color[3]/255)
                love.graphics.rectangle("fill", screenX, screenY, tileSize, tileSize)
                
                -- Draw sprite for discovered but unvisited landmarks
                if tile.landmark and tile.landmark.discovered and not tile.landmark.visited then
                    local landmark_type = tile.landmark.type
                    local quad_to_draw = landmarkQuads[landmark_type] or landmarkQuads.DEFAULT -- Fallback to DEFAULT quad
                    
                    if landmarkSpriteSheet and quad_to_draw then
                        local quad_params = GameConfig.LANDMARK_SPRITES[landmark_type] or GameConfig.LANDMARK_SPRITES.DEFAULT
                        
                        local dest_width = tileSize  -- Target width on screen (e.g., GameConfig.WORLD.TILE_SIZE)
                        local dest_height = tileSize -- Target height on screen
                        
                        -- Calculate scale to fit the sprite into the tile while maintaining aspect ratio
                        local scale_x = dest_width / quad_params.width
                        local scale_y = dest_height / quad_params.height
                        local scale = math.min(scale_x, scale_y) -- Use min to fit entirely, math.max to fill/crop
                                                                -- For pixel art, exact pixel mapping might be desired if tileSize matches sprite part.
                                                                -- For now, fitting with aspect ratio.

                        -- Calculate centered position for the scaled sprite within the tile
                        local actual_rendered_width = quad_params.width * scale
                        local actual_rendered_height = quad_params.height * scale
                        local render_x = screenX + (tileSize - actual_rendered_width) / 2
                        local render_y = screenY + (tileSize - actual_rendered_height) / 2

                        love.graphics.setColor(1, 1, 1, 1) -- Reset color for image drawing
                        love.graphics.draw(landmarkSpriteSheet, quad_to_draw, render_x, render_y, 0, scale, scale)
                    end
                end
            else
                -- Unexplored tiles are black
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("fill", screenX, screenY, tileSize, tileSize)
            end
            
            ::continue::
        end
    end
end

--- Render the player
function Renderer.renderPlayer()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local gameState = GameManager.GameState
    local tileSize = gameState.viewMode == "zoomed" and GameConfig.WORLD.TILE_SIZE or GameConfig.WORLD.MINI_TILE_SIZE
    local viewSize = GameConfig.WORLD.VIEW_RADIUS
    
    local playerScreenX, playerScreenY
    
    if gameState.viewMode == "zoomed" then
        -- Player is always centered in zoomed view
        playerScreenX = screenWidth / 2
        playerScreenY = screenHeight / 2
    else
        -- Minimap view - player position relative to minimap camera
        local startX = math.max(1, gameState.minimap_camera.x)
        local startY = math.max(1, gameState.minimap_camera.y)
        
        playerScreenX = (gameState.player.x - startX) * tileSize + tileSize / 2
        playerScreenY = (gameState.player.y - startY) * tileSize + tileSize / 2
    end
    
    love.graphics.setColor(1, 0, 0) -- Red color for player
    love.graphics.circle("fill", playerScreenX, playerScreenY, tileSize / 3) -- Draw player as a circle
end

-- Render UI elements
function Renderer.renderUI()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local gameState = GameManager.GameState
    local fontSize = GameConfig.UI.FONT_SIZE
    
    love.graphics.setFont(love.graphics.newFont(fontSize))
    love.graphics.setColor(1, 1, 1) -- White color for UI text

    -- Stamina bar
    local staminaPercentage = gameState.player.stamina / GameConfig.PLAYER.STARTING_STAMINA
    local barWidth = 200
    local barHeight = 20
    local barX = 10
    local barY = 10
    
    -- Background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
    
    -- Fill based on stamina
    if staminaPercentage > 0.5 then
        love.graphics.setColor(0, 1, 0) -- Green
    elseif staminaPercentage > 0.2 then
        love.graphics.setColor(1, 1, 0) -- Yellow
    else
        love.graphics.setColor(1, 0, 0) -- Red
    end
    love.graphics.rectangle("fill", barX, barY, barWidth * staminaPercentage, barHeight)
    
    love.graphics.setColor(1, 1, 1) -- Reset color
    love.graphics.print("Stamina: " .. math.floor(gameState.player.stamina), barX, barY + barHeight + 5)

    -- Current biome info
    local currentTile = gameState.world.tiles[gameState.player.x][gameState.player.y]
    love.graphics.print("Current Biome: " .. currentTile.biome.name, 10, 90)
    love.graphics.print("Hazard: " .. (currentTile.biome.hazard or "None"), 10, 110)
    love.graphics.print("View Mode: " .. gameState.viewMode .. " (Press 'M' to toggle)", 10, 130)

    -- Active contract display
    if gameState.contracts.active and #gameState.contracts.active > 0 then
        local contract = gameState.contracts.active[1]
        local contractText = "Contract: "
        if contract.type == "DISCOVER" then
            contractText = contractText .. string.format(ContractSystem.CONTRACT_TYPES.DISCOVER.description, contract.target)
        elseif contract.type == "EXPLORE" then
            contractText = contractText .. string.format(ContractSystem.CONTRACT_TYPES.EXPLORE.description, contract.required, contract.target)
        elseif contract.type == "COLLECT" then
            contractText = contractText .. string.format(ContractSystem.CONTRACT_TYPES.COLLECT.description, contract.required, contract.target)
        end
        love.graphics.print(contractText, screenWidth - GameConfig.UI.CONTRACT_OFFSET_X, 10)
    end

    -- Inventory display
    love.graphics.print("Inventory:", 10, GameConfig.UI.INVENTORY_START_Y)
    local inventoryY = GameConfig.UI.INVENTORY_START_Y + fontSize + 5
    for item, value in pairs(gameState.player.inventory) do
        if item == "relic_fragments" then
            if type(value) == "table" then
                for fragment_type, fragment_count in pairs(value) do
                    love.graphics.print("- " .. fragment_type .. " fragment: " .. fragment_count, 20, inventoryY)
                    inventoryY = inventoryY + fontSize + 2
                end
            end
        else
            local displayValue = value
            if type(value) == "boolean" then
                displayValue = value and "Yes" or "No"
            else
                displayValue = tostring(value)
            end
            love.graphics.print("- " .. item .. ": " .. displayValue, 20, inventoryY)
            inventoryY = inventoryY + fontSize + 2
        end
    end

    -- Relic Reconstruction UI
    Renderer.renderRelicReconstructionUI()

    -- Notifications
    local notificationY = screenHeight - 50
    for i, notification in ipairs(gameState.notifications) do
        if notification.message then
            love.graphics.setColor(1, 1, 1, notification.alpha) -- Use notification alpha for fading
            love.graphics.print(notification.message, screenWidth / 2 - love.graphics.getFont():getWidth(notification.message) / 2, notificationY)
            notificationY = notificationY - (fontSize + 5) -- Stack notifications upwards
        end
    end
    love.graphics.setColor(1, 1, 1, 1) -- Reset color
end

-- Render the Relic Reconstruction UI
function Renderer.renderRelicReconstructionUI()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local fontSize = GameConfig.UI.FONT_SIZE
    local uiX = screenWidth - GameConfig.UI.RELIC_UI_OFFSET_X
    local uiY = screenHeight - GameConfig.UI.RELIC_UI_OFFSET_Y
    
    love.graphics.setFont(love.graphics.newFont(fontSize))
    love.graphics.setColor(1, 1, 1) -- White color for UI text

    love.graphics.print("Relic Reconstruction:", uiX, uiY)
    uiY = uiY + fontSize + 5

    -- Display current fragments
    love.graphics.print("Fragments:", uiX + 10, uiY)
    uiY = uiY + fontSize + 2
    if GameManager.GameState.meta.relic_fragments then
        for fragment_type, count in pairs(GameManager.GameState.meta.relic_fragments) do
            love.graphics.print("- " .. fragment_type .. ": " .. count, uiX + 20, uiY)
            uiY = uiY + fontSize + 2
        end
    end
    uiY = uiY + 5

    -- Display relics and their status
    love.graphics.print("Relics:", uiX + 10, uiY)
    uiY = uiY + fontSize + 2
    for _, relic in ipairs(GameManager.GameState.meta.relics) do
        local status = relic.reconstructed and "Reconstructed" or "Missing Fragments"
        local statusColor = relic.reconstructed and {0, 1, 0} or {1, 0.5, 0} -- Green for reconstructed, Orange for missing
        
        love.graphics.setColor(statusColor[1], statusColor[2], statusColor[3])
        love.graphics.print("- " .. relic.name .. ": " .. status, uiX + 20, uiY)
        
        -- If missing fragments, display required fragments
        if not relic.reconstructed then
            local fragmentsNeeded = {}
            for f_type, f_count in pairs(relic.fragments) do
                local currentCount = GameManager.GameState.meta.relic_fragments[f_type] or 0
                if currentCount < f_count then
                    table.insert(fragmentsNeeded, f_type .. " (" .. currentCount .. "/" .. f_count .. ")")
                end
            end
            if #fragmentsNeeded > 0 then
                love.graphics.setColor(1, 0.7, 0.7) -- Lighter red for needed fragments
                love.graphics.print("  Needed: " .. table.concat(fragmentsNeeded, ", "), uiX + 30, uiY + fontSize)
            end
        end
        uiY = uiY + fontSize + (not relic.reconstructed and fontSize + 2 or 2)
    end
    love.graphics.setColor(1, 1, 1) -- Reset color
end

-- Render notifications
function Renderer.renderNotifications()
    local gameState = GameManager.GameState
    
    local notificationY = 10
    for i, notif in ipairs(gameState.notifications) do
        -- Set color with alpha for fade effect
        love.graphics.setColor(0, 0, 0, 0.7 * notif.alpha)  -- Semi-transparent background
        love.graphics.rectangle("fill", 10, notificationY, 400, 30)
        
        love.graphics.setColor(1, 1, 0, notif.alpha)  -- Yellow text with alpha
        love.graphics.print(notif.text, 20, notificationY + 10)
        
        notificationY = notificationY + 40
    end
end

-- Render active contracts
function Renderer.renderContracts()
    local gameState = GameManager.GameState
    local screenWidth = love.graphics.getWidth()
    
    if #gameState.contracts.active > 0 then
        local yOffset = 30
        for i, contract in ipairs(gameState.contracts.active) do
            local contractType = ContractSystem.CONTRACT_TYPES[contract.type]
            local description = contractType.description
            
            -- Format description with target and required values
            if contract.type == "DISCOVER" then
                description = string.format(description, contract.target)
            elseif contract.type == "EXPLORE" then
                local biomeName = "Unknown"
                if WorldGeneration.BIOMES[contract.target] then
                    biomeName = WorldGeneration.BIOMES[contract.target].name
                end
                description = string.format(description, contract.required, biomeName)
            elseif contract.type == "COLLECT" then
                description = string.format(description, contract.required, contract.target)
            elseif contract.type == "PATHFINDER" then
                description = string.format(description, "X:" .. contract.target_x .. ", Y:" .. contract.target_y)
            end
            
            -- Set color based on completion status
            if contract.completed then
                love.graphics.setColor(0, 1, 0)  -- Green for completed
            else
                love.graphics.setColor(1, 1, 1)  -- White for active
            end
            
            love.graphics.print(description, screenWidth - GameConfig.UI.CONTRACT_OFFSET_X, yOffset)
            love.graphics.print("Progress: " .. contract.progress .. "/" .. contract.required, 
                                screenWidth - GameConfig.UI.CONTRACT_OFFSET_X, yOffset + 20)
            
            -- Add checkmark for completed contracts
            if contract.completed then
                love.graphics.print("✓ COMPLETED!", screenWidth - GameConfig.UI.CONTRACT_OFFSET_X, yOffset + 40)
            end
            
            yOffset = yOffset + 60
        end
    end
end

return Renderer
