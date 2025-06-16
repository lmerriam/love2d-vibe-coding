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
    },
    [7] = {
        name = "Ancient Path",
        color = {160, 140, 80}, -- Sandy/golden brown for visibility
        traversal_difficulty = 1,
        hazard = "None",
        is_impassable = false
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

    -- Find a random safe starting location in a Tier 1 region
    local start_x, start_y = nil, nil
    local tier1_region_id = -1
    for i, region_config in ipairs(GameConfig.WORLD_REGIONS) do
        if region_config.difficultyTier == 1 then
            tier1_region_id = region_config.id
            break
        end
    end

    -- Find potential Tier 1 starting locations
    local potential_starts = {}
    for x = 1, width do
        for y = 1, height do
            if region_map[x][y] == tier1_region_id then
                table.insert(potential_starts, {x = x, y = y})
            end
        end
    end

    -- Pick a random starting location from Tier 1 region
    if #potential_starts > 0 then
        local chosen_start = potential_starts[math.random(1, #potential_starts)]
        start_x = chosen_start.x
        start_y = chosen_start.y
        
        -- Set the player starting position in config
        GameConfig.PLAYER.STARTING_X = start_x
        GameConfig.PLAYER.STARTING_Y = start_y
        
        print("Random starting location set to: " .. start_x .. ", " .. start_y)
    else
        -- Fallback to center if no Tier 1 region found
        start_x = math.floor(width / 2)
        start_y = math.floor(height / 2)
        GameConfig.PLAYER.STARTING_X = start_x
        GameConfig.PLAYER.STARTING_Y = start_y
        print("Fallback starting location set to center: " .. start_x .. ", " .. start_y)
    end

    -- Ensure starting area remains Tier 1
    local start_area_radius = 10 -- How far around the start to force Tier 1
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
            end
            end -- Close the if statement for valid edge check
        end
    end
        end
        return line_tiles
    end

    -- Second pass: MST-based Path Generation
    local function generateMSTNodes(world, region_map, region_centers)
        local nodes = {}
        local node_id = 1
        
        -- Add player starting position as the first node (now dynamically set)
        table.insert(nodes, {
            id = node_id,
            x = GameConfig.PLAYER.STARTING_X,
            y = GameConfig.PLAYER.STARTING_Y,
            type = "start",
            region_id = region_map[GameConfig.PLAYER.STARTING_X][GameConfig.PLAYER.STARTING_Y]
        })
        node_id = node_id + 1
        
        -- Add region centers as nodes
        for region_id, center in pairs(region_centers) do
            table.insert(nodes, {
                id = node_id,
                x = center.x,
                y = center.y,
                type = "region_center",
                region_id = region_id,
                config = center.config
            })
            node_id = node_id + 1
        end
        
        -- Add major landmarks as nodes if enabled
        if GameConfig.MST_PATH_SYSTEM.INCLUDE_LANDMARKS_AS_NODES then
            for x = 1, world.width do
                for y = 1, world.height do
                    local tile = world.tiles[x][y]
                    if tile.landmark then
                        local is_major = false
                        for _, major_type in ipairs(GameConfig.MST_PATH_SYSTEM.MAJOR_LANDMARK_TYPES) do
                            if tile.landmark.type == major_type then
                                is_major = true
                                break
                            end
                        end
                        
                        if is_major then
                            table.insert(nodes, {
                                id = node_id,
                                x = x,
                                y = y,
                                type = "landmark",
                                landmark_type = tile.landmark.type,
                                region_id = region_map[x][y]
                            })
                            node_id = node_id + 1
                        end
                    end
                end
            end
        end
        
        -- Add strategic nodes for better connectivity if enabled
        if GameConfig.MST_PATH_SYSTEM.ADD_STRATEGIC_NODES then
            local strategic_count = GameConfig.MST_PATH_SYSTEM.STRATEGIC_NODES_COUNT
            local min_distance = GameConfig.MST_PATH_SYSTEM.MIN_NODE_DISTANCE
            local attempts = 0
            local max_attempts = world.width * world.height / 10
            
            local function isValidStrategicPosition(x, y, existing_nodes)
                -- Check minimum distance from existing nodes
                for _, node in ipairs(existing_nodes) do
                    local distance = math.sqrt((x - node.x)^2 + (y - node.y)^2)
                    if distance < min_distance then
                        return false
                    end
                end
                
                -- Prefer positions that are not impassable
                local tile = world.tiles[x][y]
                if tile.biome.is_impassable then
                    return false
                end
                
                return true
            end
            
            for i = 1, strategic_count do
                local placed = false
                local attempt_count = 0
                
                while not placed and attempt_count < max_attempts do
                    local x = math.random(math.floor(world.width * 0.1), math.floor(world.width * 0.9))
                    local y = math.random(math.floor(world.height * 0.1), math.floor(world.height * 0.9))
                    
                    if isValidStrategicPosition(x, y, nodes) then
                        table.insert(nodes, {
                            id = node_id,
                            x = x,
                            y = y,
                            type = "strategic",
                            region_id = region_map[x][y]
                        })
                        node_id = node_id + 1
                        placed = true
                    end
                    
                    attempt_count = attempt_count + 1
                end
                
                if not placed then
                    print("Warning: Could not place strategic node " .. i .. " after " .. max_attempts .. " attempts")
                end
            end
        end
        
        return nodes
    end
    
    local function calculatePathWeight(world, region_map, elevation_map, x1, y1, x2, y2)
        local distance = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
        local weight = distance
        
        -- Sample points along the path to calculate terrain penalty
        local sample_count = math.max(5, math.floor(distance / 3)) -- More samples for better accuracy
        local terrain_penalty = 0
        local elevation_penalty = 0
        local region_crossings = 0
        local last_region = nil
        local last_elevation = nil
        
        for i = 0, sample_count do
            local t = i / sample_count
            local sample_x = math.floor(x1 + t * (x2 - x1) + 0.5)
            local sample_y = math.floor(y1 + t * (y2 - y1) + 0.5)
            
            if WorldGeneration.isInBounds(world, sample_x, sample_y) then
                local tile = world.tiles[sample_x][sample_y]
                local biome_id = tile.biome.id
                local region_id = region_map[sample_x][sample_y]
                local elevation = elevation_map[sample_x][sample_y]
                
                -- Apply terrain penalty
                local penalty = GameConfig.MST_PATH_SYSTEM.TERRAIN_PENALTIES[biome_id] or 1.0
                terrain_penalty = terrain_penalty + penalty
                
                -- Apply elevation-based penalties
                if last_elevation then
                    local elevation_change = math.abs(elevation - last_elevation)
                    -- Penalize steep grades heavily (ancient paths prefer gentle slopes)
                    local grade_penalty = elevation_change * GameConfig.MST_PATH_SYSTEM.ELEVATION_PENALTY_SCALE
                    elevation_penalty = elevation_penalty + grade_penalty
                    
                    -- Bonus for following valleys (preferring lower elevations)
                    local valley_bonus = (1.0 - elevation) * GameConfig.MST_PATH_SYSTEM.VALLEY_SEEKING_STRENGTH
                    elevation_penalty = elevation_penalty - valley_bonus
                end
                last_elevation = elevation
                
                -- Count region crossings
                if last_region and last_region ~= region_id then
                    region_crossings = region_crossings + 1
                end
                last_region = region_id
            end
        end
        
        -- Apply terrain penalty (average across samples)
        weight = weight * (terrain_penalty / (sample_count + 1))
        
        -- Apply elevation penalty
        weight = weight + (elevation_penalty / (sample_count + 1))
        
        -- Apply region crossing bonus (encourages inter-region connectivity)
        if region_crossings > 0 then
            weight = weight * GameConfig.MST_PATH_SYSTEM.REGION_CROSSING_BONUS
        end
        
        return weight
    end
    
    local function buildMinimumSpanningTree(nodes, world, region_map, elevation_map)
        if #nodes <= 1 then return {} end
        
        local mst_edges = {}
        local in_mst = {}
        local edge_costs = {}
        
        -- Start with the first node (player start)
        in_mst[1] = true
        
        -- Initialize edge costs from first node to all others
        for i = 2, #nodes do
            local weight = calculatePathWeight(world, region_map, elevation_map,
                nodes[1].x, nodes[1].y, nodes[i].x, nodes[i].y)
            edge_costs[i] = { cost = weight, from_node = 1, to_node = i }
        end
        
        -- Prim's algorithm: Add nodes one by one
        for _ = 1, #nodes - 1 do
            -- Find minimum cost edge to a node not in MST
            local min_cost = math.huge
            local min_edge = nil
            
            for i = 2, #nodes do
                if not in_mst[i] and edge_costs[i] and edge_costs[i].cost < min_cost then
                    min_cost = edge_costs[i].cost
                    min_edge = edge_costs[i]
                end
            end
            
            if min_edge then
                -- Add this edge to MST
                table.insert(mst_edges, {
                    from = nodes[min_edge.from_node],
                    to = nodes[min_edge.to_node],
                    cost = min_edge.cost
                })
                
                -- Add the new node to MST
                in_mst[min_edge.to_node] = true
                
                -- Update edge costs: check if new node provides cheaper paths to remaining nodes
                for i = 2, #nodes do
                    if not in_mst[i] then
                        local weight = calculatePathWeight(world, region_map, elevation_map,
                            nodes[min_edge.to_node].x, nodes[min_edge.to_node].y, 
                            nodes[i].x, nodes[i].y)
                        
                        if not edge_costs[i] or weight < edge_costs[i].cost then
                            edge_costs[i] = { cost = weight, from_node = min_edge.to_node, to_node = i }
                        end
                    end
                end
            end
        end
        
        return mst_edges
    end
    
    local function carveMSTCorridors(world, mst_edges, elevation_map)
        local PATH_BIOME_ID = GameConfig.MST_PATH_SYSTEM.PATH_BIOME_ID
        local base_width = GameConfig.MST_PATH_SYSTEM.BASE_CORRIDOR_WIDTH
        local meander_frequency = GameConfig.MST_PATH_SYSTEM.MEANDER_FREQUENCY
        local meander_strength = GameConfig.MST_PATH_SYSTEM.MEANDER_STRENGTH
        
        for _, edge in ipairs(mst_edges) do
            -- Safety check: ensure edge has valid from and to nodes
            if edge.from and edge.to and edge.from.x and edge.from.y and edge.to.x and edge.to.y then
            
            -- Calculate dynamic width based on node importance (with safety checks)
            local from_type = edge.from.type or "strategic"
            local to_type = edge.to.type or "strategic"
            local from_width = GameConfig.MST_PATH_SYSTEM.NODE_IMPORTANCE_WIDTHS[from_type] or base_width
            local to_width = GameConfig.MST_PATH_SYSTEM.NODE_IMPORTANCE_WIDTHS[to_type] or base_width
            
            local base_path = getLine(edge.from.x, edge.from.y, edge.to.x, edge.to.y)
            
            -- Create organic meander using noise-based curves instead of random wobble
            local meandered_path = {}
            Perlin.seed(math.random(1, 10000)) -- Random seed for this path's meander
            
            for i, path_point in ipairs(base_path) do
                local t = (i - 1) / (#base_path - 1) -- Progression along path (0 to 1)
                local meander_x = path_point.x
                local meander_y = path_point.y
                
                if math.random() < meander_frequency and i > 1 and i < #base_path then
                    -- Use noise for smoother, more natural curves
                    local noise_x = Perlin.normalized(i * 0.1, 0, 1, 0.5)
                    local noise_y = Perlin.normalized(0, i * 0.1, 1, 0.5)
                    
                    -- Apply meander perpendicular to path direction
                    local prev_point = base_path[i-1]
                    local dx = path_point.x - prev_point.x
                    local dy = path_point.y - prev_point.y
                    local length = math.sqrt(dx*dx + dy*dy)
                    
                    if length > 0 then
                        -- Perpendicular vector for natural meandering
                        local perp_x = -dy / length
                        local perp_y = dx / length
                        
                        local meander_offset = (noise_x - 0.5) * meander_strength
                        meander_x = math.max(1, math.min(world.width, path_point.x + perp_x * meander_offset))
                        meander_y = math.max(1, math.min(world.height, path_point.y + perp_y * meander_offset))
                    end
                end
                
                table.insert(meandered_path, {x = meander_x, y = meander_y, progress = t})
            end
            
            -- Carve corridor with variable width
            for i, path_tile in ipairs(meandered_path) do
                -- Interpolate width based on distance from important nodes
                local current_width = math.floor(from_width + (to_width - from_width) * path_tile.progress + 0.5)
                
                -- Apply terrain-based width modifiers
                if WorldGeneration.isInBounds(world, path_tile.x, path_tile.y) then
                    local terrain_biome = world.tiles[path_tile.x][path_tile.y].biome.id
                    local terrain_modifier = GameConfig.MST_PATH_SYSTEM.TERRAIN_WIDTH_MODIFIERS[terrain_biome] or 1.0
                    current_width = math.max(0, math.floor(current_width * terrain_modifier + 0.5))
                end
                
                -- Check if we're near a junction (close to nodes) and expand width
                local near_junction = false
                local junction_distance = GameConfig.MST_PATH_SYSTEM.JUNCTION_EXPANSION_RADIUS
                for _, node in ipairs({edge.from, edge.to}) do
                    local dist_to_node = math.sqrt((path_tile.x - node.x)^2 + (path_tile.y - node.y)^2)
                    if dist_to_node <= junction_distance then
                        current_width = current_width + 1
                        near_junction = true
                        break
                    end
                end
                
                -- Carve the corridor with calculated width
                for dx = -current_width, current_width do
                    for dy = -current_width, current_width do
                        -- Use circular brush for more natural paths (instead of + shape)
                        local distance = math.sqrt(dx*dx + dy*dy)
                        if distance <= current_width then
                            local carve_x, carve_y = path_tile.x + dx, path_tile.y + dy
                            if WorldGeneration.isInBounds(world, carve_x, carve_y) then
                                world.tiles[carve_x][carve_y].biome = {
                                    id = PATH_BIOME_ID,
                                    name = WorldGeneration.BIOMES[PATH_BIOME_ID].name,
                                    color = WorldGeneration.BIOMES[PATH_BIOME_ID].color,
                                    traversal_difficulty = WorldGeneration.BIOMES[PATH_BIOME_ID].traversal_difficulty,
                                    hazard = WorldGeneration.BIOMES[PATH_BIOME_ID].hazard
                                }
                                world.tiles[carve_x][carve_y].isCorridorTile = true
                            end
                        end
                    end
                end
            end
        end
    end

    -- Generate MST-based corridors if enabled
    if GameConfig.MST_PATH_SYSTEM.ENABLED then
        -- Generate elevation map for terrain-aware pathing
        Perlin.seed(base_seed + 2) -- Different seed for elevation
        local elevation_map = {}
        for x = 1, width do
            elevation_map[x] = {}
            for y = 1, height do
                local ex = x * GameConfig.MST_PATH_SYSTEM.NOISE_SCALE_ELEVATION
                local ey = y * GameConfig.MST_PATH_SYSTEM.NOISE_SCALE_ELEVATION
                elevation_map[x][y] = Perlin.normalized(ex, ey, 4, 0.6) -- Multiple octaves for realistic terrain
            end
        end
        
        -- Find center of regions
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
            end
        end
        
        -- Generate nodes, build MST, and carve corridors
        local nodes = generateMSTNodes(world, region_map, region_centers)
        local mst_edges = buildMinimumSpanningTree(nodes, world, region_map, elevation_map)
        carveMSTCorridors(world, mst_edges, elevation_map)
        
        print("MST path generation complete. Created " .. #mst_edges .. " corridors connecting " .. #nodes .. " nodes.")
    end

    -- Third pass: Identify borders and create chokepoints (simplified), avoiding corridor tiles
    local CHOKEPOINT_CHANCE = 0.1 -- 10% chance for a border tile to become a path
    local PATH_BIOME_ID = GameConfig.MST_PATH_SYSTEM.PATH_BIOME_ID

    for x = 1, width do
        for y = 1, height do
            if not world.tiles[x][y].isCorridorTile then -- Skip if already part of a MST corridor
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
