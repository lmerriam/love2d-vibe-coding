-- src/config/game_config.lua
-- Central configuration for Shattered Expanse

local GameConfig = {
    -- World generation settings
    WORLD = {
        WIDTH = 100,
        HEIGHT = 100,
        TILE_SIZE = 32,
        MINI_TILE_SIZE = 6,
        VIEW_RADIUS = 10,
        EXPLORE_RADIUS = 3,
        LANDMARK_COUNT = 20,
        OBELISK_PAIRS_COUNT = 2, -- Number of Ancient Obelisk / Hidden Spring pairs
        SEER_CACHE_PAIRS_COUNT = 2, -- Number of Seer's Totem / Hidden Cache pairs
        LANDMARK_SCROLL_CHANCE = 0.25
    },

    BIOME_IDS = {
        RUSTED_OASIS = 1, -- Plains
        VEILED_JUNGLE = 2,
        STORMSPIRE_PEAKS = 3, -- Mountains
        DESERT = 4,
        TUNDRA = 5,
        IMPASSABLE_MOUNTAIN_FACE = 6
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
        STARTING_X = 1,
        STARTING_Y = 1,
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

    LANDMARK_SPRITES = {
        -- Default sprite if a specific one isn't found
        DEFAULT = {
            { shape = "rectangle", mode = "fill", color = {128, 128, 128}, params = { 0.25, 0.25, 0.5, 0.5 } } -- Grey square
        },
        ["Ancient Ruins"] = {
            { shape = "rectangle", mode = "line", color = {100, 100, 100}, params = { 0.1, 0.5, 0.3, 0.4 } }, -- Broken wall 1
            { shape = "rectangle", mode = "line", color = {100, 100, 100}, params = { 0.6, 0.2, 0.3, 0.4 } }, -- Broken wall 2
            { shape = "polygon", mode = "fill", color = {150,150,150}, params = {0.4,0.4, 0.6,0.4, 0.5,0.2} } -- Roof piece
        },
        ["Mystic Shrine"] = {
            { shape = "circle", mode = "fill", color = {0, 150, 200}, params = { 0.5, 0.5, 0.3 } }, -- Blue orb
            { shape = "rectangle", mode = "fill", color = {200, 200, 100}, params = { 0.4, 0.7, 0.2, 0.2 } } -- Pedestal
        },
        ["Crystal Formation"] = {
            { shape = "polygon", mode = "fill", color = {180, 100, 255}, params = {0.5,0.1, 0.3,0.8, 0.4,0.8} }, -- Crystal shard 1
            { shape = "polygon", mode = "fill", color = {200, 120, 255}, params = {0.5,0.1, 0.7,0.8, 0.6,0.8} }, -- Crystal shard 2
        },
        ["Abandoned Camp"] = {
            { shape = "polygon", mode = "fill", color = {139,69,19}, params = {0.2,0.8, 0.8,0.8, 0.5,0.3} }, -- Brown tent shape
            { shape = "rectangle", mode = "fill", color = {255,0,0}, params = {0.45,0.65, 0.1,0.1} } -- Small red for "fire"
        },
        ["Strange Monolith"] = {
            { shape = "rectangle", mode = "fill", color = {50, 50, 60}, params = { 0.4, 0.1, 0.2, 0.8 } } -- Tall dark rectangle
        },
        ["Ancient Obelisk"] = {
            { shape = "polygon", mode = "fill", color = {180, 180, 180}, params = {0.5,0.1, 0.3,0.9, 0.7,0.9} } -- Tall grey obelisk shape
        },
        ["Hidden Spring"] = {
            { shape = "circle", mode = "fill", color = {100, 150, 255}, params = { 0.5, 0.5, 0.35 } }, -- Blue water
            { shape = "circle", mode = "line", color = {80, 120, 200}, params = { 0.5, 0.5, 0.4 } } -- Darker outline
        },
        ["Ancient Lever"] = {
            { shape = "rectangle", mode = "fill", color = {150,150,150}, params = {0.4, 0.2, 0.2, 0.6} }, -- Lever base
            { shape = "circle", mode = "fill", color = {200,50,50}, params = {0.5, 0.25, 0.1} } -- Red handle
        },
        ["Seer's Totem"] = {
            { shape = "rectangle", mode = "fill", color = {100, 80, 60}, params = {0.45, 0.2, 0.1, 0.6} }, -- Wooden pole
            { shape = "circle", mode = "fill", color = {80, 40, 220}, params = {0.5, 0.3, 0.15} } -- Purple "eye"
        },
        ["Hidden Cache"] = {
            { shape = "rectangle", mode = "fill", color = {139,69,19}, params = {0.2, 0.4, 0.6, 0.4} }, -- Brown chest body
            { shape = "rectangle", mode = "fill", color = {210,180,140}, params = {0.25, 0.35, 0.5, 0.1} } -- Lighter lid part
        },
        ["Contract_Scroll"] = {
            { shape = "rectangle", mode = "fill", color = {240, 230, 200}, params = {0.2, 0.2, 0.6, 0.6} }, -- Parchment
            { shape = "line", color = {100,100,100}, params = {0.3,0.3, 0.7,0.3} }, -- Line 1
            { shape = "line", color = {100,100,100}, params = {0.3,0.5, 0.7,0.5} }, -- Line 2
            { shape = "line", color = {100,100,100}, params = {0.3,0.7, 0.7,0.7} }  -- Line 3
        }
        -- Note: params for rectangle are {rel_x, rel_y, rel_width, rel_height}
        -- params for circle are {rel_cx, rel_cy, rel_radius}
        -- params for polygon are {x1,y1, x2,y2, ...} (relative coordinates)
        -- params for line are {x1,y1, x2,y2, ...} (can be multiple segments)
        -- All coordinates and dimensions are relative to the tile size (0.0 to 1.0)
    }
}

return GameConfig
