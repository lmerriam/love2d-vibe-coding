-- src/rendering/renderer.lua
-- Handles all rendering operations for Shattered Expanse

local GameManager = require("src.core.game_manager")
local GameConfig = require("src.config.game_config")
local WorldGeneration = require("src.world.world_generation")
local ContractSystem = require("src.systems.contract_system")

local Renderer = {}

-- Main rendering function called every frame
function Renderer.render()
    Renderer.renderWorld()
    Renderer.renderPlayer()
    Renderer.renderUI()
    Renderer.renderNotifications()
    Renderer.renderContracts()
    Renderer.renderRelicReconstructionUI() -- Add call to new UI function
end

-- Render the world tiles
function Renderer.renderWorld()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local gameState = GameManager.GameState
    local tileSize = gameState.viewMode == "zoomed" and GameConfig.WORLD.TILE_SIZE or GameConfig.WORLD.MINI_TILE_SIZE
    local viewSize = GameConfig.WORLD.VIEW_RADIUS
    
    -- Calculate visible area based on view mode
    local startX, endX, startY, endY
    
    if gameState.viewMode == "zoomed" then
        -- Show tiles around camera position
        startX = gameState.camera.x - viewSize
        endX = gameState.camera.x + viewSize
        startY = gameState.camera.y - viewSize
        endY = gameState.camera.y + viewSize
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
                    local landmark_sprite_def = GameConfig.LANDMARK_SPRITES[tile.landmark.type] or GameConfig.LANDMARK_SPRITES.DEFAULT
                    if landmark_sprite_def then
                        for _, part in ipairs(landmark_sprite_def) do
                            love.graphics.setColor(part.color[1]/255, part.color[2]/255, part.color[3]/255)
                            if part.shape == "rectangle" then
                                love.graphics.rectangle(part.mode, 
                                                        screenX + part.params[1] * tileSize, 
                                                        screenY + part.params[2] * tileSize, 
                                                        part.params[3] * tileSize, 
                                                        part.params[4] * tileSize)
                            elseif part.shape == "circle" then
                                love.graphics.circle(part.mode, 
                                                       screenX + part.params[1] * tileSize, 
                                                       screenY + part.params[2] * tileSize, 
                                                       part.params[3] * tileSize)
                            elseif part.shape == "polygon" then
                                local poly_coords = {}
                                for i = 1, #part.params, 2 do
                                    table.insert(poly_coords, screenX + part.params[i] * tileSize)
                                    table.insert(poly_coords, screenY + part.params[i+1] * tileSize)
                                end
                                love.graphics.polygon(part.mode, poly_coords)
                            elseif part.shape == "line" then
                                local line_coords = {}
                                for i = 1, #part.params, 2 do
                                    table.insert(line_coords, screenX + part.params[i] * tileSize)
                                    table.insert(line_coords, screenY + part.params[i+1] * tileSize)
                                end
                                love.graphics.line(line_coords)
                            end
                        end
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

-- Render the player
function Renderer.renderPlayer()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local gameState = GameManager.GameState
    local tileSize = gameState.viewMode == "zoomed" and GameConfig.WORLD.TILE_SIZE or GameConfig.WORLD.MINI_TILE_SIZE
    local viewSize = GameConfig.WORLD.VIEW_RADIUS
    
    -- Calculate visible area for minimap mode (same logic as in renderWorld)
    local startX, startY
    if gameState.viewMode == "minimap" then
        local tilesPerScreenX = math.floor(screenWidth / tileSize)
        local tilesPerScreenY = math.floor(screenHeight / tileSize)
        
        startX = math.max(1, gameState.minimap_camera.x)
        startY = math.max(1, gameState.minimap_camera.y)
        local endX = math.min(gameState.world.width, startX + tilesPerScreenX - 1)
        local endY = math.min(gameState.world.height, startY + tilesPerScreenY - 1)
        
        -- Adjust startX/startY if we hit world boundaries
        if endX == gameState.world.width then
            startX = math.max(1, endX - tilesPerScreenX + 1)
        end
        if endY == gameState.world.height then
            startY = math.max(1, endY - tilesPerScreenY + 1)
        end
    end
    
    -- Calculate player screen position
    local playerScreenX, playerScreenY
    
    if gameState.viewMode == "zoomed" then
        -- Calculate player position relative to camera
        local playerOffsetX = (gameState.player.x - gameState.camera.x) * tileSize
        local playerOffsetY = (gameState.player.y - gameState.camera.y) * tileSize
        playerScreenX = screenWidth/2 + playerOffsetX - tileSize/2
        playerScreenY = screenHeight/2 + playerOffsetY - tileSize/2
    else
        -- In minimap view, position player relative to minimap camera
        playerScreenX = (gameState.player.x - startX) * tileSize
        playerScreenY = (gameState.player.y - startY) * tileSize
    end
    
    -- Only draw player if they're visible on screen
    if gameState.viewMode == "zoomed" or 
       (gameState.player.x >= startX and gameState.player.x <= startX + math.floor(screenWidth / tileSize) and
        gameState.player.y >= startY and gameState.player.y <= startY + math.floor(screenHeight / tileSize)) then
        -- Draw player at center of tile
        love.graphics.setColor(unpack(GameConfig.PLAYER.COLOR))
        love.graphics.circle("fill", playerScreenX + tileSize/2, playerScreenY + tileSize/2, tileSize/2)
    end
