# API Contracts: Cycle Management

**Feature**: 004-cycle-management
**Date**: 2025-10-16
**Architecture**: Single-file client-side application (no REST API)

## Overview

This document defines the function interfaces (contracts) for cycle management operations. Since this is a single-file client-side application, there are no REST APIs. Instead, this document specifies the JavaScript function signatures that act as the internal API layer.

## Function Contracts by Layer

### Data Access Layer

#### `saveProjects()`

**Purpose**: Persist all projects to LocalStorage and optionally sync to Firebase

**Signature**:
```javascript
function saveProjects(): boolean
```

**Input**: None (operates on global `currentProjects` variable)

**Output**:
- `true` if save successful
- `false` if save failed (localStorage quota exceeded, etc.)

**Side Effects**:
- Updates `localStorage.setItem('spec_kit_data', ...)`
- Triggers Firebase sync if user is authenticated
- Creates backup before save in `localStorage.setItem('spec_kit_backup', ...)`

**Error Handling**:
```javascript
try {
  localStorage.setItem('spec_kit_data', JSON.stringify(data));
  return true;
} catch (error) {
  console.error('Save failed:', error);
  return false;
}
```

---

#### `loadProjects()`

**Purpose**: Load all projects from LocalStorage, apply migrations

**Signature**:
```javascript
function loadProjects(): Project[]
```

**Input**: None (reads from localStorage)

**Output**: Array of Project objects (empty array if no data)

**Side Effects**:
- Reads `localStorage.getItem('spec_kit_data')`
- Applies `migrateIterationToCycles()` to all iterations
- Updates `currentProjects` global variable

**Migration Logic**:
```javascript
function loadProjects() {
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
```

---

### Business Logic Layer - Cycle Management

#### `cycleManagementAdd()`

**Purpose**: Create a new cycle for an iteration

**Signature**:
```javascript
function cycleManagementAdd(iterationId: string, cycleName?: string): Cycle | null
```

**Input**:
- `iterationId` (required): ID of the iteration to add cycle to
- `cycleName` (optional): Custom name for new cycle. If omitted, generates default name "Cycle N"

**Output**:
- `Cycle` object if successful
- `null` if validation fails or iteration not found

**Validation**:
```javascript
const validation = validateCycleName(cycleName);
if (!validation.valid) {
  alert(validation.errors[0]);
  return null;
}
```

**Business Logic**:
1. Find iteration by ID
2. Generate unique cycle ID: `cycle_${Date.now()}`
3. Determine next order number: `max(existing orders) + 1`
4. Create cycle object with metadata
5. Append to `iteration.cycles` array
6. Set as `iteration.currentCycle`
7. Initialize empty data structures for all steps
8. Call `saveProjects()`
9. Return created cycle

**Example**:
```javascript
function cycleManagementAdd(iterationId, cycleName) {
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
  const stepIds = getStepIds(); // From workflow definition
  stepIds.forEach(stepId => {
    if (!iteration.inputs[stepId]) iteration.inputs[stepId] = {};
    if (!iteration.notes[stepId]) iteration.notes[stepId] = {};
    if (!iteration.completedSteps[stepId]) iteration.completedSteps[stepId] = {};
    if (!iteration.cycleHistory[stepId]) iteration.cycleHistory[stepId] = {};

    iteration.inputs[stepId][newCycle.id] = '';
    iteration.notes[stepId][newCycle.id] = '';
    iteration.completedSteps[stepId][newCycle.id] = false;
  });

  saveProjects();
  return newCycle;
}
```

---

#### `cycleManagementRename()`

**Purpose**: Update the name of an existing cycle

**Signature**:
```javascript
function cycleManagementRename(iterationId: string, cycleId: string, newName: string): boolean
```

**Input**:
- `iterationId` (required): ID of the iteration containing the cycle
- `cycleId` (required): ID of the cycle to rename
- `newName` (required): New name for the cycle

**Output**:
- `true` if rename successful
- `false` if validation fails or cycle not found

**Validation**:
```javascript
const validation = validateCycleName(newName);
if (!validation.valid) {
  alert(validation.errors[0]);
  return false;
}
```

**Business Logic**:
1. Find iteration by ID
2. Find cycle within iteration by cycle ID
3. Validate new name (non-empty, max length)
4. Update `cycle.name`
5. Call `saveProjects()`
6. Return success status

