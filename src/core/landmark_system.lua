-- src/core/landmark_system.lua
-- Landmark interaction system for player discoveries
-- Separated from main GameManager for better AI comprehension

local GameConfig = require("src.config.game_config")
local WorldGeneration = require("src.world.world_generation")
local ContractSystem = require("src.systems.contract_system")

local LandmarkSystem = {}

-- Process landmark interaction when player visits a landmark
-- @param landmark: Landmark data structure
-- @param tile: Tile containing the landmark
-- @param player: Player data structure
-- @param world: World data structure
-- @param contracts: Contracts data structure
-- @param addNotificationFn: Function to add notifications
-- @side_effects: May modify landmark state, player inventory, world tiles, contracts
function LandmarkSystem.processLandmarkInteraction(landmark, tile, player, world, contracts, addNotificationFn)
    if not landmark.visited then
        landmark.visited = true
        
        -- Route to specific handler based on landmark type
        if landmark.type == "Contract_Scroll" then
            LandmarkSystem.handleContractScroll(landmark, tile, player, world, contracts, addNotificationFn)
        elseif landmark.type == "Ancient Obelisk" then
            LandmarkSystem.handleAncientObelisk(landmark, tile, player, world, addNotificationFn)
        elseif landmark.type == "Hidden Spring" then
            LandmarkSystem.handleHiddenSpring(landmark, tile, player, world, addNotificationFn)
        elseif landmark.type == "Ancient Lever" then
            LandmarkSystem.handleAncientLever(landmark, tile, player, world, addNotificationFn)
        elseif landmark.type == "Seer's Totem" then
            LandmarkSystem.handleSeerTotem(landmark, tile, player, world, addNotificationFn)
        elseif landmark.type == "Hidden Cache" then
            LandmarkSystem.handleHiddenCache(landmark, tile, player, world, addNotificationFn)
        else
            -- Handle generic landmark types
            LandmarkSystem.handleGenericLandmark(landmark, tile, player, world, addNotificationFn)
        end
    end
end

-- Handle Contract Scroll landmark interaction
-- @param landmark: Landmark data structure
-- @param tile: Tile containing the landmark
-- @param player: Player data structure
-- @param world: World data structure
-- @param contracts: Contracts data structure
-- @param addNotificationFn: Function to add notifications
-- @side_effects: Adds new contract to active contracts
function LandmarkSystem.handleContractScroll(landmark, tile, player, world, contracts, addNotificationFn)
    -- Generate new contract from scroll
    local newContract = ContractSystem.generateContract()
    table.insert(contracts.active, newContract)
    addNotificationFn("New contract acquired from scroll!")
end

-- Handle Ancient Obelisk landmark interaction
-- @param landmark: Landmark data structure
-- @param tile: Tile containing the landmark
-- @param player: Player data structure
-- @param world: World data structure
-- @param addNotificationFn: Function to add notifications
-- @side_effects: May reveal linked Hidden Spring, adds relic fragment to inventory
function LandmarkSystem.handleAncientObelisk(landmark, tile, player, world, addNotificationFn)
    -- Give standard reward
    player.inventory = player.inventory or {}
    player.inventory.relic_fragment = (player.inventory.relic_fragment or 0) + 1
    addNotificationFn("Discovered an Ancient Obelisk! Gained 1 relic fragment.")

    -- Reveal linked Hidden Spring if it exists
    if landmark.reveals_landmark_at then
        local spring_coords = landmark.reveals_landmark_at
        if LandmarkSystem.isValidCoordinate(world, spring_coords.x, spring_coords.y) then
            local spring_tile = world.tiles[spring_coords.x][spring_coords.y]
            if spring_tile.landmark and spring_tile.landmark.type == "Hidden Spring" then
                if not spring_tile.landmark.discovered then
                    spring_tile.landmark.discovered = true
                    spring_tile.explored = true -- Ensure minimap visibility
                    addNotificationFn("The Obelisk hums, revealing the location of a Hidden Spring on your map!")
                end
            end
        end
    end
end

-- Handle Hidden Spring landmark interaction
-- @param landmark: Landmark data structure
-- @param tile: Tile containing the landmark
-- @param player: Player data structure
-- @param world: World data structure
-- @param addNotificationFn: Function to add notifications
-- @side_effects: Adds relic fragments to inventory
function LandmarkSystem.handleHiddenSpring(landmark, tile, player, world, addNotificationFn)
    player.inventory = player.inventory or {}
    -- Give enhanced reward for finding hidden spring
    local spring_reward = math.random(2, 3)
    player.inventory.relic_fragment = (player.inventory.relic_fragment or 0) + spring_reward
    addNotificationFn("You found the Hidden Spring! Gained " .. spring_reward .. " relic fragments.")
end

-- Handle Ancient Lever landmark interaction
-- @param landmark: Landmark data structure
-- @param tile: Tile containing the landmark
-- @param player: Player data structure
-- @param world: World data structure
-- @param addNotificationFn: Function to add notifications
-- @side_effects: May activate secret passage, adds relic fragment to inventory
function LandmarkSystem.handleAncientLever(landmark, tile, player, world, addNotificationFn)
    if not landmark.activated then
        landmark.activated = true
        player.inventory = player.inventory or {}
        player.inventory.relic_fragment = (player.inventory.relic_fragment or 0) + 1
        addNotificationFn("You pull the Ancient Lever... A distant rumble echoes.")

        -- Activate the secret passage
        LandmarkSystem.activateSecretPassage(world, addNotificationFn)
    else
        addNotificationFn("The Ancient Lever has already been pulled.")
    end
