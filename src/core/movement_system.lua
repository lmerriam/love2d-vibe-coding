-- src/core/movement_system.lua
-- Movement system for player actions and position updates
-- Separated from main GameManager for better AI comprehension

local GameConfig = require("src.config.game_config")
local AbilitySystem = require("src.systems.ability_system")
local WorldGeneration = require("src.world.world_generation")

local MovementSystem = {}

-- Validate if a move to new coordinates is allowed
-- @param world: World data structure
-- @param player: Player data structure  
-- @param newX: Target X coordinate
-- @param newY: Target Y coordinate
-- @return boolean: true if move is valid, false otherwise
-- @return string|nil: error message if move is invalid
function MovementSystem.validateMove(world, player, newX, newY)
    -- Bounds check
    if newX < 1 or newX > world.width or newY < 1 or newY > world.height then
        return false, "Movement out of world bounds"
    end
    
    -- Check for impassable terrain
    local target_tile_biome_id = world.tiles[newX][newY].biome.id
    local target_biome_props = WorldGeneration.BIOMES[target_tile_biome_id]

    if target_biome_props and target_biome_props.is_impassable then
        -- Check for climbing picks if it's an impassable mountain face
        if target_tile_biome_id == GameConfig.BIOME_IDS.IMPASSABLE_MOUNTAIN_FACE then
            if not (player.inventory and player.inventory.has_climbing_picks) then
                return false, "Cannot climb this steep mountain face without climbing picks."
            end
        else
            -- Generic impassable message if not specifically handled above
            return false, "Cannot pass here."
        end
    end

    return true, nil
end

-- Update player position after validation
-- @param player: Player data structure
-- @param newX: Target X coordinate
-- @param newY: Target Y coordinate
-- @side_effects: Modifies player.x and player.y
function MovementSystem.updatePosition(player, newX, newY)
    player.x = newX
    player.y = newY
end

-- Apply movement-based ability effects
-- @param player: Player data structure
-- @param world: World data structure
-- @side_effects: May modify player abilities state
function MovementSystem.applyMovementEffects(player, world)
    AbilitySystem.applyMovementEffects(player, world)
end

-- Check for environmental hazards at position
-- @param world: World data structure
-- @param player: Player data structure
-- @param x: X coordinate to check
-- @param y: Y coordinate to check
-- @return number: stamina loss amount
-- @side_effects: May modify player.stamina, may trigger notifications
function MovementSystem.checkHazard(world, player, x, y, addNotificationFn)
    local tile = world.tiles[x][y]
    local biome_id = tile.biome.id
    local stamina_loss = 0
    
    -- Check for hazard suit immunity
    if player.abilities and player.abilities.hazard_suit then
        return stamina_loss
    end
    
    -- Helper function to check relic protection
    local function isRelicReconstructed(relicName)
        if player.gameState and player.gameState.meta and player.gameState.meta.relics then
            for _, relic in ipairs(player.gameState.meta.relics) do
                if relic.name == relicName and relic.reconstructed then
                    return true
                end
            end
        end
        return false
    end
    
    -- Jungle hazard
    if biome_id == 2 and math.random() < GameConfig.HAZARDS.JUNGLE_CHANCE then
        if not (isRelicReconstructed("Void Anchor") and math.random() < GameConfig.RELIC_EFFECTS.VOID_ANCHOR_HAZARD_IGNORE_CHANCE) then
            stamina_loss = GameConfig.HAZARDS.JUNGLE_STAMINA_LOSS
            -- Apply Chrono Prism reduction if active
            if isRelicReconstructed("Chrono Prism") then
                stamina_loss = stamina_loss * (1 - GameConfig.RELIC_EFFECTS.CHRONO_PRISM_HAZARD_REDUCTION_PERCENT)
            end
            -- Apply biome mastery reduction if available (stacks with Chrono Prism)
            local biomeMasteryReduction = AbilitySystem.ABILITY_EFFECTS.biome_mastery.effect(player, tile) or 1
            stamina_loss = math.floor(stamina_loss * biomeMasteryReduction) -- Ensure whole number
            player.stamina = player.stamina - stamina_loss
        else
            if addNotificationFn then
                addNotificationFn("Void Anchor protects you from the hazard!")
            end
        end
    -- Mountain peak hazard
    elseif biome_id == 3 and math.random() < GameConfig.HAZARDS.PEAK_CHANCE then
        if not (isRelicReconstructed("Void Anchor") and math.random() < GameConfig.RELIC_EFFECTS.VOID_ANCHOR_HAZARD_IGNORE_CHANCE) then
            if math.random() > GameConfig.HAZARDS.PEAK_REWARD_CHANCE then
                stamina_loss = GameConfig.HAZARDS.PEAK_STAMINA_LOSS
                -- Apply Chrono Prism reduction if active
                if isRelicReconstructed("Chrono Prism") then
                    stamina_loss = stamina_loss * (1 - GameConfig.RELIC_EFFECTS.CHRONO_PRISM_HAZARD_REDUCTION_PERCENT)
                end
                stamina_loss = math.floor(stamina_loss) -- Ensure whole number
                player.stamina = player.stamina - stamina_loss
            else
                -- Add relic fragment to inventory
                player.inventory = player.inventory or {}
                player.inventory.relic_fragment = (player.inventory.relic_fragment or 0) + 1
            end
        else
            if addNotificationFn then
                addNotificationFn("Void Anchor protects you from the hazard!")
            end
        end
    end
    
    return stamina_loss
end

-- Explore tiles around player position  
-- @param world: World data structure
-- @param player: Player data structure
-- @param isRelicReconstructedFn: Function to check relic status
-- @side_effects: Modifies world tile exploration state
function MovementSystem.exploreAroundPlayer(world, player, isRelicReconstructedFn)
    local currentExploreRadius = GameConfig.WORLD.EXPLORE_RADIUS
    if isRelicReconstructedFn("Aether Lens") then
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

-- Check if player has died from stamina loss
-- @param player: Player data structure
-- @return boolean: true if player has died
function MovementSystem.checkPlayerDeath(player)
    return player.stamina <= 0
end

return MovementSystem
