# Function Interface Contracts: Command Library Multi-Column Layout

**Feature**: 007-1-20-20 Command Library Multi-Column Layout
**Date**: 2025-10-17
**Purpose**: Define function signatures and contracts for all modules

## Layer Architecture Overview

This feature implements a strict three-layer architecture following Constitution Principle VII:

```
┌─────────────────────────────────────┐
│  Presentation Layer                 │  ← render* functions
│  - renderCommandGrid()              │  ← DOM manipulation, UI updates
│  - renderColumnSelector()           │
├─────────────────────────────────────┤
│  Business Logic Layer               │  ← layout* functions
│  - layoutCalculateGrid()            │  ← Pure calculations, no I/O
│  - layoutCalculateFontSizes()       │
├─────────────────────────────────────┤
│  Data Access Layer                  │  ← column* functions
│  - columnLoadPreference()           │  ← localStorage operations only
│  - columnSavePreference()           │
└─────────────────────────────────────┘
```

**Call Flow Rules**:
- Presentation → Business → Data (one-way flow)
- render* functions MAY call layout* and column* functions
- layout* functions are pure (no side effects)
- column* functions MUST NOT manipulate DOM or contain business logic

---

## Data Access Layer Contracts

### columnSavePreference

**Layer Assignment**: Data Access Layer

**Purpose**: Persist user's column count preference to LocalStorage

**Signature**:
```javascript
function columnSavePreference(columnCount: number): boolean
```

**Input Contract**:
```javascript
columnCount: number  // Integer 1-20, user's desired column count
```

**Input Validation**:
- `columnCount` must be number (not string, not null)
- Must not be NaN
- Will be clamped to 1-20 range
- Non-integers will be floored

**Output Contract**:
```javascript
Returns: boolean
- true: Preference successfully saved to localStorage
- false: Save failed (localStorage unavailable, quota exceeded, invalid input)
```

**Business Logic** (minimal - validation only):
```javascript
const MIN_COLUMNS = 1;
const MAX_COLUMNS = 20;

// Validate type
if (typeof columnCount !== 'number' || isNaN(columnCount)) {
    console.error('Invalid column count type:', columnCount);
    return false;
}

// Clamp to valid range and floor to integer
const clamped = Math.max(MIN_COLUMNS, Math.min(MAX_COLUMNS, Math.floor(columnCount)));
```

**Side Effects**:
- Writes to `localStorage` key: `'speckit_column_count'`
- Overwrites previous preference (single value, not array)
- No DOM manipulation
- No business logic calculations

**Error Handling**:
- Returns `false` on any error (does not throw)
- Logs error to console for debugging
- Graceful degradation: App continues with in-memory preference

**Example Usage**:
```javascript
// User selects 10 columns
const success = columnSavePreference(10);
if (!success) {
    console.warn('Column preference not saved, using in-memory value');
}
```

**Prohibited Patterns**:
```javascript
// ❌ WRONG: columnSavePreference MUST NOT manipulate DOM
function columnSavePreference(count) {
    localStorage.setItem('speckit_column_count', count.toString());
    document.getElementById('column-display').textContent = count; // ❌ WRONG
}

// ❌ WRONG: columnSavePreference MUST NOT contain business logic
function columnSavePreference(count) {
    const fontSize = calculateFontSize(count); // ❌ WRONG: Business logic
    localStorage.setItem('speckit_column_count', count.toString());
}
```

---

### columnLoadPreference

**Layer Assignment**: Data Access Layer

**Purpose**: Retrieve user's column count preference from LocalStorage

**Signature**:
```javascript
function columnLoadPreference(): number
```

**Input Contract**: None (no parameters)

**Output Contract**:
```javascript
Returns: number
- Success: integer 1-20 (validated preference)
- No data: 4 (default column count)
- Invalid data: 4 (default, with console warning)
```

**Business Logic** (minimal - validation only):
```javascript
const DEFAULT_COLUMNS = 4;
const MIN_COLUMNS = 1;
const MAX_COLUMNS = 20;

try {
    const stored = localStorage.getItem('speckit_column_count');

    // Handle null/undefined (first visit)
    if (stored === null || stored === undefined) {
        return DEFAULT_COLUMNS;
    }

    // Parse and validate
    const parsed = parseInt(stored, 10);

    // Handle NaN or invalid numbers
    if (isNaN(parsed)) {
        console.warn('Invalid column count in localStorage, using default');
        return DEFAULT_COLUMNS;
    }

    // Clamp to valid range
    if (parsed < MIN_COLUMNS || parsed > MAX_COLUMNS) {
        console.warn(`Column count ${parsed} out of range, using default`);
        return DEFAULT_COLUMNS;
    }

    return parsed;

} catch (error) {
    console.error('Error reading from localStorage:', error);
    return DEFAULT_COLUMNS;
}
```