end

-- Handle Seer's Totem landmark interaction
-- @param landmark: Landmark data structure
-- @param tile: Tile containing the landmark
-- @param player: Player data structure
-- @param world: World data structure
-- @param addNotificationFn: Function to add notifications
-- @side_effects: May reveal linked Hidden Cache, adds relic fragment to inventory
function LandmarkSystem.handleSeerTotem(landmark, tile, player, world, addNotificationFn)
    player.inventory = player.inventory or {}
    player.inventory.relic_fragment = (player.inventory.relic_fragment or 0) + 1
    addNotificationFn("Discovered a Seer's Totem! Gained 1 relic fragment.")

    -- Reveal linked Hidden Cache if it exists
    if landmark.reveals_landmark_at then
        local cache_coords = landmark.reveals_landmark_at
        if LandmarkSystem.isValidCoordinate(world, cache_coords.x, cache_coords.y) then
            local cache_tile = world.tiles[cache_coords.x][cache_coords.y]
            if cache_tile.landmark and cache_tile.landmark.type == "Hidden Cache" then
                if not cache_tile.landmark.discovered then
                    cache_tile.landmark.discovered = true
                    cache_tile.explored = true -- Ensure minimap visibility
                    addNotificationFn("The Totem whispers, revealing a Hidden Cache on your map!")
                end
            end
        end
    end
end

-- Handle Hidden Cache landmark interaction
-- @param landmark: Landmark data structure
-- @param tile: Tile containing the landmark
-- @param player: Player data structure
-- @param world: World data structure
-- @param addNotificationFn: Function to add notifications
-- @side_effects: May loot cache and add rewards to inventory
function LandmarkSystem.handleHiddenCache(landmark, tile, player, world, addNotificationFn)
    if not landmark.looted then
        landmark.looted = true
        local reward_config = GameConfig.LANDMARK_CONFIG.HIDDEN_CACHE_REWARD
        local reward_text_parts = {}

        if reward_config.relic_fragments then
            player.inventory.relic_fragments = player.inventory.relic_fragments or {}
            for frag_type, amount in pairs(reward_config.relic_fragments) do
                player.inventory.relic_fragments[frag_type] = (player.inventory.relic_fragments[frag_type] or 0) + amount
                table.insert(reward_text_parts, amount .. " " .. frag_type .. " fragment(s)")
            end
        end

        if #reward_text_parts > 0 then
            addNotificationFn("You found the Hidden Cache! Gained: " .. table.concat(reward_text_parts, ", ") .. ".")
        else
            addNotificationFn("You found the Hidden Cache, but it was empty.")
        end
    else
        addNotificationFn("This Hidden Cache has already been looted.")
    end
end

-- Handle generic landmark types
-- @param landmark: Landmark data structure
-- @param tile: Tile containing the landmark
-- @param player: Player data structure
-- @param world: World data structure
-- @param addNotificationFn: Function to add notifications
-- @side_effects: Adds relic fragment to inventory
function LandmarkSystem.handleGenericLandmark(landmark, tile, player, world, addNotificationFn)
    player.inventory = player.inventory or {}
    player.inventory.relic_fragment = (player.inventory.relic_fragment or 0) + 1
    addNotificationFn("Discovered " .. landmark.type .. "! Gained 1 relic fragment.")
end

-- Activate secret passage mechanism
-- @param world: World data structure
-- @param addNotificationFn: Function to add notifications
-- @side_effects: Modifies world tiles to open passage
function LandmarkSystem.activateSecretPassage(world, addNotificationFn)
    local passage_config = GameConfig.SECRET_PASSAGES.LEVER_ACTIVATED
    if passage_config then
        local revealed_biome_id = passage_config.REVEALED_BIOME_ID
        local revealed_biome_props = WorldGeneration.BIOMES[revealed_biome_id]
        
        if revealed_biome_props then
            for _, p_tile_coords in ipairs(passage_config.TILES) do
                if LandmarkSystem.isValidCoordinate(world, p_tile_coords.x, p_tile_coords.y) then
                    local passage_tile = world.tiles[p_tile_coords.x][p_tile_coords.y]
                    passage_tile.biome = {
                        id = revealed_biome_id,
                        name = revealed_biome_props.name,
                        color = revealed_biome_props.color,
                        traversal_difficulty = revealed_biome_props.traversal_difficulty,
                        hazard = revealed_biome_props.hazard,
                        is_impassable = revealed_biome_props.is_impassable
                    }
                    passage_tile.explored = true -- Make passage visible
                end
            end
            addNotificationFn("A secret passage has opened!")
        else
            print("Error: Invalid REVEALED_BIOME_ID for secret passage in game_config.")
        end
    end
end

-- Validate if coordinates are within world bounds
-- @param world: World data structure
-- @param x: X coordinate
-- @param y: Y coordinate
-- @return boolean: true if coordinates are valid
function LandmarkSystem.isValidCoordinate(world, x, y)
    return world.tiles[x] and world.tiles[x][y] ~= nil
end

return LandmarkSystem
