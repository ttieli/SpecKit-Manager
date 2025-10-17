# Implementation Plan: Command Library Multi-Column Layout

**Branch**: `007-1-20-20` | **Date**: 2025-10-17 | **Spec**: [specs/007-1-20-20/spec.md](./spec.md)
**Input**: Feature specification from `/specs/007-1-20-20/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

This feature adds dynamic column count selection (1-20 columns) to the command library, enabling users to optimize screen real estate on wide displays. Commands reflow into a CSS Grid layout with automatic font scaling (16px → 10px minimum) to maintain readability. User preferences persist via localStorage. The implementation uses CSS Grid with `repeat()` and CSS Custom Properties for layout, segmented font scaling algorithm for readability, ellipsis truncation with tooltips for overflow handling, and a simple integer localStorage structure for preference persistence.

## Technical Context

**Language/Version**: JavaScript ES6+ (Vanilla JavaScript, no transpilation)
**Primary Dependencies**: None (zero external dependencies)
**Storage**: LocalStorage (column preference persistence via `speckit_column_count` key)
**Testing**: Manual testing via test-automation.html (integration tests reflecting user scenarios)
**Target Platform**: Modern browsers (Chrome 90+, Firefox 88+, Safari 14+, Edge 90+)
**Project Type**: Single-file architecture (index.html with inline CSS/JS)
**Performance Goals**: <50ms render time for 100 commands, <1ms layout calculations, 60fps transitions
**Constraints**: No horizontal scroll at any column count (1-20), minimum font size ≥10px for accessibility
**Scale/Scope**: 1-20 columns, 100+ commands, single HTML file (<150KB)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Simplicity and Anti-Abstraction
✅ **PASS**: Feature uses simple, direct solutions:
- CSS Grid with `repeat()` for layout (no complex layout engine)
- Simple localStorage integer for preference (no object structure needed)
- Pure function calculations for font scaling (no OOP abstractions)
- Native HTML5 range input for column selector (no custom UI framework)

### Principle II: Architectural Integrity
✅ **PASS**: Feature follows existing architectural patterns:
- Single-file architecture: All code in index.html
- LocalStorage persistence: Consistent with existing project/command data
- Event-driven UI: onclick attribute binding for user interactions
- Functional programming: Pure functions for layout calculations

### Principle III: Clean and Modular Code
✅ **PASS**: Code organization adheres to standards:
- Functions ≤50 lines (layoutCalculateGrid, columnSavePreference, etc.)
- Nesting depth ≤3 levels (conditional font scaling logic)
- ES6+ syntax: const/let, arrow functions, template literals
- Clear naming conventions: render*, layout*, column* prefixes

### Principle IV: Integration-First Testing
✅ **PASS**: Testing strategy prioritizes integration tests:
- Manual tests in test-automation.html covering user scenarios
- Test cases map to acceptance criteria (column selection, font scaling, persistence)
- 100% critical path coverage: load → select → persist → reload
- Unit tests secondary (validation logic, edge cases)

### Principle V: Bilingual Documentation
✅ **PASS**: All documentation provides bilingual support:
- Document titles: Chinese/English
- Key terms: 列数/Column Count, 字体缩放/Font Scaling
- User scenarios: Bilingual descriptions
- UI labels: "列数 (Columns)" in renderColumnSelector()

### Principle VI: Modularity Mandate
✅ **PASS**: Feature implements 3 function groups (pseudo-modules):

1. **Column Management Module** (column* functions):
   - Purpose: Handle column preference persistence
   - Functions: columnLoadPreference(), columnSavePreference()
   - Dependencies: None (localStorage only)
   - Test Strategy: Mock localStorage

2. **Layout Calculation Module** (layout* functions):
   - Purpose: Calculate CSS Grid and font parameters
   - Functions: layoutCalculateGrid(), layoutCalculateFontSizes()
   - Dependencies: None (pure functions)
   - Test Strategy: Input/output validation

3. **Command Grid Rendering Module** (render* functions):
   - Purpose: Update DOM with multi-column layout
   - Functions: renderCommandGrid(), renderColumnSelector()
   - Dependencies: column*, layout* modules
   - Test Strategy: Verify DOM output, performance timing

**Module Dependency Graph**:
```
[render* functions] ──→ [layout* functions] (calculations)
        ↓
