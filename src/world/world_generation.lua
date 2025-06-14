-- src/world/world_generation.lua
-- Simple Perlin noise implementation

-- Permutation table
local perm = {}
for i = 0, 255 do
    perm[i] = math.random(0, 255)
end

-- Fade function
local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

-- Linear interpolation
local function lerp(t, a, b)
    return a + t * (b - a)
end

-- Gradient function
local function grad(hash, x, y, z)
    local h = hash % 16
    local u = h < 8 and x or y
    local v = h < 4 and y or (h == 12 or h == 14) and x or z
    return ((h % 2) == 0 and u or -u) + ((h % 3) == 0 and v or -v)
end

-- 2D Perlin noise
local function noise(x, y)
    local X = math.floor(x) % 255
    local Y = math.floor(y) % 255
    
    x = x - math.floor(x)
    y = y - math.floor(y)
    
    local u = fade(x)
    local v = fade(y)
    
    local a  = perm[X] + Y
    local aa = perm[a % 255]
    local ab = perm[(a+1) % 255]
    local b  = perm[(X+1) % 255] + Y
    local ba = perm[b % 255]
    local bb = perm[(b+1) % 255]
    
    return lerp(v, lerp(u, grad(perm[aa % 255], x, y, 0),
                        grad(perm[ba % 255], x-1, y, 0)),
                lerp(u, grad(perm[ab % 255], x, y-1, 0),
                        grad(perm[bb % 255], x-1, y-1, 0)))
end

local WorldGeneration = {}

-- Biome definitions
local BIOMES = {
    {id = 1, name = "Rusted Oasis", color = {200, 180, 100}, risk = "Low", hazard = "None"},
    {id = 2, name = "Veiled Jungle", color = {30, 120, 40}, risk = "Medium", hazard = "20% stamina drain"},
    {id = 3, name = "Stormspire Peaks", color = {120, 120, 140}, risk = "High", hazard = "40% stamina drain or reward"}
}

local LANDMARK_TYPES = {"Temple", "Caravan", "Cave", "Monolith"}

-- Generate a new world
function WorldGeneration.generateWorld(width, height)
    local world = {
        width = width,
        height = height,
        tiles = {}
    }
    
    -- Initialize empty grid
    for x = 1, width do
        world.tiles[x] = {}
        for y = 1, height do
            world.tiles[x][y] = {
                biome = nil,
                explored = false,
                landmark = nil
            }
        end
    end
    
    -- Assign biomes based on noise
    for x = 1, width do
        for y = 1, height do
            local noiseValue = noise(x * 0.1, y * 0.1)
            local tile = world.tiles[x][y]
            
            if noiseValue < 0.3 then
                tile.biome = BIOMES[1]
            elseif noiseValue < 0.6 then
                tile.biome = BIOMES[2]
            else
                tile.biome = BIOMES[3]
            end
        end
    end
    
    -- Place landmarks
    for i = 1, 20 do
        local placed = false
        while not placed do
            local x = math.random(1, width)
            local y = math.random(1, height)
            local tile = world.tiles[x][y]
            
            -- Only place landmarks on walkable tiles (non-peak biomes)
            if tile.biome.id ~= 3 then
                tile.landmark = {
                    type = LANDMARK_TYPES[math.random(#LANDMARK_TYPES)],
                    discovered = false,
                    visited = false,  -- New visited state
                    reward_type = "ability_" .. math.random(1, 5)
                }
                placed = true
            end
        end
    end
    
    return world
end

return WorldGeneration