**Side Effects**:
- Reads from `localStorage` key: `'speckit_column_count'`
- No mutations
- No DOM manipulation
- No business logic calculations

**Error Handling**:
- Returns default (4) if localStorage unavailable
- Returns default if key doesn't exist
- Returns default if parse fails
- Logs warnings/errors to console

**Example Usage**:
```javascript
// On page load or tab switch
const columnCount = columnLoadPreference();
console.log(`User prefers ${columnCount} columns`);
```

**Prohibited Patterns**:
```javascript
// ❌ WRONG: columnLoadPreference MUST NOT contain business logic
function columnLoadPreference() {
    const count = parseInt(localStorage.getItem('speckit_column_count'), 10);
    const fontSize = calculateFontSize(count); // ❌ WRONG: Business logic
    return count;
}

// ❌ WRONG: columnLoadPreference MUST NOT manipulate DOM
function columnLoadPreference() {
    const count = parseInt(localStorage.getItem('speckit_column_count'), 10);
    document.getElementById('column-selector').value = count; // ❌ WRONG
    return count;
}
```

---

## Business Logic Layer Contracts

### layoutCalculateGrid

**Layer Assignment**: Business Logic Layer

**Purpose**: Calculate CSS Grid layout parameters based on column count

**Signature**:
```javascript
function layoutCalculateGrid(columnCount: number): GridLayout
```

**Input Contract**:
```javascript
columnCount: number  // Validated integer 1-20
```

**Input Validation**:
- Assumes input is already validated (1-20 range)
- If invalid, clamps to safe defaults

**Output Contract**:
```javascript
Returns: GridLayout {
    columnCount: number,           // Echo of input (1-20)
    gridTemplateColumns: string,   // CSS value: "repeat(N, minmax(0, 1fr))"
    gap: string,                   // CSS gap value: "1rem"
    itemPadding: string,           // CSS padding: "0.5rem" or "0.75rem"
    fontSize: number,              // Base font size in pixels
    lineHeight: number             // Line height multiplier (1.2-1.5)
}
```

**Output Example**:
```javascript
// For columnCount = 4
{
    columnCount: 4,
    gridTemplateColumns: "repeat(4, minmax(0, 1fr))",
    gap: "1rem",
    itemPadding: "0.75rem",
    fontSize: 16,
    lineHeight: 1.5
}

// For columnCount = 12
{
    columnCount: 12,
    gridTemplateColumns: "repeat(12, minmax(0, 1fr))",
    gap: "1rem",
    itemPadding: "0.5rem",
    fontSize: 12,
    lineHeight: 1.3
}

// For columnCount = 20
{
    columnCount: 20,
    gridTemplateColumns: "repeat(20, minmax(0, 1fr))",
    gap: "1rem",
    itemPadding: "0.5rem",
    fontSize: 10,
    lineHeight: 1.2
}
```

**Business Logic**:
```javascript
function layoutCalculateGrid(columnCount) {
    // Clamp to valid range (safety check)
    const count = Math.max(1, Math.min(20, columnCount));

    // CSS Grid template - always use minmax(0, 1fr) for equal-width columns
    const gridTemplateColumns = `repeat(${count}, minmax(0, 1fr))`;

    // Calculate font size using segmented scaling
    let fontSize;
    if (count <= 4) {
        fontSize = 16; // Constant for 1-4 columns
    } else if (count <= 8) {
        fontSize = Math.max(14, 20 - (count - 4) * 0.5);
    } else if (count <= 12) {
        fontSize = Math.max(12, 14 - (count - 8) * 0.5);
    } else {
        fontSize = Math.max(10, 12 - (count - 12) * 0.25);
    }

    // Calculate responsive parameters
    const lineHeight = count <= 4 ? 1.5 : (count <= 12 ? 1.3 : 1.2);
    const itemPadding = fontSize >= 14 ? '0.75rem' : '0.5rem';

    return {
        columnCount: count,
        gridTemplateColumns,
        gap: '1rem',
        itemPadding,
        fontSize,
        lineHeight
    };
}
```

**Side Effects**: None (pure function)

