# Implementation Tasks: Command Library Multi-Column Layout

**Feature**: 007-1-20-20 Command Library Multi-Column Layout
**Branch**: `007-1-20-20`
**Date**: 2025-10-17
**Status**: Ready for Implementation

## Task Overview

This tasks.md file provides a complete, dependency-ordered task list for implementing the multi-column layout feature. Tasks are organized into 6 phases following the implementation strategy defined in plan.md and quickstart.md.

**Total Estimated Time**: 4.5 hours
**Target File**: `/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_SpecKit_Automation_Web/index.html`

**Key Principles**:
- Constitution Principle VI: Modularity Mandate (function groups: column*, layout*, render*)
- Constitution Principle VII: Separation of Concerns (Data → Business → Presentation layers)
- Single-file architecture: All code in index.html
- NO automated tests requested (manual testing only)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish foundational constants and CSS infrastructure for multi-column layout
**Duration**: 30 minutes
**Blocks**: All subsequent phases

### Constants

- [ ] T001 [P] Define MIN_COLUMNS constant (value: 1) in index.html JavaScript section after line 3619 (after global variables)
- [ ] T002 [P] Define MAX_COLUMNS constant (value: 20) in index.html JavaScript section after T001
- [ ] T003 [P] Define DEFAULT_COLUMNS constant (value: 4) in index.html JavaScript section after T002

### CSS Grid Foundation

- [ ] T004 Add text overflow handling styles for .command-label and .command-text in index.html CSS section (after existing command styles around line 800-1200): white-space: nowrap, overflow: hidden, text-overflow: ellipsis, min-width: 0
- [ ] T005 Add smooth transition styles for #command-list in index.html CSS section (after existing #command-list styles): transition for grid-template-columns 0.3s ease and gap 0.3s ease
- [ ] T006 Add smooth transition styles for .command-label and .command-text in index.html CSS section: transition for font-size 0.3s ease and line-height 0.3s ease

### Column Selector UI Styles

- [ ] T007 Add .column-selector base styles in index.html CSS section (new section after command styles around line 1200): display flex, align-items center, gap 1rem, padding 1rem, background #f8fafc, border-radius 8px, margin-bottom 1.5rem
- [ ] T008 Add .column-selector label styles in index.html CSS section: font-weight 600, font-size 0.9rem, color #475569
- [ ] T009 Add .column-selector input[type="range"] styles in index.html CSS section: flex 1, max-width 300px
- [ ] T010 Add .column-selector-display styles in index.html CSS section: font-weight 700, font-size 1.1rem, color #2563eb, min-width 2rem, text-align center
- [ ] T011 Add .column-preset-btn styles in index.html CSS section: padding 0.4rem 0.8rem, font-size 0.85rem, background white, border 1px solid #cbd5e1, border-radius 6px, cursor pointer, transition all 0.2s
- [ ] T012 Add .column-preset-btn:hover styles in index.html CSS section: background #2563eb, color white, border-color #2563eb
- [ ] T013 Add .column-preset-btn.active styles in index.html CSS section: background #2563eb, color white, border-color #2563eb

**Phase 1 Validation**:
- Open index.html in browser DevTools
- Verify constants defined in JavaScript console: `console.log(MIN_COLUMNS, MAX_COLUMNS, DEFAULT_COLUMNS)`
- Verify CSS classes exist in Styles panel

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Implement module boundary markers and layer separation per Constitution Principles VI & VII
**Duration**: 15 minutes
**Blocks**: ALL user story implementation (Phase 3, 4, 5)

### Module Boundary Comments (Constitution Principle VI)

- [ ] T014 Add module boundary comment "// ========== DATA ACCESS LAYER: Column Management Module ==========" in index.html JavaScript section after constants (around line 3625)
- [ ] T015 Add module boundary comment "// ========== BUSINESS LOGIC LAYER: Layout Calculation Module ==========" in index.html JavaScript section after Data Access Layer functions will be added (placeholder for after T017-T018)
- [ ] T016 Add module boundary comment "// ========== PRESENTATION LAYER: Command Grid Rendering Module ==========" in index.html JavaScript section after Business Logic Layer functions will be added (placeholder for after T019-T020)

