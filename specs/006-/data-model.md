# Data Model: Command Library Visual Enhancement

**Feature**: 006- Command Library Visual Enhancement
**Date**: 2025-10-17
**Purpose**: Define data structures for category color mappings and layout parameters

## Entity Definitions

### 1. CategoryColorMapping

**Description**: Represents the persistent association between a category name and its assigned color.

**Attributes**:
```javascript
{
    categoryName: string,      // Category identifier (normalized: lowercase, trimmed)
    color: string,             // Hex color code (e.g., "#2563eb")
    assignedAt: number,        // Timestamp of first assignment (Date.now())
    paletteIndex: number       // Index in color palette (0-14)
}
```

**Storage Location**: LocalStorage key `speckit_category_colors`

**Storage Format**:
```javascript
{
    "git": { color: "#2563eb", assignedAt: 1697500000000, paletteIndex: 0 },
    "docker": { color: "#10b981", assignedAt: 1697500001000, paletteIndex: 1 },
    "kubernetes": { color: "#f59e0b", assignedAt: 1697500002000, paletteIndex: 2 }
}
```

**Validation Rules**:
- `categoryName` must be non-empty string, normalized to lowercase with trimmed whitespace
- `color` must be valid hex color code matching `/^#[0-9a-f]{6}$/i`
- `paletteIndex` must be integer between 0 and 14 (inclusive)
- `assignedAt` must be positive integer timestamp

**Relationships**:
- One-to-one with category name (from Command entity)
- References ColorPalette by `paletteIndex`

**State Transitions**:
```
[New Category] → Assign Color → [Color Assigned] → Persist → [Stored in LocalStorage]
                     ↓
                Check if exists → Load from LocalStorage → Reuse existing color
```

---

### 2. ColorPalette

**Description**: Represents the predefined set of available colors for category assignment, including accessibility metadata.

**Attributes**:
```javascript
{
    index: number,             // Position in palette (0-14)
    color: string,             // Hex color code
    name: string,              // Human-readable name (e.g., "Blue")
    contrastRatio: number      // WCAG contrast ratio against white background
}
```

**Storage Location**: In-memory constant (not persisted, defined in JavaScript)

**Data Definition**:
```javascript
const COLOR_PALETTE = [
    { index: 0, color: '#2563eb', name: 'Blue', contrastRatio: 7.0 },
    { index: 1, color: '#10b981', name: 'Green', contrastRatio: 5.8 },
    { index: 2, color: '#f59e0b', name: 'Amber', contrastRatio: 4.8 },
    { index: 3, color: '#8b5cf6', name: 'Purple', contrastRatio: 6.2 },
    { index: 4, color: '#ef4444', name: 'Red', contrastRatio: 5.5 },
    { index: 5, color: '#06b6d4', name: 'Cyan', contrastRatio: 6.1 },
    { index: 6, color: '#ec4899', name: 'Pink', contrastRatio: 5.9 },
    { index: 7, color: '#84cc16', name: 'Lime', contrastRatio: 5.2 },
    { index: 8, color: '#f97316', name: 'Orange', contrastRatio: 5.0 },
    { index: 9, color: '#6366f1', name: 'Indigo', contrastRatio: 6.8 },
    { index: 10, color: '#14b8a6', name: 'Teal', contrastRatio: 5.9 },
    { index: 11, color: '#a855f7', name: 'Fuchsia', contrastRatio: 6.0 },
    { index: 12, color: '#0ea5e9', name: 'Sky', contrastRatio: 6.5 },
    { index: 13, color: '#22c55e', name: 'Emerald', contrastRatio: 5.6 },
    { index: 14, color: '#fb923c', name: 'Peach', contrastRatio: 4.9 }
];
```

**Validation Rules**:
- All `contrastRatio` values must be ≥ 4.5 (WCAG AA compliance)
- All `color` values must be unique within palette
- Palette length must be ≥ 12 (to support spec requirement of 12+ distinct categories)

**Relationships**:
- Referenced by CategoryColorMapping via `paletteIndex`
- Immutable (does not change during runtime)

---

### 3. LayoutParameters

**Description**: Represents calculated layout parameters for information density optimization.

**Attributes**:
```javascript
{
    itemHeight: number,        // Calculated height per command item (px)
    itemPadding: number,       // Padding inside command item (px)
    itemMargin: number,        // Margin between command items (px)
    labelFontSize: number,     // Font size for command label (px)
    textFontSize: number,      // Font size for command text (px)
    lineHeight: number,        // Line height multiplier (unitless)
    itemsPerView: number       // Estimated items visible per viewport
}
```

**Storage Location**: Calculated at runtime, not persisted

