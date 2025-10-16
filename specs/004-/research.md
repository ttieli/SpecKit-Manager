# Research Document: Cycle Management for Project Iterations

**Feature**: 004-cycle-management
**Date**: 2025-10-16
**Purpose**: Resolve technical unknowns and document architecture decisions

## Research Questions

### Q1: Data Structure Migration Strategy

**Question**: How should existing iteration data be migrated to support cycle-based storage without data loss?

**Decision**: Preserve existing data in a timestamped first cycle

**Rationale**:
- **Backward Compatibility**: All existing projects continue to function without manual intervention
- **Data Integrity**: No data loss during migration - all inputs, notes, and completion states are preserved
- **User Transparency**: Timestamp in cycle name (e.g., "Initial Cycle - Migrated 2025-10-16") clearly communicates the migration event
- **Minimal Code Impact**: Migration can be implemented as a one-time transformation during data load

**Alternatives Considered**:
1. **Option A: Create empty first cycle, archive old data separately**
   - Rejected: Splits historical data from working data, confusing for users
   - Requires additional UI for viewing archived data

2. **Option C: Leave old data as-is, require manual cycle assignment**
   - Rejected: Poor user experience, requires manual work for every existing project
   - Risk of users losing track of historical data

3. **Option D: Smart migration with heuristic cycle detection**
   - Rejected: Too complex for initial implementation
   - Heuristics may incorrectly infer cycle boundaries
   - Out of scope for MVP

**Implementation Details**:
```javascript
// Migration logic (pseudo-code)
function migrateIterationToCycles(iteration) {
  if (!iteration.cycles || iteration.cycles.length === 0) {
    const migrationDate = new Date().toISOString().split('T')[0];
    const firstCycle = {
      id: `cycle_${Date.now()}`,
      name: `Initial Cycle - Migrated ${migrationDate}`,
      createdAt: iteration.createdAt || new Date().toISOString(),
      order: 1
    };

    // Preserve existing data structure by wrapping it under first cycle
    const cycleId = firstCycle.id;
    iteration.cycles = [firstCycle];
    iteration.currentCycle = cycleId;

    // Transform flat data to cycle-keyed structure
    // Old: inputs = {step1: "value"}
    // New: inputs = {step1: {cycle_xxx: "value"}}
    transformDataToCycleKeyed(iteration, cycleId);
  }
  return iteration;
}
```

---

### Q2: Cycle Selector UI Pattern

**Question**: What UI pattern should be used for cycle selection and management operations?

**Decision**: Dropdown selector with inline action buttons

**Rationale**:
- **Consistency**: Matches existing cycle color selector pattern in the current UI
- **Space Efficiency**: Dropdown conserves screen space for iterations with many cycles
- **Discoverability**: Action buttons (add/rename/delete) visible next to each cycle in dropdown
- **Accessibility**: Standard dropdown semantics support keyboard navigation

**Alternatives Considered**:
1. **Tab-based cycle selector**
   - Rejected: Tabs consume horizontal space, difficult to scale beyond 5-7 cycles
   - Poor fit for iterations with 10+ cycles

2. **Sidebar list with hierarchical view**
   - Rejected: Adds UI complexity, requires additional layout restructuring
   - Over-engineered for the core use case

3. **Modal dialog for cycle management**
   - Rejected: Extra click required to access cycles, slows workflow
   - Hides cycle context while working on iteration

**Implementation Details**:
```html
<!-- Cycle Selector UI (simplified) -->
<div class="cycle-selector">
  <select id="cycleSelect" onchange="handleCycleSwitch(this.value)">
    <option value="cycle_1">Initial Cycle - Migrated 2025-10-16</option>
    <option value="cycle_2" selected>Cycle 2</option>
    <option value="cycle_3">Client Feedback Round</option>
  </select>
  <button onclick="handleAddCycle()" title="Add Cycle">➕</button>
  <button onclick="handleRenameCycle()" title="Rename Current Cycle">✏️</button>
  <button onclick="handleDeleteCycle()" title="Delete Current Cycle">🗑️</button>
</div>
```

