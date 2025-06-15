-- src/systems/ability_system.lua
-- Manages player abilities and their effects on gameplay

local GameConfig = require("src.config.game_config")

local AbilitySystem = {}

-- Define ability effects and their implementation
AbilitySystem.ABILITY_EFFECTS = {
    basic_map = {
        name = "Basic Map",
        description = "Reveals the basic outline of the world map",
        effect = function(player, world)
            -- This effect reveals the world outline at the start of a run
            -- Implementation is in the apply effects function
            return true
        end
    },
    
    stamina_boost = {
        name = "Stamina Boost",
        description = "Increases maximum stamina by 20 per level",
        effect = function(player, world)
            local level = player.abilities.stamina_boost or 0
            return 20 * level
        end
    },
    
    biome_mastery = {
        name = "Biome Mastery",
        description = "Reduces hazard damage by 25% per level",
        effect = function(player, tile)
            local level = player.abilities.biome_mastery or 0
            return 1.0 - (0.25 * level)  -- Returns damage multiplier (0.75, 0.5, etc.)
        end
    },
    
    pathfinder = {
        name = "Pathfinder",
        description = "Increases exploration radius by 1 per level",
        effect = function(player, world)
            local level = player.abilities.pathfinder or 0
            return level  -- Returns additional exploration radius
        end
    },
    
    treasure_hunter = {
        name = "Treasure Hunter",
        description = "25% chance per level to find extra resources at landmarks",
        effect = function(player, landmark)
            local level = player.abilities.treasure_hunter or 0
            return level * 0.25  -- Returns probability of bonus
        end
    },
    
    aerial_survey = {
        name = "Aerial Survey",
        description = "Once per run, reveal all landmarks within a large radius",
        usageEffect = function(player, world, x, y)
            if player.used_aerial_survey then
                return false, "Already used Aerial Survey this run"
            end
            
            -- Reveal landmarks in a radius
            local radius = 15  -- Large radius
            local revealed = 0
            
            for dx = -radius, radius do
                for dy = -radius, radius do
                    local tx = x + dx
                    local ty = y + dy
                    
                    -- Check boundaries
                    if tx >= 1 and tx <= world.width and ty >= 1 and ty <= world.height then
                        -- Check if it's within the circular radius
                        if dx*dx + dy*dy <= radius*radius then
                            local tile = world.tiles[tx][ty]
                            if tile.landmark and not tile.landmark.discovered then
                                tile.landmark.discovered = true
                                revealed = revealed + 1
                            end
                        end
                    end
                end
            end
            
            player.used_aerial_survey = true
            return true, "Revealed " .. revealed .. " landmarks"
        end
    },
    
    hazard_suit = {
        name = "Hazard Suit",
        description = "Immunity to all environmental hazards",
        effect = function(player, world)
            -- Simply having this ability grants immunity
            -- Implementation is in the hazard check function
            return true
        end
    }
}

-- Get all available abilities
function AbilitySystem.getAvailableAbilities()
    local abilities = {}
    for ability_id, ability_data in pairs(AbilitySystem.ABILITY_EFFECTS) do
        abilities[ability_id] = {
            name = ability_data.name,
            description = ability_data.description
        }
    end
    return abilities
end

-- Apply all start-of-run ability effects
function AbilitySystem.applyStartEffects(player, world)
    -- Apply basic_map effect if player has it
    if player.abilities.basic_map then
        -- Reveal the outer edge of the map
        for x = 1, world.width do
            for y = 1, world.height do
                if x == 1 or y == 1 or x == world.width or y == world.height then
                    world.tiles[x][y].explored = true
                end
            end
        end
    end
    
    -- Apply stamina boost
    if player.abilities.stamina_boost then
        local boost = AbilitySystem.ABILITY_EFFECTS.stamina_boost.effect(player, world)
        player.stamina = player.stamina + boost
    end
    
    -- Reset one-use abilities
    player.used_aerial_survey = false
end

-- Apply movement-based ability effects
function AbilitySystem.applyMovementEffects(player, world)
    -- Apply pathfinder effect
    if player.abilities.pathfinder then
        -- The actual implementation is in GameManager.exploreAroundPlayer
        -- which adds this bonus to the exploration radius
    end
    
    -- Other movement-based effects would go here
end

-- Use an active ability at the current position
function AbilitySystem.useAbility(ability_id, player, world)
    -- Check if player has the ability
    if not player.abilities[ability_id] then
        return false, "You don't have this ability"
    end
    
    -- Get the ability data
    local ability_data = AbilitySystem.ABILITY_EFFECTS[ability_id]
    
    -- Check if it's an active ability
    if not ability_data.usageEffect then
        return false, "This is a passive ability"
    end
    
    -- Use the ability at the player's current position
    return ability_data.usageEffect(player, world, player.x, player.y)
end

-- Unlock a new ability or upgrade an existing one
function AbilitySystem.unlockAbility(ability_id, player)
    -- Check if the ability exists
    if not AbilitySystem.ABILITY_EFFECTS[ability_id] then
        return false, "Invalid ability"
    end
    
    -- Add to unlocked abilities list in meta if not already there
    local already_unlocked = false
    for _, id in ipairs(player.meta.unlocked_abilities) do
        if id == ability_id then
            already_unlocked = true
            break
        end
    end
    
    if not already_unlocked then
        table.insert(player.meta.unlocked_abilities, ability_id)
    end
    
    -- Add or upgrade in current abilities
    player.abilities[ability_id] = (player.abilities[ability_id] or 0) + 1
    
    return true, AbilitySystem.ABILITY_EFFECTS[ability_id].name .. " unlocked/upgraded to level " .. player.abilities[ability_id]
end

-- Get the exploration radius with pathfinder bonus
function AbilitySystem.getExplorationRadius(player)
    local base_radius = GameConfig.WORLD.EXPLORE_RADIUS
    
    -- Add pathfinder bonus
    if player.abilities.pathfinder then
        local bonus = player.abilities.pathfinder
        return base_radius + bonus
    end
    
    return base_radius
end

return AbilitySystem
