### **ACTIVE CONTEXT: "SHATTERED EXPANSE"**

---

### **CURRENT WORK FOCUS**
- Implementing contract system
- Enhancing UI/UX elements
- Finalizing meta-progression implementation

---

### **RECENT CHANGES**
- Implemented biome-specific hazard system with stamina drain mechanics
- Added player death handling with meta-progression saving
- Created inventory system with UI display
- Implemented landmark discovery mechanics
- Added meta resource tracking and display
- Fixed exploration radius logic

---

### **NEXT STEPS**
1. **Contract System**:
   - Implement contract generation logic
   - Create progress tracking
   - Add reward distribution

2. **Enhanced Rendering**:
   - Add landmark visualization
   - Implement proper fog of war
   - Create biome-specific tile rendering

3. **Save/Load System**:
   - Integrate serpent.lua for serialization
   - Implement persistent meta-progression
   - Add save/load handlers

---

### **ACTIVE DECISIONS AND CONSIDERATIONS**
- Using a global GameState table for simplicity
- Separating run-specific state from persistent meta-state
- Implementing systems as decoupled modules
- Using observer pattern for event-driven systems
- Using a simplified inventory system for prototype

---

### **IMPORTANT PATTERNS AND PREFERENCES**
- Keep Lua modules focused and single-responsibility
- Use descriptive variable and function names
- Add comments for complex algorithms
- Follow Love2D callback structure (load, update, draw)
- Precompute values where possible for performance

---

### **LEARNINGS AND PROJECT INSIGHTS**
- Biome hazard probabilities need careful balancing
- Inventory system should have capacity limits
- Landmark discovery adds meaningful exploration goals
- Meta-progression provides important player retention
- UI needs to be clean and non-intrusive
