-- src/core/data_validation.lua
-- Data structure validation for Shattered Expanse
-- Ensures data integrity and provides clear error messages for AI debugging

local GameConfig = require("src.config.game_config")

local DataValidation = {}

-- Validate Player data structure
-- @param player: Player data structure to validate
-- @return boolean: true if valid
-- @return string|nil: error message if invalid
function DataValidation.validatePlayer(player)
    if type(player) ~= "table" then
        return false, "Player must be a table"
    end
    
    if type(player.x) ~= "number" or player.x < 1 then
        return false, "Player.x must be a positive number"
    end
    
    if type(player.y) ~= "number" or player.y < 1 then
        return false, "Player.y must be a positive number"
    end
    
    if type(player.stamina) ~= "number" then
        return false, "Player.stamina must be a number"
    end
    
    if player.inventory and type(player.inventory) ~= "table" then
        return false, "Player.inventory must be a table if present"
    end
    
    if player.abilities and type(player.abilities) ~= "table" then
        return false, "Player.abilities must be a table if present"
    end
    
    return true, nil
end

-- Validate World data structure
-- @param world: World data structure to validate
-- @return boolean: true if valid
-- @return string|nil: error message if invalid
function DataValidation.validateWorld(world)
    if type(world) ~= "table" then
        return false, "World must be a table"
    end
    
    if type(world.width) ~= "number" or world.width <= 0 then
        return false, "World.width must be a positive number"
    end
    
    if type(world.height) ~= "number" or world.height <= 0 then
        return false, "World.height must be a positive number"
    end
    
    if type(world.tiles) ~= "table" then
        return false, "World.tiles must be a table"
    end
    
    -- Validate tiles array structure (sample validation to avoid performance issues)
    if #world.tiles ~= world.width then
        return false, "World.tiles array length must match world.width"
    end
    
    -- Sample a few tiles for structure validation
    for i = 1, math.min(3, world.width) do
        if type(world.tiles[i]) ~= "table" then
            return false, "World.tiles[" .. i .. "] must be a table"
        end
        if #world.tiles[i] ~= world.height then
            return false, "World.tiles[" .. i .. "] length must match world.height"
        end
        
        -- Validate a sample tile
        local valid, error = DataValidation.validateTile(world.tiles[i][1])
        if not valid then
            return false, "Invalid tile at [" .. i .. "][1]: " .. error
        end
    end
    
    return true, nil
end

-- Validate Tile data structure
-- @param tile: Tile data structure to validate
-- @return boolean: true if valid
-- @return string|nil: error message if invalid
function DataValidation.validateTile(tile)
    if type(tile) ~= "table" then
        return false, "Tile must be a table"
    end
    
    if type(tile.biome) ~= "table" then
        return false, "Tile.biome must be a table"
    end
    
    if type(tile.biome.id) ~= "number" then
        return false, "Tile.biome.id must be a number"
    end
    
    if type(tile.biome.name) ~= "string" then
        return false, "Tile.biome.name must be a string"
    end
    
    if type(tile.biome.color) ~= "table" or #tile.biome.color ~= 3 then
        return false, "Tile.biome.color must be a table with 3 elements"
    end
    
    if type(tile.explored) ~= "boolean" then
        return false, "Tile.explored must be a boolean"
    end
    
    -- Validate landmark if present
    if tile.landmark then
        local valid, error = DataValidation.validateLandmark(tile.landmark)
        if not valid then
            return false, "Invalid landmark: " .. error
        end
    end
    
    return true, nil
end

-- Validate Landmark data structure
-- @param landmark: Landmark data structure to validate
-- @return boolean: true if valid
-- @return string|nil: error message if invalid
function DataValidation.validateLandmark(landmark)
    if type(landmark) ~= "table" then
        return false, "Landmark must be a table"
    end
    
    if type(landmark.type) ~= "string" then
        return false, "Landmark.type must be a string"
    end
    
    if type(landmark.discovered) ~= "boolean" then
        return false, "Landmark.discovered must be a boolean"
    end
    
    if type(landmark.visited) ~= "boolean" then
        return false, "Landmark.visited must be a boolean"
    end
    
    -- Optional fields validation
    if landmark.activated and type(landmark.activated) ~= "boolean" then
        return false, "Landmark.activated must be a boolean if present"
    end
    
    if landmark.looted and type(landmark.looted) ~= "boolean" then
        return false, "Landmark.looted must be a boolean if present"
    end
    
    if landmark.reveals_landmark_at then
        if type(landmark.reveals_landmark_at) ~= "table" then
            return false, "Landmark.reveals_landmark_at must be a table if present"
        end
        if type(landmark.reveals_landmark_at.x) ~= "number" or type(landmark.reveals_landmark_at.y) ~= "number" then
            return false, "Landmark.reveals_landmark_at must have numeric x and y coordinates"
        end
    end
    
    return true, nil
