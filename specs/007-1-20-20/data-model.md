# Data Model: Command Library Multi-Column Layout

**Feature**: 007-1-20-20 Command Library Multi-Column Layout
**Date**: 2025-10-17
**Purpose**: Define data structures for column preferences and layout calculations

## Entity Definitions

### 1. ColumnPreference

**Description**: Represents the user's persistent preference for the number of columns to display in the command library (1-20 columns).

**Attributes**:
```javascript
{
    columnCount: number,       // Integer 1-20, user's selected column count
    savedAt: number            // Timestamp of last save (Date.now())
}
```

**Storage Location**: LocalStorage key `speckit_column_count`

**Storage Format**:
```javascript
// Stored as simple integer string (not JSON object)
localStorage.setItem('speckit_column_count', '4');

// Retrieved and parsed as integer
const columnCount = parseInt(localStorage.getItem('speckit_column_count'), 10);
```

**Default Value**: 4 columns

**Justification for Default**:
- Provides reasonable balance between density and readability
- Works well on common screen sizes (1920x1080, 1440x900)
- Font size remains at maximum 16px for optimal readability
- Matches common UI patterns (4-column grids are ubiquitous)

**Validation Rules**:
- `columnCount` must be integer between 1 and 20 (inclusive)
- Invalid values (NaN, null, undefined, out of range) reset to default (4)
- Non-integer values are floored to nearest integer
- Storage write failures fall back gracefully to in-memory preference

**State Transitions**:
```
[First Visit] → No preference exists → Use default (4) → [Default Active]
                                          ↓
                                    User changes column count
                                          ↓
                              [New Preference] → Save to localStorage → [Preference Persisted]
                                          ↓
                                    Page reload
                                          ↓
                              Load from localStorage → [Preference Restored]
```

**Edge Cases**:
1. **localStorage unavailable** (private browsing): Use in-memory default, no persistence
2. **Corrupted data**: Parse fails → Reset to default → Overwrite with valid value
3. **Out of range value** (< 1 or > 20): Clamp to nearest valid value → Save corrected value
4. **Invalid type** (string "abc"): Validation fails → Reset to default

---

### 2. ColumnLayout

**Description**: Represents calculated layout parameters for rendering the command grid based on selected column count.

**Attributes**:
```javascript
{
    columnCount: number,           // Selected column count (1-20)
    gridTemplateColumns: string,   // CSS Grid template value
    fontSize: number,              // Calculated font size (px)
    minFontSize: number,           // Minimum allowed font size (10px)
    lineHeight: number,            // Line height multiplier
    itemPadding: string,           // CSS padding value
    gap: string                    // CSS gap between columns
}
```

**Storage Location**: Calculated at runtime (not persisted)

**Calculation Logic**:
```javascript
function layoutCalculateGrid(columnCount) {
    // CSS Grid template using repeat() and minmax()
    const gridTemplateColumns = `repeat(${columnCount}, minmax(0, 1fr))`;

    // Calculate font size based on column count (segmented scaling)
    let fontSize;
    if (columnCount <= 4) {
        fontSize = 16; // Constant for 1-4 columns
    } else if (columnCount <= 8) {
        fontSize = Math.max(14, 20 - (columnCount - 4) * 0.5);
    } else if (columnCount <= 12) {
        fontSize = Math.max(12, 14 - (columnCount - 8) * 0.5);
    } else {
        fontSize = Math.max(10, 12 - (columnCount - 12) * 0.25);
    }

    // Calculate responsive parameters
    const lineHeight = columnCount <= 4 ? 1.5 : (columnCount <= 12 ? 1.3 : 1.2);
    const itemPadding = fontSize >= 14 ? '0.75rem' : '0.5rem';

    return {
        columnCount,
        gridTemplateColumns,
        fontSize,
        minFontSize: 10,
        lineHeight,
        itemPadding,
        gap: '1rem'
    };
}
```

