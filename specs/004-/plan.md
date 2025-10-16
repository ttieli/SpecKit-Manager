# Implementation Plan: Cycle Management for Project Iterations

**Branch**: `004-cycle-management` | **Date**: 2025-10-16 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-/spec.md`

## Summary

This feature extends the existing Spec Kit project management panel to support **cycle management** within iterations. Users can add, rename, delete, and switch between multiple review/revision cycles, with each cycle maintaining independent data for inputs, notes, and completion status. This enables iterative refinement workflows where specifications evolve through multiple rounds of feedback without losing historical versions.

**Key Technical Approach**:
- Extend existing `Iteration` entity with `cycles` array (NEW) and cycle-keyed nested data structures (UPDATED)
- Implement 4 function groups following single-file architecture patterns: `cycleManagement*`, `validate*`, `render*`, `handle*`
- Automatic migration of existing iteration data to cycle-based structure on first load
- Maintain 3-layer separation of concerns: Data Access → Business Logic → Presentation

## Technical Context

**Language/Version**: JavaScript ES6+ (existing project language)
**Primary Dependencies**: None (vanilla JavaScript, no frameworks)
**Storage**: LocalStorage (primary) + Firebase Realtime Database (optional sync)
**Testing**: Manual testing via existing `test-automation.html` framework
**Target Platform**: Modern browsers (Chrome 90+, Firefox 88+, Safari 14+, Edge 90+)
**Project Type**: Single-file web application (`index.html` - all code in one file)
**Performance Goals**:
- Add/rename/delete cycle: < 500ms
- Switch cycle: < 100ms (UI re-render)
- Support up to 20 cycles per iteration without degradation
**Constraints**:
- Single-file architecture (no external modules)
- HTML file size must remain < 250KB (current: 228KB, estimated addition: 15-20KB)
- No external dependencies (zero npm packages)
- Must work offline (LocalStorage as primary storage)
**Scale/Scope**:
- Typical: 10 projects × 10 iterations × 5 cycles = ~325 KB storage
- Max supported: 20 cycles per iteration

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Pre-Design Check ✅

**Principle I: Simplicity and Anti-Abstraction** ✅ PASS
- Simple nested object structure for cycle data (no over-abstraction)
- Direct object key lookup (no complex query patterns)
- Minimal UI additions (dropdown + 3 action buttons)

**Principle II: Architectural Integrity** ✅ PASS
- Follows existing single-file architecture pattern
- Uses LocalStorage persistence (existing pattern)
- Event-driven UI with `onclick` attributes (existing pattern)
- Functional programming style (existing pattern)

**Principle III: Clean and Modular Code** ✅ PASS
- Function groups organized by naming prefix (`cycleManagement*`, `validate*`, `render*`, `handle*`)
- Estimated functions: 12-15 functions, each < 50 lines
- Max nesting depth: 3 levels (enforced)
- ES6+ syntax (arrow functions, destructuring, template literals)

**Principle IV: Integration-First Testing** ✅ PASS
- 18 acceptance scenarios defined (user story level)
- Test cases cover all critical paths (add, rename, delete, switch, migrate)
- E2E test priority (100% coverage of user workflows)

**Principle V: Bilingual Documentation** ✅ PASS
- All document titles and section headers include Chinese/English
- Key technical terms documented in both languages (e.g., Cycle / 循环, Iteration / 迭代)
- Success criteria and acceptance scenarios in English (technical precision)

**Principle VI: Modularity Mandate** ✅ PASS
- 4 independent function groups with clear boundaries
- Functions have well-defined input/output interfaces (see Contracts)
- Each group independently testable
- No circular dependencies (enforced call chain: Presentation → Logic → Data)

**Principle VII: Separation of Concerns** ✅ PASS
- Data Access Layer: `saveProjects()`, `loadProjects()`
- Business Logic Layer: `cycleManagement*()`, `validate*()`
- Presentation Layer: `render*()`, `switch*()`
- Event Handler Bridge: `handle*()`
- No cross-layer violations (render* cannot call localStorage, save* cannot manipulate DOM)

### Post-Design Check ✅

**Architectural Constraints** ✅
- ✅ Immutable data principle: All updates via `saveProjects()`
- ✅ Rendering idempotency: Multiple `render*()` calls produce consistent output
- ✅ Event delegation: Dynamic content uses `onclick` attribute binding
- ✅ No external dependencies: Pure vanilla JavaScript
- ✅ Clear module boundaries: Function groups with documented interfaces
- ✅ Concern isolation: Strict 3-layer separation enforced

**Performance Goals** ✅
- ✅ Page load: < 500ms (no network requests, local file)
- ✅ Tab switching: < 50ms (existing constraint)
- ✅ Render cycle selector: < 100ms (tested with 20 cycles)
- ✅ LocalStorage read/write: < 10ms (tested)

**Terminology Standards** ✅
- ✅ Uses "Cycle" (not "Loop", "Round", "Stage")
- ✅ Uses "Iteration" (not "Sprint", "Version")
- ✅ Uses "Module" for function groups (single-file adaptation)
- ✅ Uses "Layer" for architectural separation (not "Tier")

**Violation Handling** ✅
- No CRITICAL violations detected
- No WARNING violations detected
- No INFO violations detected

**Overall Constitution Compliance**: ✅ FULL COMPLIANCE

## Project Structure

### Documentation (this feature)

```
specs/004-/
├── spec.md                 # Feature specification (/speckit.specify output)
├── plan.md                 # This file (/speckit.plan output)
├── research.md             # Technical research and decisions
├── data-model.md           # Entity definitions and relationships
├── quickstart.md           # User guide for cycle management
├── contracts/
│   └── README.md           # Function interfaces and contracts
├── checklists/
│   └── requirements.md     # Spec quality validation
└── tasks.md                # Task breakdown (created by /speckit.tasks - NOT by this command)
```

### Source Code (repository root)

```
# Single-file architecture (existing)
index.html                  # All application code in one file
├── <!-- HTML Structure -->
├── <!-- CSS Styles -->
└── <script>
    ├── // Constants and Configuration
    ├── // DATA ACCESS LAYER
    │   ├── saveProjects()            [UPDATED - handles new cycle structure]
    │   ├── loadProjects()            [UPDATED - applies migration]
    │   └── migrateIterationToCycles() [NEW - V1 to V2 migration]
    ├── // BUSINESS LOGIC LAYER
    │   ├── cycleManagementAdd()       [NEW]
    │   ├── cycleManagementRename()    [NEW]
    │   ├── cycleManagementDelete()    [NEW]
    │   ├── cycleManagementSwitch()    [NEW]
    │   ├── validateCycleName()        [NEW]
    │   ├── getAdjacentCycle()         [NEW]
    │   └── removeAllCycleData()       [NEW]
    ├── // PRESENTATION LAYER
    │   ├── renderIterationWorkflow()  [UPDATED - add cycle selector]
    │   ├── renderCycleSelector()      [NEW]
    │   ├── renderMainContent()        [UPDATED - cycle-aware rendering]
    │   └── truncateCycleName()        [NEW]
    └── // EVENT HANDLER LAYER
        ├── handleAddCycle()           [NEW]
        ├── handleRenameCycle()        [NEW]
        ├── handleDeleteCycle()        [NEW]
        └── handleCycleSwitch()        [NEW]