**CSS Considerations**:
- Dropdown max-height with scroll for cycles > 5
- Truncate long cycle names with ellipsis, show full name in tooltip
- Visual indicator for currently active cycle

---

### Q3: Data Storage Schema for Cycle-Specific Data

**Question**: How should cycle-specific data (inputs, notes, completedSteps) be stored to ensure data isolation and efficient access?

**Decision**: Nested object structure with cycleId as intermediate key

**Rationale**:
- **Data Isolation**: Each cycle's data is completely independent, preventing accidental overwrites
- **Efficient Access**: Direct lookup via `iteration.inputs[stepId][cycleId]` without array iteration
- **Backward Compatible**: Existing flat structure can be transformed to nested structure during migration
- **Storage Efficiency**: No data duplication, minimal overhead (just additional object level)

**Alternatives Considered**:
1. **Array-based storage with cycle metadata**
   ```javascript
   inputs: [
     { cycleId: 'cycle_1', stepId: 'step_1', value: 'text' },
     { cycleId: 'cycle_2', stepId: 'step_1', value: 'different text' }
   ]
   ```
   - Rejected: Requires array filtering/searching for every data access
   - Poor performance for iterations with many steps and cycles
   - Verbose storage format

2. **Separate top-level arrays per cycle**
   ```javascript
   cycles: [
     { id: 'cycle_1', inputs: {...}, notes: {...}, completedSteps: {...} }
   ]
   ```
   - Rejected: Duplicates step structure across every cycle
   - Harder to query "show me all cycles where step X is completed"
   - Violates existing data model pattern

**Chosen Schema**:
```javascript
{
  "iteration": {
    "id": "iter_123",
    "cycles": [
      { "id": "cycle_1", "name": "Initial Cycle", "order": 1, "createdAt": "2025-10-16T10:00:00Z" },
      { "id": "cycle_2", "name": "Review Round", "order": 2, "createdAt": "2025-10-16T11:00:00Z" }
    ],
    "currentCycle": "cycle_2",
    "inputs": {
      "step_specify": {
        "cycle_1": "Original specification text",
        "cycle_2": "Revised specification after review"
      },
      "step_plan": {
        "cycle_1": "Initial plan",
        "cycle_2": "" // Empty for new cycle
      }
    },
    "notes": {
      "step_specify": {
        "cycle_1": "Initial notes",
        "cycle_2": "Updated notes based on feedback"
      }
    },
    "completedSteps": {
      "step_specify": {
        "cycle_1": true,
        "cycle_2": true
      },
      "step_plan": {
        "cycle_1": true,
        "cycle_2": false // Incomplete in new cycle
      }
    },
    "cycleHistory": {
      "step_specify": {
        "cycle_1": "2025-10-16T10:30:00Z",
        "cycle_2": "2025-10-16T11:15:00Z"
      }
    }
  }
}
```

**Access Patterns**:
```javascript
// Get input for current cycle and step
const currentInput = iteration.inputs[stepId][iteration.currentCycle] || '';

// Check if step is completed in current cycle
const isCompleted = iteration.completedSteps[stepId]?.[iteration.currentCycle] || false;

// Get all cycles where a step is completed
const completedCycles = Object.entries(iteration.completedSteps[stepId] || {})
  .filter(([cycleId, completed]) => completed)
  .map(([cycleId]) => cycleId);
```

---

### Q4: Cycle Deletion Safety Mechanisms

**Question**: What safeguards should prevent accidental cycle deletion and ensure data integrity?

**Decision**: Multi-layer protection with confirmation dialog and minimum cycle enforcement

**Rationale**:
- **User Intent Verification**: Confirmation dialog prevents accidental clicks
- **Data Integrity**: Enforcing minimum 1 cycle ensures iterations always have working state
- **Clear Communication**: Explicit warning about permanent data loss
- **Graceful Fallback**: Auto-switch to adjacent cycle after deletion maintains workflow continuity

**Safety Layers**:

1. **Pre-deletion Validation**:
   ```javascript
   function handleDeleteCycle(cycleId) {
     const iteration = getCurrentIteration();

     // Safety check: prevent deleting last cycle
     if (iteration.cycles.length === 1) {
       alert('Cannot delete the last cycle. Each iteration must have at least one cycle.');
       return;
     }

     // Proceed to confirmation
     confirmCycleDeletion(cycleId);
   }
   ```