[column* functions] (persistence)
```

### Principle VII: Separation of Concerns
✅ **PASS**: Feature separates concerns across 3 layers:

**Data Access Layer** (column* functions):
- Responsibilities: Read/write column preference from localStorage
- Components: columnLoadPreference(), columnSavePreference()
- Prohibited: ❌ DOM manipulation, ❌ Business logic

**Business Logic Layer** (layout* functions):
- Responsibilities: Calculate grid layout and font sizes based on column count
- Components: layoutCalculateGrid(), layoutCalculateFontSizes()
- Prohibited: ❌ DOM manipulation, ❌ Direct localStorage access

**Presentation Layer** (render* functions):
- Responsibilities: Update DOM with calculated layout and font styles
- Components: renderCommandGrid(), renderColumnSelector()
- Prohibited: ❌ Direct localStorage access (must use column* functions)

**Call Chain** (unidirectional):
```
renderCommandGrid() → columnLoadPreference() → localStorage
                   → layoutCalculateGrid() → pure calculation
                   → layoutCalculateFontSizes() → pure calculation
                   → DOM.innerHTML update
```

### Summary
✅ **ALL PRINCIPLES PASS** - Feature ready for implementation
- No architectural violations
- No complexity violations
- Clear module boundaries with no circular dependencies
- Strict layer separation with one-way call flow

## Project Structure

### Documentation (this feature)

```
specs/007-1-20-20/
├── plan.md                          # This file (/speckit.plan command output)
├── research.md                      # Phase 0 output (technical decisions)
├── data-model.md                    # Phase 1 output (data structures)
├── contracts/
│   └── function-interfaces.md       # Phase 1 output (function contracts)
└── tasks.md                         # Phase 2 output (/speckit.tasks command - NOT created yet)
```

### Source Code (repository root)

```
index.html                           # Single-file architecture
├── <style> section
│   ├── Base styles
│   ├── Command grid styles         # NEW: CSS Grid for multi-column layout
│   ├── Column selector styles      # NEW: UI control for column count selection
│   └── Responsive styles
└── <script> section
    ├── Constants
    │   ├── MIN_COLUMNS = 1         # NEW: Minimum column count
    │   ├── MAX_COLUMNS = 20        # NEW: Maximum column count
    │   └── DEFAULT_COLUMNS = 4     # NEW: Default column count
    ├── Data Access Layer
    │   ├── columnLoadPreference()  # NEW: Load column count from localStorage
    │   ├── columnSavePreference()  # NEW: Save column count to localStorage
    │   ├── saveProjects()          # Existing
    │   └── loadProjects()          # Existing
    ├── Business Logic Layer
    │   ├── layoutCalculateGrid()   # NEW: Calculate CSS Grid parameters
    │   ├── layoutCalculateFontSizes() # NEW: Calculate font scaling
    │   └── [existing validation]   # Existing
    ├── Presentation Layer
    │   ├── renderCommandGrid()     # MODIFIED: Add multi-column layout support
    │   ├── renderColumnSelector()  # NEW: Render column count selector UI
    │   ├── renderProjects()        # Existing
    │   └── switchTab()             # Existing
    └── Event Handlers
        ├── handleColumnCountChange() # NEW: Handle column count selection
        ├── handleColumnCountSet()  # NEW: Save and apply column count
        └── [existing handlers]     # Existing

tests/
└── test-automation.html             # MODIFIED: Add multi-column layout tests
    ├── Column preference tests     # NEW
    ├── Layout calculation tests    # NEW
    ├── Font scaling tests          # NEW
    ├── Grid rendering tests        # NEW
    └── [existing tests]            # Existing
```

**Structure Decision**: This feature adheres to the single-file architecture pattern. All new code (column management, layout calculations, rendering enhancements) will be added to index.html following the established code organization order:
1. Constants (column count limits)
2. Data Access Layer (column* functions)
3. Business Logic Layer (layout* functions)
4. Presentation Layer (render* functions, modifications to existing)
5. Event Handlers (handle* functions)

No new files are created. Testing enhancements are added to the existing test-automation.html file.

## Complexity Tracking

*Fill ONLY if Constitution Check has violations that must be justified*

**No violations detected** - This section is intentionally left empty as all constitution principles pass.

## Module Boundary Definition *(新增 / NEW - Constitution Principle VI)*

This feature implements three pseudo-modules as function groups, following the single-file architecture pattern:

---

### Module 1: Column Management Module (column*)

**Purpose**: Manage user's column count preference persistence using localStorage

**Interface**:
```javascript
// Load column count preference from localStorage
function columnLoadPreference(): number
// Returns: integer 1-20 (validated), or default 4 if not found/invalid

