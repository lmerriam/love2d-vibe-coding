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
            -- Greek-style columns (3 vertical rectangles)
            { shape = "rectangle", mode = "fill", color = {120, 120, 110}, params = { 0.15, 0.3, 0.1, 0.6 } }, -- Left column
            { shape = "rectangle", mode = "fill", color = {120, 120, 110}, params = { 0.45, 0.35, 0.1, 0.55 } }, -- Center column
            { shape = "rectangle", mode = "fill", color = {120, 120, 110}, params = { 0.75, 0.4, 0.1, 0.5 } }, -- Right column
            -- Broken pediment top (triangular shape with missing section)
            { shape = "polygon", mode = "fill", color = {140, 140, 130}, params = {0.1,0.3, 0.4,0.3, 0.25,0.15} }, -- Left triangle
            { shape = "polygon", mode = "fill", color = {140, 140, 130}, params = {0.6,0.35, 0.9,0.35, 0.75,0.2} }, -- Right triangle
            -- Fallen pillar piece (diagonal rectangle)
            { shape = "polygon", mode = "fill", color = {100, 100, 90}, params = {0.3,0.8, 0.6,0.75, 0.65,0.85, 0.35,0.9} }, -- Fallen stone
            -- Moss accents
            { shape = "rectangle", mode = "fill", color = {60, 100, 60}, params = { 0.13, 0.7, 0.04, 0.2 } }, -- Moss on left column
            { shape = "circle", mode = "fill", color = {60, 100, 60}, params = { 0.35, 0.85, 0.03 } } -- Moss on fallen stone
        },
        ["Mystic Shrine"] = {
            -- Stone base with step-like structure
            { shape = "rectangle", mode = "fill", color = {140, 140, 120}, params = { 0.2, 0.7, 0.6, 0.2 } }, -- Base platform
            { shape = "rectangle", mode = "fill", color = {160, 160, 140}, params = { 0.3, 0.6, 0.4, 0.15 } }, -- Middle step
            { shape = "rectangle", mode = "fill", color = {180, 180, 160}, params = { 0.4, 0.5, 0.2, 0.15 } }, -- Top pedestal
            -- Glowing central gem
            { shape = "circle", mode = "fill", color = {100, 200, 255}, params = { 0.5, 0.45, 0.08 } }, -- Inner glow
            { shape = "circle", mode = "fill", color = {50, 150, 255}, params = { 0.5, 0.45, 0.06 } }, -- Gem core
            -- Flame elements on either side
            { shape = "polygon", mode = "fill", color = {255, 150, 0}, params = {0.25,0.55, 0.2,0.65, 0.3,0.65, 0.28,0.5} }, -- Left flame
            { shape = "polygon", mode = "fill", color = {255, 150, 0}, params = {0.75,0.55, 0.7,0.65, 0.8,0.65, 0.72,0.5} }, -- Right flame
            { shape = "polygon", mode = "fill", color = {255, 200, 100}, params = {0.25,0.58, 0.22,0.63, 0.28,0.63, 0.26,0.53} }, -- Left flame highlight
            { shape = "polygon", mode = "fill", color = {255, 200, 100}, params = {0.75,0.58, 0.72,0.63, 0.78,0.63, 0.74,0.53} }, -- Right flame highlight
            -- Subtle rune markings
            { shape = "line", color = {100,100,80}, params = {0.35,0.75, 0.4,0.75, 0.4,0.8, 0.35,0.8} }, -- Left rune
            { shape = "line", color = {100,100,80}, params = {0.6,0.75, 0.65,0.75, 0.65,0.8, 0.6,0.8} } -- Right rune
        },
        ["Crystal Formation"] = {
            -- Multiple crystal shards of different heights with gradient colors
            { shape = "polygon", mode = "fill", color = {120, 60, 200}, params = {0.5,0.1, 0.35,0.7, 0.4,0.8, 0.45,0.75} }, -- Main central crystal (dark purple base)
            { shape = "polygon", mode = "fill", color = {160, 100, 240}, params = {0.5,0.1, 0.25,0.85, 0.35,0.85, 0.4,0.8} }, -- Left crystal (medium purple)
            { shape = "polygon", mode = "fill", color = {180, 120, 255}, params = {0.5,0.1, 0.65,0.8, 0.75,0.85, 0.6,0.85} }, -- Right crystal (lighter purple)
            { shape = "polygon", mode = "fill", color = {140, 80, 220}, params = {0.4,0.75, 0.15,0.9, 0.25,0.9, 0.35,0.85} }, -- Far left small crystal
            { shape = "polygon", mode = "fill", color = {200, 140, 255}, params = {0.6,0.85, 0.75,0.9, 0.85,0.9, 0.75,0.85} }, -- Far right small crystal
            -- Crystal tips (lighter colors)
            { shape = "polygon", mode = "fill", color = {220, 180, 255}, params = {0.5,0.1, 0.45,0.2, 0.55,0.2} }, -- Main tip
            { shape = "polygon", mode = "fill", color = {210, 170, 255}, params = {0.5,0.1, 0.35,0.25, 0.4,0.3} }, -- Left tip
            { shape = "polygon", mode = "fill", color = {230, 190, 255}, params = {0.5,0.1, 0.6,0.25, 0.65,0.3} }, -- Right tip
            -- Small sparkle effects (tiny white dots)
            { shape = "circle", mode = "fill", color = {255, 255, 255}, params = { 0.3, 0.4, 0.015 } }, -- Sparkle 1
            { shape = "circle", mode = "fill", color = {255, 255, 255}, params = { 0.7, 0.5, 0.015 } }, -- Sparkle 2
            { shape = "circle", mode = "fill", color = {255, 255, 255}, params = { 0.5, 0.3, 0.01 } } -- Sparkle 3
        },
        ["Abandoned Camp"] = {
            -- Tent with fabric texture
            { shape = "polygon", mode = "fill", color = {120, 80, 40}, params = {0.2,0.8, 0.8,0.8, 0.5,0.3} }, -- Main tent shape
            { shape = "polygon", mode = "fill", color = {100, 60, 20}, params = {0.5,0.3, 0.8,0.8, 0.75,0.75, 0.5,0.35} }, -- Tent shading
            -- Tent fabric lines
            { shape = "line", color = {80,50,10}, params = {0.3,0.75, 0.7,0.75} }, -- Horizontal line 1
            { shape = "line", color = {80,50,10}, params = {0.35,0.65, 0.65,0.65} }, -- Horizontal line 2
            { shape = "line", color = {80,50,10}, params = {0.4,0.55, 0.6,0.55} }, -- Horizontal line 3
            -- Larger campfire with flame shapes
            { shape = "circle", mode = "fill", color = {60, 40, 30}, params = { 0.15, 0.85, 0.08 } }, -- Fire pit
            { shape = "polygon", mode = "fill", color = {255, 100, 0}, params = {0.15,0.77, 0.12,0.85, 0.18,0.85, 0.17,0.75} }, -- Flame 1
            { shape = "polygon", mode = "fill", color = {255, 150, 0}, params = {0.15,0.77, 0.13,0.83, 0.17,0.83, 0.16,0.78} }, -- Flame 1 highlight
            { shape = "polygon", mode = "fill", color = {255, 80, 0}, params = {0.12,0.8, 0.1,0.85, 0.14,0.85, 0.13,0.78} }, -- Flame 2
            { shape = "polygon", mode = "fill", color = {255, 120, 0}, params = {0.18,0.79, 0.16,0.85, 0.2,0.85, 0.19,0.77} }, -- Flame 3
            -- Log seating
            { shape = "rectangle", mode = "fill", color = {100, 60, 30}, params = { 0.05, 0.75, 0.15, 0.05 } }, -- Left log
            { shape = "rectangle", mode = "fill", color = {100, 60, 30}, params = { 0.25, 0.88, 0.15, 0.05 } }, -- Bottom log
            -- Abandoned backpack
            { shape = "rectangle", mode = "fill", color = {80, 60, 40}, params = { 0.85, 0.75, 0.1, 0.15 } }, -- Backpack body
            { shape = "rectangle", mode = "fill", color = {60, 40, 20}, params = { 0.87, 0.77, 0.06, 0.08 } } -- Backpack flap
        },
        ["Strange Monolith"] = {
            -- Slightly irregular monolith shape
            { shape = "polygon", mode = "fill", color = {40, 40, 50}, params = {0.42,0.1, 0.58,0.12, 0.6,0.88, 0.4,0.9} }, -- Main irregular shape
            -- Ancient carvings/symbols along the sides
            { shape = "line", color = {80,80,90}, params = {0.44,0.25, 0.56,0.25} }, -- Top symbol line 1
            { shape = "line", color = {80,80,90}, params = {0.46,0.3, 0.54,0.3} }, -- Top symbol line 2
            { shape = "circle", mode = "line", color = {80,80,90}, params = { 0.5, 0.4, 0.04 } }, -- Circle symbol
            { shape = "line", color = {80,80,90}, params = {0.44,0.5, 0.48,0.55, 0.52,0.55, 0.56,0.5} }, -- Zigzag symbol
            { shape = "line", color = {80,80,90}, params = {0.45,0.65, 0.55,0.65} }, -- Bottom symbol line 1
            { shape = "line", color = {80,80,90}, params = {0.47,0.7, 0.53,0.7} }, -- Bottom symbol line 2
            -- Subtle energy glow at the top
            { shape = "circle", mode = "fill", color = {100, 120, 200}, params = { 0.5, 0.11, 0.06 } }, -- Blue glow
            { shape = "circle", mode = "fill", color = {150, 170, 255}, params = { 0.5, 0.11, 0.03 } }, -- Bright center
            -- Small offering stones at base
            { shape = "circle", mode = "fill", color = {70, 70, 60}, params = { 0.35, 0.88, 0.03 } }, -- Left stone
            { shape = "circle", mode = "fill", color = {70, 70, 60}, params = { 0.65, 0.9, 0.025 } }, -- Right stone
            { shape = "circle", mode = "fill", color = {70, 70, 60}, params = { 0.45, 0.92, 0.02 } } -- Center small stone
        },
        ["Ancient Obelisk"] = {
            -- Egyptian-inspired obelisk with pyramid top
            { shape = "rectangle", mode = "fill", color = {160, 150, 120}, params = { 0.45, 0.15, 0.1, 0.7 } }, -- Main shaft
            { shape = "polygon", mode = "fill", color = {180, 170, 140}, params = {0.5,0.1, 0.42,0.18, 0.58,0.18} }, -- Pyramid top
            { shape = "polygon", mode = "fill", color = {200, 190, 160}, params = {0.5,0.1, 0.46,0.15, 0.54,0.15} }, -- Pyramid tip highlight
            -- Golden tip
            { shape = "polygon", mode = "fill", color = {255, 215, 0}, params = {0.5,0.1, 0.48,0.13, 0.52,0.13} }, -- Gold tip
            -- Hieroglyphic-like markings (horizontal lines at different levels)
            { shape = "line", color = {120,110,80}, params = {0.47,0.25, 0.53,0.25} }, -- Top marking
            { shape = "line", color = {120,110,80}, params = {0.47,0.3, 0.53,0.3} }, -- Second marking
            { shape = "rectangle", mode = "fill", color = {120,110,80}, params = { 0.485, 0.35, 0.03, 0.02 } }, -- Small rect symbol
            { shape = "line", color = {120,110,80}, params = {0.47,0.45, 0.53,0.45} }, -- Middle marking
            { shape = "circle", mode = "fill", color = {120,110,80}, params = { 0.5, 0.55, 0.015 } }, -- Circle symbol
            { shape = "line", color = {120,110,80}, params = {0.47,0.65, 0.53,0.65} }, -- Lower marking
            { shape = "line", color = {120,110,80}, params = {0.47,0.75, 0.53,0.75} }, -- Bottom marking
            -- Wider foundation base
            { shape = "rectangle", mode = "fill", color = {140, 130, 100}, params = { 0.4, 0.85, 0.2, 0.05 } }, -- Base foundation
            { shape = "rectangle", mode = "fill", color = {120, 110, 80}, params = { 0.38, 0.88, 0.24, 0.03 } } -- Foundation shadow
        },
        ["Hidden Spring"] = {
            -- Irregular pool shape (not perfect circle)
            { shape = "polygon", mode = "fill", color = {80, 150, 255}, params = {0.2,0.4, 0.3,0.25, 0.7,0.3, 0.8,0.6, 0.65,0.8, 0.35,0.75} }, -- Irregular water pool
            -- Ripple effects (concentric irregular shapes)
            { shape = "polygon", mode = "line", color = {100, 170, 255}, params = {0.3,0.45, 0.35,0.35, 0.65,0.4, 0.7,0.65, 0.6,0.7, 0.4,0.65} }, -- Outer ripple
            { shape = "polygon", mode = "line", color = {120, 190, 255}, params = {0.35,0.5, 0.4,0.4, 0.6,0.45, 0.65,0.6, 0.55,0.65, 0.45,0.6} }, -- Inner ripple
            -- Small rock formations around edges
            { shape = "circle", mode = "fill", color = {100, 90, 80}, params = { 0.15, 0.35, 0.04 } }, -- Rock 1
            { shape = "circle", mode = "fill", color = {110, 100, 90}, params = { 0.75, 0.25, 0.035 } }, -- Rock 2
            { shape = "circle", mode = "fill", color = {90, 80, 70}, params = { 0.8, 0.7, 0.03 } }, -- Rock 3
            { shape = "circle", mode = "fill", color = {105, 95, 85}, params = { 0.25, 0.8, 0.025 } }, -- Rock 4
            -- Blue-white highlights for movement
            { shape = "circle", mode = "fill", color = {200, 230, 255}, params = { 0.45, 0.45, 0.02 } }, -- Highlight 1
            { shape = "circle", mode = "fill", color = {220, 240, 255}, params = { 0.55, 0.55, 0.015 } }, -- Highlight 2
            { shape = "circle", mode = "fill", color = {180, 210, 255}, params = { 0.4, 0.6, 0.01 } } -- Highlight 3
        },
        ["Ancient Lever"] = {
            -- Stone base with weathered texture
            { shape = "rectangle", mode = "fill", color = {120, 110, 100}, params = { 0.35, 0.6, 0.3, 0.3 } }, -- Main base
            { shape = "rectangle", mode = "fill", color = {100, 90, 80}, params = { 0.37, 0.62, 0.26, 0.08 } }, -- Base weathering line 1
            { shape = "rectangle", mode = "fill", color = {140, 130, 120}, params = { 0.37, 0.75, 0.26, 0.05 } }, -- Base highlight
            -- Metal lever arm (longer, angled)
            { shape = "line", color = {160,160,140}, params = {0.5,0.6, 0.65,0.25} }, -- Main lever arm
            { shape = "line", color = {180,180,160}, params = {0.51,0.59, 0.66,0.24} }, -- Lever highlight
            -- Lever handle/grip
            { shape = "circle", mode = "fill", color = {140, 120, 100}, params = { 0.66, 0.24, 0.04 } }, -- Handle base
            { shape = "circle", mode = "fill", color = {160, 140, 120}, params = { 0.66, 0.24, 0.03 } }, -- Handle highlight
            -- Gear/mechanism details
            { shape = "circle", mode = "line", color = {100,100,80}, params = { 0.5, 0.6, 0.06 } }, -- Gear outline
            { shape = "line", color = {100,100,80}, params = {0.44,0.6, 0.56,0.6} }, -- Gear line 1
            { shape = "line", color = {100,100,80}, params = {0.5,0.54, 0.5,0.66} }, -- Gear line 2
            -- Position indicator markings
            { shape = "line", color = {80,70,60}, params = {0.25,0.45, 0.3,0.5} }, -- Position mark 1
            { shape = "line", color = {80,70,60}, params = {0.7,0.45, 0.75,0.5} }, -- Position mark 2
            { shape = "circle", mode = "fill", color = {200,50,50}, params = { 0.72, 0.47, 0.015 } } -- Active indicator
        },
        ["Seer's Totem"] = {
            -- Carved wooden pole with face/mask
            { shape = "rectangle", mode = "fill", color = {100, 70, 40}, params = { 0.45, 0.2, 0.1, 0.7 } }, -- Main wooden pole
            { shape = "rectangle", mode = "fill", color = {80, 50, 20}, params = { 0.46, 0.22, 0.08, 0.66 } }, -- Wood shading
            -- Carved face/mask in the wood
            { shape = "polygon", mode = "fill", color = {120, 90, 60}, params = {0.5,0.3, 0.4,0.45, 0.6,0.45, 0.55,0.55, 0.45,0.55} }, -- Face outline
            -- Multiple "eyes" or seeing elements
            { shape = "circle", mode = "fill", color = {80, 40, 220}, params = { 0.46, 0.38, 0.02 } }, -- Left eye
            { shape = "circle", mode = "fill", color = {80, 40, 220}, params = { 0.54, 0.38, 0.02 } }, -- Right eye
            { shape = "circle", mode = "fill", color = {120, 80, 255}, params = { 0.5, 0.32, 0.015 } }, -- Third eye (center top)
            { shape = "circle", mode = "fill", color = {100, 60, 240}, params = { 0.5, 0.5, 0.025 } }, -- Central mystical eye
            -- Feather decorations (small lines extending outward)
            { shape = "line", color = {60,40,20}, params = {0.35,0.35, 0.25,0.25} }, -- Left feather 1
            { shape = "line", color = {60,40,20}, params = {0.38,0.4, 0.28,0.35} }, -- Left feather 2
            { shape = "line", color = {60,40,20}, params = {0.65,0.35, 0.75,0.25} }, -- Right feather 1
            { shape = "line", color = {60,40,20}, params = {0.62,0.4, 0.72,0.35} }, -- Right feather 2
            -- Ritual markings/paint (colored accents)
            { shape = "line", color = {200,100,100}, params = {0.47,0.6, 0.53,0.6} }, -- Red paint line 1
            { shape = "line", color = {200,100,100}, params = {0.47,0.65, 0.53,0.65} }, -- Red paint line 2
            { shape = "circle", mode = "fill", color = {100,200,100}, params = { 0.5, 0.75, 0.01 } }, -- Green dot
            { shape = "line", color = {100,100,200}, params = {0.47,0.8, 0.53,0.8} } -- Blue paint line
        },
        ["Hidden Cache"] = {
            -- Ornate chest with decorative edges
            { shape = "rectangle", mode = "fill", color = {120, 70, 30}, params = { 0.2, 0.5, 0.6, 0.35 } }, -- Main chest body
            { shape = "rectangle", mode = "fill", color = {100, 50, 10}, params = { 0.22, 0.52, 0.56, 0.31 } }, -- Chest shading
            -- Ornate decorative edges
            { shape = "line", color = {180,140,80}, params = {0.2,0.5, 0.8,0.5} }, -- Top decorative line
            { shape = "line", color = {180,140,80}, params = {0.2,0.85, 0.8,0.85} }, -- Bottom decorative line
            { shape = "line", color = {180,140,80}, params = {0.2,0.5, 0.2,0.85} }, -- Left decorative line
            { shape = "line", color = {180,140,80}, params = {0.8,0.5, 0.8,0.85} }, -- Right decorative line
            -- Lock mechanism detail
            { shape = "rectangle", mode = "fill", color = {255, 215, 0}, params = { 0.47, 0.65, 0.06, 0.08 } }, -- Golden lock
            { shape = "circle", mode = "fill", color = {200, 170, 0}, params = { 0.5, 0.69, 0.015 } }, -- Lock keyhole
            -- Slightly open lid with glow effect from inside
            { shape = "rectangle", mode = "fill", color = {140, 90, 50}, params = { 0.22, 0.47, 0.56, 0.06 } }, -- Lid (slightly raised)
            { shape = "rectangle", mode = "fill", color = {255, 255, 150}, params = { 0.25, 0.52, 0.5, 0.02 } }, -- Glow from inside
            -- Small coins or gems visible
            { shape = "circle", mode = "fill", color = {255, 215, 0}, params = { 0.35, 0.75, 0.015 } }, -- Gold coin 1
            { shape = "circle", mode = "fill", color = {255, 215, 0}, params = { 0.45, 0.78, 0.012 } }, -- Gold coin 2
            { shape = "circle", mode = "fill", color = {100, 255, 100}, params = { 0.6, 0.73, 0.01 } }, -- Green gem
            { shape = "circle", mode = "fill", color = {100, 100, 255}, params = { 0.55, 0.8, 0.008 } } -- Blue gem
        },
        ["Contract_Scroll"] = {
            -- Parchment with rolled edges
            { shape = "rectangle", mode = "fill", color = {240, 230, 200}, params = { 0.2, 0.25, 0.6, 0.5 } }, -- Main parchment
            { shape = "rectangle", mode = "fill", color = {220, 210, 180}, params = { 0.22, 0.27, 0.56, 0.46 } }, -- Parchment shading
            -- Rolled edges at top and bottom
            { shape = "rectangle", mode = "fill", color = {200, 190, 160}, params = { 0.18, 0.2, 0.64, 0.08 } }, -- Top roll
            { shape = "rectangle", mode = "fill", color = {200, 190, 160}, params = { 0.18, 0.72, 0.64, 0.08 } }, -- Bottom roll
            { shape = "line", color = {160,150,120}, params = {0.18,0.24, 0.82,0.24} }, -- Top roll line
            { shape = "line", color = {160,150,120}, params = {0.18,0.76, 0.82,0.76} }, -- Bottom roll line
            -- Seal or wax stamp
            { shape = "circle", mode = "fill", color = {200, 50, 50}, params = { 0.75, 0.35, 0.04 } }, -- Red wax seal
            { shape = "circle", mode = "fill", color = {160, 30, 30}, params = { 0.75, 0.35, 0.03 } }, -- Seal inner detail
            -- More varied text representation
            { shape = "line", color = {80,80,80}, params = {0.25,0.35, 0.65,0.35} }, -- Title line (longer)
            { shape = "line", color = {100,100,100}, params = {0.25,0.45, 0.6,0.45} }, -- Line 1
            { shape = "line", color = {100,100,100}, params = {0.25,0.5, 0.55,0.5} }, -- Line 2 (shorter)
            { shape = "line", color = {100,100,100}, params = {0.25,0.55, 0.62,0.55} }, -- Line 3
            { shape = "line", color = {100,100,100}, params = {0.25,0.6, 0.5,0.6} }, -- Line 4 (shorter)
            { shape = "line", color = {100,100,100}, params = {0.25,0.65, 0.58,0.65} }, -- Line 5
            -- Ribbon or binding element
            { shape = "rectangle", mode = "fill", color = {150, 100, 200}, params = { 0.48, 0.15, 0.04, 0.7 } }, -- Purple ribbon
            { shape = "rectangle", mode = "fill", color = {120, 80, 160}, params = { 0.485, 0.17, 0.03, 0.66 } } -- Ribbon shading
        }
        -- Note: params for rectangle are {rel_x, rel_y, rel_width, rel_height}
        -- params for circle are {rel_cx, rel_cy, rel_radius}
        -- params for polygon are {x1,y1, x2,y2, ...} (relative coordinates)
        -- params for line are {x1,y1, x2,y2, ...} (can be multiple segments)
        -- All coordinates and dimensions are relative to the tile size (0.0 to 1.0)
    }
}

return GameConfig
