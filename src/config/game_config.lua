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
    }
}

return GameConfig
