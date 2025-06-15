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

-- Helper function to check if a specific relic is reconstructed
function GameManager.isRelicReconstructed(relicName)
    if GameManager.GameState.meta and GameManager.GameState.meta.relics then
        for _, relic in ipairs(GameManager.GameState.meta.relics) do
            if relic.name == relicName and relic.reconstructed then
                return true
            end
        end
    end
    return false
end

-- Initialize the game
function GameManager.initialize()
    -- Load saved game if exists
    GameManager.loadGame()

    -- Apply Life Spring stamina boost if relic is reconstructed
    local baseStamina = GameConfig.PLAYER.STARTING_STAMINA
    if GameManager.isRelicReconstructed("Life Spring") then
        baseStamina = baseStamina + GameConfig.RELIC_EFFECTS.LIFE_SPRING_STAMINA_BOOST
    end
    GameManager.GameState.player.stamina = baseStamina -- Set initial stamina
    
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
    -- GameManager.GameState.meta already holds the default values (including relics)
    -- as defined at the top of this file when GameManager.GameState is initialized.
    -- We will selectively update these defaults with values from the save file if they exist.

    if love.filesystem.getInfo(GameConfig.SAVE.FILENAME) then
        local fileData = love.filesystem.read(GameConfig.SAVE.FILENAME)
        local ok, loadedSaveObject = serpent.load(fileData) -- loadedSaveObject is like { meta = { ... } }

        if ok and loadedSaveObject and loadedSaveObject.meta then
            local loadedMetaFromSave = loadedSaveObject.meta
            
            -- Update known fields in GameState.meta from loadedMetaFromSave if they exist.
            -- If a field is not present in loadedMetaFromSave, the default value in GameState.meta remains.
            if loadedMetaFromSave.banked_resources ~= nil then
                GameManager.GameState.meta.banked_resources = loadedMetaFromSave.banked_resources
            end
            if loadedMetaFromSave.unlocked_abilities ~= nil then
                GameManager.GameState.meta.unlocked_abilities = loadedMetaFromSave.unlocked_abilities
            end
            if loadedMetaFromSave.discovered_landmarks ~= nil then
                GameManager.GameState.meta.discovered_landmarks = loadedMetaFromSave.discovered_landmarks
            end
            if loadedMetaFromSave.relics ~= nil then
                -- If the save file has a 'relics' table, use it.
                GameManager.GameState.meta.relics = loadedMetaFromSave.relics
            end
            -- If loadedMetaFromSave.relics is nil (e.g., from an old save file without this field),
            -- then GameManager.GameState.meta.relics will retain its default value,
            -- which was set when GameManager.GameState was initially defined.
            
            -- Ensure crucial sub-fields are present, e.g. crystal in banked_resources
            if GameManager.GameState.meta.banked_resources == nil then
                 GameManager.GameState.meta.banked_resources = {crystal = 0} -- Default if banked_resources itself was nil
            elseif GameManager.GameState.meta.banked_resources.crystal == nil then
                 GameManager.GameState.meta.banked_resources.crystal = 0 -- Default if crystal key was missing
            end

        end
        -- If 'ok' is false, or loadedSaveObject/loadedSaveObject.meta is nil,
        -- GameState.meta remains unchanged (i.e., it keeps its default values).
    end
    -- If no save file exists, GameState.meta also remains unchanged (i.e., it keeps its default values).
end

