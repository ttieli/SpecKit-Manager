# Tasks: Cycle Management for Project Iterations

**Input**: Design documents from `/specs/004-/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Manual testing via test-automation.html (no automated test tasks - manual validation per acceptance scenarios)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions
- **Single-file architecture**: All code in `index.html`
- Manual tests in `test-automation.html`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project preparation and validation

- [X] T001 Verify index.html exists and current file size (target: <228KB before changes, <250KB after)
- [X] T002 Backup current index.html to specs/004-/backup-index.html for rollback safety
- [X] T003 [P] Read existing code structure in index.html to identify insertion points for new functions

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Module Boundary Setup *(Constitution Principle VI - Single-File Adaptation)*

- [X] T004 [P] [MODULE] Add "CYCLE MANAGEMENT - DATA ACCESS LAYER" section comment in index.html after existing data layer functions
- [X] T005 [P] [MODULE] Add "CYCLE MANAGEMENT - BUSINESS LOGIC LAYER" section comment in index.html after existing business logic functions
- [X] T006 [P] [MODULE] Add "CYCLE MANAGEMENT - PRESENTATION LAYER" section comment in index.html after existing presentation functions
- [X] T007 [P] [MODULE] Add "CYCLE MANAGEMENT - EVENT HANDLER LAYER" section comment in index.html after existing event handlers
- [X] T008 [MODULE] Add test section "Cycle Management Tests" in test-automation.html with subsections for each function group

### Separation of Concerns Setup *(Constitution Principle VII - Single-File Adaptation)*

- [X] T009 [P] [LAYER:DATA] Add code review checklist entry in plan.md: "No render* functions in cycle management call localStorage"
- [X] T010 [P] [LAYER:BUSINESS] Add code review checklist entry in plan.md: "No cycleManagement* functions manipulate DOM"
- [X] T011 [P] [LAYER:PRESENTATION] Add code review checklist entry in plan.md: "No render* functions call saveProjects() directly"
- [X] T012 [LAYER] Document layer call chain: Event Handler → Presentation → Business Logic → Data Access in plan.md

### Data Migration Foundation

- [X] T013 [LAYER:DATA] Implement migrateIterationToCycles() function in index.html Data Access Layer (per data-model.md migration spec)
- [X] T014 [LAYER:DATA] Update loadProjects() in index.html to call migrateIterationToCycles() for each iteration
- [X] T015 [LAYER:DATA] Update saveProjects() in index.html to create backup before save in spec_kit_backup key
- [X] T016 [LAYER:DATA] Add DATA_VERSION constant = 2 at top of script section in index.html

**Checkpoint**: Foundation ready - migration logic in place, user story implementation can now begin

---

## Phase 3: User Story 1 - Add New Cycle to Iteration (Priority: P1) 🎯 MVP

**Goal**: Users can add new cycle rounds to existing iterations with custom names, enabling tracking of multiple review/revision rounds

**Independent Test**: Create project with one iteration, click "Add Cycle" button, enter custom name "Test Cycle", verify cycle appears in dropdown and automatically becomes active cycle with empty workflow data

### Implementation for User Story 1

#### Data Access Layer Tasks (LAYER:DATA)

- [X] T017 [P] [US1] [MODULE:DataAccess] [LAYER:DATA] No new data functions needed (uses existing saveProjects/loadProjects)

#### Business Logic Layer Tasks (LAYER:BUSINESS)

- [X] T018 [P] [US1] [MODULE:Validation] [LAYER:BUSINESS] Implement validateCycleName(name) function in index.html Business Logic Layer (returns {valid: boolean, errors: string[]})
- [X] T019 [US1] [MODULE:CycleManagement] [LAYER:BUSINESS] Implement cycleManagementAdd(iterationId, cycleName) function in index.html Business Logic Layer
  - Generate cycle ID: `cycle_${Date.now()}`
  - Determine order: `Math.max(...cycles.map(c => c.order), 0) + 1`
  - Create cycle object: {id, name, createdAt: ISO8601, order}
  - Push to iteration.cycles array
  - Set iteration.currentCycle = newCycle.id
  - Initialize empty data: inputs[stepId][cycleId] = '', notes[stepId][cycleId] = '', completedSteps[stepId][cycleId] = false for all workflow steps
  - Call saveProjects()
  - Return new cycle object or null if validation fails

#### Presentation Layer Tasks (LAYER:PRESENTATION)

- [X] T020 [P] [US1] [MODULE:UI] [LAYER:PRESENTATION] Implement renderCycleSelector(iterationId) function in index.html Presentation Layer
  - Find iteration by ID
  - Sort cycles by order
  - Return HTML string with `<select id="cycleSelect">` containing options for each cycle
  - Add three buttons: ➕ Add, ✏️ Rename, 🗑️ Delete with onclick handlers
  - Truncate cycle names >50 chars with escapeHtml() and title attribute for tooltip
- [X] T021 [P] [US1] [MODULE:UI] [LAYER:PRESENTATION] Implement truncateCycleName(name, maxLength) function in index.html Presentation Layer
- [X] T022 [P] [US1] [MODULE:UI] [LAYER:PRESENTATION] Implement escapeHtml(text) function in index.html Presentation Layer (use document.createElement('div') with textContent)
- [X] T023 [US1] [MODULE:UI] [LAYER:PRESENTATION] Update renderIterationWorkflow(iterationId) function in index.html to call renderCycleSelector() and insert HTML at top of workflow
- [X] T024 [US1] [MODULE:UI] [LAYER:PRESENTATION] Update renderIterationWorkflow() to read cycle-specific data: inputs[stepId][currentCycleId], notes[stepId][currentCycleId], completedSteps[stepId][currentCycleId]

#### Event Handler Tasks (Bridge Layer)

- [X] T025 [US1] [MODULE:EventHandlers] Implement handleAddCycle(iterationId) function in index.html Event Handler Layer
  - Prompt user: `prompt('Enter cycle name (leave empty for default):')`
  - Handle cancellation (null return)
  - Call cycleManagementAdd(iterationId, cycleName)
  - If successful, call renderIterationWorkflow(iterationId) to update UI
  - If failed (validation), user already alerted by cycleManagementAdd

### Manual Testing for User Story 1

- [ ] T026 [US1] Add test case in test-automation.html "Test: Add Cycle with Custom Name" verifying acceptance scenario 2
- [ ] T027 [US1] Add test case in test-automation.html "Test: Add Cycle with Default Name" verifying acceptance scenario 1
- [ ] T028 [US1] Add test case in test-automation.html "Test: Add Cycle with Empty Name Validation" verifying acceptance scenario 6
- [ ] T029 [US1] Add test case in test-automation.html "Test: New Cycle Has Empty Data" verifying acceptance scenario 3
- [ ] T030 [US1] Add test case in test-automation.html "Test: New Cycle Auto-Switch" verifying acceptance scenario 5

**Checkpoint**: At this point, User Story 1 should be fully functional - users can add cycles, see them in dropdown, auto-switch to new cycle, validate empty names are rejected

---

## Phase 4: User Story 2 - Rename Existing Cycle (Priority: P2)

**Goal**: Users can rename cycles to better reflect their purpose, improving workflow clarity and organization

**Independent Test**: Create iteration with 2-3 cycles, click ✏️ Rename button, enter new name "Client Review Round", press Enter, verify name updates in dropdown immediately and persists after page refresh

### Implementation for User Story 2

#### Business Logic Layer Tasks (LAYER:BUSINESS)

- [ ] T031 [P] [US2] [MODULE:CycleManagement] [LAYER:BUSINESS] Implement cycleManagementRename(iterationId, cycleId, newName) function in index.html Business Logic Layer
  - Find iteration by ID
  - Find cycle by ID within iteration
  - Validate newName using validateCycleName() (reuse from US1)
  - Update cycle.name = trimmedName
  - Call saveProjects()
  - Return true on success, false on failure

#### Event Handler Tasks (Bridge Layer)

- [ ] T032 [US2] [MODULE:EventHandlers] Implement handleRenameCycle(iterationId, cycleId) function in index.html Event Handler Layer
  - Find current cycle to get existing name
  - Prompt user: `prompt('Enter new cycle name:', currentCycleName)`
  - Handle cancellation (null return)
  - Call cycleManagementRename(iterationId, cycleId, newName)
  - If successful, call renderIterationWorkflow(iterationId) to update UI
  - If failed, user already alerted by cycleManagementRename

### Manual Testing for User Story 2

- [ ] T033 [US2] Add test case in test-automation.html "Test: Rename Cycle Updates Dropdown" verifying acceptance scenario 2
- [ ] T034 [US2] Add test case in test-automation.html "Test: Rename Cycle Persists After Refresh" verifying acceptance scenario 5
- [ ] T035 [US2] Add test case in test-automation.html "Test: Rename Cycle Empty Name Validation" verifying acceptance scenario 4
- [ ] T036 [US2] Add test case in test-automation.html "Test: Cancel Rename Preserves Original Name" verifying acceptance scenario 3

**Checkpoint**: At this point, User Stories 1 AND 2 should both work - users can add cycles AND rename them with validation

---

## Phase 5: User Story 3 - Delete Cycle (Priority: P3)

**Goal**: Users can delete cycles that were created by mistake or are no longer relevant, maintaining a clean iteration history

**Independent Test**: Create iteration with 3 cycles, select middle cycle, click 🗑️ Delete button, confirm dialog, verify: (1) cycle removed from dropdown, (2) auto-switched to adjacent cycle, (3) data persists after refresh, (4) cannot delete last remaining cycle

### Implementation for User Story 3

#### Business Logic Layer Tasks (LAYER:BUSINESS)

- [ ] T037 [P] [US3] [MODULE:CycleManagement] [LAYER:BUSINESS] Implement getAdjacentCycle(iteration, deletedCycleId) function in index.html Business Logic Layer
  - Sort cycles by order
  - Find index of deleted cycle
  - Return previous cycle if exists, otherwise next cycle, otherwise first cycle (fallback)
- [ ] T038 [P] [US3] [MODULE:CycleManagement] [LAYER:BUSINESS] Implement removeAllCycleData(iteration, cycleId) function in index.html Business Logic Layer
  - Iterate over all stepIds in inputs/notes/completedSteps/cycleHistory
  - Delete cycleId key from each nested object: `delete iteration.inputs[stepId][cycleId]`
  - No return value (mutates iteration object)
- [ ] T039 [US3] [MODULE:CycleManagement] [LAYER:BUSINESS] Implement cycleManagementDelete(iterationId, cycleId) function in index.html Business Logic Layer
  - Find iteration by ID
  - Check minimum cycle constraint: if (iteration.cycles.length === 1) { alert('Cannot delete last cycle'); return false; }
  - Find cycle by ID to get name for confirmation
  - Show confirmation dialog with cycle name and data loss warning
  - If confirmed:
    - Determine if need auto-switch (deletingCurrentCycle = iteration.currentCycle === cycleId)
    - If auto-switch needed, get adjacent cycle and set iteration.currentCycle = adjacentCycle.id
    - Remove cycle from array: iteration.cycles = iteration.cycles.filter(c => c.id !== cycleId)
    - Call removeAllCycleData(iteration, cycleId)
    - Call saveProjects()
    - Return true
  - If cancelled or validation failed: return false

#### Event Handler Tasks (Bridge Layer)

- [ ] T040 [US3] [MODULE:EventHandlers] Implement handleDeleteCycle(iterationId, cycleId) function in index.html Event Handler Layer
  - Call cycleManagementDelete(iterationId, cycleId)
  - If successful, call renderIterationWorkflow(iterationId) to update UI
  - If failed (validation or cancellation), no action needed (already handled by cycleManagementDelete)

### Manual Testing for User Story 3

- [ ] T041 [US3] Add test case in test-automation.html "Test: Delete Cycle Shows Confirmation Dialog" verifying acceptance scenario 1
- [ ] T042 [US3] Add test case in test-automation.html "Test: Delete Cycle Removes From List and Auto-Switches" verifying acceptance scenario 2
- [ ] T043 [US3] Add test case in test-automation.html "Test: Cancel Delete Cycle Preserves Cycle" verifying acceptance scenario 3
- [ ] T044 [US3] Add test case in test-automation.html "Test: Delete Cycle Removes All Data" verifying acceptance scenario 4
- [ ] T045 [US3] Add test case in test-automation.html "Test: Cannot Delete Last Cycle" verifying acceptance scenario 5
- [ ] T046 [US3] Add test case in test-automation.html "Test: Delete Cycle Persists After Refresh" verifying acceptance scenario 6

**Checkpoint**: All three user stories should now be independently functional - users can add, rename, AND delete cycles with full data integrity

---

## Phase 6: Cycle Switching (Foundational for All Stories)

**Goal**: Users can switch between cycles to view/edit different cycle data

**Independent Test**: Create iteration with 3 cycles with different data in each, switch between cycles using dropdown, verify correct data displayed for each cycle

### Implementation for Cycle Switching

#### Business Logic Layer Tasks (LAYER:BUSINESS)

- [ ] T047 [MODULE:CycleManagement] [LAYER:BUSINESS] Implement cycleManagementSwitch(iterationId, cycleId) function in index.html Business Logic Layer
  - Find iteration by ID
  - Validate cycle exists in iteration.cycles
  - Update iteration.currentCycle = cycleId
  - Call saveProjects()
  - Return true on success, false if cycle not found

#### Event Handler Tasks (Bridge Layer)

- [ ] T048 [MODULE:EventHandlers] Implement handleCycleSwitch(iterationId, cycleId) function in index.html Event Handler Layer
  - Called by dropdown onchange event
  - Call cycleManagementSwitch(iterationId, cycleId)
  - Call renderIterationWorkflow(iterationId) to update UI with new cycle's data

### Manual Testing for Cycle Switching

- [ ] T049 Add test case in test-automation.html "Test: Switch Cycle Updates Workflow Data" verifying cycle-specific inputs/notes/completedSteps displayed
- [ ] T050 Add test case in test-automation.html "Test: Switch Cycle Persists Selection After Refresh"

**Checkpoint**: Full cycle management now functional - add, rename, delete, AND switch cycles

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories, finalization, and validation

### CSS Styling

- [ ] T051 [P] Add CSS styles for .cycle-selector in index.html <style> section (dropdown styling, button spacing, responsive design)
- [ ] T052 [P] Add CSS styles for cycle selector buttons in index.html (button sizing, hover effects, icon alignment)
- [ ] T053 Add CSS styles for long cycle name tooltips in index.html (title attribute default styling adequate, no custom needed)

### Edge Case Handling

- [ ] T054 [P] Add CYCLE_NAME_MAX_LENGTH = 200 constant in index.html constants section
- [ ] T055 [P] Update validateCycleName() in index.html to check max length and return error if exceeded
- [ ] T056 Handle long cycle names in renderCycleSelector(): call truncateCycleName() with maxLength=50 and add title attribute with full name

### Data Integrity Validation

- [ ] T057 [P] Implement validateIterationIntegrity(iteration) function in index.html Business Logic Layer (per data-model.md spec)
  - Check all cycleIds in inputs/notes/completedSteps/cycleHistory exist in cycles array
  - Check currentCycle references valid cycle
  - Check cycle orders are unique
  - Return {valid: boolean, errors: string[]}
- [ ] T058 Call validateIterationIntegrity() in loadProjects() after migration, log warnings for any violations (optional - defensive)

### Performance Optimization (if >10 cycles)

- [ ] T059 [P] Add CYCLE_PAGINATION_THRESHOLD = 10 constant in index.html
- [ ] T060 Update renderCycleSelector() in index.html: if cycles.length > CYCLE_PAGINATION_THRESHOLD, add search input and pagination controls (optional - future enhancement)

### Documentation and Validation

- [ ] T061 [P] Review plan.md Module Boundary Definition section and verify all 4 modules implemented correctly
- [ ] T062 [P] Review plan.md Layers of Concerns Design section and verify no layer violations (use code review checklist)
- [ ] T063 Verify all functions follow naming conventions: cycleManagement*, validate*, render*, handle*
- [ ] T064 Verify all functions < 50 lines, nesting depth ≤ 3 levels (Constitution Principle III)
- [ ] T065 Run manual test cases in test-automation.html for all 18 acceptance scenarios from spec.md
- [ ] T066 Validate file size: ensure index.html remains < 250KB after all changes
- [ ] T067 Test data migration: load existing project with old structure, verify migration to cycle structure with timestamped first cycle
- [ ] T068 Test with 20 cycles in single iteration: verify dropdown performance < 100ms, no UI degradation
- [ ] T069 Cross-browser testing: Chrome, Firefox, Safari, Edge (verify cycle selector, dropdown, prompts work)
- [ ] T070 Test offline functionality: disconnect network, verify all cycle operations work with localStorage only

### Final Validation Against Success Criteria

- [ ] T071 Validate SC-001: Users can add cycle in < 5 seconds (3 clicks: Add → enter name → confirm)
- [ ] T072 Validate SC-002: Users can rename cycle in < 10 seconds (2 clicks: rename → type → Enter)
- [ ] T073 Validate SC-003: Users can delete cycle in < 5 seconds (2 clicks: delete → confirm)
- [ ] T074 Validate SC-004: All operations complete with < 100ms UI update after saveProjects()
- [ ] T075 Validate SC-005: 100% data integrity - no data loss on page refresh or localStorage save/load
- [ ] T076 Validate SC-006: Handle 20 cycles without performance degradation
- [ ] T077 Validate SC-007: Cycle-specific data (inputs/notes) updates correctly 100% of time when switching
- [ ] T078 Validate SC-008: No data corruption - each cycle maintains independent data after all CRUD operations

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - User Story 1 (Add Cycle): Can start after Foundational (no dependencies on other stories)
  - User Story 2 (Rename Cycle): Can start after Foundational (no dependencies, but logically after US1)
  - User Story 3 (Delete Cycle): Depends on US1 (needs getAdjacentCycle for auto-switch logic)
- **Cycle Switching (Phase 6)**: Depends on US1 (needs cycle selector UI from US1)
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1 - Add Cycle)**: Independent - can complete standalone
- **User Story 2 (P2 - Rename Cycle)**: Independent - can complete standalone (logically after US1 for testing)
- **User Story 3 (P3 - Delete Cycle)**: Depends on US1 (reuses validateCycleName, needs cycle selector)

### Within Each User Story

- Business Logic before Presentation (validate* and cycleManagement* before render*)
- Presentation before Event Handlers (render* before handle*)
- Event Handlers orchestrate all layers
- Manual tests can be written anytime after implementation

### Parallel Opportunities

- **Phase 1 (Setup)**: All 3 tasks marked [P] can run in parallel
- **Phase 2 (Foundational)**: Module boundary tasks (T004-T008) can run in parallel, Layer setup tasks (T009-T012) can run in parallel
- **Within User Story 1**: T018 (validate), T020-T022 (render functions) can run in parallel
- **Within User Story 2**: No parallel opportunities (only 2 sequential tasks)
- **Within User Story 3**: T037-T038 (helper functions) can run in parallel before T039
- **Phase 7 (Polish)**: CSS tasks (T051-T053), constants (T054-T055), validation (T057-T058) can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch all parallelizable tasks for User Story 1 together:
Task T018: "Implement validateCycleName() in Business Logic Layer"
Task T020: "Implement renderCycleSelector() in Presentation Layer"
Task T021: "Implement truncateCycleName() in Presentation Layer"
Task T022: "Implement escapeHtml() in Presentation Layer"

# Then sequentially:
Task T019: "Implement cycleManagementAdd()" (depends on T018 validateCycleName)
Task T023: "Update renderIterationWorkflow()" (depends on T020 renderCycleSelector)
Task T024: "Update renderIterationWorkflow() for cycle data" (depends on T023)
Task T025: "Implement handleAddCycle()" (depends on T019 and T023-T024)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T003) - 30 min
2. Complete Phase 2: Foundational (T004-T016) - 1-2 hours
3. Complete Phase 3: User Story 1 (T017-T030) - 3-4 hours
4. **STOP and VALIDATE**: Test all US1 acceptance scenarios manually
5. Demo: "Users can now add cycles to iterations!"

**Estimated MVP Time**: 5-7 hours

### Incremental Delivery

1. **Foundation** (Phase 1-2) → Migration and module boundaries ready
2. **MVP** (Phase 3 - US1) → Add cycles functional → Deploy/Demo
3. **Enhancement 1** (Phase 4 - US2) → Rename cycles functional → Deploy/Demo
4. **Enhancement 2** (Phase 5 - US3) → Delete cycles functional → Deploy/Demo
5. **Complete** (Phase 6) → Cycle switching functional → Deploy/Demo
6. **Polish** (Phase 7) → Edge cases, performance, validation → Final Release

Each phase adds value without breaking previous phases.

### Parallel Team Strategy

With multiple developers:

1. All together: Complete Phase 1-2 (Setup + Foundational) - 2-3 hours
2. Once Foundational done:
   - **Developer A**: User Story 1 (Add Cycle) - 3-4 hours
   - **Developer B**: User Story 2 (Rename Cycle) - 1-2 hours
   - **Developer C**: Prepare manual tests (T026-T030, T033-T036, T041-T046)
3. After US1-US2 complete:
   - **Developer A**: User Story 3 (Delete Cycle) - 2-3 hours
   - **Developer B**: Cycle Switching (Phase 6) - 1 hour
   - **Developer C**: Polish tasks (Phase 7 - CSS, edge cases)
4. All together: Final validation (T065-T078) - 1-2 hours

**Total Parallel Time**: ~8-10 hours (vs 12-15 hours sequential)

---

## Notes

### Task Label Format

**Standard Labels**:
- **[P]** = Parallel task (different files or independent code sections)
- **[Story]** = User story identifier ([US1], [US2], [US3])

**Constitution Labels** *(Constitution Principles VI & VII)*:
- **[MODULE:Name]** = Module identifier ([MODULE:DataAccess], [MODULE:CycleManagement], [MODULE:UI], [MODULE:EventHandlers])
- **[LAYER:Name]** = Layer identifier ([LAYER:DATA], [LAYER:BUSINESS], [LAYER:PRESENTATION])

**Full Example**:
```
- [ ] T019 [US1] [MODULE:CycleManagement] [LAYER:BUSINESS] Implement cycleManagementAdd(iterationId, cycleName) in index.html Business Logic Layer
```

**Interpretation**:
- `T019` = Task ID (sequential order)
- `[US1]` = Belongs to User Story 1 (Add Cycle)
- `[MODULE:CycleManagement]` = Part of Cycle Management module
- `[LAYER:BUSINESS]` = Part of Business Logic Layer
- Description: Exact function name, parameters, and location in file

### Single-File Architecture Adaptations

**Module Boundaries**:
- Modules are function groups, not separate files
- Use section comments to mark boundaries: `// ===== CYCLE MANAGEMENT - BUSINESS LOGIC LAYER =====`
- Function naming enforces module membership: `cycleManagement*`, `validate*`, `render*`, `handle*`

