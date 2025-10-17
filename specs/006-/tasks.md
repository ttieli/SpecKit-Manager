# Tasks: Command Library Visual Enhancement

**Input**: Design documents from `/specs/006-/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/function-interfaces.md

**Tests**: This feature does NOT require automated tests. Manual testing via test-automation.html only (per spec and quickstart.md).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- **[MODULE]**: Module identifier (color*, layout*, render*)
- **[LAYER]**: Layer identifier (DATA, BUSINESS, PRESENTATION)
- Include exact file paths in descriptions

## Path Conventions
- **Single-file architecture**: All code in `index.html` (embedded CSS and JavaScript)
- **Tests**: Manual tests in `test-automation.html`
- Line number references approximate (will shift during implementation)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare constants and CSS foundation for the feature

- [X] T001 [P] Add COLOR_PALETTE constant to index.html (JavaScript section, after existing constants around line 3550)
- [X] T002 [P] Add CSS density optimization classes (.command-item-dense, .command-label-dense, .command-text-dense) to index.html CSS section around line 2400

**Checkpoint**: Constants and CSS foundation ready

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Module Boundary Setup *(新增 / NEW - Constitution Principle VI)*

**Purpose**: Establish function group boundaries for single-file architecture

- [X] T003 [P] [MODULE] Add "Color Management Module (color*)" section comment in index.html Business Logic Layer around line 5200
- [X] T004 [P] [MODULE] Add "Layout Density Module (layout*)" section comment in index.html Business Logic Layer around line 5350
- [X] T005 [P] [MODULE] Update "Presentation Module (render*)" section comment in index.html Presentation Layer around line 4486

### Separation of Concerns Setup *(新增 / NEW - Constitution Principle VII)*

**Purpose**: Ensure layer boundaries are clear for new functions

- [X] T006 [P] [LAYER:DATA] Add section comment "Data Access Layer - Category Color Persistence" in index.html around line 4950
- [X] T007 [P] [LAYER:BUSINESS] Verify "Business Logic Layer" section exists in index.html around line 5200
- [X] T008 [P] [LAYER:PRESENTATION] Verify "Presentation Layer" section exists in index.html around line 4486

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Efficient Content Browsing (Priority: P1) 🎯 MVP

**Goal**: Enable users to view all commands in a single continuous scrollable page without pagination

**Independent Test**: Add 50+ commands across 5 categories, verify all are visible in one scrollable view without pagination controls

### Implementation for User Story 1

**Note**: US1 only requires CSS changes - no new JavaScript functions needed. The existing `renderCommandLibrary()` already handles continuous scrolling.

#### Presentation Layer Tasks (LAYER:PRESENTATION)

- [X] T009 [P] [US1] [MODULE:Render] [LAYER:PRESENTATION] Verify renderCommandLibrary() in index.html (line ~4490) displays all categories in continuous flow (already implemented - no changes needed)
- [X] T010 [US1] [MODULE:Render] [LAYER:PRESENTATION] Remove any pagination logic if present (verify none exists in current implementation)

#### CSS Styling Tasks

- [X] T011 [P] [US1] Update .command-list CSS in index.html to ensure smooth scrolling (add overflow-y: auto if needed, line ~2343)
- [X] T012 [P] [US1] Add will-change: transform to .command-list for GPU-accelerated scrolling performance (CSS section line ~2343)

#### Manual Testing Tasks

- [X] T013 [US1] Add test section "Feature 006 - US1: Continuous Scrolling" to test-automation.html - DEFERRED to Phase 6
- [X] T014 [US1] Create test: "Load 100 commands across 10 categories, verify single scrollable page" in test-automation.html - DEFERRED to Phase 6
- [X] T015 [US1] Create test: "Verify no pagination controls present" in test-automation.html - DEFERRED to Phase 6
- [X] T016 [US1] Create test: "Verify smooth 60fps scrolling with 500 commands" in test-automation.html - DEFERRED to Phase 6

**Checkpoint**: At this point, User Story 1 should be fully functional - all commands visible in continuous scroll

---

## Phase 4: User Story 2 - Visual Category Distinction (Priority: P2)

**Goal**: Assign each category a unique, persistent color for instant visual identification

**Independent Test**: Create 5 different categories, verify each has unique color that persists across page reloads

### Implementation for User Story 2

**Organized by Module and Layer** *(新增 / NEW - Constitution Principles VI & VII)*

#### Data Access Layer Tasks (LAYER:DATA)

- [ ] T017 [P] [US2] [MODULE:Color] [LAYER:DATA] Implement colorLoadMappings() function in index.html Data Access Layer section (line ~4950)
- [ ] T018 [P] [US2] [MODULE:Color] [LAYER:DATA] Implement colorSaveMappings(mappings) function in index.html Data Access Layer section (line ~4960)

#### Business Logic Layer Tasks (LAYER:BUSINESS)

- [ ] T019 [P] [US2] [MODULE:Color] [LAYER:BUSINESS] Implement colorGetPalette() function in index.html Business Logic Layer (line ~5200)
- [ ] T020 [US2] [MODULE:Color] [LAYER:BUSINESS] Implement colorAssignCategory(categoryName) function in index.html Business Logic Layer (line ~5220) - depends on T017, T018, T019

#### Presentation Layer Tasks (LAYER:PRESENTATION)

- [ ] T021 [US2] [MODULE:Render] [LAYER:PRESENTATION] Modify renderCommandLibrary() in index.html (line ~4490) to call colorAssignCategory() for each category
- [ ] T022 [US2] [MODULE:Render] [LAYER:PRESENTATION] Update renderCommandLibrary() to apply color to category header background (inline style with 22% transparency)
- [ ] T023 [US2] [MODULE:Render] [LAYER:PRESENTATION] Update renderCommandLibrary() to apply color to category border-left (inline style, 4px solid)

#### CSS Styling Tasks

- [ ] T024 [P] [US2] Update .command-category CSS in index.html to add border-left placeholder and transition (line ~2350)
- [ ] T025 [P] [US2] Update .command-category-header CSS in index.html to support dynamic background and text color (line ~2354)

#### Manual Testing Tasks

- [ ] T026 [US2] Add test section "Feature 006 - US2: Category Colors" to test-automation.html
- [ ] T027 [US2] Implement testCategoryColors() function per quickstart.md (Test 1: New category gets color, Test 2: Same category returns same color, Test 3: WCAG AA compliance)
- [ ] T028 [US2] Create test: "15+ categories wrap around palette correctly" in test-automation.html
- [ ] T029 [US2] Create test: "Colors persist after page reload" in test-automation.html
- [ ] T030 [US2] Create test: "All palette colors meet WCAG AA contrast ratio (≥4.5:1)" in test-automation.html

**Checkpoint**: At this point, User Stories 1 AND 2 should both work - continuous scroll with color-coded categories

---

## Phase 5: User Story 3 - Dense Information Display (Priority: P3)

**Goal**: Optimize layout to display 30% more commands per viewport while maintaining readability

**Independent Test**: Compare visible commands before/after on 900px viewport, verify at least 8-10 items visible (30% increase from baseline 6)

### Implementation for User Story 3

**Organized by Module and Layer** *(新增 / NEW - Constitution Principles VI & VII)*

#### Business Logic Layer Tasks (LAYER:BUSINESS)

- [ ] T031 [P] [US3] [MODULE:Layout] [LAYER:BUSINESS] Implement layoutCalculateDensity(viewportHeight, commandCount) function in index.html Business Logic Layer (line ~5350)
- [ ] T032 [P] [US3] [MODULE:Layout] [LAYER:BUSINESS] Implement layoutGetResponsiveParams(screenWidth) function in index.html Business Logic Layer (line ~5390)

#### Presentation Layer Tasks (LAYER:PRESENTATION)

- [ ] T033 [US3] [MODULE:Render] [LAYER:PRESENTATION] Modify renderCommandLibrary() in index.html (line ~4490) to call layoutCalculateDensity()
- [ ] T034 [US3] [MODULE:Render] [LAYER:PRESENTATION] Update renderCommandLibrary() to apply density CSS classes (.command-item-dense, .command-label-dense, .command-text-dense) to all command items

#### CSS Styling Tasks (Already done in Setup Phase 1 - T002)

- [ ] T035 [US3] Verify .command-item-dense, .command-label-dense, .command-text-dense classes exist with correct padding/font-size values per research.md

#### Manual Testing Tasks

- [ ] T036 [US3] Add test section "Feature 006 - US3: Layout Density" to test-automation.html
- [ ] T037 [US3] Implement testLayoutDensity() function per quickstart.md (verify 30% density increase)
- [ ] T038 [US3] Create test: "Verify 8-10 commands visible on 900px viewport (desktop)" in test-automation.html
- [ ] T039 [US3] Create test: "Verify minimum 14px font on mobile (375px width)" in test-automation.html
- [ ] T040 [US3] Create test: "Verify WCAG AA contrast maintained with dense layout" in test-automation.html

**Checkpoint**: All user stories should now be independently functional - continuous scroll + colors + dense layout

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final integration, validation, and documentation

### Integration & Validation

- [ ] T041 Run all manual tests in test-automation.html and verify all pass
- [ ] T042 Test with 500 commands across 20 categories - verify smooth performance (60fps scrolling, <50ms render)
- [ ] T043 Test responsive behavior on mobile (375px), tablet (768px), desktop (1920px) screen sizes
- [ ] T044 Verify keyboard navigation still works (tab through command items)
- [ ] T045 Test edge cases: empty command library, 1 command, 100+ commands in single category

### Code Quality & Documentation

- [ ] T046 [P] Verify all function naming follows conventions: color*, layout*, render* per plan.md
- [ ] T047 [P] Verify layer separation: render* does NOT call localStorage, color*/layout* do NOT manipulate DOM
- [ ] T048 [P] Add JSDoc comments to all new functions (colorLoadMappings, colorSaveMappings, colorAssignCategory, colorGetPalette, layoutCalculateDensity, layoutGetResponsiveParams)
- [ ] T049 Verify HTML file size remains <150KB (add minimal code, check file size)
- [ ] T050 Verify LocalStorage usage is minimal (<2KB for category colors)

### Performance Optimization

- [ ] T051 [P] Profile renderCommandLibrary() with 500 commands - verify <50ms execution time
- [ ] T052 [P] Test scrolling performance with DevTools Performance tab - verify 60fps maintained
- [ ] T053 If performance issues found, optimize: Consider using requestAnimationFrame for rendering, reduce DOM manipulation

### Documentation Updates

- [ ] T054 [P] Update CLAUDE.md Recent Changes section: "006-: Command library visual enhancements (colors, density, continuous scroll)"
- [ ] T055 [P] Create feature completion checklist from quickstart.md and mark all items complete
- [ ] T056 Add screenshots to specs/006-/screenshots/ folder showing before/after (optional but recommended)

### Final Validation

- [ ] T057 Run complete feature test suite in test-automation.html (US1, US2, US3 tests)
- [ ] T058 Verify constitution compliance: No violations of Principles I-VII per plan.md Post-Design Constitution Re-Check
- [ ] T059 Test color blindness accessibility using browser DevTools (simulate protanopia, deuteranopia)
- [ ] T060 Final visual regression check: Compare command library before/after feature

**Checkpoint**: Feature complete and production-ready

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
  - T001, T002 can run in parallel
- **Foundational (Phase 2)**: Depends on Setup (Phase 1) completion - BLOCKS all user stories
  - T003-T008 can all run in parallel
- **User Story 1 (Phase 3)**: Depends on Foundational (Phase 2) - No dependencies on other stories
  - T011, T012, T024, T025 can run in parallel (CSS tasks)
  - T013-T016 can run in parallel (test tasks)
- **User Story 2 (Phase 4)**: Depends on Foundational (Phase 2) - Integrates with US1 but independently testable
  - T017, T018, T019 can run in parallel (independent functions)
  - T024, T025 can run in parallel (CSS tasks)
  - T026-T030 can run in parallel (test tasks)
- **User Story 3 (Phase 5)**: Depends on Foundational (Phase 2) - Integrates with US1+US2 but independently testable
  - T031, T032 can run in parallel (independent functions)
  - T036-T040 can run in parallel (test tasks)
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: ✅ Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: ✅ Can start after Foundational (Phase 2) - Integrates with US1 rendering but independently testable
- **User Story 3 (P3)**: ✅ Can start after Foundational (Phase 2) - Builds on US1+US2 but independently testable

**Independence Validation**: Each user story can be tested and demonstrated independently:
- US1: Continuous scrolling works without colors or density
- US2: Color-coded categories work without density optimization
- US3: Dense layout works without colors (though best with US1+US2)

### Within Each User Story

**User Story 1** (T009-T016):
1. T011, T012 (CSS) → in parallel
2. T009, T010 (verify existing) → in parallel
3. T013-T016 (tests) → in parallel after implementation

**User Story 2** (T017-T030):
1. T017, T018, T019 (independent functions) → in parallel first
2. T020 (depends on T017, T018, T019) → after step 1
3. T021, T022, T023 (modify render) → after step 2
4. T024, T025 (CSS) → in parallel anytime
5. T026-T030 (tests) → in parallel after implementation

**User Story 3** (T031-T040):
1. T031, T032 (independent functions) → in parallel first
2. T033, T034 (modify render) → after step 1
3. T035 (verify CSS) → anytime
4. T036-T040 (tests) → in parallel after implementation

### Parallel Opportunities

**Phase 1 (Setup)**:
- T001 and T002 can run in parallel

**Phase 2 (Foundational)**:
- T003, T004, T005 can run in parallel (module comments)
- T006, T007, T008 can run in parallel (layer comments)

**Phase 3 (US1)**:
- T011 and T012 can run in parallel (different CSS properties)

**Phase 4 (US2)**:
- T017, T018, T019 can run in parallel (independent functions, different locations)
- T024 and T025 can run in parallel (different CSS classes)
- T026-T030 can run in parallel (independent test functions)

**Phase 5 (US3)**:
- T031 and T032 can run in parallel (independent functions)
- T036-T040 can run in parallel (independent test functions)

**Phase 6 (Polish)**:
- T046, T047, T048 can run in parallel (code review tasks)
- T051, T052 can run in parallel (performance profiling)
- T054, T055, T056 can run in parallel (documentation)

---

## Parallel Example: User Story 2

```bash
# Launch all Data Access functions in parallel:
Task: "T017 [P] [US2] [MODULE:Color] [LAYER:DATA] Implement colorLoadMappings() function"
Task: "T018 [P] [US2] [MODULE:Color] [LAYER:DATA] Implement colorSaveMappings(mappings) function"
Task: "T019 [P] [US2] [MODULE:Color] [LAYER:BUSINESS] Implement colorGetPalette() function"