**Error Handling**:
- No errors thrown (defensive programming with clamps)
- Always returns valid GridLayout object

**Performance**:
- O(1) complexity (simple arithmetic)
- Executes in < 1ms
- No external dependencies

**Example Usage**:
```javascript
const layout = layoutCalculateGrid(10);
console.log(`Grid template: ${layout.gridTemplateColumns}`);
console.log(`Font size: ${layout.fontSize}px`);
```

**Prohibited Patterns**:
```javascript
// ❌ WRONG: layoutCalculateGrid MUST NOT access localStorage
function layoutCalculateGrid(columnCount) {
    const saved = localStorage.getItem('speckit_column_count'); // ❌ WRONG
    // ...
}

// ❌ WRONG: layoutCalculateGrid MUST NOT manipulate DOM
function layoutCalculateGrid(columnCount) {
    const layout = { /* ... */ };
    document.getElementById('grid').style.gridTemplateColumns = layout.gridTemplateColumns; // ❌ WRONG
    return layout;
}
```

---

### layoutCalculateFontSizes

**Layer Assignment**: Business Logic Layer

**Purpose**: Calculate detailed font size parameters for different text elements

**Signature**:
```javascript
function layoutCalculateFontSizes(columnCount: number): FontSizes
```

**Input Contract**:
```javascript
columnCount: number  // Validated integer 1-20
```

**Input Validation**:
- Assumes input is already validated (1-20 range)
- If invalid, clamps to safe defaults

**Output Contract**:
```javascript
Returns: FontSizes {
    columnCount: number,           // Echo of input (1-20)
    commandLabelSize: number,      // Font size for command labels (px)
    commandTextSize: number,       // Font size for command text (px)
    categoryHeaderSize: number,    // Font size for category headers (px)
    lineHeight: number,            // Line height multiplier (1.2-1.5)
    minReadableSize: number        // Minimum enforced (10px)
}
```

**Output Example**:
```javascript
// For columnCount = 4
{
    columnCount: 4,
    commandLabelSize: 16,
    commandTextSize: 14,
    categoryHeaderSize: 18,
    lineHeight: 1.5,
    minReadableSize: 10
}

// For columnCount = 12
{
    columnCount: 12,
    commandLabelSize: 12,
    commandTextSize: 11,
    categoryHeaderSize: 14,
    lineHeight: 1.3,
    minReadableSize: 10
}

// For columnCount = 20
{
    columnCount: 20,
    commandLabelSize: 10,
    commandTextSize: 10,
    categoryHeaderSize: 12,
    lineHeight: 1.2,
    minReadableSize: 10
}
```

**Business Logic**:
```javascript
function layoutCalculateFontSizes(columnCount) {
    // Clamp to valid range
    const count = Math.max(1, Math.min(20, columnCount));

    let labelSize, textSize, headerSize, lineHeight;

    // Segmented scaling for different column ranges
    if (count <= 4) {
        // 1-4 columns: Maximum readability
        labelSize = 16;
        textSize = 14;
        headerSize = 18;
        lineHeight = 1.5;
    } else if (count <= 8) {
        // 5-8 columns: Gentle reduction
        const factor = (count - 4) * 0.5;
        labelSize = Math.max(14, 20 - factor);
        textSize = Math.max(12, 18 - factor);
        headerSize = Math.max(16, 22 - factor);
        lineHeight = 1.4;
    } else if (count <= 12) {
        // 9-12 columns: Compact territory
        const factor = (count - 8) * 0.5;
        labelSize = Math.max(12, 14 - factor);
        textSize = Math.max(11, 12 - factor);
        headerSize = Math.max(14, 16 - factor);
        lineHeight = 1.3;
    } else {
        // 13-20 columns: Dense for power users
        const factor = (count - 12) * 0.25;
        labelSize = Math.max(10, 12 - factor);
        textSize = Math.max(10, 11 - factor);
        headerSize = Math.max(12, 14 - factor);
        lineHeight = 1.2;
    }

    return {
        columnCount: count,
        commandLabelSize: labelSize,
        commandTextSize: textSize,
        categoryHeaderSize: headerSize,
        lineHeight,
        minReadableSize: 10
    };
}
```

**Side Effects**: None (pure function)

**Error Handling**: No errors thrown (defensive programming)

**Performance**:
- O(1) complexity
- Executes in < 1ms
- No external dependencies

**Example Usage**:
```javascript
const fonts = layoutCalculateFontSizes(15);
console.log(`Label: ${fonts.commandLabelSize}px, Text: ${fonts.commandTextSize}px`);
```

