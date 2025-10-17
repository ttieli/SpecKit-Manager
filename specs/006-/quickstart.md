# Quick Start Guide: Command Library Visual Enhancement

**Feature**: 006- Command Library Visual Enhancement
**For**: Developers implementing this feature
**Last Updated**: 2025-10-17

## Overview

This feature enhances the command library interface with:
1. **Color-coded categories** - Each category gets a unique, persistent color
2. **Optimized layout** - 30% more commands visible per screen
3. **Continuous scrolling** - All commands in one page (no pagination)

**Implementation Time**: ~3-4 hours
**Complexity**: Low-Medium (CSS + localStorage + simple algorithms)

---

## Prerequisites

Before starting:
- [x] Read [spec.md](spec.md) for user requirements
- [x] Review [plan.md](plan.md) for architecture decisions
- [x] Check [data-model.md](data-model.md) for data structures
- [x] Read [contracts/function-interfaces.md](contracts/function-interfaces.md) for API contracts

**Required Knowledge**:
- JavaScript ES6+ (arrow functions, destructuring, template literals)
- CSS (flexbox, responsive design)
- LocalStorage API
- DOM manipulation

---

## Implementation Checklist

### Phase 1: Data Access Layer (30 minutes)

**File**: `index.html` (JavaScript section, lines ~4900-5000)

- [ ] **Task 1.1**: Define color palette constant
  ```javascript
  // Add after existing constants (around line 3550)
  const COLOR_PALETTE = [
      { index: 0, color: '#2563eb', name: 'Blue', contrastRatio: 7.0 },
      // ... (see research.md for full palette)
  ];
  ```

- [ ] **Task 1.2**: Implement `colorLoadMappings()`
  ```javascript
  function colorLoadMappings() {
      try {
          const stored = localStorage.getItem('speckit_category_colors');
          return stored ? JSON.parse(stored) : {};
      } catch (error) {
          console.error('Failed to load category colors:', error);
          return {};
      }
  }
  ```

- [ ] **Task 1.3**: Implement `colorSaveMappings(mappings)`
  ```javascript
  function colorSaveMappings(mappings) {
      try {
          localStorage.setItem('speckit_category_colors', JSON.stringify(mappings));
          return true;
      } catch (error) {
          console.error('Failed to save category colors:', error);
          return false;
      }
  }
  ```

**Validation**: Test in browser console:
```javascript
colorSaveMappings({ "test": { color: "#2563eb", assignedAt: Date.now(), paletteIndex: 0 } });
console.log(colorLoadMappings()); // Should show saved mapping
```

---

### Phase 2: Business Logic Layer (60 minutes)

**File**: `index.html` (JavaScript section, lines ~5200-5500)

- [ ] **Task 2.1**: Implement `colorGetPalette()`
  ```javascript
  function colorGetPalette() {
      return COLOR_PALETTE;
  }
  ```

- [ ] **Task 2.2**: Implement `colorAssignCategory(categoryName)`
  ```javascript
  function colorAssignCategory(categoryName) {
      const key = categoryName.toLowerCase().trim();
      const mappings = colorLoadMappings();

      // Check if already assigned
      if (mappings[key]) {
          return {
              color: mappings[key].color,
              isNew: false,
              paletteIndex: mappings[key].paletteIndex
          };
      }

      // Assign new color
      const existingCount = Object.keys(mappings).length;
      const paletteIndex = existingCount % COLOR_PALETTE.length;
      const assignment = {
          color: COLOR_PALETTE[paletteIndex].color,
          assignedAt: Date.now(),
          paletteIndex
      };

      // Save and return
      mappings[key] = assignment;
      colorSaveMappings(mappings);

      return {
          color: assignment.color,
          isNew: true,
          paletteIndex
      };
  }
  ```

- [ ] **Task 2.3**: Implement `layoutCalculateDensity(viewportHeight, commandCount)`
  ```javascript
  function layoutCalculateDensity(viewportHeight, commandCount) {
      const baseParams = {
          itemPadding: 12,
          itemMargin: 10,
          labelFontSize: 14.4,
          textFontSize: 12.8,
          lineHeight: 1.3
      };

      const itemHeight = (baseParams.itemPadding * 2) +
                         (baseParams.labelFontSize * baseParams.lineHeight) +
                         (baseParams.textFontSize * baseParams.lineHeight) +
                         baseParams.itemMargin;

      const itemsPerView = Math.floor(viewportHeight / itemHeight);

      return { ...baseParams, itemHeight, itemsPerView };
  }
  ```