2. **User Confirmation**:
   ```javascript
   function confirmCycleDeletion(cycleId) {
     const cycle = getCycleById(cycleId);
     const message = `Are you sure you want to delete "${cycle.name}"?\n\n` +
                    `All cycle data will be permanently removed:\n` +
                    `- Input values\n` +
                    `- Notes\n` +
                    `- Completion status\n\n` +
                    `This action cannot be undone.`;

     if (confirm(message)) {
       executeCycleDeletion(cycleId);
     }
   }
   ```

3. **Graceful Cycle Switching**:
   ```javascript
   function executeCycleDeletion(cycleId) {
     const iteration = getCurrentIteration();
     const deletingCurrentCycle = (iteration.currentCycle === cycleId);

     // Remove cycle metadata
     iteration.cycles = iteration.cycles.filter(c => c.id !== cycleId);

     // Remove all cycle-specific data
     removeAllCycleData(iteration, cycleId);

     // Auto-switch if deleting current cycle
     if (deletingCurrentCycle) {
       const newCurrentCycle = selectAdjacentCycle(iteration.cycles, cycleId);
       iteration.currentCycle = newCurrentCycle.id;
     }

     saveProjects();
     renderIterationWorkflow();
   }

   function selectAdjacentCycle(cycles, deletedCycleId) {
     // Prefer previous cycle, fallback to next cycle
     const sortedCycles = cycles.sort((a, b) => a.order - b.order);
     const deletedIndex = sortedCycles.findIndex(c => c.id === deletedCycleId);

     return sortedCycles[deletedIndex - 1] || sortedCycles[0];
   }
   ```

**Alternatives Considered**:
1. **Soft delete with archive**
   - Rejected: Out of scope, adds complexity
   - Would require archive UI and restore functionality

2. **Undo functionality**
   - Rejected: Out of scope for MVP
   - Would require state history tracking

---

### Q5: Performance Optimization for Large Cycle Collections

**Question**: How should the system handle iterations with 20+ cycles without performance degradation?

**Decision**: Lazy rendering with pagination and virtual scrolling for cycle selector

**Rationale**:
- **Progressive Enhancement**: Basic implementation supports typical use case (3-5 cycles)
- **Scalability**: Optimization layer activates only when needed (>10 cycles)
- **User Experience**: No performance impact for majority of users

**Implementation Strategy**:

1. **Threshold Detection**:
   ```javascript
   const CYCLE_PAGINATION_THRESHOLD = 10;

   function renderCycleSelector(iteration) {
     if (iteration.cycles.length <= CYCLE_PAGINATION_THRESHOLD) {
       renderBasicCycleSelector(iteration);
     } else {
       renderPaginatedCycleSelector(iteration);
     }
   }
   ```

2. **Basic Selector** (≤10 cycles):
   ```javascript
   function renderBasicCycleSelector(iteration) {
     // Standard dropdown with all options
     const html = `
       <select id="cycleSelect">
         ${iteration.cycles.map(cycle => `
           <option value="${cycle.id}" ${cycle.id === iteration.currentCycle ? 'selected' : ''}>
             ${escapeHtml(cycle.name)}
           </option>
         `).join('')}
       </select>
     `;
     return html;
   }
   ```

3. **Paginated Selector** (>10 cycles):
   ```javascript
   function renderPaginatedCycleSelector(iteration) {
     const PAGE_SIZE = 10;
     const currentCycleIndex = iteration.cycles.findIndex(c => c.id === iteration.currentCycle);
     const currentPage = Math.floor(currentCycleIndex / PAGE_SIZE);

     const paginatedCycles = iteration.cycles.slice(
       currentPage * PAGE_SIZE,
       (currentPage + 1) * PAGE_SIZE
     );

     return `
       <select id="cycleSelect" onchange="handleCycleSwitch(this.value)">
         ${paginatedCycles.map(cycle => renderCycleOption(cycle, iteration.currentCycle)).join('')}
       </select>
       <div class="cycle-pagination">
         <button onclick="loadCyclePage(${currentPage - 1})" ${currentPage === 0 ? 'disabled' : ''}>◀</button>
         <span>Page ${currentPage + 1} of ${Math.ceil(iteration.cycles.length / PAGE_SIZE)}</span>
         <button onclick="loadCyclePage(${currentPage + 1})" ${(currentPage + 1) * PAGE_SIZE >= iteration.cycles.length ? 'disabled' : ''}>▶</button>
       </div>
       <input type="text" placeholder="Search cycles..." oninput="filterCycles(this.value)" />
     `;
   }
   ```