**Prohibited Patterns**:
```javascript
// ❌ WRONG: layoutCalculateFontSizes MUST NOT manipulate DOM
function layoutCalculateFontSizes(columnCount) {
    const fonts = { /* ... */ };
    document.querySelectorAll('.command-label').forEach(el => {
        el.style.fontSize = fonts.commandLabelSize + 'px'; // ❌ WRONG
    });
    return fonts;
}
```

---

## Presentation Layer Contracts

### renderCommandGrid

**Layer Assignment**: Presentation Layer

**Purpose**: Render command library with multi-column layout and optimized font sizes

**Signature**:
```javascript
function renderCommandGrid(commands: Array = commands): void
```

**Input Contract**:
```javascript
commands: Array<Command>  // Optional, defaults to global commands variable

Command = {
    id: string,
    label: string,
    text: string,
    category: string
}
```

**Input Validation**:
- `commands` must be array (can be empty)
- If not provided, uses global `commands` variable

**Output Contract**:
```javascript
Returns: void (no return value)
```

**Side Effects**:
- Updates DOM element `#command-list` with new HTML
- Calls `columnLoadPreference()` to get column count
- Calls `layoutCalculateGrid()` to get layout parameters
- Calls `layoutCalculateFontSizes()` to get font parameters
- Applies CSS Grid styles via inline styles and CSS custom properties
- Applies font sizes to command elements

**Business Logic Flow**:
```javascript
1. Get DOM container #command-list
2. Load column preference via columnLoadPreference()
3. Calculate layout via layoutCalculateGrid(columnCount)
4. Calculate fonts via layoutCalculateFontSizes(columnCount)
5. If empty commands, show empty state
6. Group commands by category
7. For each category:
   - Render category header with calculated headerSize
   - Render command items with calculated labelSize and textSize
8. Apply CSS Grid template to container
9. Set innerHTML to update DOM
```

**HTML Output Structure**:
```html
<div id="command-list" style="
    display: grid;
    grid-template-columns: repeat(10, minmax(0, 1fr));
    gap: 1rem;
">
    <div class="command-category">
        <div class="command-category-header" style="font-size: 14px;">
            Git
        </div>
        <div class="command-item" style="padding: 0.5rem;">
            <div class="command-info">
                <div class="command-label" style="font-size: 12px;">Clone repo</div>
                <div class="command-text" style="font-size: 11px; line-height: 1.3;">
                    git clone ...
                </div>
            </div>
            <div class="command-actions">...</div>
        </div>
    </div>
</div>
```

**CSS Classes Applied**:
- `.command-category`: Category group container
- `.command-category-header`: Category header with dynamic font size
- `.command-item`: Individual command card
- `.command-label`: Command label with dynamic font size
- `.command-text`: Command text with dynamic font size and line-height

**CSS Techniques Used**:
```css
/* Text overflow handling */
.command-label,
.command-text {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    min-width: 0; /* Critical for grid children */
}

/* Smooth transitions */
#command-list {
    transition: grid-template-columns 0.3s ease;
}

.command-label,
.command-text {
    transition: font-size 0.3s ease;
}
```

**Performance**:
- Target: < 50ms for 100 commands
- Uses string concatenation for HTML building
- Single DOM write (innerHTML) to minimize reflows
- CSS Grid handles layout calculation (no JavaScript layout computation)

**Error Handling**:
- Returns early if container not found
- Gracefully handles missing category (uses "Uncategorized")
- Handles empty commands array (shows empty state)

**Example Usage**:
```javascript
// Render all commands with current column preference
renderCommandGrid();

// Render filtered commands
const gitCommands = commands.filter(c => c.category === 'Git');
renderCommandGrid(gitCommands);
```

**Integration with Other Layers**:
```javascript
function renderCommandGrid(commandsToRender = commands) {
    const container = document.getElementById('command-list');
    if (!container) return;

    // DATA ACCESS LAYER: Load preference
    const columnCount = columnLoadPreference();

    // BUSINESS LOGIC LAYER: Calculate layout
    const layout = layoutCalculateGrid(columnCount);
    const fonts = layoutCalculateFontSizes(columnCount);

    // PRESENTATION LAYER: Apply styles and render
    container.style.gridTemplateColumns = layout.gridTemplateColumns;
    container.style.gap = layout.gap;

    // Build HTML with calculated font sizes
    let html = '';
    // ... (build HTML using fonts.commandLabelSize, fonts.commandTextSize, etc.)

    container.innerHTML = html;
}
```

