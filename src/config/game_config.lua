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
        LANDMARK_SCROLL_CHANCE = 0.25
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
        RECONSTRUCT_RELIC_KEY = "f2" -- Key to mark the next available relic as reconstructed
    },

    -- Gameplay actions
    ACTIONS = {
        RECONSTRUCT_ATTEMPT_KEY = "r" -- Key to attempt relic reconstruction
    }
}

return GameConfig
