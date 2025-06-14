### **TECH CONTEXT: "SHATTERED EXPANSE"**

---

### **TECHNOLOGIES USED**
- **Primary Engine**: Love2D (v11.4)
- **Programming Language**: Lua (5.1)
- **Dependencies**:
  - `serpent.lua`: Serialization for save/load functionality
- **Development Tools**:
  - VS Code with Lua Language Server extension
  - Love2D debugger

---

### **DEVELOPMENT SETUP**
1. **Environment Configuration**:
   - Install Love2D framework
   - Clone project repository
   - Install dependencies via LuaRocks:
     ```
     luarocks install serpent
     ```
2. **Project Structure**:
   ```
   /src
     /world        - World generation and management
     /entities     - Player and game entities
     /systems      - Game systems (movement, hazards, etc.)
     /ui           - User interface components
     /utils        - Utility functions and helpers
   main.lua        - Entry point
   ```

3. **Build & Run**:
   - Execute with: `love .` in project root
   - Debug with VS Code Love2D launch configuration

---

### **TECHNICAL CONSTRAINTS**
1. **Performance Limitations**:
   - Tile-based rendering must be optimized for 100x100 grid
   - Perlin noise generation should be precomputed at world creation
   - Avoid expensive operations in main game loop

2. **Memory Management**:
   - Lua garbage collection can cause hitches
   - Minimize table allocations during gameplay
   - Use object pooling for entities

3. **Platform Support**:
   - Target platforms: Windows, macOS, Linux
   - Screen resolution: Minimum 1024x768

---

### **DEPENDENCIES**
1. **Core Dependencies**:
   - `serpent.lua`: MIT License
2. **Version Constraints**:
   - Love2D: 11.4+
   - Lua: 5.1+

3. **Dependency Management**:
   - Dependencies included in `lib/` directory
   - No external package manager required

---

### **TOOL USAGE PATTERNS**
1. **Development Workflow**:
   - TDD approach with busted unit tests
   - Version control with Git
   - Continuous integration for build verification

2. **Debugging Practices**:
   - Love2D's built-in console output
   - VS Code debugger with breakpoints
   - Runtime performance profiling

3. **Asset Management**:
   - Sprites stored in `assets/sprites/`
   - Fonts stored in `assets/fonts/`
   - Configuration files in `config/`