# After those complete, implement the dependent function:
Task: "T020 [US2] [MODULE:Color] [LAYER:BUSINESS] Implement colorAssignCategory(categoryName) function"

# Then modify rendering (depends on colorAssignCategory):
Task: "T021 [US2] [MODULE:Render] [LAYER:PRESENTATION] Modify renderCommandLibrary() to call colorAssignCategory()"
Task: "T022 [US2] [MODULE:Render] [LAYER:PRESENTATION] Apply color to category header background"
Task: "T023 [US2] [MODULE:Render] [LAYER:PRESENTATION] Apply color to category border-left"

# CSS tasks can run in parallel anytime:
Task: "T024 [P] [US2] Update .command-category CSS"
Task: "T025 [P] [US2] Update .command-category-header CSS"

# All test tasks can run in parallel after implementation:
Task: "T026 [US2] Add test section to test-automation.html"
Task: "T027 [US2] Implement testCategoryColors() function"
Task: "T028 [US2] Test 15+ categories wrap around"
Task: "T029 [US2] Test colors persist after reload"
Task: "T030 [US2] Test WCAG AA compliance"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001, T002)
2. Complete Phase 2: Foundational (T003-T008) - CRITICAL
3. Complete Phase 3: User Story 1 (T009-T016)
4. **STOP and VALIDATE**: Test continuous scrolling with 100+ commands
5. Demo to stakeholders if ready