end

-- Validate GameState data structure
-- @param gameState: GameState data structure to validate
-- @return boolean: true if valid
-- @return string|nil: error message if invalid
function DataValidation.validateGameState(gameState)
    if type(gameState) ~= "table" then
        return false, "GameState must be a table"
    end
    
    -- Validate player
    if gameState.player then
        local valid, error = DataValidation.validatePlayer(gameState.player)
        if not valid then
            return false, "Invalid player: " .. error
        end
    end
    
    -- Validate world
    if gameState.world then
        local valid, error = DataValidation.validateWorld(gameState.world)
        if not valid then
            return false, "Invalid world: " .. error
        end
    end
    
    -- Validate contracts
    if gameState.contracts then
        if type(gameState.contracts) ~= "table" then
            return false, "GameState.contracts must be a table"
        end
        if gameState.contracts.active and type(gameState.contracts.active) ~= "table" then
            return false, "GameState.contracts.active must be a table"
        end
        if gameState.contracts.completed and type(gameState.contracts.completed) ~= "number" then
            return false, "GameState.contracts.completed must be a number"
        end
    end
    
    -- Validate meta progression
    if gameState.meta then
        local valid, error = DataValidation.validateMetaProgression(gameState.meta)
        if not valid then
            return false, "Invalid meta progression: " .. error
        end
    end
    
    return true, nil
end

-- Validate MetaProgression data structure
-- @param meta: MetaProgression data structure to validate
-- @return boolean: true if valid
-- @return string|nil: error message if invalid
function DataValidation.validateMetaProgression(meta)
    if type(meta) ~= "table" then
        return false, "Meta progression must be a table"
    end
    
    if meta.banked_resources and type(meta.banked_resources) ~= "table" then
        return false, "Meta.banked_resources must be a table if present"
    end
    
    if meta.unlocked_abilities and type(meta.unlocked_abilities) ~= "table" then
        return false, "Meta.unlocked_abilities must be a table if present"
    end
    
    if meta.discovered_landmarks and type(meta.discovered_landmarks) ~= "table" then
        return false, "Meta.discovered_landmarks must be a table if present"
    end
    
    if meta.relics then
        if type(meta.relics) ~= "table" then
            return false, "Meta.relics must be a table if present"
        end
        -- Validate each relic
        for i, relic in ipairs(meta.relics) do
            if type(relic) ~= "table" then
                return false, "Meta.relics[" .. i .. "] must be a table"
            end
            if type(relic.name) ~= "string" then
                return false, "Meta.relics[" .. i .. "].name must be a string"
            end
            if type(relic.reconstructed) ~= "boolean" then
                return false, "Meta.relics[" .. i .. "].reconstructed must be a boolean"
            end
            if relic.fragments and type(relic.fragments) ~= "table" then
                return false, "Meta.relics[" .. i .. "].fragments must be a table if present"
            end
        end
    end
    
    return true, nil
end

-- Validate coordinates are within world bounds
-- @param world: World data structure
-- @param x: X coordinate
-- @param y: Y coordinate
-- @return boolean: true if coordinates are valid
-- @return string|nil: error message if invalid
function DataValidation.validateCoordinates(world, x, y)
    if type(x) ~= "number" or type(y) ~= "number" then
        return false, "Coordinates must be numbers"
    end
    
    if x < 1 or x > world.width then
        return false, "X coordinate " .. x .. " is out of bounds (1-" .. world.width .. ")"
    end
    
    if y < 1 or y > world.height then
        return false, "Y coordinate " .. y .. " is out of bounds (1-" .. world.height .. ")"
    end
    
    return true, nil
end

-- Perform comprehensive validation of game state
-- @param gameState: Complete game state to validate
-- @return boolean: true if all validations pass
-- @return table: List of validation errors (empty if valid)
function DataValidation.performFullValidation(gameState)
    local errors = {}
    
    -- Validate overall structure
    local valid, error = DataValidation.validateGameState(gameState)
    if not valid then
        table.insert(errors, "GameState validation failed: " .. error)
    end
    
    -- Cross-reference validation
    if gameState.player and gameState.world then
        local coordValid, coordError = DataValidation.validateCoordinates(gameState.world, gameState.player.x, gameState.player.y)
        if not coordValid then
            table.insert(errors, "Player coordinates invalid: " .. coordError)
        end
    end
    
    return #errors == 0, errors
end

-- Log validation errors in a structured format
-- @param errors: Array of error messages
-- @param context: Context string for the validation
function DataValidation.logValidationErrors(errors, context)
    if #errors > 0 then
        print("=== VALIDATION ERRORS in " .. (context or "unknown context") .. " ===")
        for i, error in ipairs(errors) do
            print(i .. ". " .. error)
        end
        print("=== END VALIDATION ERRORS ===")
    end
end

return DataValidation