**Prohibited Patterns**:
```javascript
// ❌ WRONG: renderCommandGrid MUST NOT directly access localStorage
function renderCommandGrid(commands) {
    const columnCount = parseInt(localStorage.getItem('speckit_column_count'), 10); // ❌ WRONG
    // Should use: columnLoadPreference()
}

// ❌ WRONG: renderCommandGrid MUST NOT contain business logic calculations
function renderCommandGrid(commands) {
    const columnCount = columnLoadPreference();

    // ❌ WRONG: Business logic should be in layoutCalculateFontSizes()
    let fontSize;
    if (columnCount <= 4) {
        fontSize = 16;
    } else if (columnCount <= 8) {
        fontSize = Math.max(14, 20 - (columnCount - 4) * 0.5);
    }
    // ...
}
```

---

### renderColumnSelector

**Layer Assignment**: Presentation Layer

**Purpose**: Render UI control for selecting column count (1-20) with live preview

**Signature**:
```javascript
function renderColumnSelector(): void
```

**Input Contract**: None (no parameters)

**Output Contract**:
```javascript
Returns: void (no return value)
```

**Side Effects**:
- Updates DOM element `#column-selector-container` with HTML
- Calls `columnLoadPreference()` to get current preference
- Binds event handlers for user interaction

**HTML Output Structure**:
```html
<div id="column-selector-container">
    <label for="column-count-input">列数 (Columns):</label>
    <input type="range"
           id="column-count-input"
           min="1"
           max="20"
           value="4"
           oninput="handleColumnCountChange(this.value)">
    <span id="column-count-display">4</span>
    <button onclick="handleColumnCountSet(1)">1</button>
    <button onclick="handleColumnCountSet(4)">4</button>
    <button onclick="handleColumnCountSet(8)">8</button>
    <button onclick="handleColumnCountSet(12)">12</button>
    <button onclick="handleColumnCountSet(20)">20</button>
</div>
```

**User Interactions**:
1. **Slider input**: Live preview, no save until release
2. **Preset buttons**: Immediate save and re-render
3. **Keyboard shortcuts**: Ctrl/Cmd + Plus/Minus (optional)

**Example Usage**:
```javascript
// On page load or tab switch to Commands
renderColumnSelector();
```

**Event Handlers**:
```javascript
// Live preview (no save)
function handleColumnCountChange(value) {
    const count = parseInt(value, 10);
    document.getElementById('column-count-display').textContent = count;

    // Live preview without saving
    const layout = layoutCalculateGrid(count);
    document.getElementById('command-list').style.gridTemplateColumns = layout.gridTemplateColumns;
}

// Save and persist
function handleColumnCountSet(count) {
    columnSavePreference(count);
    renderCommandGrid(); // Re-render with new layout
}
```

---

## Cross-Module Integration

### Typical Call Flow

```javascript
// User switches to Commands tab or page loads
switchTab('commands') → {

    // 1. PRESENTATION LAYER: Render column selector
    renderColumnSelector() → {
        // DATA ACCESS LAYER: Get current preference
        const currentCount = columnLoadPreference();
        // Render UI with current value
    }

    // 2. PRESENTATION LAYER: Render command grid
    renderCommandGrid(commands) → {

        // DATA ACCESS LAYER: Load preference
        const columnCount = columnLoadPreference() → {
            // Read from localStorage: 'speckit_column_count'
            // Return validated integer 1-20, or default 4
        };

        // BUSINESS LOGIC LAYER: Calculate grid layout
        const layout = layoutCalculateGrid(columnCount) → {
            // Pure calculation: gridTemplateColumns, fontSize, gap, padding
            // No side effects, returns layout object
        };

        // BUSINESS LOGIC LAYER: Calculate font sizes
        const fonts = layoutCalculateFontSizes(columnCount) → {
            // Pure calculation: labelSize, textSize, headerSize
            // No side effects, returns fonts object
        };

        // PRESENTATION LAYER: Apply styles and update DOM
        container.style.gridTemplateColumns = layout.gridTemplateColumns;
        container.style.gap = layout.gap;
        // Build HTML with fonts.commandLabelSize, fonts.commandTextSize, etc.
        container.innerHTML = htmlBuilder;
    }
}

// User changes column count
handleColumnCountSet(newCount) → {

    // DATA ACCESS LAYER: Save preference
    columnSavePreference(newCount) → {
        // Validate and clamp to 1-20
        // Write to localStorage: 'speckit_column_count'
    };

    // PRESENTATION LAYER: Re-render with new layout
    renderCommandGrid() → {
        // ... (same flow as above, but with new columnCount)
    }
}
```

