# Function Interface Contracts: Command Library Visual Enhancement

**Feature**: 006- Command Library Visual Enhancement
**Date**: 2025-10-17
**Purpose**: Define function signatures and contracts for all modules

## Data Access Layer Contracts

### colorSaveMappings

**Purpose**: Persist category-to-color mappings to LocalStorage

**Signature**:
```javascript
function colorSaveMappings(mappings: Object): boolean
```

**Input Contract**:
```javascript
mappings: {
    [categoryName: string]: {
        color: string,          // Hex color "#RRGGBB"
        assignedAt: number,     // Timestamp (Date.now())
        paletteIndex: number    // 0-14
    }
}
```

**Input Validation**:
- `mappings` must be a plain object (not null, not array)
- Each key must be non-empty string
- Each value must have `color`, `assignedAt`, `paletteIndex` properties
- `color` must match `/^#[0-9a-f]{6}$/i`
- `paletteIndex` must be integer 0-14

**Output Contract**:
```javascript
Returns: boolean
- true: Mappings successfully saved to localStorage
- false: Save failed (localStorage unavailable, quota exceeded, invalid input)
```

**Side Effects**:
- Writes to `localStorage` key: `'speckit_category_colors'`
- Overwrites previous mappings (full replacement, not merge)

**Error Handling**:
- Returns `false` on any error (does not throw)
- Logs error to console for debugging

**Example Usage**:
```javascript
const mappings = {
    "git": { color: "#2563eb", assignedAt: 1697500000000, paletteIndex: 0 },
    "docker": { color: "#10b981", assignedAt: 1697500001000, paletteIndex: 1 }
};
const success = colorSaveMappings(mappings);
if (!success) {
    console.error("Failed to save category color mappings");
}
```

---

### colorLoadMappings

**Purpose**: Retrieve category-to-color mappings from LocalStorage

**Signature**:
```javascript
function colorLoadMappings(): Object
```

**Input Contract**: None (no parameters)

**Output Contract**:
```javascript
Returns: Object
- Success: { [categoryName: string]: ColorMapping }
- No data: {} (empty object)
- Error: {} (empty object, fallback)
```

**Output Structure**:
```javascript
{
    "git": { color: "#2563eb", assignedAt: 1697500000000, paletteIndex: 0 },
    "docker": { color: "#10b981", assignedAt: 1697500001000, paletteIndex: 1 }
}
```

**Side Effects**:
- Reads from `localStorage` key: `'speckit_category_colors'`
- No mutations

**Error Handling**:
- Returns `{}` if localStorage unavailable
- Returns `{}` if key doesn't exist
- Returns `{}` if JSON parse fails
- Logs errors to console

**Example Usage**:
```javascript
const mappings = colorLoadMappings();
console.log(Object.keys(mappings).length + " categories have assigned colors");
```

---

## Business Logic Layer Contracts

### colorAssignCategory

**Purpose**: Get existing color for a category or assign a new one from the palette

**Signature**:
```javascript
function colorAssignCategory(categoryName: string): ColorAssignment
```

**Input Contract**:
```javascript
categoryName: string  // Non-empty category name (will be normalized)
```

**Input Validation**:
- `categoryName` must be non-empty string after trimming
- Normalized to lowercase and trimmed internally

**Output Contract**:
```javascript
Returns: ColorAssignment {
    color: string,       // Hex color code
    isNew: boolean,      // true if newly assigned, false if existing
    paletteIndex: number // Index in COLOR_PALETTE (0-14)
}
```

**Business Logic**:
1. Normalize category name: `const key = categoryName.toLowerCase().trim()`
2. Load existing mappings via `colorLoadMappings()`
3. If mapping exists for `key`: return existing color with `isNew: false`
4. If mapping doesn't exist:
   - Count existing mappings to determine next palette index
   - Assign color using rotation: `index = existingCount % PALETTE_LENGTH`
   - Create new mapping entry
   - Save updated mappings via `colorSaveMappings()`
   - Return new color with `isNew: true`

**Side Effects**:
- MAY write to localStorage (if new category)
- Updates in-memory color mapping cache

**Error Handling**:
- If save fails, still returns assigned color (may not persist)
- Logs warning if persistence fails

**Example Usage**:
```javascript
const assignment = colorAssignCategory("Git");
console.log(`Git uses ${assignment.color} (${assignment.isNew ? 'new' : 'existing'})`);
// Output: "Git uses #2563eb (new)" on first call
// Output: "Git uses #2563eb (existing)" on subsequent calls
```

**Invariants**:
- Same category name always returns same color (deterministic)
- Color assignment is stable across sessions (persisted)

---

### colorGetPalette

**Purpose**: Retrieve the full color palette with accessibility metadata

**Signature**:
```javascript
function colorGetPalette(): Array<ColorInfo>
```

**Input Contract**: None (no parameters)