4. **Search Functionality**:
   ```javascript
   function filterCycles(searchTerm) {
     const iteration = getCurrentIteration();
     const filtered = iteration.cycles.filter(cycle =>
       cycle.name.toLowerCase().includes(searchTerm.toLowerCase())
     );

     renderCycleSelector({ ...iteration, cycles: filtered });
   }
   ```

**Performance Targets**:
- Render cycle selector: <50ms (up to 20 cycles)
- Switch cycles: <100ms (re-render workflow with new cycle data)
- Search/filter: <200ms (real-time filtering)

**Alternatives Considered**:
1. **Virtual scrolling in dropdown**
   - Rejected: Native `<select>` doesn't support virtual scrolling
   - Would require custom dropdown component (out of scope)

2. **Separate "Cycle Manager" view**
   - Rejected: Adds navigation complexity
   - Users want inline access to cycle operations

---

## Best Practices Research

### Single-File Architecture Patterns

**Research Topic**: Best practices for maintaining code quality in single-file applications

**Findings**:
1. **Function Organization**: Group related functions with comment headers
   ```javascript
   // ============================================
   // DATA ACCESS LAYER - Cycle Management
   // ============================================

   function saveCycleData(iteration) { ... }
   function loadCycleData(iterationId) { ... }
   ```

2. **Naming Conventions as Pseudo-Modules**:
   - Data Access: `save*`, `load*`, `delete*`
   - Business Logic: `validate*`, `calculate*`, `process*`
   - Presentation: `render*`, `switch*`
   - Event Handlers: `handle*`, `on*`

3. **Dependency Flow Enforcement**:
   - Review checklist: No `render*` functions call `localStorage`
   - Linting rules (if applicable): Warn on prohibited cross-layer calls

**Application to This Feature**:
- All cycle management functions follow naming conventions
- Code organized in top-down layer order (Data → Logic → UI → Handlers)
- Function dependencies documented in plan.md Module Boundary section

---

### LocalStorage Data Integrity Patterns

**Research Topic**: Prevent data corruption in localStorage-based applications

**Findings**:
1. **Atomic Writes with Versioning**:
   ```javascript
   const DATA_VERSION = 2; // Increment on schema changes

   function saveProjects() {
     const data = {
       version: DATA_VERSION,
       timestamp: new Date().toISOString(),
       projects: currentProjects
     };

     try {
       localStorage.setItem('spec_kit_data', JSON.stringify(data));
       return true;
     } catch (error) {
       console.error('Save failed:', error);
       return false;
     }
   }
   ```

2. **Migration Strategy**:
   ```javascript
   function loadProjects() {
     const rawData = localStorage.getItem('spec_kit_data');
     if (!rawData) return [];

     const data = JSON.parse(rawData);

     // Handle version migrations
     if (data.version === 1) {
       data.projects = migrateV1ToV2(data.projects);
       data.version = 2;
       saveProjects(); // Persist upgraded data
     }

     return data.projects.map(migrateIterationToCycles);
   }
   ```

3. **Backup Before Destructive Operations**:
   ```javascript
   function cycleManagementDelete(iterationId, cycleId) {
     // Create backup before deletion
     const backup = JSON.parse(JSON.stringify(currentProjects));
     localStorage.setItem('spec_kit_backup', JSON.stringify(backup));

     // Proceed with deletion
     const success = performCycleDeletion(iterationId, cycleId);

     if (!success) {
       // Restore from backup
       currentProjects = backup;
       saveProjects();
     }
   }
   ```