**Font Scaling Ranges** (from research.md):
- **1-4 columns**: 16px (constant) - Maximum readability
- **5-8 columns**: 14-16px (scaled) - Gentle reduction
- **9-12 columns**: 12-14px (scaled) - Compact territory
- **13-20 columns**: 10-12px (scaled) - Dense for power users

**Validation Rules**:
- `fontSize` must never fall below 10px (accessibility minimum)
- `lineHeight` must be ≥ 1.2 (readability minimum)
- `columnCount` input must be validated (1-20 range)
- All size values must be positive numbers

**Relationships**:
- Derived from ColumnPreference.columnCount (input)
- Applied to command grid rendering (output)
- Used by renderCommandGrid() to apply CSS styles

**Performance Characteristics**:
- O(1) complexity (simple arithmetic and conditionals)
- Executes in < 1ms
- No DOM operations (pure calculation)
- No external dependencies

---

### 3. FontSizeParameters

**Description**: Represents the detailed font size calculations for different column count ranges, supporting responsive text scaling.

**Attributes**:
```javascript
{
    columnCount: number,           // Input column count (1-20)
    commandLabelSize: number,      // Font size for command labels (px)
    commandTextSize: number,       // Font size for command text (px)
    categoryHeaderSize: number,    // Font size for category headers (px)
    lineHeight: number,            // Line height multiplier (unitless)
    minReadableSize: number        // Minimum font size enforced (10px)
}
```

**Storage Location**: Calculated at runtime by layoutCalculateFontSizes()

**Calculation Logic**:
```javascript
function layoutCalculateFontSizes(columnCount) {
    let labelSize, textSize, headerSize, lineHeight;

    if (columnCount <= 4) {
        labelSize = 16;
        textSize = 14;
        headerSize = 18;
        lineHeight = 1.5;
    } else if (columnCount <= 8) {
        const factor = (columnCount - 4) * 0.5;
        labelSize = Math.max(14, 20 - factor);
        textSize = Math.max(12, 18 - factor);
        headerSize = Math.max(16, 22 - factor);
        lineHeight = 1.4;
    } else if (columnCount <= 12) {
        const factor = (columnCount - 8) * 0.5;
        labelSize = Math.max(12, 14 - factor);
        textSize = Math.max(11, 12 - factor);
        headerSize = Math.max(14, 16 - factor);
        lineHeight = 1.3;
    } else {
        const factor = (columnCount - 12) * 0.25;
        labelSize = Math.max(10, 12 - factor);
        textSize = Math.max(10, 11 - factor);
        headerSize = Math.max(12, 14 - factor);
        lineHeight = 1.2;
    }

    return {
        columnCount,
        commandLabelSize: labelSize,
        commandTextSize: textSize,
        categoryHeaderSize: headerSize,
        lineHeight,
        minReadableSize: 10
    };
}
```

**WCAG Accessibility Considerations**:
- Minimum 10px font size justified for UI labels (not body text)
- Users can zoom browser up to 200% (WCAG 2.1 compliance)
- Command library items are short identifiers, not sustained reading text
- Industry precedent: macOS system UI uses 10px for secondary labels

**Validation Rules**:
- All font sizes must be ≥ 10px (minReadableSize)
- `lineHeight` must be ≥ 1.2
- Size relationships: `headerSize > labelSize > textSize`
- All values must be positive numbers

**Relationships**:
- Derived from ColumnPreference.columnCount
- Used by renderCommandGrid() to apply font styles
- Coordinated with ColumnLayout for cohesive styling

---

### 4. Command (Existing - Reference)

**Description**: Existing entity representing a saved command in the library. No schema changes required for this feature.

**Relevant Attributes** (for this feature):
```javascript
{
    id: string,                // Unique identifier
    label: string,             // Command name/label
    text: string,              // Command text content
    category: string           // Category name (used for grouping)
}
```

**Modifications**: None required - existing structure supports multi-column layout.