**Example**:
```javascript
function cycleManagementRename(iterationId, cycleId, newName) {
  const iteration = findIterationById(iterationId);
  if (!iteration) return false;

  const cycle = iteration.cycles.find(c => c.id === cycleId);
  if (!cycle) return false;

  const trimmedName = newName.trim();
  const validation = validateCycleName(trimmedName);
  if (!validation.valid) {
    alert(validation.errors[0]);
    return false;
  }

  cycle.name = trimmedName;
  saveProjects();
  return true;
}
```

---

#### `cycleManagementDelete()`

**Purpose**: Delete a cycle and all associated data

**Signature**:
```javascript
function cycleManagementDelete(iterationId: string, cycleId: string): boolean
```

**Input**:
- `iterationId` (required): ID of the iteration containing the cycle
- `cycleId` (required): ID of the cycle to delete

**Output**:
- `true` if deletion successful
- `false` if validation fails (minimum cycle enforcement) or cycle not found

**Validation**:
```javascript
if (iteration.cycles.length === 1) {
  alert('Cannot delete the last cycle. Each iteration must have at least one cycle.');
  return false;
}
```

**Business Logic**:
1. Find iteration by ID
2. Check minimum cycle constraint (must have >1 cycle)
3. Show confirmation dialog
4. If confirmed:
   - Remove cycle from `cycles` array
   - Remove all cycle-specific data (inputs, notes, completedSteps, cycleHistory)
   - If deleting current cycle, auto-switch to adjacent cycle
   - Call `saveProjects()`
5. Return success status

