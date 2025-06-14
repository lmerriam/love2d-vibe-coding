-- main.lua
-- Entry point for Shattered Expanse game

-- Game state
local GameState = {
    world = nil,
    player = {
        x = 1,
        y = 1,
        stamina = 100
    },
    meta = {
        banked_resources = {crystal = 0},
        unlocked_abilities = {"basic_map"},
        discovered_landmarks = {}
    },
    viewMode = "zoomed", -- "zoomed" or "minimap"
    camera = {
        x = 1,
        y = 1
    }
}

-- Load dependencies
local WorldGeneration = require("src.world.world_generation")

function love.load()
    -- Initialize game world
    GameState.world = WorldGeneration.generateWorld(100, 100)
    print("World generated with dimensions: " .. GameState.world.width .. "x" .. GameState.world.height)
    
    -- Set default font
    love.graphics.setFont(love.graphics.newFont(14))
end

function love.update(dt)
    -- Update game logic
end

function love.draw()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local tileSize = GameState.viewMode == "zoomed" and 32 or 6
    local viewSize = 10  -- Tiles visible in each direction in zoomed view
    
    -- Update camera position in zoomed mode with boundary constraints
    if GameState.viewMode == "zoomed" then
        GameState.camera.x = math.max(viewSize + 1, math.min(GameState.player.x, GameState.world.width - viewSize))
        GameState.camera.y = math.max(viewSize + 1, math.min(GameState.player.y, GameState.world.height - viewSize))
    end
    
    -- Calculate visible area based on view mode
    local startX, endX, startY, endY
    
    if GameState.viewMode == "zoomed" then
        -- Show tiles around camera position
        startX = GameState.camera.x - viewSize
        endX = GameState.camera.x + viewSize
        startY = GameState.camera.y - viewSize
        endY = GameState.camera.y + viewSize
    else
        -- Show entire world for minimap
        startX = 1
        endX = GameState.world.width
        startY = 1
        endY = GameState.world.height
    end
    
    -- Render world grid
    for x = startX, endX do
        for y = startY, endY do
            local tile = GameState.world.tiles[x][y]
            local screenX, screenY
            
            if GameState.viewMode == "zoomed" then
                -- Center player on screen
                screenX = (x - startX) * tileSize + (screenWidth - (endX - startX + 1) * tileSize) / 2
                screenY = (y - startY) * tileSize + (screenHeight - (endY - startY + 1) * tileSize) / 2
            else
                screenX = (x-1)*tileSize
                screenY = (y-1)*tileSize
            end
            
            if tile.explored then
                -- Draw biome color
                love.graphics.setColor(tile.biome.color[1]/255, tile.biome.color[2]/255, tile.biome.color[3]/255)
                love.graphics.rectangle("fill", screenX, screenY, tileSize, tileSize)
                
                -- Draw question mark for discovered but unvisited landmarks
                if tile.landmark and tile.landmark.discovered and not tile.landmark.visited then
                    love.graphics.setColor(1, 1, 1)  -- White
                    love.graphics.print("?", screenX + tileSize/2 - 3, screenY + tileSize/2 - 7)
                end
            else
                -- Unexplored tiles are black
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("fill", screenX, screenY, tileSize, tileSize)
            end
        end
    end
    
    -- Render player
    local playerScreenX, playerScreenY
    if GameState.viewMode == "zoomed" then
        -- Calculate player position relative to camera
        local playerOffsetX = (GameState.player.x - GameState.camera.x) * tileSize
        local playerOffsetY = (GameState.player.y - GameState.camera.y) * tileSize
        playerScreenX = screenWidth/2 + playerOffsetX - tileSize/2
        playerScreenY = screenHeight/2 + playerOffsetY - tileSize/2
    else
        -- In minimap view, center player in the tile
        playerScreenX = (GameState.player.x-1)*tileSize
        playerScreenY = (GameState.player.y-1)*tileSize
    end
    
    -- Draw player at center of tile
    love.graphics.setColor(1, 0, 0)  -- Red
    love.graphics.circle("fill", playerScreenX + tileSize/2, playerScreenY + tileSize/2, tileSize/2)
    
    -- Render UI text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Shattered Expanse - World View", 10, 10)
    love.graphics.print("Player Position: " .. GameState.player.x .. ", " .. GameState.player.y, 10, 30)
    love.graphics.print("Stamina: " .. GameState.player.stamina, 10, 50)
    
    -- Display current biome info
    local currentTile = GameState.world.tiles[GameState.player.x][GameState.player.y]
    love.graphics.print("Current Biome: " .. currentTile.biome.name, 10, 90)
    love.graphics.print("Hazard: " .. currentTile.biome.hazard, 10, 110)
    love.graphics.print("View Mode: " .. GameState.viewMode .. " (Press 'M' to toggle)", 10, 130)
    
    -- Render inventory
    if GameState.player.inventory then
        local yOffset = 150  -- Adjusted for new view mode info
        for item, count in pairs(GameState.player.inventory) do
            love.graphics.print(item .. ": " .. count, 10, yOffset)
            yOffset = yOffset + 20
        end
    end
    
    -- Render meta resources
    love.graphics.print("Crystals: " .. GameState.meta.banked_resources.crystal, 10, love.graphics.getHeight() - 30)