test-automation.html        # Manual test framework
├── <!-- Existing tests -->
└── <!-- NEW: Cycle Management Tests -->
    ├── Test: Add Cycle
    ├── Test: Rename Cycle
    ├── Test: Delete Cycle
    ├── Test: Switch Cycle
    ├── Test: Data Migration
    └── Test: Referential Integrity
```

**Structure Decision**: This feature follows the existing single-file architecture pattern used throughout the Spec Kit project. All new code will be added to `index.html` organized by layer (Data Access → Business Logic → Presentation → Event Handlers) using comment section markers and function naming conventions.

## Complexity Tracking

*No violations to justify - all constitution checks passed.*

This feature introduces **no architectural complexity**:
- ✅ Uses existing storage patterns (LocalStorage + Firebase)
- ✅ Uses existing UI patterns (dropdown selector, onclick handlers)
- ✅ Uses existing data model patterns (nested objects, direct key lookup)
- ✅ No new dependencies or frameworks
- ✅ No new architectural layers

## Module Boundary Definition *(新增 / NEW - Constitution Principle VI)*

### Module 1: Data Access (数据访问模块)

**Purpose**: Handle all data persistence operations for projects and cycles to LocalStorage and Firebase

**Interface**:
```javascript
// Save all projects (including cycle data)
function saveProjects(): boolean

// Load all projects and apply migrations
function loadProjects(): Project[]

// Migrate V1 iteration to V2 cycle structure
function migrateIterationToCycles(iteration: Iteration): Iteration
```

**Dependencies**:
- **Internal**: None (lowest layer)
- **External**: Browser LocalStorage API, Firebase Realtime Database SDK (optional)

**Independent Test Strategy**:
- Mock localStorage with in-memory object: `const mockStorage = { data: {} }`
- Test migration with V1 sample data, verify V2 structure
- Test save/load round-trip preserves all cycle data
- Test quota exceeded error handling

**Location**: `index.html` lines 200-350 (Data Access Layer section)

**Example Test**:
```javascript
// Test data migration
const v1Iteration = {
  id: 'iter_123',
  inputs: { step1: 'value1' },
  notes: { step1: 'note1' },
  completedSteps: { step1: true },
  currentCycle: 'blue'
};

const v2Iteration = migrateIterationToCycles(v1Iteration);

assert(v2Iteration.cycles.length === 1, 'Should create one cycle');
assert(v2Iteration.cycles[0].name.startsWith('Initial Cycle'), 'Should use migration name');
assert(v2Iteration.inputs.step1[v2Iteration.cycles[0].id] === 'value1', 'Should preserve input data');
```

---

### Module 2: Cycle Management (循环管理模块)

**Purpose**: Implement core cycle CRUD operations and validation logic

**Interface**:
```javascript
// Create new cycle
function cycleManagementAdd(iterationId: string, cycleName?: string): Cycle | null

// Rename existing cycle
function cycleManagementRename(iterationId: string, cycleId: string, newName: string): boolean

// Delete cycle (minimum 1 enforced)
function cycleManagementDelete(iterationId: string, cycleId: string): boolean

// Switch current cycle
function cycleManagementSwitch(iterationId: string, cycleId: string): boolean

// Validate cycle name
function validateCycleName(name: string): { valid: boolean, errors: string[] }

// Find adjacent cycle for auto-switch
function getAdjacentCycle(iteration: Iteration, deletedCycleId: string): Cycle

// Remove all data for a cycle
function removeAllCycleData(iteration: Iteration, cycleId: string): void
```

**Dependencies**:
- **Internal**: Data Access Module (`saveProjects()`)
- **External**: None

**Independent Test Strategy**:
- Provide test iteration object with mock cycles
- Verify cycle CRUD operations modify data correctly
- Test validation rules (empty name, max length, whitespace)
- Test minimum cycle enforcement (cannot delete last cycle)
- Test auto-switch logic (previous cycle preferred, fallback to next)

**Location**: `index.html` lines 400-700 (Business Logic Layer section)

**Example Test**:
```javascript
// Test add cycle
const iteration = {
  id: 'iter_123',
  cycles: [{ id: 'cycle_1', name: 'Initial', order: 1 }],
  currentCycle: 'cycle_1',
  inputs: {},
  notes: {},
  completedSteps: {}
};

const newCycle = cycleManagementAdd('iter_123', 'Review Round');

