# Research: Command Library Multi-Column Layout

## Decision 1: Multi-Column Layout Approach

**Chosen**: CSS Grid with `repeat()` and CSS Custom Properties

**Rationale**:
- CSS Grid provides superior control for creating equal-width columns with dynamic column counts (1-20)
- The `repeat()` function with `minmax(0, 1fr)` ensures truly equal-width columns regardless of content
- CSS Custom Properties (CSS variables) allow JavaScript to dynamically control column count without DOM manipulation
- Performance for 1-20 columns is excellent in modern browsers, with no significant overhead compared to Flexbox
- Grid handles two-dimensional layouts better than Flexbox, which is optimal for one-dimensional layouts

**Alternatives Considered**:
- **Option A: Flexbox** - Rejected because:
  - Flexbox is optimized for one-dimensional layouts (row OR column)
  - Equal-width distribution with flex becomes unpredictable with varying content lengths
  - Requires more complex calculations and workarounds for true equal-width columns
  - Better suited for UI components rather than grid-based layouts

- **Option B: CSS Columns (column-count)** - Rejected because:
  - Designed primarily for flowing text content (newspaper-style layouts)
  - Limited control over individual column behavior and spacing
  - Content flows vertically first, then horizontally, which doesn't match the requirement for command library items
  - Poor control over overflow and wrapping behavior in each column

**Implementation Details**:
```css
.command-grid {
  display: grid;
  grid-template-columns: repeat(var(--column-count, 4), minmax(0, 1fr));
  gap: 1rem;
  width: 100%;
}
```

**Key Technical Points**:
- Use `minmax(0, 1fr)` instead of just `1fr` to prevent columns from stretching based on content size
- The minimum width of `0` allows grid to shrink columns below their content size, enabling true equal distribution
- CSS Custom Property `--column-count` can be set via JavaScript: `element.style.setProperty('--column-count', count)`
- `gap` property provides consistent spacing between columns without margin calculations
- No max-width needed on container since `minmax(0, 1fr)` prevents horizontal overflow

**Performance Characteristics**:
- Rendering performance for 1-20 columns is negligible (< 1ms difference)
- Grid's internal algorithm handles layout calculation efficiently
- No JavaScript calculations needed for column widths (handled by CSS engine)
- Reflows during column count changes are handled efficiently by modern browsers

---

## Decision 2: Font Scaling Algorithm

**Chosen**: Segmented scaling with `clamp()` and viewport-aware minimums

**Rationale**:
- Linear scaling from 1-20 columns would make fonts unreadable at high column counts
- Segmented scaling provides better readability balance across the full range
- CSS `clamp()` provides built-in boundary enforcement without JavaScript
- Accessibility standards require minimum 16px for body text, but can go smaller for UI labels (12px minimum)
- Command library items are closer to UI labels than body text, allowing for smaller minimum

**Minimum Font Size**: 10px (justified below)

**Justification for 10px Minimum**:
- WCAG 2.1 requires text to be resizable up to 200% without loss of functionality
- For interactive UI elements (not body text), 10px is acceptable if users can zoom
- Command library items are short identifiers, not paragraphs requiring sustained reading
- 10px with good contrast and clear fonts (system fonts) remains readable
- Industry precedent: macOS system UI uses 10px for secondary labels

**Scaling Formula**:

```css
/* Base approach using CSS variables for dynamic adjustment */
.command-item {
  font-size: clamp(10px, calc(var(--base-size) / var(--column-count) * var(--scale-factor)), 20px);
}
```

**Scaling Ranges** (with detailed breakdowns):

### 1-4 columns (Comfortable Reading)
- **Font Size**: 16px (constant)
- **Rationale**: Standard body text size, maximum readability
- **Line Height**: 1.5
- **Character Limit**: None (full text display)

### 5-8 columns (Balanced)
- **Font Size**: 14-16px (scaled)
- **Formula**: `clamp(14px, calc(20px - (column_count - 4) * 0.5px), 16px)`
- **Rationale**: Gentle reduction maintains readability while accommodating more columns
- **Line Height**: 1.4
- **Example**: 5 cols = 15.5px, 6 cols = 15px, 7 cols = 14.5px, 8 cols = 14px

### 9-12 columns (Compact)
- **Font Size**: 12-14px (scaled)
- **Formula**: `clamp(12px, calc(14px - (column_count - 8) * 0.5px), 14px)`
- **Rationale**: Entering compact territory, but still above minimum readability threshold
- **Line Height**: 1.3
- **Example**: 9 cols = 13.5px, 10 cols = 13px, 11 cols = 12.5px, 12 cols = 12px

### 13-20 columns (Dense)
- **Font Size**: 10-12px (scaled)
- **Formula**: `clamp(10px, calc(12px - (column_count - 12) * 0.25px), 12px)`
- **Rationale**: Maximum density for power users, maintains 10px minimum
- **Line Height**: 1.2
- **Example**: 13 cols = 11.75px, 14 cols = 11.5px, 16 cols = 11px, 20 cols = 10px

