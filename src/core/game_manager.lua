-- src/core/game_manager.lua
-- Manages the core game state and initialization

local WorldGeneration = require("src.world.world_generation")
local ContractSystem = require("src.systems.contract_system")
local AbilitySystem = require("src.systems.ability_system")
local serpent = require("lib.serpent")
local GameConfig = require("src.config.game_config")

local GameManager = {}

-- Initialize the global game state
GameManager.GameState = {
    world = nil,
    player = {
        x = GameConfig.PLAYER.STARTING_X,
        y = GameConfig.PLAYER.STARTING_Y,
        stamina = GameConfig.PLAYER.STARTING_STAMINA,
        inventory = {},
        abilities = {}  -- Dictionary: {ability_name = level}
    },
    meta = {
        banked_resources = {crystal = 0},
        unlocked_abilities = {"basic_map"},
        discovered_landmarks = {},
        relics = {
            {name = "Chrono Prism", fragments = {time=3, space=2}, reconstructed = false},
            {name = "Aether Lens", fragments = {light=4, shadow=1}, reconstructed = false},
            {name = "Void Anchor", fragments = {void=5}, reconstructed = false},
            {name = "Life Spring", fragments = {life=4, water=2}, reconstructed = false}
        }
    },
    viewMode = "zoomed", -- "zoomed" or "minimap"
    camera = {
        x = 1,
        y = 1
    },
    contracts = {
        active = {},
        completed = 0
    },
    notifications = {}
}

-- Initialize the game
function GameManager.initialize()
    -- Load saved game if exists
    GameManager.loadGame()
    
    -- Initialize game world
    GameManager.GameState.world = WorldGeneration.generateWorld(
        GameConfig.WORLD.WIDTH, GameConfig.WORLD.HEIGHT
    )
    
    -- Apply start-of-run ability effects
    AbilitySystem.applyStartEffects(GameManager.GameState.player, GameManager.GameState.world)
    
    -- Set default font
    love.graphics.setFont(love.graphics.newFont(GameConfig.UI.FONT_SIZE))
    
    -- Initialize contracts
    GameManager.GameState.contracts = {
        active = {},
        completed = 0
    }
    
    -- Initialize notifications
    GameManager.GameState.notifications = {}
    
    -- Generate initial contract
    local initialContract = ContractSystem.generateContract()
    table.insert(GameManager.GameState.contracts.active, initialContract)
    
    print("World generated with dimensions: " .. GameManager.GameState.world.width .. "x" .. GameManager.GameState.world.height)
end

-- Save game state to file
function GameManager.saveGame()
    -- Only save persistent meta data
    local dataToSave = {
        meta = GameManager.GameState.meta
    }
    
    local serialized = serpent.dump(dataToSave)
    love.filesystem.write(GameConfig.SAVE.FILENAME, serialized)
end

-- Load game state from file
function GameManager.loadGame()
    if love.filesystem.getInfo(GameConfig.SAVE.FILENAME) then
        local data = love.filesystem.read(GameConfig.SAVE.FILENAME)
        local ok, saved = serpent.load(data)
        if ok then
            -- Only load persistent meta data
            GameManager.GameState.meta = saved.meta or GameManager.GameState.meta
        end
    end
end