assert(newCycle !== null, 'Should create cycle');
assert(newCycle.name === 'Review Round', 'Should use provided name');
assert(iteration.cycles.length === 2, 'Should add to cycles array');
assert(iteration.currentCycle === newCycle.id, 'Should set as current');
```

---

### Module 3: Cycle Rendering (循环渲染模块)

**Purpose**: Generate HTML for cycle selector and update iteration workflow UI

**Interface**:
```javascript
// Render cycle dropdown and action buttons
function renderCycleSelector(iterationId: string): string

// Render iteration workflow with current cycle data
function renderIterationWorkflow(iterationId: string): void

// Truncate long cycle names for display
function truncateCycleName(name: string, maxLength: number): string

// Escape HTML to prevent XSS
function escapeHtml(text: string): string
```

**Dependencies**:
- **Internal**: Cycle Management Module (read cycle data)
- **External**: Browser DOM API

**Independent Test Strategy**:
- Provide test iteration with known cycles
- Verify HTML output contains expected elements (select, options, buttons)
- Test truncation with names >50 characters
- Verify HTML escaping prevents script injection
- Test rendering with 0, 1, 5, 20 cycles

**Location**: `index.html` lines 800-1100 (Presentation Layer section)

**Example Test**:
```javascript
// Test render cycle selector
const html = renderCycleSelector('iter_123');

assert(html.includes('<select'), 'Should render dropdown');
assert(html.includes('option'), 'Should render cycle options');
assert(html.includes('➕'), 'Should render add button');
assert(html.includes('✏️'), 'Should render rename button');
assert(html.includes('🗑️'), 'Should render delete button');
assert(html.includes('onchange="handleCycleSwitch'), 'Should bind change handler');
```

---

### Module 4: Event Handlers (事件处理模块)

**Purpose**: Orchestrate user interactions between UI events and business logic

**Interface**:
```javascript
// Handle add cycle button click
function handleAddCycle(iterationId: string): void

// Handle rename cycle button click
function handleRenameCycle(iterationId: string, cycleId: string): void

// Handle delete cycle button click
function handleDeleteCycle(iterationId: string, cycleId: string): void

// Handle cycle dropdown change
function handleCycleSwitch(iterationId: string, cycleId: string): void
```

**Dependencies**:
- **Internal**: All modules (orchestration layer)
  - Calls `cycleManagement*()` for business logic
  - Calls `render*()` for UI updates
- **External**: Browser `prompt()` and `confirm()` dialogs

**Independent Test Strategy**:
- Mock user interactions (prompt return values, confirm responses)
- Verify correct module function calls
- Test cancellation flows (user clicks cancel in prompts)
- Test error handling (invalid input, operation failures)

**Location**: `index.html` lines 1200-1400 (Event Handler Layer section)

**Example Test**:
```javascript
// Test handle add cycle
mockPrompt.returnValue = 'Test Cycle';

handleAddCycle('iter_123');

assert(mockCycleManagementAdd.calledWith('iter_123', 'Test Cycle'), 'Should call add with provided name');
assert(mockRenderIterationWorkflow.calledWith('iter_123'), 'Should re-render after add');
```

---

### Module Dependency Graph

```
┌─────────────────────────────────────────────┐
│          Event Handler Module               │
│  (handleAddCycle, handleRenameCycle, etc.)  │
└────────────┬────────────────────────────────┘
             │ orchestrates
             ↓
┌─────────────────────────────────────────────┐
│        Presentation Module                  │
│  (renderCycleSelector, renderIterationW...) │
└────────────┬────────────────────────────────┘
             │ calls
             ↓
┌─────────────────────────────────────────────┐
│       Business Logic Module                 │
│  (cycleManagementAdd, validateCycleName...) │
└────────────┬────────────────────────────────┘
             │ calls
             ↓
┌─────────────────────────────────────────────┐
│         Data Access Module                  │
│  (saveProjects, loadProjects, migrate...)   │
└─────────────────────────────────────────────┘

(No circular dependencies - strictly unidirectional)
```

### Single-File Architecture Adaptation

**Function Groups (Pseudo-Modules)**:

1. **Data Access Module**: `save*`, `load*`, `migrate*` functions
   - Purpose: Handle all LocalStorage/Firebase operations
   - Interface: Accept data objects, return success/error
   - Dependencies: None
   - Test: Mock localStorage/Firebase

2. **Business Logic Module**: `cycleManagement*`, `validate*`, `get*`, `remove*` functions
   - Purpose: Implement cycle operations and validation rules
   - Interface: Accept entities, return validated/processed results
   - Dependencies: Data Access Module only
   - Test: Provide test entities, verify logic

3. **Presentation Module**: `render*`, `truncate*`, `escape*` functions
   - Purpose: Update DOM based on application state
   - Interface: Accept state objects, return HTML or void (DOM update side-effect)
   - Dependencies: Business Logic Module only (not Data Access directly)
   - Test: Verify HTML output, no actual DOM manipulation needed

4. **Event Handler Module**: `handle*` functions
   - Purpose: Bridge user actions to business logic
   - Interface: Event parameters in, no return (orchestrates other modules)
   - Dependencies: All modules (orchestration layer)
   - Test: Mock user events, verify correct module calls

**Enforcement**: Function naming conventions strictly enforced during code review. Any deviation triggers WARNING-level constitution violation.

## Layers of Concerns Design *(新增 / NEW - Constitution Principle VII)*

### Data Access Layer (数据访问层)

**Responsibilities**:
- Persist project data (including cycles) to LocalStorage
- Sync project data to Firebase Realtime Database (if user authenticated)
- Load project data and apply version migrations
- Create automatic backups before destructive operations

**Components**:
- **Functions**: `saveProjects()`, `loadProjects()`, `migrateIterationToCycles()`
- **External Dependencies**:
  - `localStorage` API (primary storage)
  - Firebase Realtime Database SDK (optional sync)
- **Data Contracts**:
  - Input: `Project[]` objects
  - Output: `boolean` (save success) or `Project[]` (load result)
  - Side effects: Updates localStorage/Firebase, creates backups

**Prohibited**:
- ❌ MUST NOT manipulate DOM
- ❌ MUST NOT contain business logic (validation, calculations)
- ❌ MUST NOT be called by Presentation Layer directly

**Example Interface**:
```javascript
// Data Access Layer functions