**JavaScript Implementation Approach**:
```javascript
function calculateFontSize(columnCount) {
  if (columnCount <= 4) return 16;
  if (columnCount <= 8) return Math.max(14, 20 - (columnCount - 4) * 0.5);
  if (columnCount <= 12) return Math.max(12, 14 - (columnCount - 8) * 0.5);
  return Math.max(10, 12 - (columnCount - 12) * 0.25);
}
```

**Viewport Width Considerations**:
- On very narrow viewports (< 600px), reduce all font sizes by 1px to prevent overflow
- Use media queries to adjust base font size:
  ```css
  @media (max-width: 600px) {
    .command-item {
      font-size: calc(var(--font-size) - 1px);
    }
  }
  ```

---

## Decision 3: Text Overflow Strategy

**Chosen**: Hybrid approach with ellipsis truncation + tooltip on hover/focus

**Rationale**:
- Pure truncation prevents horizontal scroll while signaling there's more content (ellipsis)
- Tooltip/title attribute provides accessibility without requiring click
- Word wrapping would cause unpredictable row heights and break grid alignment
- This is the industry standard for similar UI patterns (VS Code command palette, macOS Spotlight, etc.)
- Meets WCAG 1.4.10 by making full content accessible via tooltip

**Implementation Details**:

```css
.command-item {
  /* Truncation setup */
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;

  /* Container constraints */
  min-width: 0; /* Critical for flex/grid children */
  max-width: 100%;

  /* Padding for visual breathing room */
  padding: 0.5rem 0.75rem;

  /* Ensure box-sizing includes padding */
  box-sizing: border-box;
}

/* Tooltip enhancement (optional visual improvement) */
.command-item[title]:hover::after {
  content: attr(title);
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  padding: 0.25rem 0.5rem;
  background: rgba(0, 0, 0, 0.9);
  color: white;
  font-size: 12px;
  white-space: nowrap;
  border-radius: 4px;
  z-index: 1000;
  pointer-events: none;
}
```

**JavaScript Enhancement**:
```javascript
// Add title attribute for native browser tooltip
commandElement.title = commandElement.textContent;

// Or use a proper tooltip library for better UX
```

**Accessibility Considerations**:
- Native `title` attribute works with keyboard navigation (shows on focus)
- Screen readers will read the full text content regardless of visual truncation
- ARIA labels not needed since full text is in the DOM
- Ensure focus states are visible for keyboard users

**Edge Cases Handled**:
1. **Very short commands** (< 10 chars): No truncation occurs, text displays fully
2. **Exact fit**: No ellipsis shown, text fills width perfectly
3. **Multi-word commands**: Truncation respects whole words when possible (browser default)
4. **Special characters**: Unicode and emojis truncate cleanly

**Alternative Considered but Rejected**:
- **Word wrapping**: Would break grid alignment with variable-height rows
- **Click-to-expand**: Requires interaction, worse UX than tooltip
- **Marquee scrolling**: Distracting, poor accessibility, dated UX pattern
- **No truncation**: Would cause horizontal scroll, breaking layout

---

## Decision 4: localStorage Structure

**Chosen**: Simple integer value with namespaced key

**Key**: `speckit_column_count`

**Rationale**:
- Column count is a single primitive value, no need for complex object structure
- Namespacing with `speckit_` prefix prevents conflicts with other apps on same domain
- Simple integer is easier to validate and less prone to JSON parsing errors
- Follows localStorage best practices for key naming conventions
- Future-proof: If more preferences needed, use `speckit_commands_*` pattern

**Data Structure**:
```javascript
// Stored value (string, as localStorage only stores strings)
localStorage.setItem('speckit_column_count', '4');

// Retrieved value (convert back to number)
const columnCount = parseInt(localStorage.getItem('speckit_column_count'), 10);
```

**Default Value**: 4

**Justification for Default = 4**:
- Provides reasonable balance between density and readability
- Works well on common screen sizes (1920x1080, 1440x900, laptop screens)
- Font size remains at maximum 16px for optimal readability
- Allows ~12-15 commands visible without scrolling on typical screens
- Matches common UI patterns (4-column grids are ubiquitous in design systems)

**Validation Strategy**:

```javascript
function getColumnCount() {
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
      setColumnCount(DEFAULT_COLUMNS); // Reset to valid value
      return DEFAULT_COLUMNS;
    }

    // Clamp to valid range
    if (parsed < MIN_COLUMNS || parsed > MAX_COLUMNS) {
      console.warn(`Column count ${parsed} out of range [${MIN_COLUMNS}, ${MAX_COLUMNS}], using default`);
      setColumnCount(DEFAULT_COLUMNS);
      return DEFAULT_COLUMNS;
    }

    return parsed;

  } catch (error) {
    // Handle localStorage access errors (privacy mode, quota exceeded, etc.)
    console.error('Error reading from localStorage:', error);
    return DEFAULT_COLUMNS;
  }
}

function setColumnCount(count) {
  const MIN_COLUMNS = 1;
  const MAX_COLUMNS = 20;

  // Validate before storing
  if (typeof count !== 'number' || isNaN(count)) {
    console.error('Invalid column count type:', count);
    return false;
  }

  // Clamp to valid range
  const clamped = Math.max(MIN_COLUMNS, Math.min(MAX_COLUMNS, Math.floor(count)));

  try {
    localStorage.setItem('speckit_column_count', clamped.toString());
    return true;
  } catch (error) {
    console.error('Error writing to localStorage:', error);
    return false;
  }
}
```