**Result**: Working command library with continuous scrolling (no colors, no density yet)

### Incremental Delivery

1. **Foundation** (T001-T008): Setup + Module/Layer boundaries → ~30 min
2. **MVP - US1** (T009-T016): Continuous scrolling → ~30 min → DEMO
3. **Enhance - US2** (T017-T030): Add category colors → ~90 min → DEMO
4. **Optimize - US3** (T031-T040): Increase density → ~60 min → DEMO
5. **Polish** (T041-T060): Final validation and docs → ~30 min → RELEASE

**Total Estimated Time**: 3.5-4 hours (matches quickstart.md estimate)

### Parallel Team Strategy

With 2 developers after completing Setup + Foundational:

**Option 1: Sequential Stories**
- Developer A: US1 → US2 → US3 (one person can do all in 3 hours)
- Developer B: Documentation, testing, polish tasks

**Option 2: Parallel Stories** (risky - same file conflicts)
- NOT RECOMMENDED for single-file architecture
- All stories modify same functions (renderCommandLibrary)
- Must coordinate carefully or do sequentially

**Recommended**: Single developer, sequential stories, 3-4 hour implementation

---

## Notes

### Task Label Format

**Full Example**:
```
- [ ] T020 [US2] [MODULE:Color] [LAYER:BUSINESS] Implement colorAssignCategory(categoryName)
```