end

-- Render the UI
function Renderer.renderUI()
    local gameState = GameManager.GameState
    local screenHeight = love.graphics.getHeight()
    
    -- Set color for UI text
    love.graphics.setColor(1, 1, 1)
    
    -- Game title and basic info
    love.graphics.print("Shattered Expanse - World View", 10, 10)
    love.graphics.print("Player Position: " .. gameState.player.x .. ", " .. gameState.player.y, 10, 30)
    love.graphics.print("Stamina: " .. gameState.player.stamina, 10, 50)
    
    -- Current biome info
    local currentTile = gameState.world.tiles[gameState.player.x][gameState.player.y]
    love.graphics.print("Current Biome: " .. currentTile.biome.name, 10, 90)
    love.graphics.print("Hazard: " .. currentTile.biome.hazard, 10, 110)
    love.graphics.print("View Mode: " .. gameState.viewMode .. " (Press 'M' to toggle)", 10, 130)
    
    -- Render inventory
    if gameState.player.inventory then
        local yOffset = GameConfig.UI.INVENTORY_START_Y
        for item, value in pairs(gameState.player.inventory) do
            if type(value) == "table" then
                -- Handle nested tables (like relic_fragments)
                for fragment_type, fragment_count in pairs(value) do
                    love.graphics.print(fragment_type .. " fragment: " .. fragment_count, 10, yOffset)
                    yOffset = yOffset + 20
                end
            elseif type(value) == "boolean" then
                local displayValue = value and "Yes" or "No"
                love.graphics.print(item .. ": " .. displayValue, 10, yOffset)
                yOffset = yOffset + 20
            else
                love.graphics.print(item .. ": " .. tostring(value), 10, yOffset) -- Use tostring for other types
                yOffset = yOffset + 20
            end
        end
        
        -- Render abilities
        if gameState.player.abilities then
            yOffset = yOffset + 20  -- Add some space after inventory
            love.graphics.print("Abilities:", 10, yOffset)
            yOffset = yOffset + 20
            for ability, level in pairs(gameState.player.abilities) do
                love.graphics.print("- " .. ability .. " (Level " .. level .. ")", 20, yOffset)
                yOffset = yOffset + 20
            end
        end
    end
    
    -- Render meta resources
    love.graphics.print("Crystals: " .. gameState.meta.banked_resources.crystal, 10, screenHeight - 30)
end

-- Render Relic Reconstruction UI
function Renderer.renderRelicReconstructionUI()
    local gameState = GameManager.GameState
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local startX = screenWidth - GameConfig.UI.RELIC_UI_OFFSET_X -- Use config value
    local startY = screenHeight - GameConfig.UI.RELIC_UI_OFFSET_Y -- Use config value
    local lineHeight = 20

    love.graphics.setColor(1, 1, 1) -- White text
    love.graphics.print("Relic Reconstruction:", startX, startY)
    startY = startY + lineHeight + 5 -- Add some padding

    if gameState.meta.relics and #gameState.meta.relics > 0 then
        for i, relic in ipairs(gameState.meta.relics) do
            local relicStatus = relic.reconstructed and " (Reconstructed)" or ""
            love.graphics.print(relic.name .. relicStatus, startX, startY)
            startY = startY + lineHeight

            if not relic.reconstructed then
                for fragmentType, requiredCount in pairs(relic.fragments) do
                    local currentCount = 0
                    if gameState.player.inventory.relic_fragments and gameState.player.inventory.relic_fragments[fragmentType] then
                        currentCount = gameState.player.inventory.relic_fragments[fragmentType]
                    end
                    local fragmentText = string.format("- %s: %d/%d", fragmentType, currentCount, requiredCount)
                    love.graphics.print(fragmentText, startX + 15, startY)
                    startY = startY + lineHeight
                end
            end
            startY = startY + (lineHeight / 2) -- Extra space between relics
        end
    else
        love.graphics.print("No relics defined.", startX, startY)
    end
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