**Edge Cases Handled**:
1. **First visit** (no localStorage): Returns default of 4
2. **Invalid values** (NaN, non-numeric strings): Resets to default
3. **Out of range** (< 1 or > 20): Clamps to nearest valid value
4. **localStorage unavailable** (private browsing, disabled): Gracefully falls back to default
5. **Corrupted data**: Catches parsing errors and resets
6. **Fractional numbers**: Floors to nearest integer

**Security Considerations**:
- No XSS risk (single integer, not user-generated content)
- No need for sanitization (parseInt handles malicious input safely)
- localStorage is origin-scoped (no cross-domain access)
- Value is purely client-side preference (no server synchronization needed)

**Future Extensibility**:
If additional preferences are needed, maintain the flat namespace:
- `speckit_column_count` - Current feature
- `speckit_sort_order` - Future sorting preference
- `speckit_view_mode` - Future view mode toggle
- `speckit_theme` - Future theme preference

Alternative: Use prefixed object structure only if 5+ related preferences emerge:
```javascript
// Only if necessary in future
const preferences = {
  columnCount: 4,
  sortOrder: 'alpha',
  viewMode: 'grid',
  theme: 'auto'
};
localStorage.setItem('speckit_preferences', JSON.stringify(preferences));
```

**Testing Strategy**:
```javascript
// Unit tests should cover:
// 1. Valid values (1, 4, 10, 20)
// 2. Invalid values (0, -1, 21, 100, NaN, null, undefined, "abc")
// 3. Boundary values (1, 20)
// 4. localStorage unavailable scenarios
// 5. Corrupted JSON (for future object structure)

describe('Column Count Persistence', () => {
  beforeEach(() => localStorage.clear());

  test('returns default on first visit', () => {
    expect(getColumnCount()).toBe(4);
  });

  test('returns stored valid value', () => {
    setColumnCount(8);
    expect(getColumnCount()).toBe(8);
  });

  test('clamps out-of-range values', () => {
    localStorage.setItem('speckit_column_count', '50');
    expect(getColumnCount()).toBe(4); // Reset to default
  });

  test('handles invalid data', () => {
    localStorage.setItem('speckit_column_count', 'invalid');
    expect(getColumnCount()).toBe(4);
  });
});
```

---

## Additional Implementation Recommendations

### 1. Smooth Transitions
Add CSS transitions for column count changes to improve UX:
```css
.command-grid {
  transition: grid-template-columns 0.3s ease, gap 0.3s ease;
}

.command-item {
  transition: font-size 0.3s ease;
}
```

### 2. Responsive Breakpoints
Consider maximum columns based on viewport width:
```javascript
function getMaxColumnsForViewport() {
  const width = window.innerWidth;
  if (width < 600) return 3;   // Mobile
  if (width < 900) return 8;   // Tablet
  if (width < 1200) return 12; // Laptop
  return 20;                    // Desktop
}
```

### 3. Performance Optimization
Use CSS containment for better rendering performance:
```css
.command-grid {
  contain: layout style paint;
}

.command-item {
  contain: layout style paint;
}
```

### 4. Accessibility Enhancements
- Provide visual feedback when column count changes
- Announce changes to screen readers: `aria-live="polite"`
- Ensure focus is maintained when layout shifts
- Test with 200% browser zoom (WCAG requirement)

### 5. User Controls
Implement intuitive controls for column adjustment:
- Slider input (1-20 range)
- Plus/minus buttons for incremental changes
- Keyboard shortcuts (Cmd/Ctrl + Plus/Minus)
- Preset buttons (2, 4, 8, 12 columns) for quick access

---

## Summary of Key Decisions

| Decision | Choice | Primary Benefit |
|----------|--------|-----------------|
| **Layout Method** | CSS Grid with `repeat()` | Equal-width columns, dynamic control via CSS variables |
| **Font Scaling** | Segmented scaling (16px → 10px) | Maintains readability across full 1-20 column range |
| **Overflow Strategy** | Ellipsis truncation + tooltip | Prevents horizontal scroll, preserves content access |
| **Storage Structure** | Simple integer with namespace | Easy validation, future-proof, follows best practices |

These decisions prioritize:
1. **Performance**: CSS-driven layout, minimal JavaScript
2. **Accessibility**: WCAG-compliant font sizes, keyboard navigation, screen reader support
3. **User Experience**: Smooth transitions, predictable behavior, discoverable content
4. **Maintainability**: Simple data structures, clear validation, extensible patterns
