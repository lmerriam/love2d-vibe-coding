### **SYSTEM PATTERNS: "SHATTERED EXPANSE"**

---

### **ARCHITECTURE OVERVIEW**
```mermaid
graph TD
    A[Love2D Engine] --> B[Game Initialization]
    B --> C[World Generation]
    B --> D[Game State Loading]
    C --> E[Game Loop]
    D --> E
    E --> F[Input Handling]
    F --> G[Player Movement]
    G --> H[Hazard System]
    H --> I[Contract System]
    I --> J[Progression System]
    J --> K[Rendering System]
    K --> E
```

---

### **KEY TECHNICAL DECISIONS**
1. **Procedural Generation**
   - Custom Perlin noise implementation for biome distribution
   - Random landmark placement with walkability checks
   - Tile-based world representation (100x100 grid)
2. **Game State Management**
   - Single global `GameState` table
   - Separation of run-specific state and persistent meta-state
   - Serialization using Serpent library

3. **Systems Design**
   - Decoupled systems: Movement, Hazard, Contract, Progression
   - Event-driven hazard system triggered on movement
   - Observer pattern for contract completion events

4. **Rendering Pipeline**
   - Batch rendering for tile-based world
   - Fog of war implementation using exploration flag
   - Immediate mode UI for HUD elements

---

### **DESIGN PATTERNS**
1. **Singleton Pattern**
   - Global `GameState` acts as central data store
   - Avoids complex state passing between systems

2. **Observer Pattern**
   - Contract system observes player discoveries
   - Hazard system observes player movement

3. **Strategy Pattern**
   - Different hazard implementations per biome
   - Different contract types with unique completion criteria

---

### **CRITICAL IMPLEMENTATION PATHS**
1. **World Generation Sequence**
```mermaid
sequenceDiagram
    Love2D->>WorldGen: love.load()
    WorldGen->>WorldGen: Initialize grid
    WorldGen->>Perlin: Generate noise map
    Perlin-->>WorldGen: Noise values
    WorldGen->>WorldGen: Assign biomes
    WorldGen->>LandmarkPlacer: Place landmarks
    LandmarkPlacer-->>WorldGen: Landmark positions
```

2. **Game Loop Execution**
```mermaid
sequenceDiagram
    loop Every frame
        Love2D->>Input: Process events
        Input->>Player: Handle movement
        Player->>World: Update position
        World->>Hazard: Check tile
        Hazard->>Player: Apply effects
        Player->>Contract: Check discoveries
        Contract->>Progression: Update progress
        Progression->>UI: Update HUD
        UI->>Renderer: Draw frame
    end
```

3. **Death Handling Flow**
```mermaid
flowchart TD
    A[Stamina <= 0] --> B[Save Resources]
    B --> C[Save Discoveries]
    C --> D[Reset World]
    D --> E[Generate New World]
    E --> F[Reset Player State]
    F --> G[Load Persistent Abilities]
    G --> H[Continue Game]