**Output Contract**:
```javascript
Returns: Array<ColorInfo>

ColorInfo = {
    index: number,           // 0-14
    color: string,           // Hex code
    name: string,            // Human-readable name
    contrastRatio: number    // WCAG contrast ratio vs white
}
```

**Output Example**:
```javascript
[
    { index: 0, color: '#2563eb', name: 'Blue', contrastRatio: 7.0 },
    { index: 1, color: '#10b981', name: 'Green', contrastRatio: 5.8 },
    // ... 13 more colors
]
```

**Business Logic**:
- Returns immutable COLOR_PALETTE constant
- No computation required (direct return)

**Side Effects**: None (pure function, read-only)

**Error Handling**: None (cannot fail)

**Example Usage**:
```javascript
const palette = colorGetPalette();
const wcagCompliant = palette.filter(c => c.contrastRatio >= 4.5);
console.log(`${wcagCompliant.length} colors meet WCAG AA`);
// Output: "15 colors meet WCAG AA"
```

---

### layoutCalculateDensity

**Purpose**: Calculate optimal layout parameters for information density

**Signature**:
```javascript
function layoutCalculateDensity(viewportHeight: number, commandCount: number): LayoutParams
```

**Input Contract**:
```javascript
viewportHeight: number  // Viewport height in pixels (e.g., 900)
commandCount: number    // Number of commands to display (e.g., 50)
```

**Input Validation**:
- Both parameters must be positive numbers
- `viewportHeight` typically 400-2000px
- `commandCount` typically 0-500

**Output Contract**:
```javascript
Returns: LayoutParams {
    itemHeight: number,        // Total height per item (px)
    itemPadding: number,       // Inner padding (px)
    itemMargin: number,        // Margin between items (px)
    labelFontSize: number,     // Label font size (px)
    textFontSize: number,      // Text font size (px)
    lineHeight: number,        // Line height multiplier
    itemsPerView: number       // Estimated visible items
}
```

**Output Example**:
```javascript
{
    itemHeight: 59,
    itemPadding: 12,
    itemMargin: 10,
    labelFontSize: 14.4,
    textFontSize: 12.8,
    lineHeight: 1.3,
    itemsPerView: 10
}
```

**Business Logic**:
```javascript
const baseParams = { itemPadding: 12, itemMargin: 10, labelFontSize: 14.4, textFontSize: 12.8, lineHeight: 1.3 };
const itemHeight = (baseParams.itemPadding * 2) +
                   (baseParams.labelFontSize * baseParams.lineHeight) +
                   (baseParams.textFontSize * baseParams.lineHeight) +
                   baseParams.itemMargin;
const itemsPerView = Math.floor(viewportHeight / itemHeight);
return { ...baseParams, itemHeight, itemsPerView };
```

**Side Effects**: None (pure function)

**Error Handling**:
- Returns safe defaults if inputs are invalid
- Ensures minimum font sizes (14px label, 12px text)

**Example Usage**:
```javascript
const params = layoutCalculateDensity(900, 50);
console.log(`Can display ${params.itemsPerView} commands per screen`);
// Output: "Can display 10 commands per screen"
```

**Performance**:
- O(1) complexity (simple arithmetic)
- Executes in <1ms

---

### layoutGetResponsiveParams

**Purpose**: Get responsive layout parameters based on screen width

**Signature**:
```javascript
function layoutGetResponsiveParams(screenWidth: number): ResponsiveLayout
```

**Input Contract**:
```javascript
screenWidth: number  // Screen width in pixels (e.g., 1920, 768, 375)
```

**Input Validation**:
- `screenWidth` must be positive number
- Typically 320-2560px

**Output Contract**:
```javascript
Returns: ResponsiveLayout {
    breakpoint: string,      // "mobile" | "tablet" | "desktop"
    fontSize: string,        // CSS font-size value (rem)
    minFontPx: number,       // Minimum font size (px)
    padding: string          // CSS padding value (px)
}
```

**Output Example**:
```javascript
// For screenWidth = 375 (mobile)
{
    breakpoint: "mobile",
    fontSize: "0.85rem",
    minFontPx: 14,
    padding: "10px"
}

// For screenWidth = 1920 (desktop)
{
    breakpoint: "desktop",
    fontSize: "0.9rem",
    minFontPx: 14,
    padding: "12px"
}
```

**Business Logic**:
```javascript
if (screenWidth < 640) {
    return { breakpoint: "mobile", fontSize: "0.85rem", minFontPx: 14, padding: "10px" };
} else if (screenWidth < 1024) {
    return { breakpoint: "tablet", fontSize: "0.88rem", minFontPx: 14, padding: "11px" };
} else {
    return { breakpoint: "desktop", fontSize: "0.9rem", minFontPx: 14, padding: "12px" };
}
```

**Side Effects**: None (pure function)

**Error Handling**: Returns desktop defaults if input is invalid