### Layer Separation Markers (Constitution Principle VII)

- [ ] T017 Add inline documentation comment at Data Access Layer section explaining: "Responsibilities: Read/write column preference from localStorage ONLY. Prohibited: DOM manipulation, business logic calculations."
- [ ] T018 Add inline documentation comment at Business Logic Layer section explaining: "Responsibilities: Pure calculations for grid layout and font sizes. Prohibited: DOM manipulation, localStorage access."
- [ ] T019 Add inline documentation comment at Presentation Layer section explaining: "Responsibilities: Update DOM with calculated layout. Prohibited: Direct localStorage access (use column* functions), business logic calculations."

**Phase 2 Validation**:
- Review code structure in editor
- Verify clear visual separation between layers
- Verify comments accurately describe layer responsibilities

**CRITICAL**: This phase MUST be completed before any user story work begins to ensure proper architectural foundation.

---

## Phase 3: User Story 1 - Column Count Selection (Priority: P1) 🎯 MVP

**User Story**: As a user managing a large command library, I want to adjust the number of columns displayed (1-20 columns) so that I can view more commands at once on wide screens or focus on fewer commands on narrow screens.

**Goal**: Enable users to select 1-20 columns with persistence
**Duration**: 90 minutes
**Independent Test**: Select different column counts (1, 5, 10, 20), verify reflow and persistence across page reloads

### Data Access Layer: Column Preference Management

- [ ] T020 [US1] Implement columnLoadPreference() function in index.html Data Access Layer section (after T014 comment, around line 3630): Read 'speckit_column_count' from localStorage, parse as integer, validate range 1-20, return DEFAULT_COLUMNS if invalid/missing, handle errors with try-catch
- [ ] T021 [US1] Implement columnSavePreference(columnCount) function in index.html Data Access Layer section (after T020, around line 3660): Validate input type (number, not NaN), clamp to MIN_COLUMNS-MAX_COLUMNS range, floor to integer, write to localStorage as string, return boolean success status, handle errors with try-catch

### Business Logic Layer: Integration Points Verification

- [ ] T022 [US1] Verify integration points ready: Confirm constants (T001-T003) defined, confirm layer comments (T014-T019) in place, confirm column* functions (T020-T021) implemented

### Presentation Layer: Column Selector UI

- [ ] T023 [US1] Implement renderColumnSelector() function in index.html Presentation Layer section (after T016 comment, around line 3900): Get container element #command-controls, call columnLoadPreference() for current value, build HTML with slider (min=MIN_COLUMNS, max=MAX_COLUMNS, value=currentCount, oninput="handleColumnCountChange(this.value)"), add display span #column-count-display, add preset buttons (1, 4, 8, 12, 20) with onclick="handleColumnCountSet(N)", apply .column-selector styles, insert into DOM
- [ ] T024 [US1] Implement handleColumnCountChange(value) event handler in index.html JavaScript section (after Presentation Layer functions, around line 4000): Parse value as integer, update #column-count-display text, update active button highlighting, call layoutCalculateGrid(count) for preview parameters, call layoutCalculateFontSizes(count) for preview fonts, apply styles to #command-list (gridTemplateColumns, gap), apply font sizes to .command-label, .command-text, .command-category-header elements (live preview without saving)
- [ ] T025 [US1] Implement handleColumnCountSet(count) event handler in index.html JavaScript section (after T024, around line 4050): Call columnSavePreference(count) to persist, update slider value and display, update active button class, call renderCommandLibrary() to re-render with saved preference

### Integration: Modify Existing renderCommandLibrary()