-- Handle player death
function GameManager.onPlayerDeath()
    -- Persist the player's current relic fragments to meta.
    -- The player's inventory at the time of death reflects what they should carry over.
    if GameManager.GameState.player.inventory and GameManager.GameState.player.inventory.relic_fragments then
        -- We want meta to store the player's current fragment counts, not add to a previous meta count.
        -- So, we directly assign a deep copy of the player's current fragments to meta.
        GameManager.GameState.meta.relic_fragments = GameManager.deepCopy(GameManager.GameState.player.inventory.relic_fragments)
    else
        -- If player has no fragments in inventory, ensure meta reflects that (or an empty table if it was nil)
        GameManager.GameState.meta.relic_fragments = {}
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

    local startingStamina = GameConfig.PLAYER.STARTING_STAMINA
    if GameManager.isRelicReconstructed("Life Spring") then
        startingStamina = startingStamina + GameConfig.RELIC_EFFECTS.LIFE_SPRING_STAMINA_BOOST
    end

    GameManager.GameState.player = {
        x = GameConfig.PLAYER.STARTING_X,
        y = GameConfig.PLAYER.STARTING_Y,
        stamina = startingStamina, -- Apply potential Life Spring boost
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
        -- Check for impassable terrain BEFORE moving
        local target_tile_biome_id = world.tiles[newX][newY].biome.id
        local target_biome_props = WorldGeneration.BIOMES[target_tile_biome_id]

        if target_biome_props and target_biome_props.is_impassable then
            -- Check for climbing picks if it's an impassable mountain face
            if target_tile_biome_id == GameConfig.BIOME_IDS.IMPASSABLE_MOUNTAIN_FACE then
                if player.inventory and player.inventory.has_climbing_picks then
                    -- Allow movement
                else
                    GameManager.addNotification("Cannot climb this steep mountain face without climbing picks.")
                    return -- Stop movement
                end
            -- Add other impassable checks here later (e.g., for Deep Water and Raft)
            else
                -- Generic impassable message if not specifically handled above
                GameManager.addNotification("Cannot pass here.")
                return -- Stop movement
            end
        end

        player.x = newX
        player.y = newY

        -- NOTE: Default movement stamina cost has been removed.
        -- Chrono Prism's effect has been repurposed to reduce hazard stamina loss in checkHazard().
        
        -- Explore tiles around player
        GameManager.exploreAroundPlayer()
        
        -- Apply movement-based ability effects
        AbilitySystem.applyMovementEffects(player, world)
        
        -- Check for hazards (stamina already deducted for move, this is for tile-specific hazards)
        GameManager.checkHazard(player.x, player.y)
        
        -- Check if player is on a landmark
        GameManager.checkLandmark()

        -- Check for player death after all stamina deductions
        if player.stamina <= 0 then
            GameManager.onPlayerDeath()
        end
    end
end

-- Explore tiles around player
function GameManager.exploreAroundPlayer()
    local player = GameManager.GameState.player
    local world = GameManager.GameState.world
    
    local currentExploreRadius = GameConfig.WORLD.EXPLORE_RADIUS
    if GameManager.isRelicReconstructed("Aether Lens") then
        currentExploreRadius = currentExploreRadius + GameConfig.RELIC_EFFECTS.AETHER_LENS_EXPLORE_BONUS
    end
    
    -- Explore in defined radius with boundary checks
    for dx = -currentExploreRadius, currentExploreRadius do
        for dy = -currentExploreRadius, currentExploreRadius do
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
        if not (GameManager.isRelicReconstructed("Void Anchor") and math.random() < GameConfig.RELIC_EFFECTS.VOID_ANCHOR_HAZARD_IGNORE_CHANCE) then
            local staminaLoss = GameConfig.HAZARDS.JUNGLE_STAMINA_LOSS
            -- Apply Chrono Prism reduction if active
            if GameManager.isRelicReconstructed("Chrono Prism") then
                staminaLoss = staminaLoss * (1 - GameConfig.RELIC_EFFECTS.CHRONO_PRISM_HAZARD_REDUCTION_PERCENT)
            end
            -- Apply biome mastery reduction if available (stacks with Chrono Prism)
            local biomeMasteryReduction = AbilitySystem.ABILITY_EFFECTS.biome_mastery.effect(player, tile) or 1
            player.stamina = player.stamina - math.floor(staminaLoss * biomeMasteryReduction) -- Ensure whole number
        else
            GameManager.addNotification("Void Anchor protects you from the hazard!")
        end
    elseif biome_id == 3 and math.random() < GameConfig.HAZARDS.PEAK_CHANCE then
        if not (GameManager.isRelicReconstructed("Void Anchor") and math.random() < GameConfig.RELIC_EFFECTS.VOID_ANCHOR_HAZARD_IGNORE_CHANCE) then
            if math.random() > GameConfig.HAZARDS.PEAK_REWARD_CHANCE then
                local staminaLoss = GameConfig.HAZARDS.PEAK_STAMINA_LOSS
                -- Apply Chrono Prism reduction if active
                if GameManager.isRelicReconstructed("Chrono Prism") then
                    staminaLoss = staminaLoss * (1 - GameConfig.RELIC_EFFECTS.CHRONO_PRISM_HAZARD_REDUCTION_PERCENT)
                end
                player.stamina = player.stamina - math.floor(staminaLoss) -- Ensure whole number
            else
                -- Add relic fragment to inventory
                player.inventory = player.inventory or {}
                player.inventory.relic_fragment = (player.inventory.relic_fragment or 0) + 1
            end
        else
            GameManager.addNotification("Void Anchor protects you from the hazard!")
        end
    end
    
    -- Player death check is now handled in movePlayer after all stamina changes for the turn.
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
        elseif currentTile.landmark.type == "Ancient Obelisk" then
            player.inventory = player.inventory or {}
            player.inventory.relic_fragment = (player.inventory.relic_fragment or 0) + 1 -- Standard reward
            GameManager.addNotification("Discovered an Ancient Obelisk! Gained 1 relic fragment.")

            if currentTile.landmark.reveals_landmark_at then
                local spring_coords = currentTile.landmark.reveals_landmark_at
                if GameManager.GameState.world.tiles[spring_coords.x] and GameManager.GameState.world.tiles[spring_coords.x][spring_coords.y] then
                    local spring_tile = GameManager.GameState.world.tiles[spring_coords.x][spring_coords.y]
                    if spring_tile.landmark and spring_tile.landmark.type == "Hidden Spring" then
                        if not spring_tile.landmark.discovered then
                            spring_tile.landmark.discovered = true
                            spring_tile.explored = true -- Ensure the tile itself is marked explored for minimap visibility
                            -- We might want a different flag like 'pinpointed' or 'revealed_on_map'
                            -- For now, 'discovered' means it will show up on the map.
                            GameManager.addNotification("The Obelisk hums, revealing the location of a Hidden Spring on your map!")
                        end
                    end
                end
            end
        elseif currentTile.landmark.type == "Hidden Spring" then
            -- Player has reached the Hidden Spring
            player.inventory = player.inventory or {}
            -- Give a slightly better reward for finding a hidden spring
            local spring_reward = math.random(2,3)
            player.inventory.relic_fragment = (player.inventory.relic_fragment or 0) + spring_reward
            GameManager.addNotification("You found the Hidden Spring! Gained " .. spring_reward .. " relic fragments.")
        else
            -- Add reward for other regular landmarks
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

-- Debug function to add relic fragments
function GameManager.addDebugRelicFragments()
    local player = GameManager.GameState.player
    local relics = GameManager.GameState.meta.relics or {} -- Default to empty table if nil
    local amountToAdd = GameConfig.DEBUG.FRAGMENT_ADD_AMOUNT

    if not player.inventory.relic_fragments then
        player.inventory.relic_fragments = {}
    end

    if #relics == 0 then
        GameManager.addNotification("Debug: No relics defined in GameState.meta to add fragments for.")
        return
    end

    for _, relic in ipairs(relics) do
        if relic and relic.fragments then -- Ensure relic and its fragments table exist
            for fragmentType, _ in pairs(relic.fragments) do
                player.inventory.relic_fragments[fragmentType] = (player.inventory.relic_fragments[fragmentType] or 0) + amountToAdd
            end
        end
    end
    GameManager.addNotification(string.format("Added %d of each defined relic fragment type (debug).", amountToAdd))
end

-- Debug function to mark the next available relic as reconstructed
function GameManager.debugReconstructNextRelic()
    local relics = GameManager.GameState.meta.relics or {}
    local reconstructedRelicName = nil

    if #relics == 0 then
        GameManager.addNotification("Debug: No relics defined in GameState.meta to reconstruct.")
        return
    end

    for i, relic in ipairs(relics) do
        if relic and not relic.reconstructed then
            relic.reconstructed = true
            reconstructedRelicName = relic.name
            break -- Reconstruct only one relic per key press
        end
    end

    if reconstructedRelicName then
        GameManager.addNotification(string.format("Debug: Reconstructed relic '%s'.", reconstructedRelicName))
    else
        GameManager.addNotification("Debug: All defined relics are already reconstructed.")
    end
end

-- Attempt to reconstruct a relic
function GameManager.attemptRelicReconstruction()
    local player = GameManager.GameState.player
    local metaRelics = GameManager.GameState.meta.relics or {}
    local playerFragments = player.inventory.relic_fragments or {}
    local canReconstructAny = false
    local allRelicsDone = true

    for i, relic in ipairs(metaRelics) do
        if not relic.reconstructed then
            allRelicsDone = false -- Found at least one not reconstructed
            local hasEnoughFragments = true
            if relic.fragments then
                for fragmentType, requiredCount in pairs(relic.fragments) do
                    if (playerFragments[fragmentType] or 0) < requiredCount then
                        hasEnoughFragments = false
                        break
                    end
                end
            else
                hasEnoughFragments = false -- No fragments defined for relic, cannot reconstruct
            end

            if hasEnoughFragments then
                canReconstructAny = true
                -- Deduct fragments
                for fragmentType, requiredCount in pairs(relic.fragments) do
                    playerFragments[fragmentType] = playerFragments[fragmentType] - requiredCount
                    if playerFragments[fragmentType] == 0 then
                        playerFragments[fragmentType] = nil -- Clean up if count is zero
                    end
                end
                
                relic.reconstructed = true
                GameManager.addNotification(string.format("Relic '%s' reconstructed! Its power flows through you.", relic.name))
                -- Relic effects are applied passively based on their reconstructed state.
                return true -- Successfully reconstructed one relic
            end
        end
    end

    if allRelicsDone then
        GameManager.addNotification("All relics have already been reconstructed!")
    elseif not canReconstructAny then
        GameManager.addNotification("Not enough fragments to reconstruct any available relic.")
    end
    return false
end

-- Debug function to add climbing picks to player inventory
function GameManager.debugAddClimbingPicks()
    local player = GameManager.GameState.player
    player.inventory = player.inventory or {} -- Ensure inventory table exists
    player.inventory.has_climbing_picks = true
    GameManager.addNotification("Debug: Climbing Picks added to inventory.")
end

-- Debug function to toggle full map reveal
function GameManager.debugToggleRevealMap()
    if not GameManager.GameState.world or not GameManager.GameState.world.tiles then
        GameManager.addNotification("Debug: World not generated yet.")
        return
    end

    -- Determine if we are revealing or hiding (though hiding doesn't un-explore)
    local currentlyRevealed = true
    for x = 1, GameManager.GameState.world.width do
        for y = 1, GameManager.GameState.world.height do
            if not GameManager.GameState.world.tiles[x][y].explored then
                currentlyRevealed = false
                break
            end
        end
        if not currentlyRevealed then break end
    end

    local newExploredState = not currentlyRevealed

    for x = 1, GameManager.GameState.world.width do
        for y = 1, GameManager.GameState.world.height do
            GameManager.GameState.world.tiles[x][y].explored = newExploredState
            if GameManager.GameState.world.tiles[x][y].landmark then
                 GameManager.GameState.world.tiles[x][y].landmark.discovered = newExploredState
            end
        end
    end

    if newExploredState then
        GameManager.addNotification("Debug: Map revealed.")
    else
        GameManager.addNotification("Debug: Map exploration reset (visual only).") -- Tiles remain explored=true
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
