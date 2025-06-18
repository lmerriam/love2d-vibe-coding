-- src/config/game_config.lua
-- Central configuration for Shattered Expanse

local GameConfig = {
    -- World generation settings
    WORLD = {
        WIDTH = 200,
        HEIGHT = 200,
        TILE_SIZE = 32,
        MINI_TILE_SIZE = 6,
        VIEW_RADIUS = 10,
        EXPLORE_RADIUS = 3,
        LANDMARK_COUNT = 40, -- Doubled for larger world
        OBELISK_PAIRS_COUNT = 4, -- Doubled for larger world
        SEER_CACHE_PAIRS_COUNT = 4, -- Doubled for larger world
        LANDMARK_SCROLL_CHANCE = 0.25
    },

    BIOME_IDS = {
        RUSTED_OASIS = 1, -- Plains
        VEILED_JUNGLE = 2,
        STORMSPIRE_PEAKS = 3, -- Mountains
        DESERT = 4,
        TUNDRA = 5,
        IMPASSABLE_MOUNTAIN_FACE = 6,
        MST_PATH = 7 -- Distinct path tiles created by MST system
        -- Add new biome IDs here as they are created
    },

    WORLD_REGIONS = {
        -- Tier 1: Starting Region
        {
            id = 1, name = "The Verdant Belt", difficultyTier = 1, isSafePassageTarget = true,
            biomePalette = {
                { biome_id = 1, minNoise = 0, maxNoise = 0.4 }, -- Rusted Oasis (Plains) - Reduced range
                { biome_id = 2, minNoise = 0.4, maxNoise = 1.0 }  -- Veiled Jungle - Increased range
            }
        },
        -- Tier 2: Intermediate Region (Hazardous)
        {
            id = 2, name = "The Cinder Wastes", difficultyTier = 2, isSafePassageTarget = false,
            biomePalette = {
                { biome_id = 4, minNoise = 0, maxNoise = 0.5 }, -- Desert - Reduced range
                { biome_id = 3, minNoise = 0.5, maxNoise = 1.0 }  -- Stormspire Peaks (Mountains) - Increased range
            }
        },
        -- Tier 1: Another Safe Hub
        {
            id = 3, name = "The Sunken Oasis", difficultyTier = 1, isSafePassageTarget = true,
            biomePalette = {
                { biome_id = 1, minNoise = 0, maxNoise = 1.0 } -- Mostly Rusted Oasis (Plains) - Stays the same
            }
        },
        -- Tier 3: Advanced Region (Hazardous)
        {
            id = 4, name = "The Frostfell", difficultyTier = 3, isSafePassageTarget = false,
            biomePalette = {
                { biome_id = 5, minNoise = 0, maxNoise = 0.4 }, -- Tundra - Reduced range
                { biome_id = 3, minNoise = 0.4, maxNoise = 1.0 }  -- Stormspire Peaks (Mountains) - Increased range
            }
        }
        -- Add more regions as needed
    },
    
    -- Player settings
    PLAYER = {
        STARTING_X = nil, -- Will be set randomly during world generation
        STARTING_Y = nil, -- Will be set randomly during world generation
        STARTING_STAMINA = 100,
        COLOR = {1, 0, 0} -- Red
    },
    
    -- Hazard settings
    HAZARDS = {
        JUNGLE_CHANCE = 0.2,
        JUNGLE_STAMINA_LOSS = 10,
        PEAK_CHANCE = 0.4,
        PEAK_STAMINA_LOSS = 20,
        PEAK_REWARD_CHANCE = 0.3
    },
    
    -- UI settings
    UI = {
        FONT_SIZE = 14,
        NOTIFICATION_DURATION = 3,
        CONTRACT_COMPLETION_DISPLAY_TIME = 5,
        INVENTORY_START_Y = 150,
        CONTRACT_OFFSET_X = 250,
        RELIC_UI_OFFSET_X = 250, -- Offset from right edge for Relic UI
        RELIC_UI_OFFSET_Y = 200  -- Offset from bottom edge for Relic UI
    },
    
    -- Save settings
    SAVE = {
        FILENAME = "save.dat"
    },

    -- Debug settings
    DEBUG = {
        ADD_FRAGMENTS_KEY = "f1", -- Key to press to add relic fragments
        FRAGMENT_ADD_AMOUNT = 1,  -- Number of each fragment type to add
        RECONSTRUCT_RELIC_KEY = "f2", -- Key to mark the next available relic as reconstructed
        REVEAL_MAP_KEY = "f3", -- Key to toggle full map reveal
        DEBUG_ADD_CLIMBING_PICKS_KEY = "f4" -- Key to add climbing picks
    },

    -- Gameplay actions
    ACTIONS = {
        RECONSTRUCT_ATTEMPT_KEY = "r" -- Key to attempt relic reconstruction
    },

    -- Relic Effects Configuration
    RELIC_EFFECTS = {
        CHRONO_PRISM_HAZARD_REDUCTION_PERCENT = 0.25, -- Reduces hazard stamina loss by 25%
        AETHER_LENS_EXPLORE_BONUS = 1,
        VOID_ANCHOR_HAZARD_IGNORE_CHANCE = 0.10, -- 10% chance
        LIFE_SPRING_STAMINA_BOOST = 20
    },

    -- Secret Passage Configuration
    SECRET_PASSAGES = {
        LEVER_ACTIVATED = { -- Defines one specific passage activated by a lever
            TILES = { -- List of tiles forming the passage
                {x = 50, y = 50}, {x = 50, y = 51}, {x = 50, y = 52} 
            },
            INITIAL_BIOME_ID = 6, -- IMPASSABLE_MOUNTAIN_FACE
            REVEALED_BIOME_ID = 1, -- RUSTED_OASIS (Plains)
            LEVER_COUNT = 1 -- Number of levers in the world that can activate this
        }
        -- Can add more passage configurations here later if needed
    },

    -- MST Path System Configuration
    MST_PATH_SYSTEM = {
        ENABLED = true, -- Enable/disable MST path generation
        TERRAIN_PENALTIES = {
            [1] = 1.0, -- RUSTED_OASIS (Plains) - no penalty
            [2] = 1.5, -- VEILED_JUNGLE - moderate penalty
            [3] = 2.0, -- STORMSPIRE_PEAKS (Mountains) - high penalty
            [4] = 1.3, -- DESERT - light penalty
            [5] = 1.8, -- TUNDRA - high penalty
            [6] = 5.0  -- IMPASSABLE_MOUNTAIN_FACE - very high penalty (avoid if possible)
        },
        ELEVATION_PENALTY_SCALE = 3.0, -- Multiplier for elevation-based path penalties
        REGION_CROSSING_BONUS = 0.8, -- Reduce weight when path crosses regions (encourages connectivity)
        INCLUDE_LANDMARKS_AS_NODES = true, -- Include major landmarks as graph nodes
        MAJOR_LANDMARK_TYPES = { -- Landmark types that become graph nodes
            "Ancient Ruins",
            "Mystic Shrine", 
            "Ancient Obelisk",
            "Strange Monolith",
            "Crystal Formation",
            "Abandoned Camp",
            "Seer's Totem"
        },
        ADD_STRATEGIC_NODES = true, -- Add additional strategic nodes for better connectivity
        STRATEGIC_NODES_COUNT = 6, -- Number of additional strategic nodes to place
        MIN_NODE_DISTANCE = 15, -- Minimum distance between nodes to ensure spread
        
        -- Organic Path Generation (New System)
        USE_ORGANIC_PATHS = true, -- Enable organic pathfinding instead of straight lines
        LIGHTWEIGHT_MODE = true, -- Use simplified algorithms for better performance
        
        -- Simplified Terrain Avoidance (lightweight alternative to flow fields)
        TERRAIN_AVOIDANCE = {
            ENABLED = true,
            AVOIDANCE_STRENGTH = 1.5, -- How much paths try to avoid difficult terrain
            SAMPLE_DISTANCE = 3, -- How far ahead to look when choosing path direction
            TERRAIN_PREFERENCE = { -- Lower values = more preferred (inverted from penalties)
                [1] = 1.0, -- Plains - preferred
                [2] = 2.0, -- Jungle - avoid
                [3] = 3.0, -- Mountains - strongly avoid
                [4] = 1.2, -- Desert - slightly avoid
                [5] = 2.5, -- Tundra - avoid
                [6] = 10.0  -- Impassable - strongly avoid
            }
        },
        
        -- Simplified Bezier Curves (no flow field dependency)
        BEZIER_CURVES = {
            ENABLED = true,
            SEGMENT_LENGTH = 15, -- Break paths into segments of this length
            CONTROL_POINT_OFFSET = 0.25, -- How far control points deviate (0-1)
            RANDOM_VARIATION = 0.3, -- Random variation in control points
            CURVE_RESOLUTION = 1.0, -- Step size for curve generation (larger = fewer points)
            TERRAIN_BIAS = 0.4 -- How much terrain affects control point placement (0-1)
        },
        
        -- Path Network Hierarchy
        PATH_HIERARCHY = {
            ENABLED = true,
            
            -- Major Thoroughfares (Tier 1: Region to Region)
            MAJOR_PATHS = {
                WIDTH = 3,
                MAINTENANCE_LEVEL = 0.9, -- How well-maintained (0-1)
                BIOME_OVERRIDE_CHANCE = 0.8, -- Chance to override terrain
                ABANDONMENT_CHANCE = 0.05 -- Very low abandonment rate
            },
            
            -- Local Connectors (Tier 2: Landmarks to Thoroughfares)
            LOCAL_PATHS = {
                WIDTH = 1,
                MAINTENANCE_LEVEL = 0.6,
                BIOME_OVERRIDE_CHANCE = 0.4,
                ABANDONMENT_CHANCE = 0.15,
                BRANCH_DISTANCE = 25 -- Max distance to connect to major path
            },
            
            -- Abandoned Sections (Tier 3: Broken/Overgrown)
            ABANDONED_PATHS = {
                GLOBAL_ABANDONMENT_RATE = 0.2, -- Percentage of paths to abandon
                BIOME_ABANDONMENT_MODIFIERS = {
                    [1] = 0.5, -- Plains - less abandonment
                    [2] = 2.0, -- Jungle - high abandonment (overgrowth)
                    [3] = 1.5, -- Mountains - moderate (rockslides)
                    [4] = 0.8, -- Desert - low (preservation)
                    [5] = 1.8, -- Tundra - high (harsh conditions)
                    [6] = 0.0  -- Impassable - N/A
                },
                OVERGROWTH_BIOMES = {2, 5}, -- Biomes that overgrow paths
                BROKEN_BIOMES = {3} -- Biomes where paths are broken/blocked
            }
        },
        
        -- Legacy settings (kept for compatibility)
        BASE_CORRIDOR_WIDTH = 1, -- Base width for most path segments
        NODE_IMPORTANCE_WIDTHS = { -- Width based on node type
            start = 2,           -- Player starting area - wider
            region_center = 2,   -- Region centers - wider
            landmark = 1,        -- Landmarks - normal
            strategic = 1        -- Strategic nodes - normal
        },
        TERRAIN_WIDTH_MODIFIERS = { -- Width adjustments based on terrain
            [1] = 1.0, -- Plains - normal width
            [2] = 0.7, -- Jungle - narrower (harder to clear)
            [3] = 0.5, -- Mountains - much narrower (difficult terrain)
            [4] = 1.2, -- Desert - slightly wider (easy to traverse)
            [5] = 0.6, -- Tundra - narrower (harsh conditions)
            [6] = 0.0  -- Impassable - should be avoided anyway
        },
        JUNCTION_EXPANSION_RADIUS = 3, -- Extra width around major junctions
        
        -- Path Appearance
        PATH_BIOME_ID = 7, -- MST_PATH - distinct biome for paths
        VALLEY_SEEKING_STRENGTH = 2.0, -- How much paths prefer lower elevations
        NOISE_SCALE_ELEVATION = 0.03 -- Scale for elevation noise generation
    },

    -- Landmark specific configurations
    LANDMARK_CONFIG = {
        HIDDEN_CACHE_REWARD = { -- Define what a Hidden Cache gives
            relic_fragments = { time = 1, space = 1 } -- Example: 1 time fragment, 1 space fragment
            -- We could add other reward types here later, e.g., items, stamina boosts
        }
    },

    MAP_ICONS = {
        ANCIENT_OBELISK = "O",
        HIDDEN_SPRING = "H",
        ANCIENT_LEVER = "L",
        SEER_TOTEM = "S",
        HIDDEN_CACHE = "$"
    },

    LANDMARK_SPRITE_SHEET_PATH = "src/textures/landmarks.png",
    LANDMARK_SPRITE_SHEET_WIDTH = 1536,
    LANDMARK_SPRITE_SHEET_HEIGHT = 1024,

    LANDMARK_SPRITES = {
        -- Default sprite if a specific one isn't found
        DEFAULT = { x = 0, y = 0, width = 32, height = 32 }, -- Placeholder, consider a small generic sprite if available on sheet
        
        ["Ancient Ruins"]     = { x = 90,   y = 83,   width = 328, height = 328 },
        ["Mystic Shrine"]     = { x = 547,  y = 83,   width = 328, height = 328 },
        ["Ancient Obelisk"]   = { x = 1003, y = 61,   width = 328, height = 328 },
        ["Crystal Formation"] = { x = 90,   y = 531,  width = 328, height = 328 },
        ["Abandoned Camp"]    = { x = 547,  y = 569,  width = 328, height = 328 },
        ["Seer's Totem"]      = { x = 1003, y = 531,  width = 328, height = 328 },

        -- Existing landmarks that might still use primitive rendering or need new quad definitions
        -- For now, these are commented out to avoid conflicts with the new sprite sheet approach.
        -- If these landmarks are also on the sprite sheet, their definitions should be added above.
        -- If they are to remain primitive, the rendering logic in renderer.lua will need to handle both types.
        -- ["Strange Monolith"] = { ... },
        -- ["Hidden Spring"] = { ... },
        -- ["Ancient Lever"] = { ... },
        -- ["Hidden Cache"] = { ... },
        -- ["Contract_Scroll"] = { ... },
    }
}

return GameConfig