**Example Usage**:
```javascript
const responsive = layoutGetResponsiveParams(window.innerWidth);
console.log(`Using ${responsive.breakpoint} layout`);
```

---

## Presentation Layer Contracts

### renderCommandLibrary (Modified)

**Purpose**: Render command library with color-coded categories and optimized layout

**Signature**:
```javascript
function renderCommandLibrary(commandsToRender: Array = commands): void
```

**Input Contract**:
```javascript
commandsToRender: Array<Command> = commands  // Optional, defaults to global commands

Command = {
    id: string,
    label: string,
    text: string,
    category: string  // Used for color assignment
}
```

**Input Validation**:
- `commandsToRender` must be array (can be empty)
- If not provided, uses global `commands` variable

**Output Contract**:
```javascript
Returns: void (no return value)
```

**Side Effects**:
- Updates DOM element `#command-list` with new HTML
- Calls `colorAssignCategory()` for each unique category
- Applies color styles via inline CSS
- Applies layout optimization CSS classes

**Business Logic Flow**:
1. Get DOM container `#command-list`
2. If empty commands, show empty state message
3. Group commands by category
4. For each category:
   - Call `colorAssignCategory(categoryName)` → get color
   - Render category header with background color
   - Render command items with color accent
5. Calculate layout params via `layoutCalculateDensity()`
6. Apply density optimizations to HTML
7. Set innerHTML to update DOM

**HTML Output Structure**:
```html
<div class="command-category" style="border-left: 4px solid #2563eb;">
    <div class="command-category-header" style="background: #2563eb22; color: #2563eb;">
        Git
    </div>
    <div class="command-item command-item-dense" ...>
        <div class="command-info">
            <div class="command-label command-label-dense">Clone repo</div>
            <div class="command-text command-text-dense">git clone ...</div>
        </div>
        <div class="command-actions">...</div>
    </div>
</div>
```

**CSS Classes Applied**:
- `.command-item-dense`: Optimized padding/margin
- `.command-label-dense`: Optimized font size
- `.command-text-dense`: Optimized font size and line-height

**Performance**:
- Target: <50ms for 100 commands
- Uses string concatenation for HTML building
- Single DOM write (innerHTML) to minimize reflows

**Error Handling**:
- Returns early if container not found
- Gracefully handles missing category (uses "Uncategorized")

**Example Usage**:
```javascript
// Render all commands
renderCommandLibrary();

// Render filtered commands
const gitCommands = commands.filter(c => c.category === 'Git');
renderCommandLibrary(gitCommands);
```

---

## Cross-Module Integration

### Typical Call Flow

```javascript
// User switches to Commands tab
switchTab('commands') → {

    // 1. Load commands from storage
    const allCommands = loadCommands();  // Existing function

    // 2. Render with enhancements
    renderCommandLibrary(allCommands) → {

        // 3. Get viewport dimensions
        const viewportHeight = window.innerHeight;

        // 4. Calculate layout
        const layoutParams = layoutCalculateDensity(viewportHeight, allCommands.length);

        // 5. For each unique category
        const categories = [...new Set(allCommands.map(c => c.category))];
        categories.forEach(cat => {

            // 6. Assign/get color
            const { color } = colorAssignCategory(cat) → {

                // 7. Load existing mappings
                const mappings = colorLoadMappings();

                // 8. Check if exists or assign new
                if (!mappings[cat.toLowerCase()]) {
                    const newMapping = { /* ... */ };

                    // 9. Save new mapping
                    colorSaveMappings({ ...mappings, [cat.toLowerCase()]: newMapping });
                }
            };

            // 10. Apply color to HTML
            htmlBuilder += `<div style="border-left: 4px solid ${color}">...`;
        });

        // 11. Update DOM
        container.innerHTML = htmlBuilder;
    }
}
```

---

## Testing Contracts

### Unit Test Requirements

Each function MUST have tests covering:

1. **Happy path**: Valid inputs, expected outputs
2. **Edge cases**: Empty inputs, boundary values, extreme inputs
3. **Error handling**: Invalid inputs, storage failures, null/undefined
4. **Side effects**: Verify localStorage writes, DOM updates
5. **Performance**: Verify execution time meets targets

### Example Test Cases

```javascript
// colorAssignCategory
- Test: New category gets color from palette
- Test: Same category returns same color (deterministic)
- Test: 16th category wraps around palette (modulo)
- Test: Persistence survives page reload

// layoutCalculateDensity
- Test: Returns 30% density increase vs baseline
- Test: Font sizes never go below 12px
- Test: itemsPerView calculation is correct

// renderCommandLibrary
- Test: Empty commands shows empty state
- Test: Categories are grouped correctly
- Test: Colors are applied to headers and items
- Test: Performance <50ms for 100 commands
```

---

## Versioning

**Version**: 1.0.0
**Stability**: Stable (ready for implementation)
**Breaking Changes**: None (purely additive to existing codebase)