---

## Testing Contracts

### Unit Test Requirements

Each function MUST have tests covering:

1. **Happy path**: Valid inputs, expected outputs
2. **Edge cases**: Boundary values (1, 20), extreme inputs
3. **Error handling**: Invalid inputs, storage failures
4. **Side effects**: Verify localStorage writes, DOM updates
5. **Performance**: Verify execution time meets targets
6. **Layer isolation**: Verify no cross-layer violations

### Example Test Cases

**columnLoadPreference**:
```javascript
- Test: First visit returns default (4)
- Test: Valid stored value (10) returns 10
- Test: Invalid value ("abc") returns default (4)
- Test: Out of range (25) returns default (4)
- Test: localStorage unavailable returns default (4)
```

**columnSavePreference**:
```javascript
- Test: Valid value (8) saves successfully → returns true
- Test: Out of range (25) clamps to 20 → saves 20
- Test: Invalid type ("abc") returns false
- Test: localStorage quota exceeded returns false
```

**layoutCalculateGrid**:
```javascript
- Test: columnCount=1 returns correct layout
- Test: columnCount=4 returns fontSize=16, lineHeight=1.5
- Test: columnCount=12 returns fontSize=12, lineHeight=1.3
- Test: columnCount=20 returns fontSize=10, lineHeight=1.2
- Test: Execution time < 1ms
- Test: gridTemplateColumns format correct for all inputs
```

**layoutCalculateFontSizes**:
```javascript
- Test: columnCount=4 returns labelSize=16, textSize=14
- Test: columnCount=12 returns labelSize=12, textSize=11
- Test: columnCount=20 returns labelSize=10, textSize=10
- Test: All sizes >= minReadableSize (10px)
- Test: Size relationships: headerSize > labelSize > textSize
```

**renderCommandGrid**:
```javascript
- Test: Empty commands shows empty state
- Test: Categories grouped correctly
- Test: CSS Grid styles applied to container
- Test: Font sizes applied to elements
- Test: Performance < 50ms for 100 commands
- Test: Calls columnLoadPreference() exactly once
- Test: Calls layoutCalculateGrid() exactly once
- Test: Does NOT directly access localStorage
```

### Layer Violation Tests

```javascript
// Test: columnSavePreference does NOT manipulate DOM
test('columnSavePreference should not manipulate DOM', () => {
    const spy = jest.spyOn(document, 'getElementById');
    columnSavePreference(10);
    expect(spy).not.toHaveBeenCalled();
});

// Test: layoutCalculateGrid does NOT access localStorage
test('layoutCalculateGrid should not access localStorage', () => {
    const spy = jest.spyOn(localStorage, 'getItem');
    layoutCalculateGrid(10);
    expect(spy).not.toHaveBeenCalled();
});

// Test: renderCommandGrid does NOT directly access localStorage
test('renderCommandGrid should use columnLoadPreference', () => {
    const spy = jest.spyOn(localStorage, 'getItem');
    const columnSpy = jest.spyOn(window, 'columnLoadPreference');
    renderCommandGrid();
    expect(spy).not.toHaveBeenCalled(); // Direct access forbidden
    expect(columnSpy).toHaveBeenCalled(); // Should use abstraction
});
```

---

## Module Naming Conventions (Constitution Principle VI)

This feature follows strict naming conventions to enforce modularity:

**Data Access Layer**:
- Prefix: `column*`
- Examples: `columnLoadPreference()`, `columnSavePreference()`
- Purpose: Manage column preference persistence only

**Business Logic Layer**:
- Prefix: `layout*`
- Examples: `layoutCalculateGrid()`, `layoutCalculateFontSizes()`
- Purpose: Pure calculations for layout parameters

**Presentation Layer**:
- Prefix: `render*`
- Examples: `renderCommandGrid()`, `renderColumnSelector()`
- Purpose: DOM manipulation and UI updates

**Event Handlers** (Bridge Layer):
- Prefix: `handle*`
- Examples: `handleColumnCountChange()`, `handleColumnCountSet()`
- Purpose: Connect user actions to appropriate layers

---

## Versioning

**Version**: 1.0.0
**Stability**: Stable (ready for implementation)
**Breaking Changes**: None (purely additive to existing codebase)
**Dependencies**: Feature 006 (uses existing category color system)