**Layer Separation**:
- Layers are also function groups in single file
- Order in file: Data Access → Business Logic → Presentation → Event Handlers
- Layer violations detected via code review checklist (no automated enforcement)

**Testing**:
- Manual tests in test-automation.html (not automated unit tests)
- Each test case corresponds to acceptance scenario from spec.md
- Run tests manually after each user story implementation

### Best Practices

- **[P] tasks** = Can be implemented in parallel (different code sections, no dependencies)
- **[Story]** label ensures task maps to specific user story for traceability
- **[MODULE]** label enables module boundary validation during code review
- **[LAYER]** label enforces separation of concerns during code review
- Each user story should be independently completable and testable
- Commit after each task or logical group of tasks
- Stop at any checkpoint to validate story independently before proceeding
- **Module tasks within a story must not create circular dependencies**
- **Layer tasks must respect unidirectional communication flow**
- Avoid: vague tasks, missing file paths, cross-story dependencies that break independence, layer violations

### Validation Checklist (Use During Code Review)

**For [MODULE] tasks**:
- [ ] Module has clear function group with consistent naming prefix
- [ ] No circular dependencies (verify call graph in plan.md)
- [ ] Module documented in plan.md Module Boundary Definition section
- [ ] Functions can be tested independently (manual tests in test-automation.html)