- [ ] T026 [US1] Locate existing renderCommandLibrary() or renderCommandGrid() function in index.html (search for function that renders command list, likely around line 4200-4800)
- [ ] T027 [US1] Add columnLoadPreference() call at start of renderCommandLibrary() function to get current column count
- [ ] T028 [US1] Add CSS Grid styles to #command-list container in renderCommandLibrary(): Set display: grid, gridTemplateColumns: repeat(columnCount, minmax(0, 1fr)), gap: 1rem, width: 100%
- [ ] T029 [US1] Preserve existing command rendering logic in renderCommandLibrary() (category grouping, command items, colors from Feature 006)
- [ ] T030 [US1] Modify switchTab('commands') function in index.html (search for switchTab function, likely around line 5500-6000) to call renderColumnSelector() before renderCommandLibrary() when tabName === 'commands'

**Phase 3 Validation** (Manual Testing):
1. Open index.html in browser, switch to Commands tab
2. Verify column selector appears with slider and preset buttons
3. Move slider to 10 → verify #command-count-display shows "10"
4. Verify commands reflow into 10 columns (live preview)
5. Click preset button "20" → verify layout changes and preference saves
6. Open browser console: `console.log(localStorage.getItem('speckit_column_count'))` → should show "20"
7. Reload page → verify column count remains at 20
8. Test all column counts: 1, 4, 8, 12, 20 → verify layout adapts correctly
9. Test with 0 commands → verify empty state displays correctly
10. Test persistence: Set to 15, reload, verify restored to 15

**Acceptance Criteria (from spec.md US1)**:
- ✅ Can select 1 column → all commands in single vertical column
- ✅ Can select 10 columns → commands distributed across 10 columns
- ✅ Can select 20 columns → commands distributed across 20 columns
- ✅ Column count preference persists across page reloads

---

## Phase 4: User Story 2 - Responsive Font Scaling (Priority: P2)

**User Story**: As a user who selects many columns, I want the font size to automatically adjust so that command text remains readable even when displaying 15-20 columns simultaneously.

**Goal**: Automatically scale fonts based on column count (16px → 10px minimum)
**Duration**: 60 minutes
**Independent Test**: Select 1, 5, 10, 15, 20 columns, verify font sizes scale correctly per segmented formula

### Business Logic Layer: Font Size Calculations

- [ ] T031 [US2] Implement layoutCalculateGrid(columnCount) function in index.html Business Logic Layer section (after T015 comment, around line 3700): Clamp columnCount to MIN_COLUMNS-MAX_COLUMNS range, calculate gridTemplateColumns as "repeat(N, minmax(0, 1fr))", implement segmented font scaling (1-4 cols: 16px constant, 5-8 cols: max(14, 20-(count-4)*0.5), 9-12 cols: max(12, 14-(count-8)*0.5), 13-20 cols: max(10, 12-(count-12)*0.25)), calculate lineHeight (1-4: 1.5, 5-12: 1.3, 13-20: 1.2), calculate itemPadding (fontSize >= 14: 0.75rem, else: 0.5rem), return object {columnCount, gridTemplateColumns, gap: '1rem', itemPadding, fontSize, lineHeight}
- [ ] T032 [US2] Implement layoutCalculateFontSizes(columnCount) function in index.html Business Logic Layer section (after T031, around line 3760): Clamp columnCount to MIN_COLUMNS-MAX_COLUMNS range, implement segmented scaling for detailed sizes (1-4 cols: labelSize=16, textSize=14, headerSize=18, lineHeight=1.5), (5-8 cols: factor=(count-4)*0.5, labelSize=max(14, 20-factor), textSize=max(12, 18-factor), headerSize=max(16, 22-factor), lineHeight=1.4), (9-12 cols: factor=(count-8)*0.5, labelSize=max(12, 14-factor), textSize=max(11, 12-factor), headerSize=max(14, 16-factor), lineHeight=1.3), (13-20 cols: factor=(count-12)*0.25, labelSize=max(10, 12-factor), textSize=max(10, 11-factor), headerSize=max(12, 14-factor), lineHeight=1.2), return object {columnCount, commandLabelSize, commandTextSize, categoryHeaderSize, lineHeight, minReadableSize: 10}