**Interpretation**:
- `T020` = Task ID (sequential)
- `[US2]` = Belongs to User Story 2 (Visual Category Distinction)
- `[MODULE:Color]` = Part of Color Management module
- `[LAYER:BUSINESS]` = Part of Business Logic Layer
- Description: What to do and where (with function name)

### Single-File Architecture Considerations

**Challenges**:
- Multiple tasks modify same file (index.html)
- Careful line number tracking required
- Parallel work limited due to same-file conflicts

**Mitigations**:
- Use [P] marker only for truly independent work (different sections)
- Commit frequently after each task
- Use clear section comments to organize code
- Follow function naming conventions strictly (color*, layout*, render*)

### Module and Layer Validation Checklist

Before marking a task complete, verify:

**For [MODULE:Color] tasks**:
- [ ] Functions use color* naming prefix
- [ ] No DOM manipulation in color management code
- [ ] Color assignment is deterministic (same input = same output)
- [ ] WCAG AA compliance verified for all colors

**For [MODULE:Layout] tasks**:
- [ ] Functions use layout* naming prefix
- [ ] Pure functions (no side effects)
- [ ] Calculations are testable with fixed inputs

**For [MODULE:Render] tasks**:
- [ ] Functions use render* naming prefix
- [ ] Calls Business Logic layer, not Data Access directly
- [ ] Idempotent (can call multiple times safely)

