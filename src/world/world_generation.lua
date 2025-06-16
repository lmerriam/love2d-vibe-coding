-- src/world/world_generation.lua
-- Handles procedural world generation using Perlin noise

local Perlin = require("lib.perlin")
local GameConfig = require("src.config.game_config")

local WorldGeneration = {}

-- Define biomes with their properties
WorldGeneration.BIOMES = {
    [1] = { 
        name = "Plains", 
        color = {100, 180, 100}, -- RGB
        traversal_difficulty = 1,
        hazard = "None"
    },
    [2] = { 
        name = "Jungle", 
        color = {20, 120, 20}, 
        traversal_difficulty = 2,
        hazard = "Stamina loss (chance-based)"
    },
    [3] = { 
        name = "Mountains", 
        color = {120, 120, 120}, 
        traversal_difficulty = 3,
        hazard = "Stamina loss with chance of relic fragment"
    },
    [4] = { 
        name = "Desert", 
        color = {200, 200, 100}, 
        traversal_difficulty = 2,
        hazard = "None" 
    },
    [5] = { 
        name = "Tundra", 
        color = {200, 200, 255}, 
        traversal_difficulty = 3,
        hazard = "Stamina loss" 
    },
    [6] = {
        name = "Impassable Mountain Face",
        color = {80, 80, 90}, -- Darker grey/blue
        traversal_difficulty = 99, -- Effectively impassable
        hazard = "None",
        is_impassable = true
    }
}

-- Landmark types with their properties
local LANDMARK_TYPES = {
    "Ancient Ruins",
    "Mystic Shrine",
    "Crystal Formation",
    "Abandoned Camp",
    "Strange Monolith",
    "Ancient Obelisk", -- New: Reveals a Hidden Spring
    "Hidden Spring",   -- New: Revealed by an Ancient Obelisk
    "Ancient Lever",   -- New: Activates a secret passage
    "Seer's Totem",    -- New: Reveals a Hidden Cache
    "Hidden Cache",    -- New: Revealed by a Seer's Totem, contains reward
    "Contract_Scroll"  -- Special landmark that gives a new contract
}