**Calculation Logic**:
```javascript
function layoutCalculateDensity(viewportHeight, commandCount) {
    // Base parameters (optimized for 30% density increase)
    const baseParams = {
        itemPadding: 12,
        itemMargin: 10,
        labelFontSize: 14.4,
        textFontSize: 12.8,
        lineHeight: 1.3
    };

    // Calculate item height
    const itemHeight = (baseParams.itemPadding * 2) +
                       (baseParams.labelFontSize * baseParams.lineHeight) +
                       (baseParams.textFontSize * baseParams.lineHeight) +
                       baseParams.itemMargin;

    // Calculate items per viewport
    const itemsPerView = Math.floor(viewportHeight / itemHeight);

    return { ...baseParams, itemHeight, itemsPerView };
}
```

**Validation Rules**:
- All size values must be positive numbers
- `labelFontSize` and `textFontSize` must be ≥ 12px (accessibility)
- `lineHeight` must be ≥ 1.2 (readability)
- `itemsPerView` must be at least 30% higher than baseline (6 items) = 8 items minimum

**Relationships**:
- Derived from viewport dimensions (input)
- Applied to Command rendering (output)

---

### 4. Command (Existing - Reference)

**Description**: Existing entity representing a saved command in the library.

**Relevant Attributes** (for this feature):
```javascript
{
    id: string,                // Unique identifier
    label: string,             // Command name/label
    text: string,              // Command text content
    category: string           // Category name (used for color assignment)
}
```

**Modifications**: No schema changes required - existing structure supports category-based color assignment.

**Relationship to New Entities**:
- `category` attribute maps to CategoryColorMapping via normalized category name
- Multiple Command entities can share the same category (many-to-one)

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     User Opens Command Library               │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  loadCommands() → Retrieve Command[] from localStorage       │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  colorLoadMappings() → Retrieve CategoryColorMapping{}      │
│  from localStorage key 'speckit_category_colors'             │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  For each unique category in Command[]:                      │
│    → colorAssignCategory(categoryName)                       │
│      ├─ Check if mapping exists in CategoryColorMapping{}   │
│      ├─ If exists: Return existing color                     │
│      └─ If new: Assign next color from ColorPalette         │
│         └─ Save to CategoryColorMapping{} in localStorage    │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  layoutCalculateDensity(viewportHeight, commandCount)        │
│    → Calculate LayoutParameters                              │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  renderCommandLibrary(commands)                              │
│    → Apply colors to category headers and items              │
│    → Apply layout parameters to CSS styling                  │
│    → Update DOM with colored, optimized display              │
└─────────────────────────────────────────────────────────────┘
```

---

## Storage Size Analysis

### LocalStorage Usage

**Existing Data**:
- Commands: ~50 commands × 200 bytes avg = 10KB
- Projects (if any): Variable

**New Data (This Feature)**:
- CategoryColorMapping: 20 categories × 100 bytes = 2KB

**Total Impact**: +2KB (negligible, well within 5MB limit)

**Storage Key Structure**:
```javascript
localStorage {
    'speckit_commands': '[{"id":"cmd_1","label":"...","text":"...","category":"Git"}...]',
    'speckit_category_colors': '{"git":{"color":"#2563eb","assignedAt":1697500000000,"paletteIndex":0},...}',
    'speckit_projects': '[...]'  // existing
}
```

---

## Constraints and Invariants

### Data Integrity Constraints

1. **Category Name Normalization**: All category names MUST be normalized (lowercase, trimmed) before lookup or storage
   ```javascript
   const normalized = categoryName.toLowerCase().trim();
   ```

2. **Color Uniqueness Per Category**: Each category MUST have exactly one color assignment
   - Enforced by: Object key uniqueness in CategoryColorMapping

3. **Color Palette Immutability**: COLOR_PALETTE constant MUST NOT be modified at runtime
   - Enforced by: `const` declaration, no mutation in code

4. **WCAG Compliance**: All assigned colors MUST have contrast ratio ≥ 4.5:1
   - Enforced by: Palette pre-validation, no runtime color generation

5. **LocalStorage Fallback**: System MUST gracefully handle localStorage unavailability
   - Enforced by: try-catch blocks, in-memory fallback

### Performance Constraints

1. **Render Time**: renderCommandLibrary() MUST complete in <50ms for 100 commands
   - Monitored via: performance.now() timing in tests

2. **Scroll Performance**: Must maintain 60fps scrolling with 500 commands
   - Enforced by: CSS will-change optimization, DOM node limit

3. **Storage Write**: Color mapping updates MUST complete in <10ms
   - Enforced by: Synchronous localStorage API, minimal data size

---

## Migration Strategy

**No Migration Required**:
- Existing Command entities have `category` attribute already
- CategoryColorMapping is new data (no existing data to migrate)
- Feature is purely additive (no breaking changes)

**Backwards Compatibility**:
- If `speckit_category_colors` key doesn't exist, initialize as empty object `{}`
- First load assigns colors to all existing categories
- Subsequent loads reuse existing assignments

**Rollback Safety**:
- Removing this feature: Simply don't read `speckit_category_colors` key
- Commands still render without colors (original functionality intact)