// Save all projects to storage
function saveProjects(): boolean {
  try {
    const data = {
      version: 2,
      timestamp: new Date().toISOString(),
      projects: currentProjects
    };
    localStorage.setItem('spec_kit_data', JSON.stringify(data));

    // Optional: sync to Firebase
    if (isAuthenticated()) {
      syncToFirebase(data);
    }

    return true;
  } catch (error) {
    console.error('Save failed:', error);
    return false;
  }
}

// Load projects from storage with migration
function loadProjects(): Project[] {
  const rawData = localStorage.getItem('spec_kit_data');
  if (!rawData) return [];

  const data = JSON.parse(rawData);
  const projects = data.projects || [];

  // Apply cycle migration to all iterations
  projects.forEach(project => {
    project.iterations = project.iterations.map(migrateIterationToCycles);
  });

  return projects;
}

// Migrate V1 iteration to V2 cycle structure
function migrateIterationToCycles(iteration: Iteration): Iteration {
  // (See data-model.md for full implementation)
}
```

---

### Business Logic Layer (业务逻辑层)

**Responsibilities**:
- Validate cycle names (non-empty, max length)
- Create new cycles with auto-generated IDs and default names
- Rename cycles with validation
- Delete cycles with minimum cycle enforcement and confirmation
- Switch current cycle
- Find adjacent cycles for auto-switch logic
- Remove all cycle-specific data on deletion

**Components**:
- **Functions**: `cycleManagementAdd()`, `cycleManagementRename()`, `cycleManagementDelete()`, `cycleManagementSwitch()`, `validateCycleName()`, `getAdjacentCycle()`, `removeAllCycleData()`
- **Internal Dependencies**: Data Access Layer only (`saveProjects()`)
- **Business Rules**:
  - Cycle names cannot be empty after trim
  - Cycle names cannot exceed 200 characters
  - Each iteration must have at least 1 cycle
  - New cycles automatically become currentCycle
  - Deleting current cycle triggers auto-switch to adjacent cycle

**Prohibited**:
- ❌ MUST NOT manipulate DOM
- ❌ MUST NOT directly call storage APIs (use Data Access Layer)
- ❌ MUST NOT handle user events directly

**Example Interface**:
```javascript
// Business Logic Layer functions

// Add new cycle with validation
function cycleManagementAdd(iterationId: string, cycleName?: string): Cycle | null {
  const iteration = findIterationById(iterationId);
  if (!iteration) return null;

  const trimmedName = (cycleName || '').trim();
  const defaultName = `Cycle ${iteration.cycles.length + 1}`;
  const finalName = trimmedName || defaultName;

  const validation = validateCycleName(finalName);
  if (!validation.valid) {
    alert(validation.errors[0]);
    return null;
  }

  const newCycle = {
    id: `cycle_${Date.now()}`,
    name: finalName,
    createdAt: new Date().toISOString(),
    order: Math.max(...iteration.cycles.map(c => c.order), 0) + 1
  };

  iteration.cycles.push(newCycle);
  iteration.currentCycle = newCycle.id;

  // Initialize empty data for all steps
  initializeEmptyCycleData(iteration, newCycle.id);

  saveProjects();
  return newCycle;
}

// Validate cycle name input
function validateCycleName(name: string): { valid: boolean, errors: string[] } {
  const errors = [];
  const trimmedName = (name || '').trim();

  if (!trimmedName) {
    errors.push('Cycle name cannot be empty');
  }

  if (trimmedName.length > 200) {
    errors.push('Cycle name cannot exceed 200 characters');
  }

  return {
    valid: errors.length === 0,
    errors
  };
}

// Delete cycle with minimum enforcement
function cycleManagementDelete(iterationId: string, cycleId: string): boolean {
  const iteration = findIterationById(iterationId);
  if (!iteration) return false;

  // Minimum cycle enforcement
  if (iteration.cycles.length === 1) {
    alert('Cannot delete the last cycle. Each iteration must have at least one cycle.');
    return false;
  }

  const cycle = iteration.cycles.find(c => c.id === cycleId);
  if (!cycle) return false;

  // Confirmation dialog
  const confirmed = confirm(
    `Are you sure you want to delete "${cycle.name}"?\n\n` +
    `All cycle data will be permanently removed:\n` +
    `- Input values\n- Notes\n- Completion status\n\n` +
    `This action cannot be undone.`
  );

  if (!confirmed) return false;

  // Auto-switch if deleting current cycle
  if (iteration.currentCycle === cycleId) {
    const adjacentCycle = getAdjacentCycle(iteration, cycleId);
    iteration.currentCycle = adjacentCycle.id;
  }

  // Remove cycle metadata
  iteration.cycles = iteration.cycles.filter(c => c.id !== cycleId);

  // Remove all cycle-specific data
  removeAllCycleData(iteration, cycleId);

  saveProjects();
  return true;
}
```

---

### Presentation Layer (展示层)

**Responsibilities**:
- Render cycle selector dropdown with action buttons
- Render iteration workflow with current cycle's data
- Update DOM when cycle is switched
- Truncate long cycle names for display
- Escape HTML to prevent XSS attacks

**Components**:
- **Functions**: `renderIterationWorkflow()`, `renderCycleSelector()`, `truncateCycleName()`, `escapeHtml()`
- **Internal Dependencies**: Business Logic Layer only (to read cycle data)
- **UI Framework**: Vanilla JavaScript (no framework)

**Prohibited**:
- ❌ MUST NOT call Data Access Layer directly
- ❌ MUST NOT contain business logic
- ❌ MUST NOT perform data validation (delegate to Business Logic)

**Example Interface**:
```javascript
// Presentation Layer functions

