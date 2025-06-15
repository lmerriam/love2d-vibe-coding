### **ACTIVE CONTEXT: "SHATTERED EXPANSE"**

---

### **CURRENT WORK FOCUS**
- Enhancing rendering (landmarks, fog of war, biome textures)
- Improving UI/UX elements (contract UI, inventory limits)

---

### **RECENT CHANGES**
- Implemented save/load system with serpent serialization
- Added persistent meta-progression saving
- Created save/load handlers for game state
- Updated contract system with scroll discovery
- Added contract UI display and progress tracking
- Implemented contract reward distribution

---

### **NEXT STEPS**
1. **Enhanced Rendering**:
   - Replace landmark "?" placeholders with proper visuals
   - Implement smooth fog of war transitions
   - Add biome-specific tile textures

2. **UI Improvements**:
   - Polish contract UI layout
   - Add visual indicators for active contracts
   - Implement inventory capacity limits

---

### **ACTIVE DECISIONS AND CONSIDERATIONS**
- Using a global GameState table for simplicity
- Separating run-specific state from persistent meta-state
- Implementing systems as decoupled modules
- Using observer pattern for contract events
- Use placeholder assets and UI until the game is ready to be polished
- Saving only meta data for persistence between sessions

---

### **IMPORTANT PATTERNS AND PREFERENCES**
- Keep Lua modules focused and single-responsibility
- Use descriptive variable and function names
- Add comments for complex algorithms
- Follow Love2D callback structure (load, update, draw)
- Precompute values where possible for performance

---

### **LEARNINGS AND PROJECT INSIGHTS**
- Save/load implementation is crucial for roguelite progression
- Contract system provides clear player direction
- Scroll discovery mechanic encourages exploration
- UI space is limited - need to design compact information displays
- Reward distribution needs balancing
- Contract progress tracking impacts performance - needs optimization