end

function love.keypressed(key)
    -- Handle key presses
    if key == "escape" then
        love.event.quit()
    elseif key == "up" and GameState.player.y > 1 then
        GameState.player.y = GameState.player.y - 1
        exploreAroundPlayer()
        checkHazard(GameState.player.x, GameState.player.y)
    elseif key == "down" and GameState.player.y < GameState.world.height then
        GameState.player.y = GameState.player.y + 1
        exploreAroundPlayer()
        checkHazard(GameState.player.x, GameState.player.y)
    elseif key == "left" and GameState.player.x > 1 then
        GameState.player.x = GameState.player.x - 1
        exploreAroundPlayer()
        checkHazard(GameState.player.x, GameState.player.y)
    elseif key == "right" and GameState.player.x < GameState.world.width then
        GameState.player.x = GameState.player.x + 1
        exploreAroundPlayer()
        checkHazard(GameState.player.x, GameState.player.y)
    elseif key == "m" then
        -- Toggle between zoomed and minimap views
        if GameState.viewMode == "zoomed" then
            GameState.viewMode = "minimap"
        else
            GameState.viewMode = "zoomed"
        end
    end
    
    -- After any movement, check if player is on a landmark tile
    local currentTile = GameState.world.tiles[GameState.player.x][GameState.player.y]
    if currentTile.landmark and currentTile.landmark.discovered and not currentTile.landmark.visited then
        currentTile.landmark.visited = true
        -- Add reward when visiting a landmark
        GameState.player.inventory = GameState.player.inventory or {}
        GameState.player.inventory.relic_fragment = (GameState.player.inventory.relic_fragment or 0) + 1
    end
end

-- Explore tiles around player
function exploreAroundPlayer()
    local player = GameState.player
    local world = GameState.world
    
    -- Explore in 3-tile radius with boundary checks
    for dx = -3, 3 do
        for dy = -3, 3 do
            local x = player.x + dx
            local y = player.y + dy
            
            -- Check boundaries before accessing tiles
            if x >= 1 and x <= world.width and y >= 1 and y <= world.height then
                world.tiles[x][y].explored = true
                if world.tiles[x][y].landmark then
                    world.tiles[x][y].landmark.discovered = true
                end
            end
        end
    end
end

function checkHazard(x, y)
    local tile = GameState.world.tiles[x][y]
    local biome_id = tile.biome.id
    
    if biome_id == 2 and math.random() < 0.2 then
        GameState.player.stamina = GameState.player.stamina - 10
    elseif biome_id == 3 and math.random() < 0.4 then
        if math.random() < 0.7 then 
            GameState.player.stamina = GameState.player.stamina - 20
        else
            -- Add relic fragment to inventory (placeholder)
            GameState.player.inventory = GameState.player.inventory or {}
            GameState.player.inventory.relic_fragment = (GameState.player.inventory.relic_fragment or 0) + 1
        end
    end
    
    -- Check for player death
    if GameState.player.stamina <= 0 then
        onPlayerDeath()
    end
end

function onPlayerDeath()
    -- Save the most valuable resource (simplified for now)
    if GameState.player.inventory and GameState.player.inventory.relic_fragment then
        GameState.meta.banked_resources.crystal = GameState.meta.banked_resources.crystal +
            math.floor(GameState.player.inventory.relic_fragment / 2)
    end
    
    -- Save discovered landmarks
    for x = 1, GameState.world.width do
        for y = 1, GameState.world.height do
            local tile = GameState.world.tiles[x][y]
            if tile.landmark and tile.landmark.discovered then
                table.insert(GameState.meta.discovered_landmarks, {
                    x = x, 
                    y = y,
                    type = tile.landmark.type
                })
            end
        end
    end
    
    -- Reset world and player
    GameState.world = WorldGeneration.generateWorld(100, 100)
    GameState.player = {
        x = 1,
        y = 1,
        stamina = 100,
        inventory = {}
    }
    
    -- Load persistent abilities
    GameState.player.abilities = {}
    for _, ability in ipairs(GameState.meta.unlocked_abilities) do
        table.insert(GameState.player.abilities, ability)
    end
end
