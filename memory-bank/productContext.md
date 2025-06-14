### **PRODUCT CONTEXT: "SHATTERED EXPANSE"**

---

### **WHY THIS PROJECT EXISTS**
- To create a unique roguelite experience focused on exploration rather than combat
- Address the lack of risk/reward exploration games in the Love2D ecosystem
- Provide a compelling meta-progression system that encourages repeated playthroughs

---

### **PROBLEMS SOLVED**
1. **Exploration Fatigue**: Players often lose interest after initial exploration. Our contract system provides constant objectives.
2. **Permadeath Frustration**: Meta-progression ensures players always make meaningful progress.
3. **Procedural Generation Monotony**: Diverse biomes with unique hazards create varied gameplay experiences.

---

### **HOW IT SHOULD WORK**
1. **Core Loop**:
   - Generate new world with unique biome layout
   - Accept exploration contracts
   - Gather resources while managing stamina
   - Die and bank progress
   - Unlock abilities for next run
2. **User Flow**:
   ```mermaid
   graph TD
     A[New Game] --> B[Generate World]
     B --> C[Explore Biomes]
     C --> D[Complete Contracts]
     D --> E[Gain Abilities/Resources]
     E --> F[Die & Save Progress]
     F --> B
   ```

---

### **USER EXPERIENCE GOALS**
- **Discovery**: Players should feel excitement when uncovering new biomes and landmarks
- **Tension**: Stamina management and hazards should create risk/reward decisions
- **Progression**: Each run should provide tangible improvements for future runs
- **Accessibility**: Simple controls with deep emergent gameplay
