-- src/systems/contract_system.lua
local ContractSystem = {}

-- Contract types and their parameters
ContractSystem.CONTRACT_TYPES = {
    DISCOVER = {
        name = "Discover",
        description = "Find a %s",
        progress_fn = function(contract, player, world)
            -- Check if player is on a landmark of the target type
            local tile = world.tiles[player.x][player.y]
            if tile.landmark and tile.landmark.type == contract.target then
                return 1
            end
            return 0
        end
    },
    EXPLORE = {
        name = "Explore",
        description = "Reveal %d%% of %s biome",
        progress_fn = function(contract, player, world)
            -- Calculate percentage of biome explored
            local total = 0
            local explored = 0
            for x = 1, world.width do
                for y = 1, world.height do
                    local tile = world.tiles[x][y]
                    if tile.biome.id == contract.target then
                        total = total + 1
                        if tile.explored then
                            explored = explored + 1
                        end
                    end
                end
            end
            return math.floor((explored / total) * 100)
        end
    },
    COLLECT = {
        name = "Collect",
        description = "Gather %d %s",
        progress_fn = function(contract, player, world)
            -- Safely check player inventory
            if player.inventory then
                return player.inventory[contract.target] or 0
            end
            return 0
        end
    }
}

-- Generate a random contract
function ContractSystem.generateContract()
    local contractTypes = {"DISCOVER", "EXPLORE", "COLLECT"}
    local contractType = contractTypes[math.random(#contractTypes)]
    
    local contract = {
        type = contractType,
        progress = 0,
        completed = false
    }
    
    -- Set contract-specific parameters
    if contractType == "DISCOVER" then
        local landmarks = {"Temple", "Caravan", "Cave", "Monolith"}
        contract.target = landmarks[math.random(#landmarks)]
        contract.required = 1
        contract.reward = {type = "stamina", amount = 20}
    elseif contractType == "EXPLORE" then
        contract.target = math.random(1, 3) -- Biome ID
        contract.required = math.random(30, 70) -- Percentage
        contract.reward = {type = "resource", amount = math.random(1, 3)}
    elseif contractType == "COLLECT" then
        contract.target = "relic_fragment"
        contract.required = math.random(3, 5)
        contract.reward = {type = "ability", name = "explorer_"..math.random(1,3)}
    end
    
    return contract
end

-- Check if contract is complete
function ContractSystem.checkCompletion(contract, player, world)
    if contract.completed then return true end
    
    local contractType = ContractSystem.CONTRACT_TYPES[contract.type]
    contract.progress = contractType.progress_fn(contract, player, world)
    
    if contract.progress >= contract.required then
        contract.completed = true
        return true
    end
    return false
end

-- Grant contract reward
function ContractSystem.grantReward(contract, player)
    if not contract.completed then return end
    
    local reward = contract.reward
    if reward.type == "stamina" then
        player.stamina = player.stamina + reward.amount
    elseif reward.type == "resource" then
        player.inventory[contract.target] = (player.inventory[contract.target] or 0) + reward.amount
    elseif reward.type == "ability" then
        player.abilities = player.abilities or {}
        table.insert(player.abilities, reward.name)
    end
end

return ContractSystem
