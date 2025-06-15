-- lib/perlin.lua
-- Perlin noise implementation for procedural generation
-- This is a simplified version to replace the missing dependency

local Perlin = {}

-- Permutation table
local p = {}
-- Fill permutation table with values 0-255
for i = 0, 255 do
    p[i] = i
end

-- Shuffle the permutation table
for i = 255, 1, -1 do
    local j = math.floor(math.random() * (i + 1))
    p[i], p[j] = p[j], p[i]
end

-- Double the permutation table to avoid overflow
for i = 0, 255 do
    p[i + 256] = p[i]
end

-- Fade function for smooth interpolation
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

-- 2D Perlin noise function
-- Returns a value between -1 and 1
function Perlin.noise(x, y, z)
    z = z or 0
    
    -- Find unit cube containing the point
    local X = math.floor(x) % 256
    local Y = math.floor(y) % 256
    local Z = math.floor(z) % 256
    
    -- Find relative x, y, z of point in cube
    x = x - math.floor(x)
    y = y - math.floor(y)
    z = z - math.floor(z)
    
    -- Compute fade curves for each of x, y, z
    local u = fade(x)
    local v = fade(y)
    local w = fade(z)
    
    -- Hash coordinates of the 8 cube corners
    local A  = p[X] + Y
    local AA = p[A] + Z
    local AB = p[A+1] + Z
    local B  = p[X+1] + Y
    local BA = p[B] + Z
    local BB = p[B+1] + Z
    
    -- Add blended results from 8 corners of cube
    return lerp(w, lerp(v, lerp(u, grad(p[AA], x, y, z),
                                  grad(p[BA], x-1, y, z)),
                          lerp(u, grad(p[AB], x, y-1, z),
                                  grad(p[BB], x-1, y-1, z))),
                  lerp(v, lerp(u, grad(p[AA+1], x, y, z-1),
                                  grad(p[BA+1], x-1, y, z-1)),
                          lerp(u, grad(p[AB+1], x, y-1, z-1),
                                  grad(p[BB+1], x-1, y-1, z-1))))
end

-- Generate 2D Perlin noise with multiple octaves for more natural-looking noise
function Perlin.fractal(x, y, octaves, persistence)
    octaves = octaves or 1
    persistence = persistence or 0.5
    
    local total = 0
    local frequency = 1
    local amplitude = 1
    local maxValue = 0
    
    for i = 0, octaves - 1 do
        total = total + Perlin.noise(x * frequency, y * frequency) * amplitude
        maxValue = maxValue + amplitude
        amplitude = amplitude * persistence
        frequency = frequency * 2
    end
    
    -- Return a value between -1 and 1
    return total / maxValue
end

-- Generate a normalized noise value (0 to 1)
function Perlin.normalized(x, y, octaves, persistence)
    -- Convert from -1,1 range to 0,1 range
    return (Perlin.fractal(x, y, octaves, persistence) + 1) * 0.5
end

-- Seed the random number generator
function Perlin.seed(seed)
    math.randomseed(seed or os.time())
    
    -- Reset and reshuffle the permutation table
    for i = 0, 255 do
        p[i] = i
    end
    
    for i = 255, 1, -1 do
        local j = math.floor(math.random() * (i + 1))
        p[i], p[j] = p[j], p[i]
    end
    
    for i = 0, 255 do
        p[i + 256] = p[i]
    end
end

-- Initialize with a random seed
Perlin.seed()

return Perlin