**For [LAYER:DATA] tasks**:
- [ ] No `document.` calls in data access functions
- [ ] No business logic (validation, transformation) in data access
- [ ] Only called by business logic layer (grep for direct calls from render*)

**For [LAYER:BUSINESS] tasks**:
- [ ] No `document.` calls in business logic functions
- [ ] No `localStorage.` or `firebase.` direct calls (uses data layer)
- [ ] Only called by presentation or event handlers

**For [LAYER:PRESENTATION] tasks**:
- [ ] No `localStorage.` or `firebase.` direct calls (uses business layer)
- [ ] No business validation logic (delegates to validate* functions)
- [ ] Only renders based on data passed as parameters

**For [MODULE:EventHandlers] tasks**:
- [ ] Orchestrates layers in correct order: Validate → Business Logic → Data Access → Presentation
- [ ] Handles user input (prompts, confirms)
- [ ] Doesn't contain business logic (delegates to cycleManagement* functions)
- [ ] Doesn't contain rendering logic (delegates to render* functions)

---

## Summary

**Total Tasks**: 78 tasks
- Phase 1 (Setup): 3 tasks
- Phase 2 (Foundational): 13 tasks
- Phase 3 (User Story 1 - Add Cycle): 14 tasks (7 implementation + 5 tests + 2 layer tasks)
- Phase 4 (User Story 2 - Rename Cycle): 6 tasks (2 implementation + 4 tests)
- Phase 5 (User Story 3 - Delete Cycle): 10 tasks (4 implementation + 6 tests)
- Phase 6 (Cycle Switching): 4 tasks (2 implementation + 2 tests)
- Phase 7 (Polish): 28 tasks (styling, edge cases, validation)

**Parallel Opportunities**: 28 tasks marked [P] can run in parallel within their phase

**Independent Test Criteria**:
- **US1**: Add cycle, verify dropdown, check empty data, test validation
- **US2**: Rename cycle, verify persistence, test validation
- **US3**: Delete cycle, verify auto-switch, test minimum cycle constraint

**Suggested MVP Scope**: Phase 1 + Phase 2 + Phase 3 (User Story 1) = 30 tasks, ~5-7 hours

**Architecture Compliance**:
- ✅ All tasks follow Constitution Principles VI (Modularity) and VII (Separation of Concerns)
- ✅ 4 modules defined: DataAccess, CycleManagement, UI, EventHandlers
- ✅ 3 layers enforced: Data Access, Business Logic, Presentation + Bridge (Event Handlers)
- ✅ No circular dependencies, unidirectional layer communication

**Ready for Implementation**: All tasks are specific, executable, and include exact file locations. Each task can be completed by an LLM without additional context.