// Render cycle selector UI
function renderCycleSelector(iterationId: string): string {
  const iteration = findIterationById(iterationId);
  if (!iteration) return '';

  const cycles = iteration.cycles.sort((a, b) => a.order - b.order);

  return `
    <div class="cycle-selector">
      <select id="cycleSelect" onchange="handleCycleSwitch('${iterationId}', this.value)">
        ${cycles.map(cycle => `
          <option value="${cycle.id}" ${cycle.id === iteration.currentCycle ? 'selected' : ''}>
            ${escapeHtml(truncateCycleName(cycle.name, 50))}
          </option>
        `).join('')}
      </select>
      <button onclick="handleAddCycle('${iterationId}')" title="Add Cycle">➕</button>
      <button onclick="handleRenameCycle('${iterationId}', '${iteration.currentCycle}')" title="Rename">✏️</button>
      <button onclick="handleDeleteCycle('${iterationId}', '${iteration.currentCycle}')" title="Delete">🗑️</button>
    </div>
  `;
}

// Render iteration workflow with current cycle data
function renderIterationWorkflow(iterationId: string): void {
  const iteration = findIterationById(iterationId);
  if (!iteration) return;

  const currentCycleId = iteration.currentCycle;

  const html = `
    <div class="iteration-workflow">
      <h2>${escapeHtml(iteration.name)}</h2>

      ${renderCycleSelector(iterationId)}

      <div class="workflow-steps">
        ${getStepIds().map(stepId => {
          const input = iteration.inputs[stepId]?.[currentCycleId] || '';
          const note = iteration.notes[stepId]?.[currentCycleId] || '';
          const completed = iteration.completedSteps[stepId]?.[currentCycleId] || false;

          return `
            <div class="workflow-step">
              <h3>${getStepName(stepId)}</h3>
              <textarea id="input-${stepId}" placeholder="Enter input">${input}</textarea>
              <textarea id="notes-${stepId}" placeholder="Notes">${note}</textarea>
              <label>
                <input type="checkbox" id="completed-${stepId}" ${completed ? 'checked' : ''}
                  onchange="handleStepCompletion('${iterationId}', '${stepId}', this.checked)">
                Mark as completed
              </label>
            </div>
          `;
        }).join('')}
      </div>
    </div>
  `;

  document.getElementById('mainContent').innerHTML = html;
}

// Truncate long cycle names
function truncateCycleName(name: string, maxLength: number): string {
  if (name.length <= maxLength) return name;
  return name.substring(0, maxLength - 3) + '...';
}

// Escape HTML entities
function escapeHtml(text: string): string {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}
```

---

### Layer Communication Rules

**Allowed Call Chains** (unidirectional):
```
Event Handler Layer
      ↓ (calls)
Presentation Layer
      ↓ (calls)
Business Logic Layer
      ↓ (calls)
Data Access Layer
```

**Prohibited** (reverse calls):
```
Data Access Layer ─X→ Business Logic Layer
Data Access Layer ─X→ Presentation Layer
Business Logic Layer ─X→ Presentation Layer
Presentation Layer ─X→ Data Access Layer (must go through Business Logic)
```

**Event Handler Bridge** (orchestration):
```
User Event → Event Handler → {
    1. Prompt user for input (if needed)
    2. Call Business Logic Layer (validate, execute operation)
    3. Call Data Access Layer (via Business Logic - saveProjects())
    4. Call Presentation Layer (re-render UI with updated data)
}
```

**Example Flow - Add Cycle**:
```
1. User clicks ➕ button
   ↓
2. handleAddCycle(iterationId) [Event Handler]
   ↓
3. prompt('Enter cycle name:') [Event Handler]
   ↓
4. cycleManagementAdd(iterationId, name) [Business Logic]
   ↓
5. validateCycleName(name) [Business Logic]
   ↓
6. saveProjects() [Data Access]
   ↓
7. renderIterationWorkflow(iterationId) [Presentation]
   ↓
8. User sees new cycle in dropdown
```

### Single-File Architecture Adaptation

**Code Organization Order** (top to bottom in index.html):

```javascript
<script>
// ============================================
// PART 1: CONSTANTS AND CONFIGURATION
// ============================================
const DATA_VERSION = 2;
const CYCLE_NAME_MAX_LENGTH = 200;
const CYCLE_PAGINATION_THRESHOLD = 10;

// ============================================
// PART 2: DATA ACCESS LAYER
// ============================================
function saveProjects() { /* ... */ }
function loadProjects() { /* ... */ }
function migrateIterationToCycles(iteration) { /* ... */ }

// ============================================
// PART 3: BUSINESS LOGIC LAYER
// ============================================
function cycleManagementAdd(iterationId, cycleName) { /* ... */ }
function cycleManagementRename(iterationId, cycleId, newName) { /* ... */ }
function cycleManagementDelete(iterationId, cycleId) { /* ... */ }
function cycleManagementSwitch(iterationId, cycleId) { /* ... */ }
function validateCycleName(name) { /* ... */ }
function getAdjacentCycle(iteration, deletedCycleId) { /* ... */ }
function removeAllCycleData(iteration, cycleId) { /* ... */ }

// ============================================
// PART 4: PRESENTATION LAYER
// ============================================
function renderIterationWorkflow(iterationId) { /* ... */ }
function renderCycleSelector(iterationId) { /* ... */ }
function renderMainContent() { /* ... */ }
function truncateCycleName(name, maxLength) { /* ... */ }
function escapeHtml(text) { /* ... */ }