-- Handle player death
function GameManager.onPlayerDeath()
    -- Save all relic fragments to meta progression
    if GameManager.GameState.player.inventory and GameManager.GameState.player.inventory.relic_fragments then
        GameManager.GameState.meta.relic_fragments = GameManager.GameState.meta.relic_fragments or {}
        for fragment_type, count in pairs(GameManager.GameState.player.inventory.relic_fragments) do
            GameManager.GameState.meta.relic_fragments[fragment_type] = (GameManager.GameState.meta.relic_fragments[fragment_type] or 0) + count
        end
    end
    
    -- Save discovered landmarks
    for x = 1, GameManager.GameState.world.width do
        for y = 1, GameManager.GameState.world.height do
            local tile = GameManager.GameState.world.tiles[x][y]
            if tile.landmark and tile.landmark.discovered then
                table.insert(GameManager.GameState.meta.discovered_landmarks, {
                    x = x, 
                    y = y,
                    type = tile.landmark.type
                })
            end
        end
    end
    
    -- Save game state before resetting
    GameManager.saveGame()

    -- Reset world and player
    GameManager.GameState.world = WorldGeneration.generateWorld(
        GameConfig.WORLD.WIDTH, GameConfig.WORLD.HEIGHT
    )
    GameManager.GameState.player = {
        x = GameConfig.PLAYER.STARTING_X,
        y = GameConfig.PLAYER.STARTING_Y,
        stamina = GameConfig.PLAYER.STARTING_STAMINA,
        inventory = {
            -- Restore relic fragments from meta
            relic_fragments = GameManager.GameState.meta.relic_fragments and GameManager.deepCopy(GameManager.GameState.meta.relic_fragments) or {}
        }
    }
    
    -- Load persistent abilities
    GameManager.GameState.player.abilities = {}
    for _, ability in ipairs(GameManager.GameState.meta.unlocked_abilities) do
        -- Initialize abilities at level 1
        GameManager.GameState.player.abilities[ability] = 1
    end
    
    -- Reset ability usage flags
    GameManager.GameState.player.used_aerial_survey = false
    
    -- Reset contracts
    GameManager.GameState.contracts = {
        active = {},
        completed = 0
    }
    
    -- Generate initial contract
    local initialContract = ContractSystem.generateContract()
    table.insert(GameManager.GameState.contracts.active, initialContract)
end

