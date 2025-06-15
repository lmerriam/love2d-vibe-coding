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
    local seed = math.random(1, 10000)
    Perlin.seed(seed)
    
    -- First pass: Generate biomes
    for x = 1, width do
        world.tiles[x] = {}
        for y = 1, height do
            -- Generate noise value for this position
            local nx = x * BIOME_SCALE
            local ny = y * BIOME_SCALE
            
            -- Get normalized noise value (0 to 1)
            local noise = Perlin.normalized(nx, ny, 3, 0.5)
            
            -- Determine biome based on noise value
            local biome_id
            if noise < 0.2 then
                biome_id = 1  -- Plains
            elseif noise < 0.4 then
                biome_id = 2  -- Jungle
            elseif noise < 0.6 then
                biome_id = 3  -- Mountains
            elseif noise < 0.8 then
                biome_id = 4  -- Desert
            else
                biome_id = 5  -- Tundra
            end
            
            -- Create the tile
            world.tiles[x][y] = {
                biome = {
                    id = biome_id,
                    name = WorldGeneration.BIOMES[biome_id].name,
                    color = WorldGeneration.BIOMES[biome_id].color,
                    traversal_difficulty = WorldGeneration.BIOMES[biome_id].traversal_difficulty,
                    hazard = WorldGeneration.BIOMES[biome_id].hazard
                },
                explored = false,
                items = {},
                terrain_features = {}
            }
        end
    end
    
    -- Second pass: Place landmarks
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
    
    print("World generation complete. Placed " .. landmarks_placed .. " landmarks")
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