**Relationship to New Entities**:
- Commands are rendered within the grid defined by ColumnLayout
- Font sizes from FontSizeParameters applied to command text
- Layout adapts to any columnCount without data structure changes

**Text Overflow Handling**:
- Use CSS `text-overflow: ellipsis` for truncation
- `white-space: nowrap` prevents wrapping
- `overflow: hidden` prevents horizontal scroll
- Native `title` attribute provides full text on hover

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│          User Opens Command Library or Changes Column Count │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  columnLoadPreference() → Retrieve from localStorage         │
│    Key: 'speckit_column_count'                               │
│    Return: integer 1-20, or default 4 if not found          │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  Validate column count (1-20 range)                          │
│    If invalid: Use default (4)                               │
│    If valid: Proceed with user preference                    │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  layoutCalculateGrid(columnCount)                            │
│    → Calculate ColumnLayout parameters                       │
│    → gridTemplateColumns, fontSize, gap, padding             │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  layoutCalculateFontSizes(columnCount)                       │
│    → Calculate FontSizeParameters                            │
│    → labelSize, textSize, headerSize, lineHeight             │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  renderCommandGrid(commands, layout, fonts)                  │
│    → Apply CSS Grid styles to container                      │
│    → Apply font sizes to command elements                    │
│    → Update DOM with new layout                              │
└─────────────────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  User changes column count via selector                      │
│    → columnSavePreference(newCount)                          │
│    → Save to localStorage: 'speckit_column_count'            │
│    → Re-trigger layout calculation and rendering             │
└─────────────────────────────────────────────────────────────┘
```

---

## Storage Size Analysis

### LocalStorage Usage

**Existing Data**:
- Commands: ~50 commands × 200 bytes avg = 10KB
- Projects: Variable size
- Category colors (Feature 006): ~2KB

**New Data (This Feature)**:
- ColumnPreference: 1 integer × 2 bytes = 2 bytes
- Total: "4" (single character for typical values)

**Total Impact**: +2 bytes (negligible, well within 5MB limit)

**Storage Key Structure**:
```javascript
localStorage {
    'speckit_commands': '[{"id":"cmd_1",...}]',
    'speckit_category_colors': '{...}',
    'speckit_column_count': '4',              // NEW: This feature
    'speckit_projects': '[...]'
}
```

---

## Constraints and Invariants

### Data Integrity Constraints

1. **Column Count Range**: columnCount MUST be integer between 1 and 20 (inclusive)
   ```javascript
   const MIN_COLUMNS = 1;
   const MAX_COLUMNS = 20;
   const clamped = Math.max(MIN_COLUMNS, Math.min(MAX_COLUMNS, Math.floor(count)));
   ```

2. **Font Size Minimum**: All font sizes MUST be ≥ 10px (accessibility)
   ```javascript
   fontSize = Math.max(10, calculatedSize);
   ```

3. **Preference Persistence**: User preference MUST persist across sessions
   - Enforced by: localStorage save on every change
   - Fallback: In-memory preference if localStorage unavailable

4. **Grid Template Validity**: CSS Grid template MUST be valid for all column counts
   - Enforced by: Template string format `repeat(${count}, minmax(0, 1fr))`
   - Validation: count is always integer 1-20

5. **Layout Integrity**: Grid MUST never cause horizontal overflow
   - Enforced by: `minmax(0, 1fr)` prevents columns from exceeding container
   - CSS: `width: 100%` on container

### Performance Constraints

1. **Calculation Time**: layoutCalculateGrid() and layoutCalculateFontSizes() MUST complete in < 1ms
   - Monitored via: performance.now() timing in tests
   - Enforced by: Simple arithmetic operations only

2. **Render Time**: renderCommandGrid() MUST complete in < 50ms for 100 commands
   - Monitored via: performance.now() timing in tests
   - Enforced by: Single DOM write (innerHTML), CSS Grid handles layout

3. **Transition Smoothness**: Column count changes MUST animate smoothly (60fps)
   - Enforced by: CSS transitions on grid-template-columns
   - Duration: 0.3s ease

4. **Storage Write**: columnSavePreference() MUST complete in < 10ms
   - Enforced by: Synchronous localStorage API, minimal data size

### Accessibility Constraints

1. **Minimum Font Size**: Text MUST be ≥ 10px for readability
   - Enforced by: Math.max(10, calculatedSize) in all font calculations
   - Rationale: UI labels (not body text) + browser zoom support

2. **Line Height**: lineHeight MUST be ≥ 1.2 for readability
   - Enforced by: Conditional logic in layoutCalculateFontSizes()
   - WCAG guideline: Adequate spacing between lines

3. **Contrast Ratio**: Colors MUST maintain contrast at all font sizes
   - Enforced by: Reusing COLOR_PALETTE from Feature 006 (WCAG-compliant)
   - No changes to color system in this feature

4. **Keyboard Navigation**: Focus states MUST remain visible at all column counts
   - Enforced by: CSS focus styles applied regardless of grid layout
   - Testing: Manual keyboard navigation tests

---

## Migration Strategy

**No Migration Required**:
- ColumnPreference is new data (no existing data to migrate)
- Existing Command entities require no schema changes
- Feature is purely additive (no breaking changes)

**Backwards Compatibility**:
- If `speckit_column_count` key doesn't exist, use default (4)
- First load with default, user can change immediately
- Existing features (search, colors, drag-drop) continue to work

**Rollback Safety**:
- Removing this feature: Simply don't read `speckit_column_count` key
- Commands render in default single-column layout (original functionality)
- No data corruption risk - preference is independent of command data

**Version Compatibility**:
- Old versions (pre-007): Ignore `speckit_column_count` key (harmless)
- New version (007+): Read preference and apply layout
- No version migration logic required

---

## Testing Data Requirements

### Test Data Sets

**Test Set 1: Column Count Validation**
```javascript
const validCounts = [1, 4, 10, 15, 20];
const invalidCounts = [0, -5, 21, 100, NaN, null, undefined, "abc", 3.7];
const edgeCases = [1, 20]; // Minimum and maximum
```

**Test Set 2: Font Size Validation**
```javascript
// Expected font sizes for different column counts
const fontSizeExpectations = {
    1: { label: 16, text: 14, header: 18 },
    4: { label: 16, text: 14, header: 18 },
    8: { label: 14, text: 12, header: 16 },
    12: { label: 12, text: 11, header: 14 },
    20: { label: 10, text: 10, header: 12 }
};
```

**Test Set 3: Layout Integrity**
```javascript
// Test various screen widths with different column counts
const layoutTests = [
    { screenWidth: 375, columnCount: 20, shouldWrap: false },
    { screenWidth: 1920, columnCount: 20, shouldWrap: false },
    { screenWidth: 768, columnCount: 10, shouldWrap: false }
];
```

**Test Set 4: localStorage Scenarios**
```javascript
// Persistence tests
const storageScenarios = [
    { initial: 4, changed: 10, expected: 10 },
    { initial: null, changed: 15, expected: 15 },
    { initial: "invalid", changed: 8, expected: 8 }
];
```

---

## Glossary

**Column Count**: The number of vertical columns in which commands are displayed (1-20)

**Column Preference**: The user's saved choice of column count, persisted in localStorage

**Column Layout**: Calculated CSS Grid parameters for rendering the multi-column grid

**Font Scaling**: Automatic reduction of font sizes as column count increases to maintain readability

**Segmented Scaling**: Non-linear font scaling approach with different formulas for different column ranges

**Grid Template**: CSS Grid property defining column structure (`repeat(N, minmax(0, 1fr))`)

**Viewport Width**: Browser window width, used for responsive layout calculations

**Minimum Readable Size**: The smallest font size allowed (10px) to ensure accessibility