-- Helper function to deep copy tables
function GameManager.deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[GameManager.deepCopy(orig_key)] = GameManager.deepCopy(orig_value)
        end
        setmetatable(copy, GameManager.deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- Format reward text for notifications
function GameManager.formatReward(reward)
    if reward.type == "stamina" then
        return reward.amount .. " stamina"
    elseif reward.type == "resource" then
        return reward.amount .. " relic fragments"
    elseif reward.type == "relic_fragment" then
        return reward.amount .. " " .. reward.fragment_type .. " relic fragment(s)"
    elseif reward.type == "ability" then
        return "Ability: " .. reward.name
    end
    return "Reward"
end

-- Add a notification to the queue
function GameManager.addNotification(text)
    local notif = {
        text = text,
        timer = GameConfig.UI.NOTIFICATION_DURATION,
        alpha = 1
    }
    table.insert(GameManager.GameState.notifications, notif)
end

-- Update notifications (called every frame)
function GameManager.updateNotifications(dt)
    -- Handle notification timers
    for i = #GameManager.GameState.notifications, 1, -1 do
        local notif = GameManager.GameState.notifications[i]
        notif.timer = notif.timer - dt
        notif.alpha = math.min(1, notif.timer)  -- Fade out effect
        
        if notif.timer <= 0 then
            table.remove(GameManager.GameState.notifications, i)
        end
    end
end

-- Update contract progress and handle completion
function GameManager.updateContracts(dt)
    -- Update contract progress
    for i, contract in ipairs(GameManager.GameState.contracts.active) do
        if not contract.completed then
            -- Check contract completion
            if ContractSystem.checkCompletion(contract, GameManager.GameState.player, GameManager.GameState.world) then
                -- Grant reward and get reward details
                local reward = ContractSystem.grantReward(contract, GameManager.GameState.player)
                GameManager.GameState.contracts.completed = GameManager.GameState.contracts.completed + 1
                
                -- Add notification
                if reward then
                    GameManager.addNotification("Contract completed! Reward: " .. GameManager.formatReward(reward))
                end
                
                -- Set removal timer
                contract.completedTime = GameConfig.UI.CONTRACT_COMPLETION_DISPLAY_TIME
            end
        end
    end
    
    -- Handle contract removal timers
    for i = #GameManager.GameState.contracts.active, 1, -1 do
        local contract = GameManager.GameState.contracts.active[i]
        if contract.completed and contract.completedTime then
            contract.completedTime = contract.completedTime - dt
            if contract.completedTime <= 0 then
                table.remove(GameManager.GameState.contracts.active, i)
            end
        end
    end
end

-- Handle movement and exploration
function GameManager.movePlayer(dx, dy)
    local player = GameManager.GameState.player
    local world = GameManager.GameState.world
    
    -- Bounds check
    local newX = player.x + dx
    local newY = player.y + dy
    
    if newX >= 1 and newX <= world.width and newY >= 1 and newY <= world.height then
        player.x = newX
        player.y = newY
        
        -- Explore tiles around player
        GameManager.exploreAroundPlayer()
        
        -- Apply movement-based ability effects
        AbilitySystem.applyMovementEffects(player, world)
        
        -- Check for hazards
        GameManager.checkHazard(player.x, player.y)
        
        -- Check if player is on a landmark
        GameManager.checkLandmark()
    end
end

-- Explore tiles around player
function GameManager.exploreAroundPlayer()
    local player = GameManager.GameState.player
    local world = GameManager.GameState.world
    
    -- Explore in defined radius with boundary checks
    for dx = -GameConfig.WORLD.EXPLORE_RADIUS, GameConfig.WORLD.EXPLORE_RADIUS do
        for dy = -GameConfig.WORLD.EXPLORE_RADIUS, GameConfig.WORLD.EXPLORE_RADIUS do
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

-- Check for hazards at the player's position
function GameManager.checkHazard(x, y)
    local tile = GameManager.GameState.world.tiles[x][y]
    local biome_id = tile.biome.id
    local player = GameManager.GameState.player
    
    -- Check for hazard suit immunity
    if player.abilities and player.abilities.hazard_suit then
        return
    end
    
    if biome_id == 2 and math.random() < GameConfig.HAZARDS.JUNGLE_CHANCE then
        -- Apply biome mastery reduction if available
        local reduction = AbilitySystem.ABILITY_EFFECTS.biome_mastery.effect(player, tile) or 1
        player.stamina = player.stamina - (GameConfig.HAZARDS.JUNGLE_STAMINA_LOSS * reduction)
    elseif biome_id == 3 and math.random() < GameConfig.HAZARDS.PEAK_CHANCE then
        if math.random() > GameConfig.HAZARDS.PEAK_REWARD_CHANCE then 
            player.stamina = player.stamina - GameConfig.HAZARDS.PEAK_STAMINA_LOSS
        else
            -- Add relic fragment to inventory
            player.inventory = player.inventory or {}
            player.inventory.relic_fragment = (player.inventory.relic_fragment or 0) + 1
        end
    end
    
    -- Check for player death
    if player.stamina <= 0 then
        GameManager.onPlayerDeath()
    end
end

-- Check if player is on a landmark
function GameManager.checkLandmark()
    local player = GameManager.GameState.player
    local currentTile = GameManager.GameState.world.tiles[player.x][player.y]
    
    if currentTile.landmark and currentTile.landmark.discovered and not currentTile.landmark.visited then
        currentTile.landmark.visited = true
        
        -- Handle different landmark types
        if currentTile.landmark.type == "Contract_Scroll" then
            -- Generate new contract from scroll
            local newContract = ContractSystem.generateContract()
            table.insert(GameManager.GameState.contracts.active, newContract)
            GameManager.addNotification("New contract acquired from scroll!")
        else
            -- Add reward for regular landmark
            player.inventory = player.inventory or {}
            player.inventory.relic_fragment = (player.inventory.relic_fragment or 0) + 1
            GameManager.addNotification("Discovered " .. currentTile.landmark.type .. "! Gained 1 relic fragment.")
        end
    end
end

-- Toggle view mode between zoomed and minimap
function GameManager.toggleViewMode()
    if GameManager.GameState.viewMode == "zoomed" then
        GameManager.GameState.viewMode = "minimap"
    else
        GameManager.GameState.viewMode = "zoomed"
    end
end

-- Update camera position based on player position
function GameManager.updateCamera()
    local viewSize = GameConfig.WORLD.VIEW_RADIUS
    local player = GameManager.GameState.player
    local world = GameManager.GameState.world
    
    if GameManager.GameState.viewMode == "zoomed" then
        GameManager.GameState.camera.x = math.max(viewSize + 1, 
            math.min(player.x, world.width - viewSize))
        GameManager.GameState.camera.y = math.max(viewSize + 1, 
            math.min(player.y, world.height - viewSize))
    end
end

return GameManager
