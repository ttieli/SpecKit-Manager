# Quick Start Guide: Command Library Multi-Column Layout

**Feature**: 007-1-20-20 Command Library Multi-Column Layout
**For**: Developers implementing this feature
**Last Updated**: 2025-10-17

## Overview

This feature adds customizable multi-column layout to the command library:
1. **Column count selector** - User can choose 1-20 columns
2. **Responsive font scaling** - Automatic size adjustment for readability
3. **Persistent preference** - Column choice saved across sessions

**Implementation Time**: ~4-5 hours
**Complexity**: Medium (CSS Grid + localStorage + segmented calculations)

---

## Prerequisites

Before starting:
- [x] Read [spec.md](spec.md) for user requirements
- [x] Review [research.md](research.md) for technical decisions
- [x] Check [data-model.md](data-model.md) for data structures
- [x] Read [contracts/function-interfaces.md](contracts/function-interfaces.md) for API contracts

**Required Knowledge**:
- JavaScript ES6+ (arrow functions, destructuring, template literals)
- CSS Grid (repeat(), minmax(), fr units)
- CSS custom properties (CSS variables)
- LocalStorage API
- DOM manipulation
- Constitution Principles VI (Modularity) and VII (Separation of Concerns)

**Critical Understanding**:
- **Layer separation**: column* (data) → layout* (business) → render* (presentation)
- **Function naming**: Strict adherence to prefixes (column*, layout*, render*)
- **No cross-layer calls**: render* functions MUST NOT directly access localStorage

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│  USER INTERACTION                                            │
│  - Slider input (1-20 columns)                               │
│  - Preset buttons (1, 4, 8, 12, 20)                          │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER (render*)                                │
│  - renderColumnSelector() → Render UI controls               │
│  - renderCommandGrid() → Apply layout and render             │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  BUSINESS LOGIC LAYER (layout*)                              │
│  - layoutCalculateGrid() → CSS Grid parameters               │
│  - layoutCalculateFontSizes() → Font size calculations       │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  DATA ACCESS LAYER (column*)                                 │
│  - columnLoadPreference() → Read from localStorage           │
│  - columnSavePreference() → Write to localStorage            │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Checklist

### Phase 1: Data Access Layer (30 minutes)

**File**: `index.html` (JavaScript section, after existing functions)

- [ ] **Task 1.1**: Define constants
  ```javascript
  // Add after existing constants (around line 3550)
  const MIN_COLUMNS = 1;
  const MAX_COLUMNS = 20;
  const DEFAULT_COLUMNS = 4;
  ```

- [ ] **Task 1.2**: Implement `columnLoadPreference()`
  ```javascript
  /**
   * DATA ACCESS LAYER: Load column count preference from localStorage
   * @returns {number} Column count (1-20), or default (4) if not found/invalid
   */
  function columnLoadPreference() {
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
              console.warn(`Column count ${parsed} out of range [${MIN_COLUMNS}, ${MAX_COLUMNS}], using default`);
              return DEFAULT_COLUMNS;
          }

          return parsed;

      } catch (error) {
          console.error('Error reading column preference from localStorage:', error);
          return DEFAULT_COLUMNS;
      }
  }
  ```

- [ ] **Task 1.3**: Implement `columnSavePreference(columnCount)`
  ```javascript
  /**
   * DATA ACCESS LAYER: Save column count preference to localStorage
   * @param {number} columnCount - Desired column count (1-20)
   * @returns {boolean} true if saved successfully, false otherwise
   */
  function columnSavePreference(columnCount) {
      // Validate type
      if (typeof columnCount !== 'number' || isNaN(columnCount)) {
          console.error('Invalid column count type:', columnCount);
          return false;
      }

      // Clamp to valid range and floor to integer
      const clamped = Math.max(MIN_COLUMNS, Math.min(MAX_COLUMNS, Math.floor(columnCount)));

      try {
          localStorage.setItem('speckit_column_count', clamped.toString());
          return true;
      } catch (error) {
          console.error('Error writing column preference to localStorage:', error);
          return false;
      }
  }
  ```