// Save column count preference to localStorage
function columnSavePreference(columnCount: number): boolean
// Input: columnCount - integer 1-20
// Returns: true if saved successfully, false if failed
```

**Dependencies**:
- **Internal**: None
- **External**: localStorage API (browser-native)

**Independent Test Strategy**:
- Mock localStorage with test values
- Test valid inputs (1, 4, 10, 20) - verify correct save/load
- Test invalid inputs (0, 21, NaN, "abc") - verify default fallback
- Test localStorage unavailable - verify graceful degradation
- Verify no DOM manipulation occurs
- Verify no business logic calculations occur

**Location**: `index.html` (Data Access Layer section)

---

### Module 2: Layout Calculation Module (layout*)

**Purpose**: Calculate CSS Grid parameters and font scaling based on column count

**Interface**:
```javascript
// Calculate CSS Grid layout parameters
function layoutCalculateGrid(columnCount: number): GridLayout
// Input: columnCount - validated integer 1-20
// Returns: {
//   columnCount: number,
//   gridTemplateColumns: string,  // "repeat(N, minmax(0, 1fr))"
//   gap: string,                   // "1rem"
//   itemPadding: string,           // "0.5rem" or "0.75rem"
//   fontSize: number,              // 10-16 px
//   lineHeight: number             // 1.2-1.5
// }

// Calculate detailed font size parameters
function layoutCalculateFontSizes(columnCount: number): FontSizes
// Input: columnCount - validated integer 1-20
// Returns: {
//   columnCount: number,
//   commandLabelSize: number,      // 10-16 px
//   commandTextSize: number,       // 10-14 px
//   categoryHeaderSize: number,    // 12-18 px
//   lineHeight: number,            // 1.2-1.5
//   minReadableSize: number        // 10 px
// }
```

**Dependencies**:
- **Internal**: None (pure functions)
- **External**: None

**Independent Test Strategy**:
- Provide test column counts (1, 4, 8, 12, 20)
- Verify output matches expected font scaling ranges
- Verify execution time < 1ms
- Verify no side effects (no localStorage, no DOM access)
- Verify fontSize never falls below 10px minimum
- Test boundary values (1, 20)
- Test segmented scaling logic correctness

**Location**: `index.html` (Business Logic Layer section)

---

### Module 3: Command Grid Rendering Module (render*)

**Purpose**: Render command library with multi-column CSS Grid layout and responsive font sizes

**Interface**:
```javascript
// Render command grid with multi-column layout
function renderCommandGrid(commands: Array<Command> = commands): void
// Input: commands - array of command objects (optional, defaults to global)
// Returns: void (side effect: updates DOM)
// Side effects:
//   - Calls columnLoadPreference() to get column count
//   - Calls layoutCalculateGrid() to get layout parameters
//   - Calls layoutCalculateFontSizes() to get font parameters
//   - Updates #command-list element with new HTML and CSS styles

// Render column count selector UI control
function renderColumnSelector(): void
// Input: none
// Returns: void (side effect: updates DOM)
// Side effects:
//   - Calls columnLoadPreference() to get current preference
//   - Updates #column-selector-container with HTML
//   - Binds event handlers for user interaction
```

**Dependencies**:
- **Internal**: Column Management Module (column*), Layout Calculation Module (layout*)
- **External**: DOM APIs (document.getElementById, innerHTML, style manipulation)

**Independent Test Strategy**:
- Mock columnLoadPreference() to return test column counts
- Mock layoutCalculateGrid() and layoutCalculateFontSizes() with test data
- Verify correct HTML structure in output
- Verify CSS Grid styles applied to container
- Verify font sizes applied to command elements
- Verify performance < 50ms for 100 commands
- Verify no direct localStorage access (must use column* functions)
- Test empty commands array (empty state rendering)
- Test category grouping preserved

**Location**: `index.html` (Presentation Layer section)

---

### Module Dependency Graph

```
┌─────────────────────────────────────────┐
│  Command Grid Rendering Module          │
│  (render* functions)                    │
│  - renderCommandGrid()                  │
│  - renderColumnSelector()               │
└────────────┬────────────────────────────┘
             │ calls
             ↓