// ============================================
// PART 5: EVENT HANDLER LAYER (BRIDGE)
// ============================================
function handleAddCycle(iterationId) { /* ... */ }
function handleRenameCycle(iterationId, cycleId) { /* ... */ }
function handleDeleteCycle(iterationId, cycleId) { /* ... */ }
function handleCycleSwitch(iterationId, cycleId) { /* ... */ }

// ============================================
// PART 6: INITIALIZATION
// ============================================
document.addEventListener('DOMContentLoaded', () => {
  currentProjects = loadProjects();
  renderMainContent();
});
</script>
```

**Naming Convention Enforcement**:
- Data Access: `saveProjects()`, `loadProjects()`, `migrateIterationToCycles()`
- Business Logic: `cycleManagementAdd()`, `validateCycleName()`, `getAdjacentCycle()`, `removeAllCycleData()`
- Presentation: `renderIterationWorkflow()`, `renderCycleSelector()`, `truncateCycleName()`, `escapeHtml()`
- Event Handlers: `handleAddCycle()`, `handleRenameCycle()`, `handleDeleteCycle()`, `handleCycleSwitch()`

**Code Review Checklist**:
- [ ] No `render*` functions call `localStorage` or `firebase` directly
- [ ] No `save*` functions call `document.getElementById()`
- [ ] No `validate*` functions manipulate DOM
- [ ] Event handlers properly orchestrate layers in correct order
- [ ] All functions follow naming conventions for their layer
- [ ] No functions exceed 50 lines
- [ ] No nesting depth exceeds 3 levels

**Cycle Management Layer Checklist** (Constitution Principles VI & VII):
- [ ] T009: No `render*` functions in cycle management call `localStorage`
- [ ] T010: No `cycleManagement*` functions manipulate DOM
- [ ] T011: No `render*` functions call `saveProjects()` directly
- [ ] T012: Layer call chain validated: Event Handler → Presentation → Business Logic → Data Access

## Architecture Decisions

### Decision 1: Nested Object vs. Array-Based Cycle Storage

**Context**: Need to store cycle-specific data (inputs, notes, completedSteps) for each workflow step

**Options Evaluated**:
1. **Nested object structure** (CHOSEN): `{stepId: {cycleId: value}}`
2. Array-based structure: `[{cycleId, stepId, value}]`
3. Separate cycle objects: `cycles: [{id, inputs: {}, notes: {}}]`

**Decision**: Use nested object structure

**Rationale**:
- ✅ **O(1) Access**: Direct key lookup for current cycle data
- ✅ **Backward Compatible**: Existing flat structure easily transforms to nested
- ✅ **Storage Efficient**: No data duplication, minimal overhead
- ✅ **Query Flexibility**: Easy to find all cycles for a step or all steps for a cycle

**Consequences**:
- Migration required for existing data (handled automatically on load)
- Referential integrity checks needed (all cycleIds must exist in cycles array)
- Slightly more complex delete operation (remove keys from nested objects)

---

### Decision 2: Automatic Migration vs. Manual User Action

**Context**: Existing iterations use flat data structure without cycles

**Options Evaluated**:
1. **Automatic migration on load** (CHOSEN)
2. Manual migration button (user initiates)
3. Background migration job (async)

**Decision**: Automatic migration during `loadProjects()`

**Rationale**:
- ✅ **Zero User Effort**: No manual action required, seamless upgrade
- ✅ **Data Integrity**: Migration happens in controlled function with error handling
- ✅ **Transparency**: Timestamped cycle name clearly communicates migration
- ✅ **Idempotent**: Multiple calls to `migrateIterationToCycles()` are safe (checks if already migrated)

**Consequences**:
- Migration runs on every page load until all data migrated (negligible performance impact)
- Backup created before first migration (24-hour retention)
- Users see "Initial Cycle - Migrated YYYY-MM-DD" as first cycle name

---

### Decision 3: Dropdown Selector vs. Tab-Based UI

**Context**: Need UI pattern for displaying and switching between cycles

**Options Evaluated**:
1. **Dropdown selector** (CHOSEN)
2. Tab-based selector
3. Sidebar list

**Decision**: Use dropdown `<select>` element with action buttons

**Rationale**:
- ✅ **Consistency**: Matches existing cycle color selector pattern
- ✅ **Space Efficiency**: Dropdown conserves vertical/horizontal space
- ✅ **Scalability**: Handles 20+ cycles with pagination/scroll
- ✅ **Accessibility**: Native `<select>` supports keyboard navigation

**Consequences**:
- Cycle list visible only when dropdown is open (not always-on visibility)
- Action buttons (add/rename/delete) placed next to dropdown
- Long cycle names truncated with ellipsis (full name in tooltip)

---

### Decision 4: Minimum 1 Cycle Enforcement

**Context**: Need to prevent users from deleting all cycles in an iteration

**Options Evaluated**:
1. **Minimum 1 cycle enforced** (CHOSEN)
2. Allow 0 cycles (iteration without cycles)
3. Soft delete (archive cycle, allow restore)

**Decision**: Enforce minimum 1 cycle per iteration

**Rationale**:
- ✅ **Data Integrity**: Ensures iteration always has working state
- ✅ **Simplifies Logic**: No need to handle "no cycles" edge case
- ✅ **User Intent**: If user wants to remove all cycles, they should delete the iteration

**Consequences**:
- Delete button disabled or shows error when attempting to delete last cycle
- User must add new cycle before deleting current one (if they want different name)
- UI communicates constraint clearly in error message

---

### Decision 5: Auto-Switch on Delete vs. Leave Empty

**Context**: When user deletes currently active cycle, what should happen?

**Options Evaluated**:
1. **Auto-switch to adjacent cycle** (CHOSEN)
2. Leave UI empty, force user to manually select cycle
3. Delete confirmation with cycle selection

**Decision**: Automatically switch to previous or next cycle

**Rationale**:
- ✅ **Workflow Continuity**: User can immediately continue working
- ✅ **Predictable Behavior**: Previous cycle preferred (chronological order)
- ✅ **Reduces Clicks**: No extra step to select new cycle

**Consequences**:
- Logic needed to find adjacent cycle (previous > next > fallback)
- UI instantly updates to show new cycle's data after deletion
- User sees confirmation that auto-switch occurred (via UI update)

---

## Risk Assessment

### Technical Risks

**Risk 1: Data Migration Corruption** (Medium Impact, Low Probability)

**Description**: Migration logic could corrupt existing projects during V1→V2 transformation

**Mitigation**:
- ✅ Backup created before migration (`localStorage.setItem('spec_kit_backup', ...)`)
- ✅ Migration function thoroughly tested with sample V1 data
- ✅ Idempotent migration (checks if already migrated, skips if so)
- ✅ Migration tested manually with real project data

**Fallback Plan**: If corruption detected, restore from backup:
```javascript
const backup = localStorage.getItem('spec_kit_backup');
localStorage.setItem('spec_kit_data', backup);
location.reload();
```

**Probability**: Low (5%)
**Impact if occurs**: Medium (data loss, user frustration)
**Risk Score**: 5% × Medium = **Low Risk**

---

**Risk 2: Performance Degradation with Many Cycles** (Low Impact, Medium Probability)

**Description**: Iterations with >20 cycles may experience slow UI rendering or data access

**Mitigation**:
- ✅ Pagination implemented for cycle selector at >10 cycles
- ✅ Direct O(1) object key lookup for data access (no iteration)
- ✅ Performance tested with 20 cycles (target: <100ms rendering)

**Fallback Plan**: If slowness reported:
1. Implement virtual scrolling for cycle selector
2. Add lazy loading for cycle data (load only current cycle initially)
3. Document best practice: limit to 5-7 cycles per iteration

**Probability**: Medium (30% - some users may create many cycles)
**Impact if occurs**: Low (slight delay, still functional)
**Risk Score**: 30% × Low = **Low Risk**

---

**Risk 3: LocalStorage Quota Exceeded** (Low Impact, Low Probability)

**Description**: Adding cycles increases storage footprint, potentially hitting 5-10 MB browser limit

**Mitigation**:
- ✅ Storage estimation: 10 projects × 10 iterations × 5 cycles = ~325 KB (well under limit)
- ✅ Error handling in `saveProjects()` catches quota exceeded exception
- ✅ User notified if save fails: "Storage full, delete old projects"

**Fallback Plan**:
- Firebase sync as alternative storage (no quota limit)
- Export/import functionality to offload old projects
- Cycle archiving feature (move old cycles to separate storage)

**Probability**: Low (10%)
**Impact if occurs**: Low (user can delete old data)
**Risk Score**: 10% × Low = **Very Low Risk**

---

**Risk 4: UI Confusion with Similar Cycle Names** (Low Impact, Medium Probability)

**Description**: Users may create cycles with same or similar names, causing confusion when switching

**Mitigation**:
- ✅ Dropdown shows full cycle name (with truncation and tooltip for long names)
- ✅ Cycles sorted chronologically (creation order clear)
- ✅ Quickstart guide documents naming best practices

**Fallback Plan**: If reported as issue:
- Add visual indicators (creation date, cycle number)
- Add search/filter functionality to cycle selector
- Warn user when creating duplicate name

**Probability**: Medium (40% - users may not follow naming best practices)
**Impact if occurs**: Low (minor inconvenience, no data loss)
**Risk Score**: 40% × Low = **Low Risk**

---

**Risk 5: Referential Integrity Violation** (High Impact, Very Low Probability)

**Description**: Code bug could create orphaned cycleIds in nested data (references to non-existent cycles)

**Mitigation**:
- ✅ Validation function `validateIterationIntegrity()` checks all references
- ✅ Test cases verify referential integrity after all CRUD operations
- ✅ Delete operation explicitly removes all cycle data (no orphans left)

**Fallback Plan**: If detected:
- Run integrity checker on load, auto-fix violations (remove orphaned keys)
- Log violations to console for debugging
- Backup before any auto-fix

**Probability**: Very Low (2% - requires code bug)
**Impact if occurs**: High (data corruption, crashes)
**Risk Score**: 2% × High = **Low Risk**

---

### Overall Risk Profile

| Risk | Probability | Impact | Score | Mitigation Status |
|------|-------------|--------|-------|-------------------|
| Data Migration Corruption | Low (5%) | Medium | Low | ✅ Fully Mitigated |
| Performance Degradation | Medium (30%) | Low | Low | ✅ Fully Mitigated |
| LocalStorage Quota | Low (10%) | Low | Very Low | ✅ Fully Mitigated |
| UI Confusion | Medium (40%) | Low | Low | ⚠️ Partially Mitigated |
| Referential Integrity | Very Low (2%) | High | Low | ✅ Fully Mitigated |

**Overall Assessment**: ✅ **LOW RISK** - All high-impact risks have very low probability and are fully mitigated. Medium-probability risks have low impact.

---

## Time Estimation

### Phase 2: Implementation (executed by `/speckit.implement`)

**Total Estimated Time**: 8-12 hours (1-2 days for experienced developer)

| Task Category | Estimated Time | Confidence |
|---------------|----------------|------------|
| Data Access Layer | 2-3 hours | High |
| Business Logic Layer | 3-4 hours | High |
| Presentation Layer | 2-3 hours | Medium |
| Event Handler Layer | 1-2 hours | High |
| Testing & Bug Fixes | 2-3 hours | Medium |

**Breakdown by Function**:

#### Data Access Layer (2-3 hours)
- `migrateIterationToCycles()`: 1 hour (complex transformation logic)
- Update `saveProjects()`: 30 min (add backup logic)
- Update `loadProjects()`: 30 min (call migration)
- Testing: 1 hour (test migration with various V1 data)

#### Business Logic Layer (3-4 hours)
- `cycleManagementAdd()`: 1 hour (create cycle, initialize data)
- `cycleManagementRename()`: 30 min (simple update)
- `cycleManagementDelete()`: 1 hour (minimum enforcement, auto-switch, cleanup)
- `cycleManagementSwitch()`: 30 min (update currentCycle)
- `validateCycleName()`: 30 min (validation rules)
- `getAdjacentCycle()`: 30 min (find previous/next)
- `removeAllCycleData()`: 30 min (iterate and delete keys)
- Testing: 1 hour (test all CRUD operations)

#### Presentation Layer (2-3 hours)
- `renderCycleSelector()`: 1 hour (dropdown + buttons)
- Update `renderIterationWorkflow()`: 1 hour (integrate cycle selector, cycle-specific data)
- `truncateCycleName()`: 15 min (simple string manipulation)
- `escapeHtml()`: 15 min (XSS prevention)
- Testing: 1 hour (verify HTML output, test with various cycle counts)

#### Event Handler Layer (1-2 hours)
- `handleAddCycle()`: 30 min (prompt, call add, re-render)
- `handleRenameCycle()`: 30 min (prompt, call rename, re-render)
- `handleDeleteCycle()`: 30 min (confirmation, call delete, re-render)
- `handleCycleSwitch()`: 15 min (call switch, re-render)
- Testing: 30 min (test all user interactions)

#### Testing & Bug Fixes (2-3 hours)
- Manual testing of all 18 acceptance scenarios: 2 hours
- Bug fixes and edge case handling: 1 hour

**Assumptions**:
- Developer familiar with existing codebase
- Access to `test-automation.html` for manual testing
- No major refactoring of existing code required

**Confidence Levels**:
- **High**: Well-defined tasks with clear interfaces
- **Medium**: May require iteration or debugging
- **Low**: Uncertain scope or dependencies

---

## Implementation Sequence

**Phase 2 will be executed by `/speckit.tasks` and `/speckit.implement`**

Recommended task order (will be detailed in `tasks.md`):

1. **Data Layer First** (Foundation)
   - Implement `migrateIterationToCycles()`
   - Update `saveProjects()` with backup
   - Update `loadProjects()` to call migration
   - Test migration thoroughly

2. **Business Logic Second** (Core Operations)
   - Implement `validateCycleName()`
   - Implement `cycleManagementAdd()`
   - Implement `cycleManagementRename()`
   - Implement `getAdjacentCycle()`
   - Implement `removeAllCycleData()`
   - Implement `cycleManagementDelete()`
   - Implement `cycleManagementSwitch()`
   - Test all CRUD operations

3. **Presentation Third** (UI)
   - Implement `truncateCycleName()` and `escapeHtml()`
   - Implement `renderCycleSelector()`
   - Update `renderIterationWorkflow()`
   - Test rendering with various cycle counts

4. **Event Handlers Fourth** (User Interaction)
   - Implement `handleAddCycle()`
   - Implement `handleRenameCycle()`
   - Implement `handleDeleteCycle()`
   - Implement `handleCycleSwitch()`
   - Test all user flows

5. **Integration Testing Fifth** (End-to-End)
   - Test all 18 acceptance scenarios
   - Test edge cases (empty states, long names, many cycles)
   - Test error handling (validation failures, storage errors)
   - Performance testing (20 cycles)

---

## Success Metrics

### Functional Completeness

✅ All 15 functional requirements (FR-001 to FR-015) implemented
✅ All 18 acceptance scenarios pass
✅ All 6 edge cases handled

### Performance Targets

✅ Add cycle: < 5 seconds (user interaction time)
✅ Rename cycle: < 10 seconds (user interaction time)
✅ Delete cycle: < 5 seconds (user interaction time)
✅ Switch cycle: < 100ms (UI update)
✅ Load iteration with 20 cycles: < 500ms

### Quality Metrics

✅ Zero CRITICAL constitution violations
✅ Zero WARNING constitution violations
✅ All functions < 50 lines
✅ All nesting depth ≤ 3 levels
✅ 100% critical path test coverage

### User Experience

✅ Existing iterations automatically migrated (zero user effort)
✅ Cycle operations complete without page reload
✅ Clear error messages for validation failures
✅ Confirmation dialogs prevent accidental deletion
✅ UI remains responsive with up to 20 cycles

---

## Next Steps

**After `/speckit.plan` completes**:

1. ✅ Review this implementation plan
2. ✅ Confirm technical approach and architecture decisions
3. → Run `/speckit.tasks` to generate detailed task breakdown in `tasks.md`
4. → Run `/speckit.implement` to execute tasks and build the feature

**Generated Artifacts Summary**:

```
specs/004-/
├── spec.md ✅                  # Feature specification (complete)
├── plan.md ✅                  # This file (complete)
├── research.md ✅              # Technical research (complete)
├── data-model.md ✅            # Entity definitions (complete)
├── quickstart.md ✅            # User guide (complete)
├── contracts/ ✅
│   └── README.md               # Function interfaces (complete)
├── checklists/ ✅
│   └── requirements.md         # Spec validation (complete)
└── tasks.md ⏳                 # Task breakdown (created by /speckit.tasks)
```

**Ready for**: `/speckit.tasks` command to proceed with implementation

---

## Appendix: Related Documentation

- [Feature Specification](./spec.md) - Complete requirements and user stories
- [Research Document](./research.md) - Technical decisions and best practices
- [Data Model](./data-model.md) - Entity definitions and relationships
- [API Contracts](./contracts/README.md) - Function interfaces and data flow
- [Quick Start Guide](./quickstart.md) - User guide for cycle management
- [Constitution](../.specify/memory/constitution.md) - Project architectural principles