**Validation**: Test in browser console:
```javascript
// Test save
columnSavePreference(10);
console.log(localStorage.getItem('speckit_column_count')); // Should be "10"

// Test load
const loaded = columnLoadPreference();
console.log(loaded); // Should be 10

// Test invalid input
columnSavePreference(25);
console.log(columnLoadPreference()); // Should be 20 (clamped)

// Test first visit
localStorage.removeItem('speckit_column_count');
console.log(columnLoadPreference()); // Should be 4 (default)
```

**Layer Compliance Check**:
- ✅ No DOM manipulation in column* functions
- ✅ No business logic calculations in column* functions
- ✅ Only localStorage operations

---

### Phase 2: Business Logic Layer (60 minutes)

**File**: `index.html` (JavaScript section, after Phase 1 functions)

- [ ] **Task 2.1**: Implement `layoutCalculateGrid(columnCount)`
  ```javascript
  /**
   * BUSINESS LOGIC LAYER: Calculate CSS Grid layout parameters
   * @param {number} columnCount - Column count (1-20)
   * @returns {Object} Grid layout parameters
   */
  function layoutCalculateGrid(columnCount) {
      // Clamp to valid range (safety check)
      const count = Math.max(MIN_COLUMNS, Math.min(MAX_COLUMNS, columnCount));

      // CSS Grid template - minmax(0, 1fr) for equal-width columns
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

- [ ] **Task 2.2**: Implement `layoutCalculateFontSizes(columnCount)`
  ```javascript
  /**
   * BUSINESS LOGIC LAYER: Calculate detailed font size parameters
   * @param {number} columnCount - Column count (1-20)
   * @returns {Object} Font size parameters
   */
  function layoutCalculateFontSizes(columnCount) {
      // Clamp to valid range
      const count = Math.max(MIN_COLUMNS, Math.min(MAX_COLUMNS, columnCount));

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

**Validation**: Test in browser console:
```javascript
// Test grid calculation
const grid4 = layoutCalculateGrid(4);
console.log(grid4);
// Expected: { columnCount: 4, gridTemplateColumns: "repeat(4, minmax(0, 1fr))", gap: "1rem", itemPadding: "0.75rem", fontSize: 16, lineHeight: 1.5 }

const grid12 = layoutCalculateGrid(12);
console.log(grid12.fontSize); // Should be 12

const grid20 = layoutCalculateGrid(20);
console.log(grid20.fontSize); // Should be 10

// Test font size calculation
const fonts4 = layoutCalculateFontSizes(4);
console.log(fonts4);
// Expected: { columnCount: 4, commandLabelSize: 16, commandTextSize: 14, categoryHeaderSize: 18, lineHeight: 1.5, minReadableSize: 10 }

const fonts20 = layoutCalculateFontSizes(20);
console.log(fonts20.commandLabelSize); // Should be 10
console.log(fonts20.commandTextSize); // Should be 10
```

**Layer Compliance Check**:
- ✅ No DOM manipulation in layout* functions
- ✅ No localStorage access in layout* functions
- ✅ Pure calculations only (deterministic output for same input)

---

### Phase 3: CSS Styling (45 minutes)

**File**: `index.html` (CSS section, after existing command library styles)

- [ ] **Task 3.1**: Add text overflow handling
  ```css
  /* Add after existing .command-label and .command-text styles */
  .command-label,
  .command-text {
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      min-width: 0; /* Critical for grid children */
  }
  ```

- [ ] **Task 3.2**: Add smooth transitions
  ```css
  /* Add after #command-list styles */
  #command-list {
      transition: grid-template-columns 0.3s ease, gap 0.3s ease;
  }

  .command-label,
  .command-text {
      transition: font-size 0.3s ease, line-height 0.3s ease;
  }
  ```

- [ ] **Task 3.3**: Add column selector styles
  ```css
  /* Add new section for column selector */
  .column-selector {
      display: flex;
      align-items: center;
      gap: 1rem;
      padding: 1rem;
      background: #f8fafc;
      border-radius: 8px;
      margin-bottom: 1.5rem;
  }

  .column-selector label {
      font-weight: 600;
      font-size: 0.9rem;
      color: #475569;
  }

  .column-selector input[type="range"] {
      flex: 1;
      max-width: 300px;
  }

  .column-selector-display {
      font-weight: 700;
      font-size: 1.1rem;
      color: #2563eb;
      min-width: 2rem;
      text-align: center;
  }

  .column-preset-btn {
      padding: 0.4rem 0.8rem;
      font-size: 0.85rem;
      background: white;
      border: 1px solid #cbd5e1;
      border-radius: 6px;
      cursor: pointer;
      transition: all 0.2s;
  }

  .column-preset-btn:hover {
      background: #2563eb;
      color: white;
      border-color: #2563eb;
  }

  .column-preset-btn.active {
      background: #2563eb;
      color: white;
      border-color: #2563eb;
  }
  ```

**Validation**: Inspect styles in DevTools, verify classes exist and transitions work

---

### Phase 4: Presentation Layer (90 minutes)

**File**: `index.html` (JavaScript section, after Phase 2 functions)

- [ ] **Task 4.1**: Implement `renderColumnSelector()`
  ```javascript
  /**
   * PRESENTATION LAYER: Render column count selector UI
   */
  function renderColumnSelector() {
      const container = document.getElementById('command-controls');
      if (!container) return;

      // DATA ACCESS LAYER: Get current preference
      const currentCount = columnLoadPreference();

      const selectorHTML = `
          <div class="column-selector">
              <label for="column-count-input">列数 (Columns):</label>
              <input type="range"
                     id="column-count-input"
                     min="${MIN_COLUMNS}"
                     max="${MAX_COLUMNS}"
                     value="${currentCount}"
                     oninput="handleColumnCountChange(this.value)">
              <span id="column-count-display" class="column-selector-display">${currentCount}</span>
              <button class="column-preset-btn ${currentCount === 1 ? 'active' : ''}"
                      onclick="handleColumnCountSet(1)">1</button>
              <button class="column-preset-btn ${currentCount === 4 ? 'active' : ''}"
                      onclick="handleColumnCountSet(4)">4</button>
              <button class="column-preset-btn ${currentCount === 8 ? 'active' : ''}"
                      onclick="handleColumnCountSet(8)">8</button>
              <button class="column-preset-btn ${currentCount === 12 ? 'active' : ''}"
                      onclick="handleColumnCountSet(12)">12</button>
              <button class="column-preset-btn ${currentCount === 20 ? 'active' : ''}"
                      onclick="handleColumnCountSet(20)">20</button>
          </div>
      `;

      // Insert before command list
      const existingSelector = container.querySelector('.column-selector');
      if (existingSelector) {
          existingSelector.outerHTML = selectorHTML;
      } else {
          container.insertAdjacentHTML('afterbegin', selectorHTML);
      }
  }
  ```

- [ ] **Task 4.2**: Implement event handlers (Bridge Layer)
  ```javascript
  /**
   * EVENT HANDLER: Handle slider input change (live preview, no save)
   * @param {string} value - Slider value (1-20)
   */
  function handleColumnCountChange(value) {
      const count = parseInt(value, 10);

      // Update display
      const display = document.getElementById('column-count-display');
      if (display) {
          display.textContent = count;
      }

      // Update active button
      document.querySelectorAll('.column-preset-btn').forEach(btn => {
          btn.classList.remove('active');
      });

      // Live preview without saving
      const layout = layoutCalculateGrid(count);
      const fonts = layoutCalculateFontSizes(count);

      const commandList = document.getElementById('command-list');
      if (commandList) {
          commandList.style.gridTemplateColumns = layout.gridTemplateColumns;
          commandList.style.gap = layout.gap;

          // Apply font sizes to all elements
          const labels = commandList.querySelectorAll('.command-label');
          labels.forEach(label => {
              label.style.fontSize = fonts.commandLabelSize + 'px';
          });

          const texts = commandList.querySelectorAll('.command-text');
          texts.forEach(text => {
              text.style.fontSize = fonts.commandTextSize + 'px';
              text.style.lineHeight = fonts.lineHeight;
          });

          const headers = commandList.querySelectorAll('.command-category-header');
          headers.forEach(header => {
              header.style.fontSize = fonts.categoryHeaderSize + 'px';
          });
      }
  }

  /**
   * EVENT HANDLER: Handle preset button click or slider release (save)
   * @param {number} count - Column count to set (1-20)
   */
  function handleColumnCountSet(count) {
      // DATA ACCESS LAYER: Save preference
      const saved = columnSavePreference(count);
      if (!saved) {
          console.warn('Failed to save column preference');
      }

      // Update slider and display
      const slider = document.getElementById('column-count-input');
      const display = document.getElementById('column-count-display');
      if (slider) slider.value = count;
      if (display) display.textContent = count;

      // Update active button
      document.querySelectorAll('.column-preset-btn').forEach(btn => {
          btn.classList.remove('active');
          if (parseInt(btn.textContent, 10) === count) {
              btn.classList.add('active');
          }
      });

      // PRESENTATION LAYER: Re-render with new layout
      renderCommandGrid();
  }
  ```

- [ ] **Task 4.3**: Modify `renderCommandLibrary()` to apply multi-column layout
  ```javascript
  /**
   * PRESENTATION LAYER: Render command library with multi-column layout
   * @param {Array} commandsToRender - Commands to render (defaults to global commands)
   */
  function renderCommandLibrary(commandsToRender = commands) {
      const container = document.getElementById('command-list');
      if (!container) return;

      // DATA ACCESS LAYER: Load column preference
      const columnCount = columnLoadPreference();

      // BUSINESS LOGIC LAYER: Calculate layout parameters
      const layout = layoutCalculateGrid(columnCount);
      const fonts = layoutCalculateFontSizes(columnCount);

      // Apply CSS Grid layout to container
      container.style.display = 'grid';
      container.style.gridTemplateColumns = layout.gridTemplateColumns;
      container.style.gap = layout.gap;
      container.style.width = '100%';

      // Empty state
      if (commandsToRender.length === 0) {
          container.innerHTML = `
              <div style="
                  grid-column: 1 / -1;
                  text-align: center;
                  padding: 60px 20px;
                  color: #94a3b8;
              ">
                  <div style="font-size: 4rem; margin-bottom: 16px; opacity: 0.6;">📋</div>
                  <div style="font-size: 1.1rem; margin-bottom: 8px;">暂无命令</div>
                  <div style="font-size: 0.9rem;">点击"添加命令"开始创建您的命令库</div>
              </div>
          `;
          return;
      }

      // Group commands by category
      const grouped = {};
      commandsToRender.forEach(cmd => {
          const category = cmd.category || 'Uncategorized';
          if (!grouped[category]) grouped[category] = [];
          grouped[category].push(cmd);
      });

      // Build HTML with calculated font sizes
      let html = '';
      Object.keys(grouped).sort().forEach(category => {
          // Get category color (from Feature 006)
          const { color } = colorAssignCategory ? colorAssignCategory(category) : { color: '#64748b' };
          const bgColor = color + '22';

          html += `
              <div class="command-category" style="grid-column: span 1;">
                  <div class="command-category-header"
                       style="
                           font-size: ${fonts.categoryHeaderSize}px;
                           background: ${bgColor};
                           color: ${color};
                           padding: 8px 12px;
                           border-radius: 6px;
                           font-weight: 700;
                           margin-bottom: 12px;
                       ">
                      ${category}
                  </div>
          `;

          grouped[category].forEach(cmd => {
              const truncatedText = cmd.text.length > 100
                  ? cmd.text.substring(0, 100) + '...'
                  : cmd.text;

              html += `
                  <div class="command-item"
                       draggable="true"
                       ondragstart="handleDragStart(event, '${cmd.id}')"
                       ondragover="handleDragOver(event)"
                       ondrop="handleDrop(event, '${cmd.id}')"
                       style="
                           padding: ${layout.itemPadding};
                           border-left: 4px solid ${color};
                       ">
                      <div class="command-info">
                          <div class="command-label"
                               style="
                                   font-size: ${fonts.commandLabelSize}px;
                                   line-height: ${fonts.lineHeight};
                                   font-weight: 600;
                                   margin-bottom: 4px;
                               ">${cmd.label}</div>
                          <div class="command-text"
                               style="
                                   font-size: ${fonts.commandTextSize}px;
                                   line-height: ${fonts.lineHeight};
                                   color: #64748b;
                               "
                               title="${cmd.text}">${truncatedText}</div>
                      </div>
                      <div class="command-actions">
                          <button class="command-action-btn copy-btn"
                                  onclick="handleCopyCommand('${cmd.id}')"
                                  title="复制">📋</button>
                          <button class="command-action-btn edit-btn"
                                  onclick="handleEditCommand('${cmd.id}')"
                                  title="编辑">✏️</button>
                          <button class="command-action-btn delete-btn"
                                  onclick="handleDeleteCommand('${cmd.id}')"
                                  title="删除">🗑️</button>
                      </div>
                  </div>
              `;
          });

          html += '</div>';
      });

      container.innerHTML = html;
  }
  ```

- [ ] **Task 4.4**: Update `switchTab()` to render column selector
  ```javascript
  // Find the existing switchTab function and modify the 'commands' case
  function switchTab(tabName) {
      // ... existing code ...

      if (tabName === 'commands') {
          // NEW: Render column selector
          renderColumnSelector();

          // Existing: Render command library
          renderCommandLibrary();
      }

      // ... existing code ...
  }
  ```

**Validation**:
1. Switch to Commands tab
2. Verify column selector appears
3. Move slider → verify live preview
4. Click preset button → verify preference saves and layout updates
5. Reload page → verify column count persists

**Layer Compliance Check**:
- ✅ renderCommandGrid() does NOT directly access localStorage (uses columnLoadPreference())
- ✅ renderCommandGrid() does NOT contain business logic (uses layoutCalculateGrid() and layoutCalculateFontSizes())
- ✅ Event handlers bridge user actions to appropriate layers

---

### Phase 5: Integration Testing (45 minutes)

**File**: Create manual test checklist (no code changes)

**Manual Testing Checklist**:

#### Visual Testing
- [ ] Column selector appears in Commands tab
- [ ] Slider shows current column count
- [ ] Display shows correct number (1-20)
- [ ] Preset buttons highlight active count
- [ ] Command grid displays in selected column count
- [ ] Font sizes scale appropriately (larger at 4 cols, smaller at 20 cols)
- [ ] Text truncates with ellipsis when too long
- [ ] Category colors still work (from Feature 006)
- [ ] Layout never causes horizontal scroll

#### Functional Testing
- [ ] Move slider → Live preview works without saving
- [ ] Click preset button → Preference saves immediately
- [ ] Reload page → Column count persists
- [ ] Test all column counts (1, 5, 10, 15, 20)
- [ ] Test with 0 commands → Empty state displays correctly
- [ ] Test with 100+ commands → All render correctly
- [ ] Test with long command text → Truncates with tooltip
- [ ] Existing features work: search, drag-drop, copy, edit, delete

#### Edge Case Testing
- [ ] localStorage unavailable (private browsing) → Uses default (4)
- [ ] Invalid stored value → Resets to default (4)
- [ ] Out of range value (25) → Clamps to 20
- [ ] Browser window resize → Layout remains stable
- [ ] Rapid slider movement → No lag or errors
- [ ] Switch tabs quickly → No rendering issues

#### Performance Testing
- [ ] renderCommandLibrary() < 50ms for 100 commands
- [ ] layoutCalculateGrid() < 1ms
- [ ] layoutCalculateFontSizes() < 1ms
- [ ] Smooth 60fps transitions when changing column count
- [ ] Smooth scrolling with 500 commands

#### Accessibility Testing
- [ ] Font sizes remain readable at all column counts (≥ 10px)
- [ ] Keyboard navigation works (Tab, Enter)
- [ ] Focus states visible
- [ ] Screen reader announces column count changes
- [ ] Browser zoom (200%) works correctly

#### Layer Compliance Testing
- [ ] Verify: column* functions do NOT manipulate DOM
- [ ] Verify: layout* functions do NOT access localStorage
- [ ] Verify: render* functions do NOT directly access localStorage
- [ ] Verify: Function names follow conventions (column*, layout*, render*)

---

## Common Issues & Solutions

### Issue 1: Column count doesn't persist after reload

**Cause**: localStorage save failing or not being called
**Solution**:
1. Check browser console for errors
2. Verify `columnSavePreference()` is called in `handleColumnCountSet()`
3. Test in non-private browsing mode
4. Check localStorage quota (should have plenty of space)

**Debug Command**:
```javascript
console.log(localStorage.getItem('speckit_column_count'));
```

---

### Issue 2: Layout breaks at high column counts (15-20)

**Cause**: CSS Grid not using `minmax(0, 1fr)` or container has max-width
**Solution**:
1. Verify `gridTemplateColumns` uses `repeat(N, minmax(0, 1fr))`
2. Ensure container has `width: 100%` (not max-width)
3. Check for conflicting CSS rules

**Debug Command**:
```javascript
const layout = layoutCalculateGrid(20);
console.log(layout.gridTemplateColumns);
// Should be: "repeat(20, minmax(0, 1fr))"
```

---

### Issue 3: Font sizes too small or unreadable at 20 columns

**Cause**: Font calculation not enforcing 10px minimum
**Solution**:
1. Verify `Math.max(10, ...)` is used in all font calculations
2. Check browser zoom level (should be 100% for testing)
3. Test on actual 1920px+ display (not DevTools responsive mode)

**Debug Command**:
```javascript
const fonts = layoutCalculateFontSizes(20);
console.log(fonts.commandLabelSize); // Should be 10
console.log(fonts.minReadableSize); // Should be 10
```

---

### Issue 4: Live preview lags or stutters

**Cause**: Re-rendering entire grid on every slider input
**Solution**:
1. Verify `handleColumnCountChange()` only updates styles (not innerHTML)
2. Add CSS transitions for smooth animation
3. Consider debouncing slider input if still laggy

**Optimization**:
```javascript
// Option: Debounce slider input
let sliderTimeout;
function handleColumnCountChange(value) {
    clearTimeout(sliderTimeout);
    sliderTimeout = setTimeout(() => {
        // Update styles...
    }, 50); // 50ms debounce
}
```

---

### Issue 5: Layer violation errors in testing

**Cause**: Functions calling across layers incorrectly
**Solution**:
1. Never call localStorage directly in render* functions
2. Never manipulate DOM in column* functions
3. Never contain business logic in column* functions

**Correct Pattern**:
```javascript
// ✅ CORRECT: Render layer calls data layer via abstraction
function renderCommandGrid() {
    const columnCount = columnLoadPreference(); // ✅ Use abstraction
    // NOT: parseInt(localStorage.getItem('speckit_column_count'), 10); ❌
}
```

---

### Issue 6: Text overflow not working (no ellipsis)

**Cause**: Missing `min-width: 0` on grid children
**Solution**:
1. Add `min-width: 0` to `.command-label` and `.command-text`
2. Verify `white-space: nowrap`, `overflow: hidden`, `text-overflow: ellipsis`

**CSS Fix**:
```css
.command-label,
.command-text {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    min-width: 0; /* CRITICAL for grid children */
}
```

---

## Testing Data

### Test Commands Dataset

Create test commands for comprehensive testing:

```javascript
// Add to browser console for testing
const testCommands = [
    { id: 'test1', label: 'Short', text: 'short text', category: 'Git' },
    { id: 'test2', label: 'Very Long Label That Should Truncate', text: 'normal text', category: 'Git' },
    { id: 'test3', label: 'Normal', text: 'Very long command text that should truncate with ellipsis when displayed in narrow columns like 15-20 column layouts', category: 'Docker' },
    // ... add 20+ more for comprehensive testing
];

// Render test data
renderCommandLibrary(testCommands);
```

### Test Scenarios

**Scenario 1: First-time user**
1. Clear localStorage: `localStorage.clear()`
2. Reload page
3. Expected: 4 columns by default
4. Change to 10 columns → Save
5. Reload page
6. Expected: 10 columns restored

**Scenario 2: Power user**
1. Set to 20 columns
2. Add 100+ commands
3. Expected: All visible, font size 10px, readable
4. Scroll smoothly
5. Search filter → Layout remains stable

**Scenario 3: Edge case - corrupted data**
1. Set localStorage manually: `localStorage.setItem('speckit_column_count', 'invalid')`
2. Reload page
3. Expected: Resets to default (4), no errors
4. Change column count → Overwrites with valid value

---

## Next Steps

After implementation:

1. **Code Review**: Request review focusing on:
   - Layer separation compliance (no cross-layer violations)
   - Function naming conventions (column*, layout*, render*)
   - Performance benchmarks (< 50ms render time)
   - Accessibility compliance (≥ 10px font sizes)

2. **Documentation**: Update CLAUDE.md if needed (unlikely, no new technologies)

3. **Testing**: Run manual tests from Phase 5 checklist

4. **Deployment**: Create PR with description:
   ```
   Feature: Command Library Multi-Column Layout (007-1-20-20)

   - Add customizable column count selector (1-20 columns)
   - Implement responsive font scaling (16px → 10px)
   - Add localStorage persistence for user preference
   - Maintain layout integrity (no horizontal overflow)

   Architecture:
   - Follows Constitution Principles VI (Modularity) and VII (Separation of Concerns)
   - Strict layer separation: column* (data) → layout* (business) → render* (presentation)

   Testing:
   - All manual tests passed (visual, functional, edge cases, performance)
   - Layer compliance verified (no cross-layer violations)
   ```

---

## Quick Reference

**Key Files**:
- `index.html` - All implementation code
- `specs/007-1-20-20/spec.md` - Requirements
- `specs/007-1-20-20/research.md` - Technical decisions
- `specs/007-1-20-20/data-model.md` - Data structures
- `specs/007-1-20-20/contracts/function-interfaces.md` - API contracts

**Key Functions**:
- `columnLoadPreference()` - Load preference from localStorage
- `columnSavePreference(count)` - Save preference to localStorage
- `layoutCalculateGrid(count)` - Calculate grid layout parameters
- `layoutCalculateFontSizes(count)` - Calculate font sizes
- `renderColumnSelector()` - Render UI controls
- `renderCommandLibrary(commands)` - Render with multi-column layout

**Key Constants**:
- `MIN_COLUMNS` = 1
- `MAX_COLUMNS` = 20
- `DEFAULT_COLUMNS` = 4
- LocalStorage key: `'speckit_column_count'`

**Key Formulas**:
- **Grid template**: `repeat(N, minmax(0, 1fr))`
- **Font scaling (1-4 cols)**: 16px (constant)
- **Font scaling (5-8 cols)**: `max(14, 20 - (N-4) * 0.5)`
- **Font scaling (9-12 cols)**: `max(12, 14 - (N-8) * 0.5)`
- **Font scaling (13-20 cols)**: `max(10, 12 - (N-12) * 0.25)`

**Estimated Time**:
- Phase 1 (Data Access): 30 minutes
- Phase 2 (Business Logic): 60 minutes
- Phase 3 (CSS): 45 minutes
- Phase 4 (Presentation): 90 minutes
- Phase 5 (Testing): 45 minutes
- **Total**: ~4.5 hours