**Example**:
```javascript
function cycleManagementDelete(iterationId, cycleId) {
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
  const needsSwitch = (iteration.currentCycle === cycleId);
  if (needsSwitch) {
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

#### `cycleManagementSwitch()`

**Purpose**: Change the current active cycle

**Signature**:
```javascript
function cycleManagementSwitch(iterationId: string, cycleId: string): boolean
```

**Input**:
- `iterationId` (required): ID of the iteration
- `cycleId` (required): ID of the cycle to switch to

**Output**:
- `true` if switch successful
- `false` if cycle not found

**Business Logic**:
1. Find iteration by ID
2. Validate cycle exists in iteration
3. Update `iteration.currentCycle`
4. Call `saveProjects()`
5. Trigger UI re-render with new cycle's data
6. Return success status

**Example**:
```javascript
function cycleManagementSwitch(iterationId, cycleId) {
  const iteration = findIterationById(iterationId);
  if (!iteration) return false;

  const cycle = iteration.cycles.find(c => c.id === cycleId);
  if (!cycle) return false;

  iteration.currentCycle = cycleId;
  saveProjects();

  // Re-render workflow with new cycle data
  renderIterationWorkflow(iterationId);

  return true;
}
```

---

### Business Logic Layer - Validation

#### `validateCycleName()`

**Purpose**: Validate cycle name input

**Signature**:
```javascript
function validateCycleName(name: string): ValidationResult
```

**Input**:
- `name` (required): Cycle name to validate

**Output**:
```javascript
{
  valid: boolean,
  errors: string[]
}
```

**Validation Rules**:
1. Cannot be empty after trim
2. Cannot exceed 200 characters
3. Cannot be only whitespace

**Example**:
```javascript
function validateCycleName(name) {
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
```

---

### Presentation Layer

#### `renderCycleSelector()`

**Purpose**: Render cycle dropdown and action buttons

**Signature**:
```javascript
function renderCycleSelector(iterationId: string): string
```

**Input**:
- `iterationId` (required): ID of the iteration to render cycles for

**Output**: HTML string for cycle selector UI

**Dependencies**:
- Reads current project data via `findIterationById()`
- Does NOT call localStorage or Firebase directly

**Example**:
```javascript
function renderCycleSelector(iterationId) {
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
```

---

#### `renderIterationWorkflow()`

**Purpose**: Render iteration workflow with current cycle data

**Signature**:
```javascript
function renderIterationWorkflow(iterationId: string): void
```

**Input**:
- `iterationId` (required): ID of the iteration to render

**Output**: None (side effect: updates DOM)

**Dependencies**:
- Calls `renderCycleSelector()` for cycle UI
- Reads cycle-specific data for inputs, notes, completion status
- Does NOT call localStorage directly

**Business Logic**:
1. Find iteration by ID
2. Get current cycle ID
3. Render cycle selector at top
4. Render each workflow step with current cycle's data
5. Update DOM via `document.getElementById('mainContent').innerHTML = ...`

**Example**:
```javascript
function renderIterationWorkflow(iterationId) {
  const iteration = findIterationById(iterationId);
  if (!iteration) return;

  const currentCycleId = iteration.currentCycle;

  const html = `
    <div class="iteration-workflow">
      <h2>${escapeHtml(iteration.name)}</h2>

      ${renderCycleSelector(iterationId)}

      <div class="workflow-steps">
        ${getStepIds().map(stepId => `
          <div class="workflow-step">
            <h3>${getStepName(stepId)}</h3>
            <textarea id="input-${stepId}" placeholder="Enter input">
${iteration.inputs[stepId]?.[currentCycleId] || ''}
            </textarea>
            <textarea id="notes-${stepId}" placeholder="Notes">
${iteration.notes[stepId]?.[currentCycleId] || ''}
            </textarea>
            <label>
              <input type="checkbox" id="completed-${stepId}"
                ${iteration.completedSteps[stepId]?.[currentCycleId] ? 'checked' : ''}
                onchange="handleStepCompletion('${iterationId}', '${stepId}', this.checked)">
              Mark as completed
            </label>
          </div>
        `).join('')}
      </div>
    </div>
  `;

  document.getElementById('mainContent').innerHTML = html;
}
```

---

### Event Handler Layer (Bridge)

#### `handleAddCycle()`

**Purpose**: Handle user click on "Add Cycle" button

**Signature**:
```javascript
function handleAddCycle(iterationId: string): void
```

**Input**:
- `iterationId` (required): ID of iteration to add cycle to

**Output**: None (side effects: creates cycle, re-renders UI)

**Orchestration**:
```
User Click → Prompt for name → Validate → Create cycle → Save → Re-render
```

**Example**:
```javascript
function handleAddCycle(iterationId) {
  const cycleName = prompt('Enter cycle name (leave empty for default):');

  // User cancelled
  if (cycleName === null) return;

  const newCycle = cycleManagementAdd(iterationId, cycleName);

  if (newCycle) {
    renderIterationWorkflow(iterationId);
  }
}
```

---

#### `handleRenameCycle()`

**Purpose**: Handle user click on "Rename" button

**Signature**:
```javascript
function handleRenameCycle(iterationId: string, cycleId: string): void
```

**Input**:
- `iterationId` (required): ID of iteration
- `cycleId` (required): ID of cycle to rename

**Output**: None (side effects: renames cycle, re-renders UI)

**Orchestration**:
```
User Click → Get current name → Prompt for new name → Validate → Rename → Save → Re-render
```

**Example**:
```javascript
function handleRenameCycle(iterationId, cycleId) {
  const iteration = findIterationById(iterationId);
  if (!iteration) return;

  const cycle = iteration.cycles.find(c => c.id === cycleId);
  if (!cycle) return;

  const newName = prompt('Enter new cycle name:', cycle.name);

  // User cancelled
  if (newName === null) return;

  const success = cycleManagementRename(iterationId, cycleId, newName);

  if (success) {
    renderIterationWorkflow(iterationId);
  }
}
```

---

#### `handleDeleteCycle()`

**Purpose**: Handle user click on "Delete" button

**Signature**:
```javascript
function handleDeleteCycle(iterationId: string, cycleId: string): void
```

**Input**:
- `iterationId` (required): ID of iteration
- `cycleId` (required): ID of cycle to delete

**Output**: None (side effects: deletes cycle, re-renders UI)

**Orchestration**:
```
User Click → Validate (min cycle) → Confirm → Delete → Auto-switch → Save → Re-render
```

**Example**:
```javascript
function handleDeleteCycle(iterationId, cycleId) {
  const success = cycleManagementDelete(iterationId, cycleId);

  if (success) {
    renderIterationWorkflow(iterationId);
  }
}
```

---

#### `handleCycleSwitch()`

**Purpose**: Handle user selection change in cycle dropdown

**Signature**:
```javascript
function handleCycleSwitch(iterationId: string, cycleId: string): void
```

**Input**:
- `iterationId` (required): ID of iteration
- `cycleId` (required): ID of cycle to switch to

**Output**: None (side effects: switches cycle, re-renders UI)

**Orchestration**:
```
User Select → Switch current cycle → Save → Re-render with new cycle data
```

**Example**:
```javascript
function handleCycleSwitch(iterationId, cycleId) {
  const success = cycleManagementSwitch(iterationId, cycleId);

  if (success) {
    renderIterationWorkflow(iterationId);
  }
}
```

---

## Utility Functions

#### `findIterationById()`

**Signature**:
```javascript
function findIterationById(iterationId: string): Iteration | null
```

**Purpose**: Locate iteration across all projects

---

#### `getAdjacentCycle()`

**Signature**:
```javascript
function getAdjacentCycle(iteration: Iteration, deletedCycleId: string): Cycle
```

**Purpose**: Find previous or next cycle for auto-switch after deletion

---

#### `removeAllCycleData()`

**Signature**:
```javascript
function removeAllCycleData(iteration: Iteration, cycleId: string): void
```

**Purpose**: Purge all data associated with a cycle (inputs, notes, completedSteps, cycleHistory)

---

#### `truncateCycleName()`

**Signature**:
```javascript
function truncateCycleName(name: string, maxLength: number): string
```

**Purpose**: Truncate long cycle names with ellipsis for display

**Example**:
```javascript
function truncateCycleName(name, maxLength) {
  if (name.length <= maxLength) return name;
  return name.substring(0, maxLength - 3) + '...';
}
```

---

#### `escapeHtml()`

**Signature**:
```javascript
function escapeHtml(text: string): string
```

**Purpose**: Prevent XSS attacks by escaping HTML entities

**Example**:
```javascript
function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}
```

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        User Actions                          │
└───────────┬─────────────────────────────────────────────────┘
            │
            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Event Handler Layer                       │
│  handleAddCycle() | handleRenameCycle() | handleDeleteCycle()│
│  handleCycleSwitch()                                         │
└───────────┬─────────────────────────────────────────────────┘
            │
            ↓
┌─────────────────────────────────────────────────────────────┐
│                   Business Logic Layer                       │
│  cycleManagementAdd() | cycleManagementRename()              │
│  cycleManagementDelete() | cycleManagementSwitch()           │
│  validateCycleName()                                         │
└───────────┬─────────────────────────────────────────────────┘
            │
            ↓
┌─────────────────────────────────────────────────────────────┐
│                   Data Access Layer                          │
│  saveProjects() | loadProjects()                             │
│  localStorage | Firebase Sync                                │
└───────────┬─────────────────────────────────────────────────┘
            │
            ↓
┌─────────────────────────────────────────────────────────────┐
│                  Presentation Layer                          │
│  renderIterationWorkflow() | renderCycleSelector()           │
│  DOM Update                                                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Error Handling Patterns

### Validation Errors

**Pattern**: Return validation result object, display error to user

```javascript
function handleAddCycle(iterationId) {
  const cycleName = prompt('Enter cycle name:');
  if (cycleName === null) return;

  const validation = validateCycleName(cycleName);
  if (!validation.valid) {
    alert(validation.errors.join('\n'));
    return;
  }

  cycleManagementAdd(iterationId, cycleName);
}
```

### Storage Errors

**Pattern**: Try-catch with user notification

```javascript
function saveProjects() {
  try {
    localStorage.setItem('spec_kit_data', JSON.stringify(data));
    return true;
  } catch (error) {
    alert('Failed to save projects. Your storage may be full.');
    console.error('Save error:', error);
    return false;
  }
}
```

### Missing Data Errors

**Pattern**: Defensive checks with null returns

```javascript
function cycleManagementRename(iterationId, cycleId, newName) {
  const iteration = findIterationById(iterationId);
  if (!iteration) {
    console.error(`Iteration ${iterationId} not found`);
    return false;
  }

  const cycle = iteration.cycles.find(c => c.id === cycleId);
  if (!cycle) {
    console.error(`Cycle ${cycleId} not found in iteration ${iterationId}`);
    return false;
  }

  // Proceed with rename
}
```

---

## Testing Contracts

### Unit Test Interface

Each function should be testable via:

```javascript
// Test cycleManagementAdd
const result = cycleManagementAdd('iter_123', 'Test Cycle');
assert(result !== null, 'Should create cycle');
assert(result.name === 'Test Cycle', 'Should use provided name');

// Test validation
const validation = validateCycleName('');
assert(validation.valid === false, 'Should reject empty name');
assert(validation.errors.length > 0, 'Should return error message');

// Test rendering
const html = renderCycleSelector('iter_123');
assert(html.includes('<select'), 'Should render dropdown');
assert(html.includes('option'), 'Should render cycle options');
```

---

## Summary

This contract specification defines:
- ✅ 15 function signatures across 4 layers
- ✅ Input/output types for all functions
- ✅ Validation rules for all user inputs
- ✅ Error handling patterns
- ✅ Data flow between layers
- ✅ Testing interfaces

All functions follow constitution principles:
- Data/business/presentation layers strictly separated
- Functions named by layer convention (save*/validate*/render*/handle*)
- No circular dependencies
- Clear input/output contracts