┌─────────────────────────────────────────┐
│  Layout Calculation Module              │
│  (layout* functions)                    │
│  - layoutCalculateGrid()                │
│  - layoutCalculateFontSizes()           │
└─────────────────────────────────────────┘
             ↓ (no dependencies)

┌─────────────────────────────────────────┐
│  Column Management Module               │
│  (column* functions)                    │
│  - columnLoadPreference()               │
│  - columnSavePreference()               │
└─────────────────────────────────────────┘
             ↓ (no dependencies)

(No circular dependencies)
```

**Call Flow**:
```
User Action → renderCommandGrid()
                ├→ columnLoadPreference() → localStorage.getItem()
                ├→ layoutCalculateGrid() → pure calculation
                ├→ layoutCalculateFontSizes() → pure calculation
                └→ DOM.innerHTML update

User Changes Column → handleColumnCountSet()
                        ├→ columnSavePreference() → localStorage.setItem()
                        └→ renderCommandGrid() → [same as above]
```

---

### Single-File Architecture Adaptation

**Function Groups (Pseudo-Modules)** - Enforced by naming conventions:

1. **Data Access Module**: `column*` functions
   - Purpose: Handle column preference persistence only
   - Interface: Accept/return integers, manage localStorage
   - Dependencies: None (localStorage API only)
   - Test: Mock localStorage

2. **Business Logic Module**: `layout*` functions
   - Purpose: Pure calculations for grid layout and font scaling
   - Interface: Accept column count, return layout/font objects
   - Dependencies: None (pure functions)
   - Test: Provide test inputs, verify output

3. **Presentation Module**: `render*` functions
   - Purpose: Update DOM with calculated layout
   - Interface: Accept data, no return (side-effect: DOM update)
   - Dependencies: column* and layout* modules
   - Test: Verify HTML output, CSS application

4. **Event Handler Module**: `handle*` functions
   - Purpose: Bridge user actions to appropriate modules
   - Interface: Event object in, orchestrate module calls
   - Dependencies: All modules (orchestration layer)
   - Test: Mock events, verify correct module calls

**Enforcement**: Function naming conventions strictly enforced during code review. Any function violating layer separation will be rejected.

## Layers of Concerns Design *(新增 / NEW - Constitution Principle VII)*

This feature strictly separates concerns across three layers, following Constitution Principle VII:

---

### Data Access Layer (数据访问层)

**Responsibilities**:
- Persist column count preference to LocalStorage
- Retrieve column count preference from LocalStorage
- Validate stored data format and range (1-20)
- Handle storage unavailability gracefully

**Components**:
- **File/Functions**: `index.html` → `columnLoadPreference()`, `columnSavePreference()`
- **External Dependencies**: localStorage API (browser-native, no libraries)
- **Data Contracts**:
  ```javascript
  // Storage key: 'speckit_column_count'
  // Storage value: string representation of integer 1-20
  // Example: "4", "10", "20"
  ```

**Prohibited**:
- ❌ MUST NOT manipulate DOM (no document.getElementById, no innerHTML)
- ❌ MUST NOT contain business logic (no font size calculations, no layout logic)
- ❌ MUST NOT be called by Presentation Layer directly (only via orchestration)

**Example Interface**:
```javascript
// Data Access Layer functions
function columnLoadPreference(): number
// Returns: validated integer 1-20, or default 4

function columnSavePreference(columnCount: number): boolean
// Input: columnCount - integer to save
// Returns: true if saved, false if failed
```

**Implementation Details**:
- Uses `localStorage.getItem('speckit_column_count')` for reads
- Uses `localStorage.setItem('speckit_column_count', value)` for writes
- Validates and clamps input to 1-20 range
- Returns default (4) if key missing or invalid
- Catches and logs errors, never throws

---

### Business Logic Layer (业务逻辑层)

**Responsibilities**:
- Calculate CSS Grid template columns based on column count
- Calculate font sizes for different column count ranges (segmented scaling)
- Determine line height, padding, and gap based on column count
- Enforce minimum font size (10px) and maximum (16px)
- Implement segmented scaling algorithm (1-4, 5-8, 9-12, 13-20)

**Components**:
- **File/Functions**: `index.html` → `layoutCalculateGrid()`, `layoutCalculateFontSizes()`
- **Internal Dependencies**: None (pure functions with no side effects)
- **Business Rules**:
  - Column count must be 1-20 (clamp if out of range)
  - Font size minimum: 10px (accessibility)
  - Font size maximum: 16px (1-4 columns)
  - Line height minimum: 1.2
  - Grid template: `repeat(N, minmax(0, 1fr))` format
  - Segmented scaling: different formulas for different ranges

**Prohibited**:
- ❌ MUST NOT manipulate DOM
- ❌ MUST NOT directly call localStorage (use Data Access Layer)
- ❌ MUST NOT handle user events directly

**Example Interface**:
```javascript
// Business Logic Layer functions
function layoutCalculateGrid(columnCount: number): GridLayout
// Input: columnCount - validated integer 1-20
// Returns: {
//   columnCount, gridTemplateColumns, gap, itemPadding, fontSize, lineHeight
// }

