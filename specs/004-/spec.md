# Feature Specification: Cycle Management for Project Iterations

**Feature Branch**: `004-cycle-management`
**Created**: 2025-10-16
**Status**: Draft
**Input**: User description: "增加每个项目的循环轮次的编辑管理，可以修改轮次的名字，删除和添加轮次等"

## Clarifications

### Session 2025-10-16

- Q: When migrating existing iterations that already have data in the old format (inputs, notes, completedSteps stored directly without cycle keys), how should this historical data be handled? → A: Preserve in first cycle with timestamp (e.g., "Initial Cycle - Migrated 2025-10-16")

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Add New Cycle to Iteration (Priority: P1)

As a project manager, I want to add new cycle rounds to existing iterations so that I can track multiple review/revision rounds for the same iteration phase.

**Why this priority**: Adding cycles is the most fundamental operation - without the ability to add cycles, users cannot create their iterative workflow history. This is the core value proposition of cycle management.

**Independent Test**: Can be fully tested by creating a project with one iteration, adding a new cycle with a custom name, and verifying the cycle appears in the iteration workflow view. Delivers immediate value by allowing users to document their iterative process.

**Acceptance Scenarios**:

1. **Given** I am viewing an iteration with existing cycles, **When** I click "Add Cycle" button, **Then** a new cycle is created with a default name (e.g., "Cycle 3") and appears in the cycle list
2. **Given** I am adding a new cycle, **When** I provide a custom name in the add cycle dialog, **Then** the new cycle is created with my specified name
3. **Given** I have added a new cycle, **When** I navigate to that cycle, **Then** I see an empty workflow with all steps marked incomplete and no input/notes data
4. **Given** I add multiple cycles, **When** I view the cycle list, **Then** cycles are displayed in chronological order (oldest to newest)
5. **Given** I add a new cycle, **When** the operation completes, **Then** the system automatically switches to the newly created cycle
6. **Given** I try to add a cycle with an empty name, **When** I submit the form, **Then** the system shows validation error "Cycle name cannot be empty"

---

### User Story 2 - Rename Existing Cycle (Priority: P2)

As a project manager, I want to rename cycles to better reflect their purpose (e.g., "Initial Review", "Client Feedback Round") so that I can organize my iteration history with meaningful labels.

**Why this priority**: After users can add cycles (P1), they need to organize them with meaningful names. This enhances usability but doesn't block the core workflow.

**Independent Test**: Can be tested by creating an iteration with 2-3 cycles, renaming them to custom names, and verifying the names persist across page refreshes. Delivers value by improving workflow clarity.

**Acceptance Scenarios**:

1. **Given** I am viewing a cycle in the cycle selector, **When** I click the "Rename" icon next to the cycle name, **Then** an inline edit field appears with the current name pre-filled
2. **Given** I am renaming a cycle, **When** I enter a new name and press Enter or click Save, **Then** the cycle name updates immediately across all views (cycle selector, iteration list, workflow header)
3. **Given** I am renaming a cycle, **When** I press Escape or click Cancel, **Then** the edit is cancelled and the original name remains
4. **Given** I try to rename a cycle to an empty string, **When** I submit the change, **Then** the system shows validation error "Cycle name cannot be empty"
5. **Given** I rename a cycle, **When** I refresh the page, **Then** the renamed cycle persists with the new name
6. **Given** I am renaming multiple cycles, **When** I rename cycle A and then cycle B, **Then** both names update independently without conflicts

---

### User Story 3 - Delete Cycle (Priority: P3)

As a project manager, I want to delete cycles that were created by mistake or are no longer relevant so that I can maintain a clean iteration history.

**Why this priority**: Deletion is a maintenance operation that becomes important as users accumulate cycles, but it's not essential for the initial workflow. Can be delivered after add and rename functionality.

**Independent Test**: Can be tested by creating an iteration with 3 cycles, deleting the middle cycle, and verifying: (1) the deleted cycle no longer appears, (2) remaining cycles are unaffected, (3) data is removed from storage. Delivers value by allowing users to clean up their workspace.

**Acceptance Scenarios**:

1. **Given** I am viewing a cycle in the cycle selector, **When** I click the "Delete" icon next to the cycle name, **Then** a confirmation dialog appears asking "Are you sure you want to delete [Cycle Name]? All cycle data will be permanently removed."
2. **Given** I confirm cycle deletion, **When** the deletion completes, **Then** the cycle is removed from the cycle list and the system automatically switches to the previous cycle (or next cycle if first was deleted)
3. **Given** I cancel cycle deletion, **When** I click "Cancel" in the confirmation dialog, **Then** no changes occur and the cycle remains
4. **Given** I delete a cycle with existing input/notes data, **When** the deletion completes, **Then** all associated data (inputs, notes, completion status) for that cycle is permanently removed from storage
5. **Given** I am on the last remaining cycle of an iteration, **When** I attempt to delete it, **Then** the system prevents deletion and shows error "Cannot delete the last cycle. Each iteration must have at least one cycle."
6. **Given** I delete a cycle and refresh the page, **When** the page reloads, **Then** the deleted cycle does not reappear (deletion is persisted)