-- Generate a new world with the given dimensions
-- Returns a world table containing all necessary information
function WorldGeneration.generateWorld(width, height)
    math.randomseed(os.time())
    
    -- Define noise scales for different features
    local REGION_SCALE = 0.02 -- Larger scale for broader regions
    local BIOME_SCALE = 0.05
    local DETAIL_SCALE = 0.1
    
    -- Create a new world structure
    local world = {
        width = width,
        height = height,
        tiles = {},
        discovered_landmarks = 0
    }
    
    -- Generate a random seed for the noise
    local base_seed = math.random(1, 10000)
    
    -- Generate Region Map
    Perlin.seed(base_seed) -- Seed for region generation
    local region_map = {}
    for x = 1, width do
        region_map[x] = {}
        for y = 1, height do
            local r_nx = x * REGION_SCALE
            local r_ny = y * REGION_SCALE
            local region_noise = Perlin.normalized(r_nx, r_ny, 2, 0.5) -- Simpler noise for broad regions

            local region_id
            -- Adjusted for 4 regions
            if region_noise < 0.25 then
                region_id = 1
            elseif region_noise < 0.50 then
                region_id = 2
            elseif region_noise < 0.75 then
                region_id = 3
            else
                region_id = 4
            end
            region_map[x][y] = region_id
        end
    end

    -- Ensure starting area is Tier 1
    local start_x = GameConfig.PLAYER.STARTING_X
    local start_y = GameConfig.PLAYER.STARTING_Y
    local start_area_radius = 10 -- How far around the start to force Tier 1
    local tier1_region_id = -1
    for i, region_config in ipairs(GameConfig.WORLD_REGIONS) do
        if region_config.difficultyTier == 1 then
            tier1_region_id = region_config.id
            break
        end
    end

    if tier1_region_id ~= -1 then
        for x = math.max(1, start_x - start_area_radius), math.min(width, start_x + start_area_radius) do
            for y = math.max(1, start_y - start_area_radius), math.min(height, start_y + start_area_radius) do
                if WorldGeneration.calculateDistance(start_x, start_y, x, y) <= start_area_radius then
                    region_map[x][y] = tier1_region_id
                end
            end
        end
    end

    -- First pass: Generate biomes based on regions
    Perlin.seed(base_seed + 1) -- Re-seed for biome detail to ensure different patterns
    for x = 1, width do
        world.tiles[x] = {}
        for y = 1, height do
            local current_region_id = region_map[x][y]
            local region_config = nil
            for i, r_conf in ipairs(GameConfig.WORLD_REGIONS) do
                if r_conf.id == current_region_id then
                    region_config = r_conf
                    break
                end
            end
            
            if not region_config then -- Fallback if region_id is somehow invalid
                print("Error: Invalid region_id " .. tostring(current_region_id) .. " at " .. x .. "," .. y)
                region_config = GameConfig.WORLD_REGIONS[1] -- Default to first region
            end

            local nx = x * BIOME_SCALE
            local ny = y * BIOME_SCALE
            local biome_noise = Perlin.normalized(nx, ny, 3, 0.5)
            
            local assigned_biome_id = GameConfig.BIOME_IDS.RUSTED_OASIS -- Default fallback biome

            for _, biome_entry in ipairs(region_config.biomePalette) do
                if biome_noise >= biome_entry.minNoise and biome_noise < biome_entry.maxNoise then
                    assigned_biome_id = biome_entry.biome_id
                    break
                end
            end
            
            -- Create the tile
            world.tiles[x][y] = {
                biome = {
                    id = assigned_biome_id,
                    name = WorldGeneration.BIOMES[assigned_biome_id].name,
                    color = WorldGeneration.BIOMES[assigned_biome_id].color,
                    traversal_difficulty = WorldGeneration.BIOMES[assigned_biome_id].traversal_difficulty,
                    hazard = WorldGeneration.BIOMES[assigned_biome_id].hazard
                },
                region_id = current_region_id, -- Store region ID for potential future use
                explored = false,
                items = {},
                terrain_features = {}
            }
        end
    end

    -- Helper function for Bresenham's Line Algorithm
    local function getLine(x1, y1, x2, y2)
        local line_tiles = {}
        local dx = math.abs(x2 - x1)
        local dy = math.abs(y2 - y1)
        local sx = (x1 < x2) and 1 or -1
        local sy = (y1 < y2) and 1 or -1
        local err = dx - dy

        while true do
            table.insert(line_tiles, {x = x1, y = y1})
            if x1 == x2 and y1 == y2 then break end
            local e2 = 2 * err
            if e2 > -dy then
                err = err - dy
                x1 = x1 + sx
            end
            if e2 < dx then
                err = err + dx
                y1 = y1 + sy
            end
        end
        return line_tiles
    end

    -- Second pass: Strategic Corridor Carving
    local PATH_BIOME_ID = GameConfig.BIOME_IDS.RUSTED_OASIS
    local safe_hubs = {}
    local start_hub_coords = nil
    local target_hub_coords = nil

    -- Find center of regions marked as safe passage targets
    local region_centers = {}
    for _, region_config in ipairs(GameConfig.WORLD_REGIONS) do
        local count = 0
        local sum_x, sum_y = 0, 0
        for tx = 1, width do
            for ty = 1, height do
                if region_map[tx][ty] == region_config.id then
                    sum_x = sum_x + tx
                    sum_y = sum_y + ty
                    count = count + 1
                end
            end
        end
        if count > 0 then
            region_centers[region_config.id] = {
                x = math.floor(sum_x / count),
                y = math.floor(sum_y / count),
                config = region_config
            }
            if region_config.isSafePassageTarget then
                table.insert(safe_hubs, region_centers[region_config.id])
            end
        end
    end
    
    -- Identify start hub (player's region) and one other target hub
    local player_start_region_id = region_map[GameConfig.PLAYER.STARTING_X][GameConfig.PLAYER.STARTING_Y]
    if region_centers[player_start_region_id] and region_centers[player_start_region_id].config.isSafePassageTarget then
        start_hub_coords = {x = region_centers[player_start_region_id].x, y = region_centers[player_start_region_id].y}
    end

    if start_hub_coords then
        for _, hub in ipairs(safe_hubs) do
            if hub.config.id ~= player_start_region_id then -- Find a *different* safe hub
                target_hub_coords = {x = hub.x, y = hub.y}
                break
            end
        end
    end
    
    if start_hub_coords and target_hub_coords then
        local base_corridor_path = getLine(start_hub_coords.x, start_hub_coords.y, target_hub_coords.x, target_hub_coords.y)
        local corridor_width = 1 -- 1 tile on each side, so 3 wide total
        
        local WOBBLE_FREQUENCY = 0.2 -- Apply wobble to 20% of path segments
        local MAX_WOBBLE_OFFSET = 2  -- Max perpendicular offset

        local wobbled_corridor_path = {}
        local last_x, last_y = base_corridor_path[1].x, base_corridor_path[1].y
        table.insert(wobbled_corridor_path, {x = last_x, y = last_y})

        for i = 2, #base_corridor_path do
            local current_p_tile = base_corridor_path[i]
            local next_x, next_y = current_p_tile.x, current_p_tile.y

            if math.random() < WOBBLE_FREQUENCY then
                local dx_path = next_x - last_x
                local dy_path = next_y - last_y
                local wobble_offset_val = math.random(-MAX_WOBBLE_OFFSET, MAX_WOBBLE_OFFSET)
                
                if dx_path == 0 then -- Vertical segment, wobble horizontally
                    next_x = math.max(1, math.min(width, next_x + wobble_offset_val))
                elseif dy_path == 0 then -- Horizontal segment, wobble vertically
                    next_y = math.max(1, math.min(height, next_y + wobble_offset_val))
                else -- Diagonal segment, choose one axis to wobble or apply more complex logic
                    if math.random() < 0.5 then
                        next_x = math.max(1, math.min(width, next_x + wobble_offset_val))
                    else
                        next_y = math.max(1, math.min(height, next_y + wobble_offset_val))
                    end
                end
            end
            -- To ensure connectivity with wobble, we might need to draw lines between wobbled points
            -- For simplicity now, just add the (potentially) wobbled point.
            -- A more robust approach would be to getLine between last_wobbled_point and current_wobbled_point.
            -- However, for small wobbles, direct addition might be okay.
            local intermediate_points = getLine(last_x, last_y, next_x, next_y)
            for j = 2, #intermediate_points do -- Start from 2nd point as last_x, last_y is already added
                table.insert(wobbled_corridor_path, intermediate_points[j])
            end
            last_x, last_y = next_x, next_y
        end

        for _, p_tile in ipairs(wobbled_corridor_path) do
            for dx_brush = -corridor_width, corridor_width do
                for dy_brush = -corridor_width, corridor_width do
                    -- Only carve a straight line for now, not a full square brush (using + shape brush)
                    if not (dx_brush ~= 0 and dy_brush ~= 0) then 
                        local carve_x, carve_y = p_tile.x + dx_brush, p_tile.y + dy_brush
                        if WorldGeneration.isInBounds(world, carve_x, carve_y) then
                            local tile_region_id = region_map[carve_x][carve_y]
                            local tile_region_config = region_centers[tile_region_id] and region_centers[tile_region_id].config or nil

                            -- Carve if the tile is in a non-safe-passage-target region
                            if tile_region_config and not tile_region_config.isSafePassageTarget then
                                world.tiles[carve_x][carve_y].biome = {
                                    id = PATH_BIOME_ID,
                                    name = WorldGeneration.BIOMES[PATH_BIOME_ID].name,
                                    color = WorldGeneration.BIOMES[PATH_BIOME_ID].color,
                                    traversal_difficulty = WorldGeneration.BIOMES[PATH_BIOME_ID].traversal_difficulty,
                                    hazard = WorldGeneration.BIOMES[PATH_BIOME_ID].hazard
                                }
                                world.tiles[carve_x][carve_y].isCorridorTile = true -- Mark for later
                            end
                        end
                    end
                end
            end
        end
    end

    -- Third pass: Identify borders and create chokepoints (simplified), avoiding corridor tiles
    local CHOKEPOINT_CHANCE = 0.1 -- 10% chance for a border tile to become a path
    -- local BORDER_DIFFICULTY_BIOME_ID = GameConfig.BIOME_IDS.STORMSPIRE_PEAKS -- Mountains as difficult border

    for x = 1, width do
        for y = 1, height do
            if not world.tiles[x][y].isCorridorTile then -- Skip if already part of a strategic corridor
                local current_tile_region_id = world.tiles[x][y].region_id
                local is_border_tile = false

                local neighbors = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}
                for _, offset in ipairs(neighbors) do
                    local nx, ny = x + offset[1], y + offset[2]
                    if WorldGeneration.isInBounds(world, nx, ny) then
                        if world.tiles[nx][ny].region_id ~= current_tile_region_id then
                            is_border_tile = true
                            break
                        end
                    end
                end

                if is_border_tile then
                    if math.random() < CHOKEPOINT_CHANCE then
                        world.tiles[x][y].biome = {
                            id = PATH_BIOME_ID,
                            name = WorldGeneration.BIOMES[PATH_BIOME_ID].name,
                            color = WorldGeneration.BIOMES[PATH_BIOME_ID].color,
                            traversal_difficulty = WorldGeneration.BIOMES[PATH_BIOME_ID].traversal_difficulty,
                            hazard = WorldGeneration.BIOMES[PATH_BIOME_ID].hazard
                        }
                    end
                end
            end
        end
    end

    -- Fourth pass: Place Impassable Mountain Faces
    local IMPASSABLE_CHANCE = 0.75 -- Increased to 75% chance for a mountain edge to become impassable
    for x = 1, width do
        for y = 1, height do
            if world.tiles[x][y].biome.id == GameConfig.BIOME_IDS.STORMSPIRE_PEAKS then
                local adjacent_to_plains = false
                local neighbors = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}
                for _, offset in ipairs(neighbors) do
                    local nx, ny = x + offset[1], y + offset[2]
                    if WorldGeneration.isInBounds(world, nx, ny) and 
                       world.tiles[nx][ny].biome.id == GameConfig.BIOME_IDS.RUSTED_OASIS then
                        adjacent_to_plains = true
                        break
                    end
                end

                if adjacent_to_plains and math.random() < IMPASSABLE_CHANCE then
                    local impassable_biome_id = GameConfig.BIOME_IDS.IMPASSABLE_MOUNTAIN_FACE
                    world.tiles[x][y].biome = {
                        id = impassable_biome_id,
                        name = WorldGeneration.BIOMES[impassable_biome_id].name,
                        color = WorldGeneration.BIOMES[impassable_biome_id].color,
                        traversal_difficulty = WorldGeneration.BIOMES[impassable_biome_id].traversal_difficulty,
                        hazard = WorldGeneration.BIOMES[impassable_biome_id].hazard,
                        is_impassable = WorldGeneration.BIOMES[impassable_biome_id].is_impassable
                    }
                end
            end
        end
    end
    
    -- Fifth pass: Place landmarks
    local total_landmarks_to_place = GameConfig.WORLD.LANDMARK_COUNT
    local obelisk_pairs_to_place = GameConfig.WORLD.OBELISK_PAIRS_COUNT or 0 -- Default to 0 if not in config yet
    local landmarks_placed = 0
    local attempts = 0
    local max_attempts_per_landmark = width * height / 4 -- Heuristic to prevent excessive looping for one landmark
    local total_placement_attempts = 0
    local max_total_attempts = width * height * 2


    -- Helper function to find an empty spot for a landmark
    local function findEmptySpotForLandmark(max_find_attempts)
        for i = 1, max_find_attempts do
            local lx = math.random(1, width)
            local ly = math.random(1, height)
            if not world.tiles[lx][ly].landmark then
                return lx, ly
            end
        end
        return nil, nil -- Could not find a spot
    end

    -- Place Obelisk-Spring pairs first
    local obelisks_placed_count = 0
    while obelisks_placed_count < obelisk_pairs_to_place and landmarks_placed < total_landmarks_to_place and total_placement_attempts < max_total_attempts do
        total_placement_attempts = total_placement_attempts + 1
        local obelisk_x, obelisk_y = findEmptySpotForLandmark(max_attempts_per_landmark)
        if obelisk_x then
            local spring_x, spring_y = findEmptySpotForLandmark(max_attempts_per_landmark)
            if spring_x and (obelisk_x ~= spring_x or obelisk_y ~= spring_y) then -- Ensure spring is at a different location
                -- Place Obelisk
                world.tiles[obelisk_x][obelisk_y].landmark = {
                    type = "Ancient Obelisk",
                    discovered = false,
                    visited = false,
                    reveals_landmark_at = { x = spring_x, y = spring_y }
                }
                landmarks_placed = landmarks_placed + 1

                -- Place Hidden Spring (if space allows for total landmarks)
                if landmarks_placed < total_landmarks_to_place then
                    world.tiles[spring_x][spring_y].landmark = {
                        type = "Hidden Spring",
                        discovered = false, -- Will be revealed by obelisk, not by normal exploration initially
                        visited = false,
                        is_hidden_spring = true,
                        initially_hidden = true -- Custom flag
                    }
                    landmarks_placed = landmarks_placed + 1
                    obelisks_placed_count = obelisks_placed_count + 1
                else
                    -- Not enough total landmark slots for the spring, undo obelisk
                    world.tiles[obelisk_x][obelisk_y].landmark = nil
                    landmarks_placed = landmarks_placed - 1
                    -- Potentially log this issue or handle it, for now, just means fewer pairs
                    break -- Stop trying to place pairs if we can't fit them
                end
            end
        end
        if total_placement_attempts > max_total_attempts / 2 and obelisks_placed_count == 0 and obelisk_pairs_to_place > 0 then
             print("Warning: Struggling to place initial obelisk pairs.") -- Avoid infinite loop if world is too small or full
        end
    end

    -- Place Seer's Totem / Hidden Cache pairs
    local seer_cache_pairs_to_place = GameConfig.WORLD.SEER_CACHE_PAIRS_COUNT or 0
    local seer_caches_placed_count = 0
    while seer_caches_placed_count < seer_cache_pairs_to_place and landmarks_placed < total_landmarks_to_place and total_placement_attempts < max_total_attempts do
        total_placement_attempts = total_placement_attempts + 1
        local totem_x, totem_y = findEmptySpotForLandmark(max_attempts_per_landmark)
        if totem_x then
            local cache_x, cache_y = findEmptySpotForLandmark(max_attempts_per_landmark)
            if cache_x and (totem_x ~= cache_x or totem_y ~= cache_y) then
                -- Place Seer's Totem
                world.tiles[totem_x][totem_y].landmark = {
                    type = "Seer's Totem",
                    discovered = false,
                    visited = false,
                    reveals_landmark_at = { x = cache_x, y = cache_y }
                }
                landmarks_placed = landmarks_placed + 1

                -- Place Hidden Cache
                if landmarks_placed < total_landmarks_to_place then
                    world.tiles[cache_x][cache_y].landmark = {
                        type = "Hidden Cache",
                        discovered = false,
                        visited = false,
                        is_hidden_cache = true,
                        initially_hidden = true,
                        looted = false -- To track if reward has been taken
                    }
                    landmarks_placed = landmarks_placed + 1
                    seer_caches_placed_count = seer_caches_placed_count + 1
                else
                    world.tiles[totem_x][totem_y].landmark = nil
                    landmarks_placed = landmarks_placed - 1
                    break 
                end
            end
        end
        if total_placement_attempts > max_total_attempts * 0.6 and seer_caches_placed_count == 0 and seer_cache_pairs_to_place > 0 then
             print("Warning: Struggling to place Seer's Totem/Cache pairs.")
        end
    end

    -- Place Ancient Levers
    local levers_to_place = GameConfig.SECRET_PASSAGES.LEVER_ACTIVATED.LEVER_COUNT or 0
    local levers_placed_count = 0
    while levers_placed_count < levers_to_place and landmarks_placed < total_landmarks_to_place and total_placement_attempts < max_total_attempts do
        total_placement_attempts = total_placement_attempts + 1
        local lever_x, lever_y = findEmptySpotForLandmark(max_attempts_per_landmark)
        if lever_x then
            world.tiles[lever_x][lever_y].landmark = {
                type = "Ancient Lever",
                discovered = false,
                visited = false,
                activated = false -- Specific to levers
            }
            landmarks_placed = landmarks_placed + 1
            levers_placed_count = levers_placed_count + 1
        end
        if total_placement_attempts > max_total_attempts * 0.75 and levers_placed_count == 0 and levers_to_place > 0 then
             print("Warning: Struggling to place Ancient Levers.")
        end
    end

    -- Place remaining landmarks
    local regular_landmarks_to_place = total_landmarks_to_place - landmarks_placed
    local regular_landmarks_placed_count = 0
    
    -- Create a list of regular landmark types (excluding special ones)
    local regular_landmark_pool = {}
    for _, l_type in ipairs(LANDMARK_TYPES) do
        if l_type ~= "Ancient Obelisk" and l_type ~= "Hidden Spring" and 
           l_type ~= "Ancient Lever" and l_type ~= "Contract_Scroll" and
           l_type ~= "Seer's Totem" and l_type ~= "Hidden Cache" then
            table.insert(regular_landmark_pool, l_type)
        end
    end

    while regular_landmarks_placed_count < regular_landmarks_to_place and landmarks_placed < total_landmarks_to_place and total_placement_attempts < max_total_attempts do
        total_placement_attempts = total_placement_attempts + 1
        local x, y = findEmptySpotForLandmark(max_attempts_per_landmark)
        
        if x and y then
            local landmark_type
            if math.random() < GameConfig.WORLD.LANDMARK_SCROLL_CHANCE and (#LANDMARK_TYPES > 2) then -- Ensure Contract_Scroll can be placed
                landmark_type = "Contract_Scroll"
            else
                if #regular_landmark_pool > 0 then
                    landmark_type = regular_landmark_pool[math.random(1, #regular_landmark_pool)]
                else
                    -- Fallback if pool is empty for some reason, though it shouldn't be
                    landmark_type = LANDMARK_TYPES[1] -- Default to first available type
                end
            end
            
            world.tiles[x][y].landmark = {
                type = landmark_type,
                discovered = false,
                visited = false
            }
            landmarks_placed = landmarks_placed + 1
            regular_landmarks_placed_count = regular_landmarks_placed_count + 1
        end
        if total_placement_attempts > max_total_attempts * 0.9 and regular_landmarks_placed_count < regular_landmarks_to_place / 2 then
            print("Warning: Struggling to place remaining regular landmarks.")
            break -- Avoid excessive looping
        end
    end

    -- Sixth pass: Ensure secret passage tiles are initially set correctly
    if GameConfig.SECRET_PASSAGES and GameConfig.SECRET_PASSAGES.LEVER_ACTIVATED then
        local passage_config = GameConfig.SECRET_PASSAGES.LEVER_ACTIVATED
        local initial_biome_id = passage_config.INITIAL_BIOME_ID
        local initial_biome_props = WorldGeneration.BIOMES[initial_biome_id]

        if initial_biome_props then
            for _, p_tile_coords in ipairs(passage_config.TILES) do
                if WorldGeneration.isInBounds(world, p_tile_coords.x, p_tile_coords.y) then
                    world.tiles[p_tile_coords.x][p_tile_coords.y].biome = {
                        id = initial_biome_id,
                        name = initial_biome_props.name,
                        color = initial_biome_props.color,
                        traversal_difficulty = initial_biome_props.traversal_difficulty,
                        hazard = initial_biome_props.hazard,
                        is_impassable = initial_biome_props.is_impassable 
                    }
                    -- Ensure no landmark is placed on these specific passage tiles
                    if world.tiles[p_tile_coords.x][p_tile_coords.y].landmark then
                        print("Warning: Removed landmark from a secret passage tile at " .. p_tile_coords.x .. "," .. p_tile_coords.y)
                        world.tiles[p_tile_coords.x][p_tile_coords.y].landmark = nil
                        -- Note: This could slightly reduce total landmarks if one was already there.
                        -- Consider adjusting landmark counts or placement logic if this becomes an issue.
                    end
                end
            end
        else
            print("Error: Invalid INITIAL_BIOME_ID for secret passage in game_config.")
        end
    end
    
    print("World generation complete. Placed " .. landmarks_placed .. " landmarks (" .. obelisks_placed_count .. " obelisk pairs, " .. seer_caches_placed_count .. " seer/cache pairs, " .. levers_placed_count .. " levers). All passes complete.")
    return world
end

-- Generate a landmark name with a random adjective and type
function WorldGeneration.generateLandmarkName(landmark_type)
    local adjectives = {
        "Ancient", "Forgotten", "Mysterious", "Shimmering", "Corrupted",
        "Abandoned", "Sacred", "Hidden", "Cursed", "Blessed",
        "Ethereal", "Haunted", "Magnificent", "Ruined", "Timeless"
    }
    
    local adjective = adjectives[math.random(1, #adjectives)]
    
    -- For Contract_Scroll, return a different format
    if landmark_type == "Contract_Scroll" then
        return "Weathered Contract Scroll"
    end
    
    return adjective .. " " .. landmark_type
end

-- Check if a point is within the world boundaries
function WorldGeneration.isInBounds(world, x, y)
    return x >= 1 and x <= world.width and y >= 1 and y <= world.height
end

-- Calculate distance between two points
function WorldGeneration.calculateDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Find the nearest landmark from a position
function WorldGeneration.findNearestLandmark(world, x, y)
    local nearest = nil
    local min_distance = math.huge
    
    for tx = 1, world.width do
        for ty = 1, world.height do
            local tile = world.tiles[tx][ty]
            if tile.landmark then
                local distance = WorldGeneration.calculateDistance(x, y, tx, ty)
                if distance < min_distance then
                    min_distance = distance
                    nearest = {x = tx, y = ty, type = tile.landmark.type}
                end
            end
        end
    end
    
    return nearest, min_distance
end

-- Add resources to a tile
function WorldGeneration.addResourceToTile(world, x, y, resource_type, amount)
    if not WorldGeneration.isInBounds(world, x, y) then
        return false
    end
    
    world.tiles[x][y].resources = world.tiles[x][y].resources or {}
    world.tiles[x][y].resources[resource_type] = (world.tiles[x][y].resources[resource_type] or 0) + amount
    return true
end

return WorldGeneration