- [ ] **Task 2.4**: Implement `layoutGetResponsiveParams(screenWidth)`
  ```javascript
  function layoutGetResponsiveParams(screenWidth) {
      if (screenWidth < 640) {
          return { breakpoint: "mobile", fontSize: "0.85rem", minFontPx: 14, padding: "10px" };
      } else if (screenWidth < 1024) {
          return { breakpoint: "tablet", fontSize: "0.88rem", minFontPx: 14, padding: "11px" };
      } else {
          return { breakpoint: "desktop", fontSize: "0.9rem", minFontPx: 14, padding: "12px" };
      }
  }
  ```

**Validation**: Test in browser console:
```javascript
const color = colorAssignCategory("Git");
console.log(color); // { color: "#2563eb", isNew: true, paletteIndex: 0 }

const layout = layoutCalculateDensity(900, 50);
console.log(layout.itemsPerView); // Should be ~10
```

---

### Phase 3: CSS Styling (45 minutes)

**File**: `index.html` (CSS section, lines ~2253-2430)

- [ ] **Task 3.1**: Add density optimization classes
  ```css
  /* Add after existing .command-item styles (around line 2373) */
  .command-item-dense {
      padding: 12px !important;
      margin-bottom: 10px !important;
  }

  .command-label-dense {
      font-size: 0.9rem !important;
      margin-bottom: 4px !important;
  }

  .command-text-dense {
      font-size: 0.8rem !important;
      line-height: 1.3 !important;
  }
  ```

- [ ] **Task 3.2**: Add category color styling support
  ```css
  /* Add after .command-category styles (around line 2350) */
  .command-category {
      margin-bottom: 32px;
      border-left: 4px solid transparent; /* Placeholder for dynamic color */
      padding-left: 12px;
      transition: border-color 0.2s;
  }

  .command-category-header {
      font-size: 1.1rem;
      font-weight: 700;
      padding: 8px 12px;
      margin-bottom: 16px;
      border-radius: 6px;
      /* Background and color will be set inline via JavaScript */
  }
  ```

**Validation**: Inspect styles in DevTools, verify classes exist

---

### Phase 4: Presentation Layer (60 minutes)

**File**: `index.html` (JavaScript section, lines ~4486-4565)

- [ ] **Task 4.1**: Modify `renderCommandLibrary()` to apply colors and layout
  ```javascript
  function renderCommandLibrary(commandsToRender = commands) {
      const container = document.getElementById('command-list');
      if (!container) return;

      // Empty state
      if (commandsToRender.length === 0) {
          container.innerHTML = `
              <div style="text-align: center; padding: 60px 20px; color: #94a3b8;">
                  <div style="font-size: 4rem; margin-bottom: 16px; opacity: 0.6;">📋</div>
                  <div style="font-size: 1.1rem; margin-bottom: 8px;">暂无命令</div>
                  <div style="font-size: 0.9rem;">点击"添加命令"开始创建您的命令库</div>
              </div>
          `;
          return;
      }

      // Group by category
      const grouped = {};
      commandsToRender.forEach(cmd => {
          const category = cmd.category || 'Uncategorized';
          if (!grouped[category]) grouped[category] = [];
          grouped[category].push(cmd);
      });

      // Get layout params
      const layoutParams = layoutCalculateDensity(window.innerHeight, commandsToRender.length);

      // Render with colors
      let html = '';
      Object.keys(grouped).sort().forEach(category => {
          const { color } = colorAssignCategory(category);
          const bgColor = color + '22'; // Add transparency for background

          html += `<div class="command-category" style="border-left-color: ${color};">
              <div class="command-category-header" style="background: ${bgColor}; color: ${color};">
                  ${category}
              </div>
          `;

          grouped[category].forEach(cmd => {
              const truncatedText = cmd.text.length > 100
                  ? cmd.text.substring(0, 100) + '...'
                  : cmd.text;

              html += `
                  <div class="command-item command-item-dense"
                       draggable="true"
                       ondragstart="handleDragStart(event, '${cmd.id}')"
                       ondragover="handleDragOver(event)"
                       ondrop="handleDrop(event, '${cmd.id}')">
                      <div class="command-info">
                          <div class="command-label command-label-dense">${cmd.label}</div>
                          <div class="command-text command-text-dense" title="${cmd.text}">${truncatedText}</div>
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

**Validation**:
1. Open Commands tab in browser
2. Verify categories have different colors
3. Verify layout is more compact
4. Verify smooth scrolling with many commands

---

### Phase 5: Integration Testing (30 minutes)

**File**: `test-automation.html`