function layoutCalculateFontSizes(columnCount: number): FontSizes
// Input: columnCount - validated integer 1-20
// Returns: {
//   columnCount, commandLabelSize, commandTextSize, categoryHeaderSize,
//   lineHeight, minReadableSize
// }
```

**Key Algorithms**:

1. **Grid Template Calculation**:
   ```javascript
   gridTemplateColumns = `repeat(${columnCount}, minmax(0, 1fr))`;
   ```

2. **Segmented Font Scaling**:
   ```javascript
   if (columnCount <= 4) fontSize = 16;          // 1-4 columns
   else if (columnCount <= 8) fontSize = 14-16;  // 5-8 columns
   else if (columnCount <= 12) fontSize = 12-14; // 9-12 columns
   else fontSize = 10-12;                        // 13-20 columns
   ```

---

### Presentation Layer (展示层)

**Responsibilities**:
- Render command grid with multi-column CSS Grid layout
- Apply calculated font sizes to command elements
- Render column count selector UI control
- Update DOM when column count changes
- Handle empty state rendering
- Preserve category grouping in grid layout

**Components**:
- **File/Functions**: `index.html` → `renderCommandGrid()`, `renderColumnSelector()`
- **Internal Dependencies**:
  - Data Access Layer: `columnLoadPreference()` for getting preference
  - Business Logic Layer: `layoutCalculateGrid()`, `layoutCalculateFontSizes()` for calculations
- **UI Framework**: Vanilla JavaScript (no frameworks)

**Prohibited**:
- ❌ MUST NOT call Data Access Layer's write functions directly (columnSavePreference)
- ❌ MUST NOT contain business logic (no font calculations, no validation)
- ❌ MUST NOT perform data validation (delegate to Business Logic)

**Example Interface**:
```javascript
// Presentation Layer functions
function renderCommandGrid(commands: Array<Command> = commands): void
// Input: commands array (optional)
// Side effects: Updates #command-list DOM element

function renderColumnSelector(): void
// Input: none
// Side effects: Updates #column-selector-container DOM element
```

**DOM Update Strategy**:
```javascript
// 1. Load preference from Data Access Layer
const columnCount = columnLoadPreference();

// 2. Calculate layout from Business Logic Layer
const layout = layoutCalculateGrid(columnCount);
const fonts = layoutCalculateFontSizes(columnCount);

// 3. Apply styles to container
container.style.gridTemplateColumns = layout.gridTemplateColumns;
container.style.gap = layout.gap;

// 4. Build HTML with calculated font sizes
let html = '';
categories.forEach(category => {
  html += `<div style="font-size: ${fonts.categoryHeaderSize}px">...`;
  commands.forEach(cmd => {
    html += `<div style="font-size: ${fonts.commandLabelSize}px">...`;
  });
});

// 5. Single DOM write
container.innerHTML = html;
```

---

### Layer Communication Rules

**Allowed Call Chains** (unidirectional):
```
┌─────────────────────────────────────┐
│  Presentation Layer                 │
│  - renderCommandGrid()              │
│  - renderColumnSelector()           │
└────────────┬────────────────────────┘
             │ calls
             ↓
┌─────────────────────────────────────┐
│  Business Logic Layer               │
│  - layoutCalculateGrid()            │
│  - layoutCalculateFontSizes()       │
└─────────────────────────────────────┘
             │ (no dependencies)
             ↓
┌─────────────────────────────────────┐
│  Data Access Layer                  │
│  - columnLoadPreference()           │
│  - columnSavePreference()           │
└─────────────────────────────────────┘
             │ writes to
             ↓
        localStorage
