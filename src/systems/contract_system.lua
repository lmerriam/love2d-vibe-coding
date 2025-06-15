-- src/systems/contract_system.lua
-- Manages the contract (quest) system

local WorldGeneration = require("src.world.world_generation")

local ContractSystem = {}

-- Define different contract types and their requirements
ContractSystem.CONTRACT_TYPES = {
    DISCOVER = {
        description = "Discover the %s landmark",
        generateContract = function()
            -- Create a contract to discover a specific landmark
            local contract = {
                type = "DISCOVER",
                target = nil,  -- Will be set to landmark type
                progress = 0,
                required = 1,
                completed = false
            }
            
            -- Pick a random landmark type except for Contract_Scroll
            local landmark_types = {
                "Ancient Ruins",
                "Mystic Shrine",
                "Crystal Formation",
                "Abandoned Camp",
                "Strange Monolith"
            }
            
            contract.target = landmark_types[math.random(1, #landmark_types)]
            return contract
        end,
        
        checkCompletion = function(contract, player, world)
            -- Check all explored tiles for the target landmark
            for x = 1, world.width do
                for y = 1, world.height do
                    local tile = world.tiles[x][y]
                    if tile.landmark and tile.landmark.type == contract.target and tile.landmark.visited then
                        contract.progress = 1
                        return true
                    end
                end
            end
            return false
        end,
        
        generateReward = function()
            local rewardTypes = {
                { type = "stamina", amount = 50 },
                { type = "resource", amount = 3 },
                { type = "relic_fragment", amount = 1, fragment_type = "time" }
            }
            return rewardTypes[math.random(1, #rewardTypes)]
        end
    },
    
    EXPLORE = {
        description = "Explore %d tiles of %s biome",
        generateContract = function()
            -- Create a contract to explore a specific biome
            local contract = {
                type = "EXPLORE",
                target = nil,  -- Will be set to biome ID
                progress = 0,
                required = math.random(5, 15),
                completed = false
            }
            
            -- Pick a random biome
            contract.target = math.random(1, #WorldGeneration.BIOMES)
            return contract
        end,
        
        checkCompletion = function(contract, player, world)
            -- Count explored tiles of the target biome
            local count = 0
            for x = 1, world.width do
                for y = 1, world.height do
                    local tile = world.tiles[x][y]
                    if tile.explored and tile.biome.id == contract.target then
                        count = count + 1
                    end
                end
            end
            
            contract.progress = math.min(count, contract.required)
            return count >= contract.required
        end,
        
        generateReward = function()
            local rewardTypes = {
                { type = "stamina", amount = 30 },
                { type = "resource", amount = 2 },
                { type = "relic_fragment", amount = 1, fragment_type = "space" }
            }
            return rewardTypes[math.random(1, #rewardTypes)]
        end
    },
    
    COLLECT = {
        description = "Collect %d %s fragments",
        generateContract = function()
            -- Create a contract to collect specific fragments
            local contract = {
                type = "COLLECT",
                target = nil,  -- Will be set to fragment type
                progress = 0,
                required = math.random(2, 5),
                completed = false
            }
            
            -- Pick a random fragment type
            local fragmentTypes = {"time", "space", "light", "shadow", "void", "life", "water"}
            contract.target = fragmentTypes[math.random(1, #fragmentTypes)]
            return contract
        end,
        
        checkCompletion = function(contract, player, world)
            -- Check if player has the required fragments
            if player.inventory and player.inventory.relic_fragments then
                local count = player.inventory.relic_fragments[contract.target] or 0
                contract.progress = math.min(count, contract.required)
                return count >= contract.required
            end
            return false
        end,
        
        generateReward = function()
            -- For collection quests, reward with a different fragment type
            local fragmentTypes = {"time", "space", "light", "shadow", "void", "life", "water"}
            local fragType = fragmentTypes[math.random(1, #fragmentTypes)]
            
            return { 
                type = "relic_fragment", 
                amount = 2, 
                fragment_type = fragType 
            }
        end
    },
    
    PATHFINDER = {
        description = "Reach the location at %s",
        generateContract = function()
            -- Create a contract to reach a specific location
            local contract = {
                type = "PATHFINDER",
                target_x = nil,
                target_y = nil,
                progress = 0,
                required = 1,
                completed = false
            }
            
            -- Set a random target location (not too close to the starting point)
            contract.target_x = math.random(20, 80)
            contract.target_y = math.random(20, 80)
            return contract
        end,
        
        checkCompletion = function(contract, player, world)
            -- Check if player is at the target location
            if player.x == contract.target_x and player.y == contract.target_y then
                contract.progress = 1
                return true
            end
            
            -- Calculate progress as inverse of distance (closer = higher progress)
            local distance = WorldGeneration.calculateDistance(
                player.x, player.y, contract.target_x, contract.target_y)
            
            -- Maximum theoretical distance in a 100x100 grid is about 141
            local maxDistance = math.sqrt(world.width^2 + world.height^2)
            contract.progress = math.floor((1 - (distance / maxDistance)) * contract.required)
            
            return false
        end,
        
        generateReward = function()
            -- Pathfinder contracts have better rewards
            local rewardTypes = {
                { type = "stamina", amount = 100 },
                { type = "resource", amount = 5 },
                { type = "ability", name = "pathfinder" }
            }
            return rewardTypes[math.random(1, #rewardTypes)]
        end
    }
}

-- Generate a random contract
function ContractSystem.generateContract()
    -- Select a random contract type
    local contractTypes = {"DISCOVER", "EXPLORE", "COLLECT", "PATHFINDER"}
    local contractType = contractTypes[math.random(1, #contractTypes)]
    
    -- Generate the contract using the type's generator function
    local contract = ContractSystem.CONTRACT_TYPES[contractType].generateContract()
    
    return contract
end

-- Check if a contract is completed
function ContractSystem.checkCompletion(contract, player, world)
    if contract.completed then
        return true
    end
    
    -- Use the contract type's check function
    local completed = ContractSystem.CONTRACT_TYPES[contract.type].checkCompletion(contract, player, world)
    
    if completed then
        contract.completed = true
    end
    
    return completed
end

-- Grant reward for a completed contract
function ContractSystem.grantReward(contract, player)
    if not contract.completed then
        return nil
    end
    
    -- Generate reward based on contract type
    local reward = ContractSystem.CONTRACT_TYPES[contract.type].generateReward()
    
    -- Apply the reward
    if reward.type == "stamina" then
        player.stamina = player.stamina + reward.amount
    elseif reward.type == "resource" then
        player.inventory = player.inventory or {}
        player.inventory.relic_fragment = (player.inventory.relic_fragment or 0) + reward.amount
    elseif reward.type == "relic_fragment" then
        player.inventory = player.inventory or {}
        player.inventory.relic_fragments = player.inventory.relic_fragments or {}
        player.inventory.relic_fragments[reward.fragment_type] = (player.inventory.relic_fragments[reward.fragment_type] or 0) + reward.amount
    elseif reward.type == "ability" then
        -- Unlock or upgrade the ability
        player.abilities = player.abilities or {}
        player.abilities[reward.name] = (player.abilities[reward.name] or 0) + 1
        
        -- Add to unlocked abilities in meta progression
        local found = false
        for _, ability in ipairs(player.meta.unlocked_abilities) do
            if ability == reward.name then
                found = true
                break
            end
        end
        
        if not found then
            table.insert(player.meta.unlocked_abilities, reward.name)
        end
    end
    
    return reward
end

return ContractSystem