- [ ] **Task 5.1**: Add test section for color assignment
  ```html
  <!-- Add to test-automation.html -->
  <div class="test-section">
      <h3>Feature 006: Category Color Assignment</h3>
      <button onclick="testCategoryColors()">Run Test</button>
      <div id="color-test-results"></div>
  </div>
  <script>
  function testCategoryColors() {
      const results = document.getElementById('color-test-results');
      let passed = 0, failed = 0;

      // Test 1: New category gets color
      const color1 = colorAssignCategory("Test Category 1");
      if (color1.color && color1.isNew) {
          results.innerHTML += '<div style="color:green">✓ New category assignment</div>';
          passed++;
      } else {
          results.innerHTML += '<div style="color:red">✗ New category assignment failed</div>';
          failed++;
      }

      // Test 2: Same category returns same color
      const color2 = colorAssignCategory("Test Category 1");
      if (color2.color === color1.color && !color2.isNew) {
          results.innerHTML += '<div style="color:green">✓ Color persistence</div>';
          passed++;
      } else {
          results.innerHTML += '<div style="color:red">✗ Color persistence failed</div>';
          failed++;
      }

      // Test 3: WCAG compliance
      const palette = colorGetPalette();
      const compliant = palette.every(c => c.contrastRatio >= 4.5);
      if (compliant) {
          results.innerHTML += '<div style="color:green">✓ WCAG AA compliance</div>';
          passed++;
      } else {
          results.innerHTML += '<div style="color:red">✗ WCAG compliance failed</div>';
          failed++;
      }

      results.innerHTML += `<div><strong>Results: ${passed} passed, ${failed} failed</strong></div>`;
  }
  </script>
  ```

- [ ] **Task 5.2**: Add test for layout density
  ```html
  <div class="test-section">
      <h3>Feature 006: Layout Density</h3>
      <button onclick="testLayoutDensity()">Run Test</button>
      <div id="layout-test-results"></div>
  </div>
  <script>
  function testLayoutDensity() {
      const results = document.getElementById('layout-test-results');
      const layout = layoutCalculateDensity(900, 50);

      // Test: 30% density increase
      const baseline = 6; // items per view before
      const target = baseline * 1.3; // 30% increase
      if (layout.itemsPerView >= target) {
          results.innerHTML = `<div style="color:green">✓ Density increase: ${layout.itemsPerView} items (target: ${target})</div>`;
      } else {
          results.innerHTML = `<div style="color:red">✗ Density increase failed: ${layout.itemsPerView} items (target: ${target})</div>`;
      }
  }
  </script>
  ```

**Validation**: Run all tests in browser, verify all pass

---

## Manual Testing Checklist

### Visual Testing

- [ ] Open Commands tab
- [ ] Verify each category has a distinct color
- [ ] Verify category headers have colored background
- [ ] Verify command items have colored left border
- [ ] Verify layout is more compact (more commands visible)
- [ ] Test on mobile (resize browser to 375px width)
- [ ] Verify font sizes remain readable

### Functional Testing

- [ ] Add new command with new category → verify gets new color
- [ ] Reload page → verify colors persist
- [ ] Add 15+ categories → verify colors wrap around palette
- [ ] Test with 500 commands → verify smooth scrolling
- [ ] Test keyboard navigation → verify still works
- [ ] Clear localStorage → verify graceful fallback

### Performance Testing

- [ ] Open DevTools Performance tab
- [ ] Record while switching to Commands tab
- [ ] Verify render time < 50ms
- [ ] Verify 60fps scrolling with 500 commands

---

## Common Issues & Solutions

### Issue 1: Colors don't persist after reload

**Cause**: LocalStorage save failing
**Solution**: Check browser console for errors, verify localStorage quota

### Issue 2: Layout not optimized

**Cause**: CSS classes not applied
**Solution**: Verify `.command-item-dense` classes exist in HTML output

### Issue 3: Colors all the same

**Cause**: `colorAssignCategory()` not called per category
**Solution**: Verify loop iterates over unique categories

### Issue 4: Scrolling laggy with many commands

**Cause**: Too many DOM nodes or reflows
**Solution**: Add `will-change: transform` to `.command-list` CSS

---

## Next Steps

After implementation:

1. **Code Review**: Request review focusing on:
   - Separation of concerns (no render* calling localStorage)
   - Function naming conventions (color*, layout*, render*)
   - WCAG compliance verification

2. **Testing**: Run `/speckit.test` command (when available)

3. **Documentation**: Update CLAUDE.md with new technologies (if any)

4. **Deployment**: Merge to main branch

---

## Quick Reference

**Key Files**:
- `index.html` - All implementation code
- `specs/006-/spec.md` - Requirements
- `specs/006-/plan.md` - Architecture
- `specs/006-/data-model.md` - Data structures
- `specs/006-/contracts/function-interfaces.md` - API contracts

**Key Functions**:
- `colorAssignCategory(name)` - Get/assign color
- `layoutCalculateDensity(height, count)` - Calculate layout
- `renderCommandLibrary(commands)` - Render with enhancements

**Key Constants**:
- `COLOR_PALETTE` - 15 WCAG-compliant colors
- LocalStorage key: `'speckit_category_colors'`

**Estimated Time**: 3-4 hours total (all phases)