**Application to This Feature**:
- All cycle operations wrapped in try-catch blocks
- Backup created before cycle deletion
- Data version incremented to trigger migration
- Migration function `migrateIterationToCycles()` run on every load

---

### Inline Editing UI Patterns

**Research Topic**: Best practices for inline rename functionality

**Findings**:
1. **Edit Mode Toggle**:
   ```javascript
   function handleRenameCycle(cycleId) {
     const cycle = getCycleById(cycleId);
     const option = document.querySelector(`option[value="${cycleId}"]`);

     // Replace option with inline input
     const input = document.createElement('input');
     input.value = cycle.name;
     input.onblur = () => saveRename(cycleId, input.value);
     input.onkeydown = (e) => {
       if (e.key === 'Enter') input.blur();
       if (e.key === 'Escape') cancelRename(cycleId);
     };

     option.replaceWith(input);
     input.focus();
     input.select();
   }
   ```

2. **Validation on Save**:
   ```javascript
   function saveRename(cycleId, newName) {
     const trimmedName = newName.trim();

     if (!trimmedName) {
       alert('Cycle name cannot be empty');
       return;
     }

     const cycle = getCycleById(cycleId);
     cycle.name = trimmedName;
     saveProjects();
     renderCycleSelector(); // Re-render with updated name
   }
   ```

3. **Cancel Mechanism**:
   ```javascript
   function cancelRename(cycleId) {
     renderCycleSelector(); // Discard changes, re-render original
   }
   ```

**Application to This Feature**:
- Rename button triggers inline edit mode
- Enter key saves, Escape key cancels
- Validation enforced before persisting
- UI immediately reflects changes across all views

---

## Technology Stack Decisions

### Core Technologies

| Component | Technology | Justification |
|-----------|------------|---------------|
| **Language** | JavaScript (ES6+) | Already used in project, no new dependencies |
| **Storage** | LocalStorage API | Primary storage, meets offline-first requirement |
| **Sync** | Firebase Realtime Database (optional) | Existing integration, opt-in for users |
| **UI Framework** | Vanilla JavaScript | Consistent with single-file architecture |
| **Testing** | Manual testing via test-automation.html | Existing test infrastructure |

### No New Dependencies Required

- All functionality achievable with native browser APIs
- No npm packages needed
- No build process required
- Maintains <250KB file size constraint

---

## Risk Assessment

### Technical Risks

1. **Data Migration Risk** (Medium)
   - **Risk**: Migration logic could corrupt existing projects
   - **Mitigation**: Backup before migration, migration tested independently
   - **Fallback**: Keep backup in localStorage with 24-hour retention

2. **Performance Risk** (Low)
   - **Risk**: Nested data structure could slow down access
   - **Mitigation**: Direct object key lookup is O(1), pagination for large lists
   - **Monitoring**: Success Criteria SC-004 (<100ms UI update)

3. **UI Complexity Risk** (Low)
   - **Risk**: Cycle selector could become cluttered with many cycles
   - **Mitigation**: Pagination + search at >10 cycles threshold
   - **User Guidance**: Document best practices in quickstart.md

### Mitigation Strategies

- **Progressive Enhancement**: Basic implementation first, optimization layer added only when needed
- **Defensive Programming**: Validate all user inputs, handle edge cases explicitly
- **Comprehensive Testing**: 18 acceptance scenarios cover all user stories
- **Rollback Plan**: Backup mechanism allows reverting to pre-migration state

---

## Summary of Decisions

| Decision Area | Choice | Key Reason |
|--------------|--------|------------|
| Data Migration | Timestamped first cycle | Preserves all data, clear communication |
| UI Pattern | Dropdown selector | Matches existing patterns, space efficient |
| Storage Schema | Nested object with cycleId keys | Data isolation, efficient access |
| Deletion Safety | Confirmation + minimum cycle | Prevents accidents, maintains integrity |
| Performance | Lazy pagination at >10 cycles | Progressive enhancement, scalable |
| Testing | Manual via test-automation.html | Consistent with existing approach |

**All NEEDS CLARIFICATION items resolved. Ready for Phase 1: Design & Contracts.**