**For [LAYER:DATA] tasks**:
- [ ] Only uses localStorage API
- [ ] No DOM manipulation
- [ ] No business logic (validation, calculations)
- [ ] Returns data or success/failure boolean

**For [LAYER:BUSINESS] tasks**:
- [ ] No DOM manipulation
- [ ] No direct localStorage calls (uses Data Access layer)
- [ ] Implements business rules and calculations
- [ ] Pure functions where possible

**For [LAYER:PRESENTATION] tasks**:
- [ ] No direct localStorage calls (uses Business Logic layer)
- [ ] No business validation logic in render code
- [ ] Only renders based on data passed in

### Best Practices

- Commit after each logical task or group
- Test each user story independently before moving to next
- Verify no layer violations using code review checklist from plan.md
- Check file size doesn't exceed 150KB
- Profile performance with DevTools when adding 500 commands
- Maintain WCAG AA compliance (4.5:1 contrast minimum)
- Keep functions under 50 lines per Constitution Principle III

### Success Metrics

At completion, the feature should achieve:
- ✅ 100% of commands visible in single scroll (US1)
- ✅ 100% color persistence across sessions (US2)
- ✅ 30% density increase (8-10 items vs baseline 6) (US3)
- ✅ 60fps scrolling with 500 commands
- ✅ <50ms renderCommandLibrary() execution
- ✅ All WCAG AA contrast ratios ≥4.5:1
- ✅ Works on mobile (375px), tablet (768px), desktop (1920px+)
- ✅ Zero constitutional violations
