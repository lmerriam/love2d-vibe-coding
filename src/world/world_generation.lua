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
    }
}

-- Landmark types with their properties
local LANDMARK_TYPES = {
    "Ancient Ruins",
    "Mystic Shrine",
    "Crystal Formation",
    "Abandoned Camp",
    "Strange Monolith",
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
        local corridor_path = getLine(start_hub_coords.x, start_hub_coords.y, target_hub_coords.x, target_hub_coords.y)
        local corridor_width = 1 -- 1 tile on each side, so 3 wide total

        for _, p_tile in ipairs(corridor_path) do
            for dx = -corridor_width, corridor_width do
                for dy = -corridor_width, corridor_width do
                    -- Only carve a straight line for now, not a full square brush
                    if not (dx ~= 0 and dy ~= 0) then -- Avoid corners of the square brush for a + shape
                        local carve_x, carve_y = p_tile.x + dx, p_tile.y + dy
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
    
    -- Fourth pass: Place landmarks
    local landmarks_to_place = GameConfig.WORLD.LANDMARK_COUNT
    local landmarks_placed = 0
    local attempts = 0
    local max_attempts = width * height  -- Prevent infinite loops
    
    while landmarks_placed < landmarks_to_place and attempts < max_attempts do
        attempts = attempts + 1
        
        -- Pick a random location
        local x = math.random(1, width)
        local y = math.random(1, height)
        
        -- Check if the tile doesn't already have a landmark
        if not world.tiles[x][y].landmark then
            -- Determine landmark type
            local landmark_type
            if math.random() < GameConfig.WORLD.LANDMARK_SCROLL_CHANCE then
                landmark_type = "Contract_Scroll"
            else
                -- Select a random landmark type except Contract_Scroll
                local index = math.random(1, #LANDMARK_TYPES - 1)
                landmark_type = LANDMARK_TYPES[index]
            end
            
            -- Add the landmark to the tile
            world.tiles[x][y].landmark = {
                type = landmark_type,
                discovered = false,
                visited = false
            }
            
            landmarks_placed = landmarks_placed + 1
        end
    end
    
    print("World generation complete. Placed " .. landmarks_placed .. " landmarks. Region, corridor, and chokepoint passes complete.")
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