---

### Edge Cases

- What happens when a user deletes the currently active cycle? System should auto-switch to the previous cycle (or next cycle if first was deleted).
- What happens when a user tries to delete the only remaining cycle in an iteration? System should prevent deletion and show error "Cannot delete the last cycle."
- What happens when cycle names become very long (>50 characters)? System should truncate with ellipsis in cycle selector but show full name in tooltip.
- What happens when a user adds 20+ cycles to a single iteration? System should provide scrollable cycle selector to handle large lists.
- What happens when two users simultaneously rename the same cycle (if Firebase sync is enabled)? Last write wins; users should see updated name on next refresh.
- What happens when a user refreshes the page while editing a cycle name? Unsaved changes are lost; system returns to view mode with original name.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide an "Add Cycle" button visible when viewing any iteration
- **FR-002**: System MUST allow users to specify a custom name when adding a new cycle (default: "Cycle N" where N is sequential)
- **FR-003**: System MUST validate cycle names to prevent empty or whitespace-only names
- **FR-004**: System MUST display all cycles for an iteration in chronological order
- **FR-005**: System MUST provide inline rename functionality with edit/save/cancel controls
- **FR-006**: System MUST update cycle names across all UI locations immediately when renamed (cycle selector, workflow header, storage)
- **FR-007**: System MUST provide delete functionality with confirmation dialog for each cycle
- **FR-008**: System MUST prevent deletion of the last remaining cycle in an iteration
- **FR-009**: System MUST automatically switch to another cycle after deletion (previous cycle preferred, then next cycle)
- **FR-010**: System MUST persist all cycle management operations (add, rename, delete) to both localStorage and Firebase (if authenticated)
- **FR-011**: System MUST maintain independent data (inputs, notes, completedSteps) for each cycle within an iteration
- **FR-012**: System MUST ensure new cycles start with empty inputs/notes and all steps marked incomplete
- **FR-013**: System MUST handle cycle name truncation in UI when names exceed 50 characters (show ellipsis with full name in tooltip)
- **FR-014**: System MUST provide scrollable cycle selector for iterations with many cycles (>5 cycles)
- **FR-015**: System MUST migrate existing iteration data by preserving all historical data (inputs, notes, completedSteps) in a first cycle named with timestamp format "Initial Cycle - Migrated YYYY-MM-DD"

### Modularity Requirements *(Constitution Principle VI)*

- **MR-001**: Feature MUST be implemented as 4 independent function groups: cycleManagement*, validate*, render*, handle*
- **MR-002**: Function naming MUST follow conventions:
  - `cycleManagement*` for CRUD operations (e.g., `cycleManagementAdd()`, `cycleManagementRename()`, `cycleManagementDelete()`)
  - `validate*` for input validation (e.g., `validateCycleName()`)
  - `render*` for UI updates (e.g., `renderCycleSelector()`, `renderCycleList()`)
  - `handle*` for event handlers (e.g., `handleAddCycle()`, `handleRenameCycle()`, `handleDeleteCycle()`)
- **MR-003**: Function dependencies:
  - `render*` functions can call `cycleManagement*` and `validate*` functions
  - `cycleManagement*` functions can call `validate*` and data layer functions (saveProjects)
  - `handle*` functions orchestrate interactions between all layers
  - No circular dependencies allowed
- **MR-004**: Each function group will have dedicated test section in test-automation.html with independent test cases

### Separation of Concerns Requirements *(Constitution Principle VII)*

- **SC-001**: Feature touches all three layers:
  - **Data Access**: `saveProjects()`, `loadProjects()` (existing functions handle storage)
  - **Business Logic**: `cycleManagementAdd()`, `cycleManagementRename()`, `cycleManagementDelete()`, `validateCycleName()`
  - **Presentation**: `renderCycleSelector()`, `renderCycleList()`, `renderIterationWorkflow()`
- **SC-002**: Cross-layer communication MUST follow unidirectional flow:
  - Presentation → Business Logic → Data Access
  - Event handlers orchestrate: User Event → Validation → Cycle Management → Data Save → UI Re-render
- **SC-003**: Prohibited patterns:
  - `render*` functions MUST NOT directly call `localStorage` or `firebase` APIs
  - `cycleManagement*` functions MUST NOT manipulate DOM
  - `validate*` functions MUST NOT modify data or render UI (return validation result objects only)
  - UI event handlers MUST NOT bypass business logic layer to directly modify data