### Presentation Layer: Apply Font Sizes

- [ ] T033 [US2] Modify renderCommandLibrary() function in index.html to call layoutCalculateFontSizes(columnCount) after columnLoadPreference() call (added in T027)
- [ ] T034 [US2] Apply calculated font sizes to category headers in renderCommandLibrary(): Set style.fontSize to fonts.categoryHeaderSize + 'px' in category header HTML
- [ ] T035 [US2] Apply calculated font sizes to command labels in renderCommandLibrary(): Set style.fontSize to fonts.commandLabelSize + 'px' and style.lineHeight to fonts.lineHeight in command label HTML
- [ ] T036 [US2] Apply calculated font sizes to command text in renderCommandLibrary(): Set style.fontSize to fonts.commandTextSize + 'px' and style.lineHeight to fonts.lineHeight in command text HTML

### CSS: Font Scaling Utility Classes (Optional Enhancement)

- [ ] T037 [US2] [P] Add CSS custom property --column-count to #command-list in renderCommandLibrary() for potential CSS-based scaling: container.style.setProperty('--column-count', columnCount)
- [ ] T038 [US2] [P] Add CSS custom property --base-font-size to #command-list for responsive scaling: container.style.setProperty('--base-font-size', fonts.commandLabelSize + 'px')

### Integration: Update renderCommandLibrary() for Dynamic Fonts

- [ ] T039 [US2] Integrate layoutCalculateGrid() call in renderCommandLibrary() function (modify T028 implementation): Store layout object, use layout.gridTemplateColumns, layout.gap, layout.itemPadding
- [ ] T040 [US2] Verify handleColumnCountChange() live preview applies font sizes correctly (modify T024 if needed): Ensure fonts from layoutCalculateFontSizes() are applied to all text elements during slider movement

**Phase 4 Validation** (Manual Testing):
1. Open index.html, switch to Commands tab
2. Set column count to 1 → verify font sizes: category headers ~18px, command labels ~16px, command text ~14px
3. Set column count to 4 → verify same as step 2 (constant range)
4. Set column count to 8 → verify font sizes reduced: labels ~14px, text ~12px, headers ~16px
5. Set column count to 12 → verify font sizes further reduced: labels ~12px, text ~11px, headers ~14px
6. Set column count to 20 → verify font sizes at minimum: labels ~10px, text ~10px, headers ~12px
7. Use browser DevTools to measure actual font sizes, confirm matches expected calculations
8. Test with long command text → verify ellipsis truncation works at all column counts
9. Test readability: Zoom browser to 200% with 20 columns → verify text remains readable

**Acceptance Criteria (from spec.md US2)**:
- ✅ 1-5 columns: font size remains at standard size (~16px)
- ✅ 6-10 columns: font size decreases moderately (~14px)
- ✅ 11-20 columns: font size decreases further but never below 10px
- ✅ All text remains readable without horizontal scrolling

---

## Phase 5: User Story 3 - Layout Integrity (Priority: P3)

**User Story**: As a user switching between different column counts, I want the overall layout to remain stable and properly sized so that the interface never breaks or requires horizontal scrolling.

**Goal**: Prevent horizontal scroll and maintain layout stability at all column counts
**Duration**: 45 minutes
**Independent Test**: Switch rapidly between all column counts (1-20), verify no overflow, smooth transitions

### Business Logic Layer: Grid Layout Validation

- [ ] T041 [US3] Add validation logic to layoutCalculateGrid() function (modify T031): Ensure gridTemplateColumns always uses minmax(0, 1fr) to prevent overflow, validate gap value is rem-based, ensure itemPadding never causes overflow
- [ ] T042 [US3] Add boundary checks to layoutCalculateFontSizes() function (modify T032): Verify all font sizes >= 10px (minReadableSize), verify lineHeight >= 1.2, ensure no fractional pixels that cause rendering issues