```

**Prohibited Calls** (reverse or cross-layer):
```
Data Access Layer ─X→ Business Logic Layer  (FORBIDDEN)
Data Access Layer ─X→ Presentation Layer    (FORBIDDEN)
Business Logic Layer ─X→ Presentation Layer (FORBIDDEN)
Presentation Layer ─X→ columnSavePreference() directly (FORBIDDEN - use event handler)
```

**Event Handler Bridge** (orchestration):
```
User Event → Event Handler → {
    1. columnSavePreference(newCount)      [Data Access Layer]
    2. renderCommandGrid()                 [Presentation Layer]
       ├→ columnLoadPreference()           [Data Access Layer]
       ├→ layoutCalculateGrid()            [Business Logic Layer]
       ├→ layoutCalculateFontSizes()       [Business Logic Layer]
       └→ DOM update
}
```

---

### Single-File Architecture Adaptation

**Code Organization Order** (top to bottom in index.html `<script>` section):

```javascript
// 1. CONSTANTS AND CONFIGURATION
const MIN_COLUMNS = 1;
const MAX_COLUMNS = 20;
const DEFAULT_COLUMNS = 4;

// 2. DATA ACCESS LAYER (column* functions)
function columnLoadPreference() { /* ... */ }
function columnSavePreference(columnCount) { /* ... */ }

// 3. BUSINESS LOGIC LAYER (layout* functions)
function layoutCalculateGrid(columnCount) { /* ... */ }
function layoutCalculateFontSizes(columnCount) { /* ... */ }

// 4. PRESENTATION LAYER (render* functions)
function renderCommandGrid(commands = commands) { /* ... */ }
function renderColumnSelector() { /* ... */ }

// 5. EVENT HANDLERS (handle* functions - bridge layer)
function handleColumnCountChange(value) { /* ... */ }
function handleColumnCountSet(count) { /* ... */ }
```

**Naming Convention Enforcement**:
- **Data Access**: `columnLoadPreference()`, `columnSavePreference()`
- **Business Logic**: `layoutCalculateGrid()`, `layoutCalculateFontSizes()`
- **Presentation**: `renderCommandGrid()`, `renderColumnSelector()`
- **Event Handlers**: `handleColumnCountChange()`, `handleColumnCountSet()`

**Code Review Checklist for This Feature**:
- [ ] No `render*` functions call `localStorage.getItem()` or `localStorage.setItem()` directly
- [ ] No `column*` functions call `document.getElementById()` or manipulate DOM
- [ ] No `layout*` functions access localStorage or manipulate DOM
- [ ] All font size calculations are in `layout*` functions (not in `render*`)
- [ ] All localStorage operations are in `column*` functions (not in `render*` or `layout*`)
- [ ] `renderCommandGrid()` calls `columnLoadPreference()` (not `localStorage.getItem()`)
- [ ] Event handlers (`handle*`) orchestrate layers in correct order: Data → Business → Presentation
- [ ] No circular dependencies between function groups

**Layer Violation Examples** (for training purposes):

❌ **WRONG** - Presentation calling localStorage directly:
```javascript
function renderCommandGrid() {
  const count = parseInt(localStorage.getItem('speckit_column_count'), 10); // WRONG
  // Should use: const count = columnLoadPreference();
}
```

❌ **WRONG** - Data Access containing business logic:
```javascript
function columnSavePreference(count) {
  const fontSize = count <= 4 ? 16 : 14; // WRONG - business logic in data layer
  localStorage.setItem('speckit_column_count', count.toString());
}
```

❌ **WRONG** - Business Logic manipulating DOM:
```javascript
function layoutCalculateGrid(count) {
  const layout = { /* ... */ };
  document.getElementById('command-list').style.gridTemplateColumns = layout.gridTemplateColumns; // WRONG
  return layout;
}
```

✅ **CORRECT** - Proper layer separation:
```javascript
// Data Access Layer
function columnLoadPreference() {
  return parseInt(localStorage.getItem('speckit_column_count'), 10) || 4;
}

// Business Logic Layer
function layoutCalculateGrid(columnCount) {
  return {
    gridTemplateColumns: `repeat(${columnCount}, minmax(0, 1fr))`,
    fontSize: columnCount <= 4 ? 16 : 14
  };
}

// Presentation Layer
function renderCommandGrid() {
  const count = columnLoadPreference();        // Data Access
  const layout = layoutCalculateGrid(count);   // Business Logic
  container.style.gridTemplateColumns = layout.gridTemplateColumns; // Presentation
}
```