### Key Entities

- **Cycle**: Represents a single review/revision round within an iteration
  - `id` (string): Unique identifier (e.g., 'cycle_1697845200000')
  - `name` (string): User-defined cycle name (required, non-empty)
  - `createdAt` (ISO8601 string): Creation timestamp
  - `order` (number): Sequential order within iteration (1, 2, 3...)
  - Note: Cycle-specific data (inputs, notes, completedSteps) is stored at iteration level using cycle ID as key

- **Iteration** (updated existing entity): Adds cycle management support
  - `cycles` (array): Array of Cycle objects (NEW)
  - `currentCycle` (string): ID of currently active cycle (UPDATED to reference cycle from cycles array)
  - `inputs` (object): Map of `{stepId: {cycleId: inputValue}}` (UPDATED to support per-cycle storage)
  - `notes` (object): Map of `{stepId: {cycleId: noteValue}}` (UPDATED to support per-cycle storage)
  - `completedSteps` (object): Map of `{stepId: {cycleId: boolean}}` (UPDATED to support per-cycle completion tracking)
  - `cycleHistory` (object): Map of `{stepId: {cycleId: completionTimestamp}}` (UPDATED to support per-cycle history)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can add a new cycle to any iteration in under 5 seconds (3 clicks: "Add Cycle" → enter name → confirm)
- **SC-002**: Users can rename any cycle in under 10 seconds (2 clicks: rename icon → type new name → Enter)
- **SC-003**: Users can delete any cycle in under 5 seconds (2 clicks: delete icon → confirm)
- **SC-004**: All cycle management operations complete with <100ms UI update latency after data save
- **SC-005**: Cycle data persists correctly with 100% data integrity (no data loss on page refresh or Firebase sync)
- **SC-006**: System handles iterations with up to 20 cycles without performance degradation (cycle selector remains responsive)
- **SC-007**: Users can navigate between cycles and see cycle-specific data (inputs/notes) update correctly 100% of the time
- **SC-008**: Cycle management operations never result in data corruption (each cycle maintains independent data)

## Assumptions

1. **Data Structure**: Assumes the existing Iteration entity will be extended to support a `cycles` array. Backward compatibility will be handled by migration logic that converts single `currentCycle` string to a cycles array with one default cycle.

2. **Cycle Naming**: Assumes users want meaningful names for cycles (not just "Cycle 1, Cycle 2"). Default names are provided for convenience but users are expected to rename them.

3. **Cycle Order**: Assumes cycles are displayed in chronological order (oldest to newest) based on creation timestamp. Users cannot manually reorder cycles.

4. **Data Isolation**: Assumes each cycle should have completely independent data (inputs, notes, completion status). There is no data inheritance or copying between cycles.

5. **Minimum Cycles**: Assumes each iteration must have at least one cycle (the "initial" cycle). Users cannot delete all cycles.

6. **Cycle Deletion**: Assumes cycle deletion is permanent and irrecoverable. No "soft delete" or undo functionality.

7. **Active Cycle Switching**: Assumes when a user deletes the currently active cycle, the system should automatically switch to the most recent remaining cycle (previous cycle if available, otherwise next cycle).

8. **Cycle Selector UI**: Assumes cycles are displayed in a dropdown selector (similar to existing cycle color selector) with add/rename/delete actions accessible via icon buttons.

9. **Firebase Sync**: Assumes cycle data syncs to Firebase using the same pattern as other project data (save entire project object, not individual cycles).

10. **Performance**: Assumes typical projects will have 3-5 cycles per iteration. System should handle up to 20 cycles gracefully but optimization beyond that is out of scope.

## Dependencies

- Existing `saveProjects()` and `loadProjects()` functions must be extended to handle new cycle data structure
- Existing iteration data structure must be backward-compatible (migration required for old data)
- Existing `renderIterationWorkflow()` function must be updated to support cycle-specific data rendering
- Cycle selector UI component must be added to iteration workflow view

## Constraints

- Must maintain single-file architecture (all code in index.html)
- Must maintain data integrity during migration from old structure to new cycle-based structure
- Must not break existing iteration workflow functionality
- Must work offline (LocalStorage as primary storage, Firebase as optional sync)
- HTML file size must remain under 250KB (current: 228KB, estimated addition: ~15-20KB)
- Performance: All cycle operations must complete in <500ms on typical hardware

## Out of Scope

- Cycle templates (predefined cycle types)
- Copying data between cycles
- Bulk cycle operations (add/delete multiple cycles at once)
- Cycle history/audit log (beyond basic creation timestamp)
- Cycle-level permissions or access control
- Cycle analytics or reporting
- Undo/redo for cycle operations
- Cycle search or filtering
- Exporting cycle data separately from iteration data
- Cycle color customization (beyond existing cycle color system)