### CSS: Grid Container Styles and Overflow Handling

- [ ] T043 [US3] Add overflow prevention styles to #command-list in index.html CSS section (modify existing styles around line 1000-1200): Add overflow-x: hidden, max-width: 100%, box-sizing: border-box
- [ ] T044 [US3] Add overflow prevention styles to .command-item in index.html CSS section: Add box-sizing: border-box, max-width: 100%, overflow: hidden
- [ ] T045 [US3] Add overflow prevention styles to .command-category in index.html CSS section: Add box-sizing: border-box, max-width: 100%
- [ ] T046 [US3] Verify .command-label and .command-text have min-width: 0 (from T004) to allow grid shrinkage

### CSS: Responsive Constraints

- [ ] T047 [US3] [P] Add responsive media query for narrow viewports in index.html CSS section (around line 2700, before </style>): @media (max-width: 600px) { #command-list { grid-template-columns override to max 3 columns, reduce gap to 0.5rem } }
- [ ] T048 [US3] [P] Add responsive media query for tablet viewports: @media (max-width: 900px) { #command-list { grid-template-columns override to max 8 columns } }
- [ ] T049 [US3] [P] Add container query support if needed: #command-list { container-type: inline-size } with @container rules for adaptive column limits

### Presentation Layer: Apply Grid Styles

- [ ] T050 [US3] Modify renderCommandLibrary() to apply comprehensive grid styles (enhance T028, T039): Set container width: 100%, overflow-x: hidden, ensure display: grid with calculated gridTemplateColumns
- [ ] T051 [US3] Add empty state spanning full grid width in renderCommandLibrary(): Use style="grid-column: 1 / -1;" on empty state div to span all columns
- [ ] T052 [US3] Ensure category grouping respects grid layout in renderCommandLibrary(): Set .command-category to grid-column: span 1, allow categories to flow naturally

### Integration: Full Multi-Column Layout Rendering

- [ ] T053 [US3] Add smooth transition coordination in handleColumnCountChange() (modify T024): Ensure all style updates happen in single animation frame using requestAnimationFrame
- [ ] T054 [US3] Add layout stability check in handleColumnCountSet() (modify T025): After renderCommandLibrary(), verify #command-list.scrollWidth <= #command-list.clientWidth (no horizontal overflow)
- [ ] T055 [US3] Add window resize handler in index.html JavaScript section (around line 7400, before </script>): window.addEventListener('resize', debounce(() => { if (currentTab === 'commands') renderCommandLibrary(); }, 300)); to handle viewport changes

**Phase 5 Validation** (Manual Testing):
1. Open index.html, switch to Commands tab with 100+ commands loaded
2. Rapidly switch between all column counts: 1, 5, 10, 15, 20, 15, 10, 5, 1
3. Verify NO horizontal scrollbar appears at any column count
4. Measure #command-list width in DevTools → should never exceed viewport width
5. Resize browser window from 1920px to 800px → verify layout adapts without overflow
6. Set to 20 columns, check all command items visible and properly aligned
7. Verify smooth transitions (0.3s ease) between column count changes
8. Test with long command text (100+ chars) → verify ellipsis prevents overflow
9. Test category grouping: Categories should stay together, flow into columns naturally
10. Stress test: Add 500 commands, switch to 20 columns → verify vertical scrolling works, no horizontal scroll

**Acceptance Criteria (from spec.md US3)**:
- ✅ Any column count 1-20: container fits within viewport, no horizontal scrolling
- ✅ Switching 2 → 20 columns: all items remain visible and aligned
- ✅ 100+ commands: vertical scrolling works smoothly without layout shifts
- ✅ Browser resize: layout gracefully adjusts (optional responsive behavior)

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final quality validation, performance verification, documentation
**Duration**: 30 minutes
**Dependencies**: Phases 1-5 complete

### Code Quality Validation

- [ ] T056 Review all column* functions for layer compliance: Verify NO DOM manipulation (document.getElementById, innerHTML, style), verify NO business logic calculations (font sizes, layout), ONLY localStorage operations
- [ ] T057 Review all layout* functions for purity: Verify NO side effects (NO DOM, NO localStorage, NO console.log in production), verify deterministic output (same input = same output), verify execution time < 1ms
- [ ] T058 Review all render* functions for abstraction usage: Verify NO direct localStorage.getItem/setItem calls (MUST use columnLoadPreference/columnSavePreference), verify NO business logic (MUST use layoutCalculateGrid/layoutCalculateFontSizes), ONLY DOM manipulation
- [ ] T059 Verify function naming conventions followed: column* for data access, layout* for business logic, render* for presentation, handle* for event handlers

### Performance Testing (Manual Benchmarking)

- [ ] T060 Benchmark layoutCalculateGrid() execution time: Add console.time/timeEnd in browser console, call function 1000 times, verify average < 1ms
- [ ] T061 Benchmark layoutCalculateFontSizes() execution time: Same as T060, verify < 1ms
- [ ] T062 Benchmark renderCommandLibrary() with 100 commands: Use performance.now() before/after call, verify < 50ms total render time
- [ ] T063 Benchmark column count change transition: Measure time from handleColumnCountSet() call to visual completion, verify < 1 second, verify smooth 60fps animation

### Layer Compliance Verification

- [ ] T064 Run layer violation checks in browser console: Spy on localStorage.getItem in render* functions (should NOT be called directly), verify render* functions call columnLoadPreference instead
- [ ] T065 Verify unidirectional data flow: render* → layout* → column*, NO reverse calls, NO circular dependencies
- [ ] T066 Review code structure in editor: Verify clear visual separation with module boundary comments (T014-T016), verify layer documentation comments (T017-T019) accurate

### Documentation Updates

- [ ] T067 Update index.html inline comments: Add JSDoc comments to all new functions (column*, layout*, render*, handle*) with @param, @returns, @description
- [ ] T068 [P] Update CLAUDE.md if needed: Verify "Recent Changes" section, add Feature 007-1-20-20 entry (likely not needed as no new technologies introduced)
- [ ] T069 Create manual testing checklist document: Copy validation steps from Phase 3-5 into standalone test checklist for future regression testing

**Phase 6 Validation** (Final Quality Check):
1. Code review checklist: All layer compliance items verified
2. Performance benchmarks: All timing targets met (< 1ms calculations, < 50ms render, < 1s transitions)
3. Manual testing: All acceptance criteria from spec.md met for US1, US2, US3
4. Documentation: All functions documented, CLAUDE.md updated if needed

---

## Dependencies

### Phase Dependencies

```
Phase 1 (Setup)
    ↓
Phase 2 (Foundational) ← BLOCKS all user story work
    ↓
    ├─→ Phase 3 (US1: Column Count Selection) ← MVP Foundation
    │       ↓
    ├─→ Phase 4 (US2: Responsive Font Scaling) ← Depends on US1 (column selection must exist first)
    │       ↓
    └─→ Phase 5 (US3: Layout Integrity) ← Depends on US1 + US2 (builds on layout and fonts)
            ↓
        Phase 6 (Polish) ← Depends on Phases 3, 4, 5 complete
```

### User Story Dependencies

**US1 (Column Count Selection)** - P1, MVP
- Independent: Can be fully implemented and tested without US2 or US3
- Provides: Column preference persistence, basic column layout, UI controls
- Test independently: Select columns 1-20, verify reflow, verify persistence

**US2 (Responsive Font Scaling)** - P2
- Depends on: US1 (column selection mechanism must exist)
- Independent testing: Given column count, verify font sizes scale correctly
- Can be tested separately by calling layoutCalculateFontSizes(count) directly

**US3 (Layout Integrity)** - P3
- Depends on: US1 (grid layout) + US2 (font scaling)
- Independent testing: Rapidly switch column counts, verify no overflow
- Enhances: Existing US1 and US2 functionality with polish and stability

### Within-Story Task Dependencies

**Phase 3 (US1) Task Dependencies**:
```
T020, T021 (Data Access) ← Can be done in parallel
    ↓
T022 (Verification) ← Requires T001-T003, T014-T019, T020-T021
    ↓
T023, T024, T025 (Presentation) ← Can be done in parallel after T022
    ↓
T026-T030 (Integration) ← Sequential: Must locate existing code first (T026), then modify (T027-T030)
```

**Phase 4 (US2) Task Dependencies**:
```
T031, T032 (Business Logic) ← Can be done in parallel
    ↓
T033-T036 (Apply Fonts) ← Sequential: Must modify renderCommandLibrary in order
    ↓
T037-T040 (Integration & Enhancement) ← Can be done in parallel after T033-T036
```

**Phase 5 (US3) Task Dependencies**:
```
T041, T042 (Validation Logic) ← Modify existing functions, can be parallel
    ↓
T043-T049 (CSS Overflow Prevention) ← Can be done in parallel (all CSS additions)
    ↓
T050-T052 (Presentation Grid Styles) ← Sequential: Must modify renderCommandLibrary
    ↓
T053-T055 (Integration Enhancements) ← Can be done in parallel
```

### Parallel Opportunities (Per Story)

**Phase 1**: T001-T003 parallel, T004-T006 parallel, T007-T013 parallel
**Phase 2**: T014-T016 parallel (different sections), T017-T019 parallel
**Phase 3 US1**: T020-T021 parallel, T023-T025 parallel after T022
**Phase 4 US2**: T031-T032 parallel, T037-T038 parallel, T039-T040 parallel
**Phase 5 US3**: T041-T042 parallel, T043-T046 parallel, T047-T049 parallel, T053-T055 parallel
**Phase 6**: T056-T059 parallel (code review), T060-T063 parallel (benchmarking), T064-T066 parallel (verification)

---

## Implementation Strategy

### MVP-First Approach

**MVP = Phase 1 + Phase 2 + Phase 3 (US1 only)**
- Duration: ~2.5 hours
- Deliverables: Column count selector (1-20), basic CSS Grid layout, localStorage persistence
- Test: Select different column counts, verify reflow and persistence

**Incremental = MVP + Phase 4 (US2)**
- Duration: +1 hour (total 3.5 hours)
- Adds: Responsive font scaling (16px → 10px), segmented scaling algorithm
- Test: Verify font sizes scale correctly at all column counts

**Complete = Incremental + Phase 5 (US3)**
- Duration: +0.75 hours (total 4.25 hours)
- Adds: Layout integrity, overflow prevention, responsive constraints
- Test: Rapid column switching, stress test with 500 commands

**Polished = Complete + Phase 6**
- Duration: +0.5 hours (total 4.75 hours)
- Adds: Code quality verification, performance benchmarks, documentation
- Test: Full acceptance criteria validation

### Recommended Workflow

1. **Day 1 Morning (2.5 hours)**: Implement MVP (Phases 1-3)
   - Checkpoint: Column selection works, preference persists

2. **Day 1 Afternoon (1 hour)**: Add font scaling (Phase 4)
   - Checkpoint: Fonts scale appropriately at all column counts

3. **Day 2 Morning (1.25 hours)**: Add layout integrity and polish (Phases 5-6)
   - Checkpoint: Production-ready, all acceptance criteria met

---

## Manual Testing Guidance

### Test Scenarios by Phase

**Phase 3 (US1) Manual Tests**:
1. First-time user: Clear localStorage, reload, verify default 4 columns
2. Column selection: Try all values 1-20, verify reflow
3. Persistence: Set to 15, reload, verify restored
4. Invalid data: Manually set localStorage to "invalid", reload, verify resets to default

**Phase 4 (US2) Manual Tests**:
1. Font scaling verification: Set to 1, 4, 8, 12, 20 cols, measure actual font sizes in DevTools
2. Minimum size enforcement: Set to 20 cols, verify no text < 10px
3. Readability test: Zoom browser to 200%, verify text readable at all column counts

**Phase 5 (US3) Manual Tests**:
1. Overflow prevention: Set to 20 cols, measure container width, verify no horizontal scroll
2. Rapid switching: Switch 1→20→1→20 quickly, verify smooth transitions, no layout breaks
3. Stress test: Add 500 commands, set to 20 cols, verify vertical scroll works, no horizontal scroll
4. Window resize: Resize browser 1920px→800px→1920px, verify layout stable

### Cross-Phase Integration Tests

1. **End-to-end**: Clear localStorage → Open app → Switch to Commands tab → Select 10 cols → Reload → Verify 10 cols restored with correct fonts and no overflow
2. **Edge cases**: Try 0 commands (empty state), 1 command (single item), 1000 commands (performance)
3. **Browser compatibility**: Test in Chrome, Firefox, Safari, Edge (modern versions)

---

## Success Metrics

**Completion Criteria**:
- ✅ All tasks T001-T069 marked complete
- ✅ All manual tests passed (Phases 3-5)
- ✅ All acceptance criteria met (spec.md US1, US2, US3)
- ✅ Performance benchmarks met (< 1ms calculations, < 50ms render, 60fps transitions)
- ✅ Layer compliance verified (no cross-layer violations)
- ✅ Constitution Principles VI & VII followed

**Measurable Outcomes (from spec.md)**:
- SC-001: ✅ Users can select 1-20 columns, commands reflow immediately
- SC-002: ✅ Font sizes scale appropriately, no text < 12px equivalent (10px enforced)
- SC-003: ✅ No horizontal scrolling at any column count 1-20
- SC-004: ✅ Column preference persists with 100% reliability
- SC-005: ✅ Column switching completes in < 1 second
- SC-006: ✅ At 20 cols on 1920px display, items ≥ 80px wide, text legible
- SC-007: ✅ Existing features (colors, search, drag-drop) work in all column layouts

---

## Notes

**File Location**: All implementation in `/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_SpecKit_Automation_Web/index.html`

**Line Number References**:
- CSS section: Lines 9-2788
- JavaScript section: Lines 2789-7480
- Constants area: Around line 3619 (after global variables)
- Data Access Layer: Around line 3630 (to be added)
- Business Logic Layer: Around line 3700 (to be added)
- Presentation Layer: Around line 3900 (to be added)
- Event Handlers: Around line 4000 (to be added)
- Existing renderCommandLibrary: Around line 4200-4800 (to be located)
- Existing switchTab: Around line 5500-6000 (to be located)

**Key localStorage Key**: `speckit_column_count` (string representation of integer 1-20)

**Critical CSS Techniques**:
- CSS Grid: `repeat(N, minmax(0, 1fr))` for equal-width columns
- Text overflow: `white-space: nowrap; overflow: hidden; text-overflow: ellipsis; min-width: 0;`
- Smooth transitions: `transition: grid-template-columns 0.3s ease;`

**Critical JavaScript Patterns**:
- Segmented font scaling: Different formulas for 1-4, 5-8, 9-12, 13-20 column ranges
- Layer separation: column* (data) → layout* (business) → render* (presentation)
- Error handling: try-catch for localStorage, default fallbacks, no thrown errors

**Constitution Compliance Checklist**:
- [ ] Function naming conventions followed (column*, layout*, render*)
- [ ] Layer separation enforced (NO cross-layer calls)
- [ ] Module boundary comments present (T014-T016)
- [ ] NO direct localStorage access in render* functions
- [ ] NO business logic in column* or render* functions
- [ ] NO DOM manipulation in column* or layout* functions

---

**End of tasks.md**
