# Data Model: Cycle Management for Project Iterations

**Feature**: 004-cycle-management
**Date**: 2025-10-16
**References**: [spec.md](./spec.md), [research.md](./research.md)

## Overview

This document defines the data model for the cycle management feature. The model extends the existing Iteration entity to support multiple review/revision cycles, with each cycle maintaining independent data for inputs, notes, and completion status.

## Core Entities

### Cycle Entity (NEW)

Represents a single review/revision round within an iteration.

**Schema**:
```javascript
{
  id: string,          // Unique identifier, format: 'cycle_<timestamp>'
  name: string,        // User-defined cycle name (required, non-empty)
  createdAt: string,   // ISO8601 timestamp (e.g., '2025-10-16T10:30:00.000Z')
  order: number        // Sequential order within iteration (1, 2, 3...)
}
```

**Field Specifications**:

| Field | Type | Required | Validation Rules | Example |
|-------|------|----------|------------------|---------|
| `id` | string | Yes | Format: `cycle_<timestamp>`, must be unique within iteration | `'cycle_1697845200000'` |
| `name` | string | Yes | Non-empty after trim, max 200 characters | `'Initial Review'` |
| `createdAt` | string | Yes | Valid ISO8601 datetime | `'2025-10-16T10:30:00.000Z'` |
| `order` | number | Yes | Positive integer, unique within iteration | `1` |

**Validation Rules**:
```javascript
function validateCycle(cycle) {
  const errors = [];

  // ID validation
  if (!cycle.id || !cycle.id.startsWith('cycle_')) {
    errors.push('Invalid cycle ID format');
  }

  // Name validation
  const trimmedName = (cycle.name || '').trim();
  if (!trimmedName) {
    errors.push('Cycle name cannot be empty');
  }
  if (trimmedName.length > 200) {
    errors.push('Cycle name cannot exceed 200 characters');
  }

  // CreatedAt validation
  if (!cycle.createdAt || isNaN(Date.parse(cycle.createdAt))) {
    errors.push('Invalid createdAt timestamp');
  }

  // Order validation
  if (!Number.isInteger(cycle.order) || cycle.order < 1) {
    errors.push('Cycle order must be a positive integer');
  }

  return {
    valid: errors.length === 0,
    errors
  };
}
```

**Lifecycle**:
1. **Creation**: Generated via `cycleManagementAdd()` with auto-generated ID and default/custom name
2. **Update**: Name can be modified via `cycleManagementRename()`
3. **Deletion**: Removed via `cycleManagementDelete()` (minimum 1 cycle enforced)

---

### Iteration Entity (UPDATED)

Existing entity extended to support cycle management.

**Updated Schema**:
```javascript
{
  id: string,                    // Unchanged
  name: string,                  // Unchanged
  description: string,           // Unchanged
  createdAt: string,             // Unchanged

  // NEW: Array of cycle metadata
  cycles: Cycle[],

  // UPDATED: References cycle ID from cycles array
  currentCycle: string,

  // UPDATED: Nested structure with cycle keys
  inputs: {
    [stepId: string]: {
      [cycleId: string]: string
    }
  },

  // UPDATED: Nested structure with cycle keys
  notes: {
    [stepId: string]: {
      [cycleId: string]: string
    }
  },

  // UPDATED: Nested structure with cycle keys
  completedSteps: {
    [stepId: string]: {
      [cycleId: string]: boolean
    }
  },

  // UPDATED: Nested structure with cycle keys
  cycleHistory: {
    [stepId: string]: {
      [cycleId: string]: string  // ISO8601 timestamp
    }
  }
}
```

**Field Changes**:

| Field | Change Type | Old Structure | New Structure |
|-------|-------------|---------------|---------------|
| `cycles` | NEW | N/A | `Cycle[]` - Array of cycle metadata |
| `currentCycle` | UPDATED | `string` (cycle color) | `string` (cycle ID from cycles array) |
| `inputs` | UPDATED | `{stepId: value}` | `{stepId: {cycleId: value}}` |
| `notes` | UPDATED | `{stepId: value}` | `{stepId: {cycleId: value}}` |
| `completedSteps` | UPDATED | `{stepId: boolean}` | `{stepId: {cycleId: boolean}}` |
| `cycleHistory` | UPDATED | `{stepId: timestamp}` | `{stepId: {cycleId: timestamp}}` |

**Complete Example**:
```javascript
{
  "id": "iteration_1697845000000",
  "name": "Feature Implementation",
  "description": "Implement user authentication system",
  "createdAt": "2025-10-16T10:00:00.000Z",

  "cycles": [
    {
      "id": "cycle_1697845100000",
      "name": "Initial Cycle - Migrated 2025-10-16",
      "createdAt": "2025-10-16T10:00:00.000Z",
      "order": 1
    },
    {
      "id": "cycle_1697846200000",
      "name": "Client Review Round",
      "createdAt": "2025-10-16T11:30:00.000Z",
      "order": 2
    },
    {
      "id": "cycle_1697847300000",
      "name": "Final Revision",
      "createdAt": "2025-10-16T13:00:00.000Z",
      "order": 3
    }
  ],

  "currentCycle": "cycle_1697846200000",

  "inputs": {
    "step_specify": {
      "cycle_1697845100000": "Initial specification text",
      "cycle_1697846200000": "Revised spec based on client feedback",
      "cycle_1697847300000": "Final specification"
    },
    "step_plan": {
      "cycle_1697845100000": "Initial implementation plan",
      "cycle_1697846200000": "Updated plan with security considerations",
      "cycle_1697847300000": ""
    }
  },

  "notes": {
    "step_specify": {
      "cycle_1697845100000": "Client requested OAuth support",
      "cycle_1697846200000": "Added multi-factor authentication requirement",
      "cycle_1697847300000": "Approved by security team"
    }
  },

  "completedSteps": {
    "step_specify": {
      "cycle_1697845100000": true,
      "cycle_1697846200000": true,
      "cycle_1697847300000": true
    },
    "step_plan": {
      "cycle_1697845100000": true,
      "cycle_1697846200000": true,
      "cycle_1697847300000": false
    },
    "step_tasks": {
      "cycle_1697845100000": true,
      "cycle_1697846200000": false,
      "cycle_1697847300000": false
    }
  },

  "cycleHistory": {
    "step_specify": {
      "cycle_1697845100000": "2025-10-16T10:30:00.000Z",
      "cycle_1697846200000": "2025-10-16T12:00:00.000Z",
      "cycle_1697847300000": "2025-10-16T13:15:00.000Z"
    },
    "step_plan": {
      "cycle_1697845100000": "2025-10-16T11:00:00.000Z",
      "cycle_1697846200000": "2025-10-16T12:30:00.000Z"
    }
  }
}
```

---

## Data Relationships

### Hierarchy

```
Project
  └── Iteration[]
        ├── cycles[]          ← NEW: Array of Cycle metadata
        ├── currentCycle      ← UPDATED: References cycle.id
        ├── inputs            ← UPDATED: Nested by cycleId
        ├── notes             ← UPDATED: Nested by cycleId
        ├── completedSteps    ← UPDATED: Nested by cycleId
        └── cycleHistory      ← UPDATED: Nested by cycleId
```

### Referential Integrity

**Rules**:
1. `iteration.currentCycle` MUST reference a valid `cycle.id` from `iteration.cycles[]`
2. Every key in `iteration.inputs[stepId]` MUST be a valid cycle ID from `iteration.cycles[]`
3. Every key in `iteration.notes[stepId]` MUST be a valid cycle ID from `iteration.cycles[]`
4. Every key in `iteration.completedSteps[stepId]` MUST be a valid cycle ID from `iteration.cycles[]`
5. Every key in `iteration.cycleHistory[stepId]` MUST be a valid cycle ID from `iteration.cycles[]`
6. Each `cycle.order` MUST be unique within the iteration

**Validation Function**:
```javascript
function validateIterationIntegrity(iteration) {
  const errors = [];

  // Extract valid cycle IDs
  const validCycleIds = new Set(iteration.cycles.map(c => c.id));

  // Check currentCycle reference
  if (!validCycleIds.has(iteration.currentCycle)) {
    errors.push(`currentCycle '${iteration.currentCycle}' not found in cycles array`);
  }

  // Check inputs references
  Object.entries(iteration.inputs || {}).forEach(([stepId, cycleData]) => {
    Object.keys(cycleData).forEach(cycleId => {
      if (!validCycleIds.has(cycleId)) {
        errors.push(`inputs[${stepId}] references invalid cycleId '${cycleId}'`);
      }
    });
  });

  // Check notes references
  Object.entries(iteration.notes || {}).forEach(([stepId, cycleData]) => {
    Object.keys(cycleData).forEach(cycleId => {
      if (!validCycleIds.has(cycleId)) {
        errors.push(`notes[${stepId}] references invalid cycleId '${cycleId}'`);
      }
    });
  });

  // Check completedSteps references
  Object.entries(iteration.completedSteps || {}).forEach(([stepId, cycleData]) => {
    Object.keys(cycleData).forEach(cycleId => {
      if (!validCycleIds.has(cycleId)) {
        errors.push(`completedSteps[${stepId}] references invalid cycleId '${cycleId}'`);
      }
    });
  });

  // Check cycleHistory references
  Object.entries(iteration.cycleHistory || {}).forEach(([stepId, cycleData]) => {
    Object.keys(cycleData).forEach(cycleId => {
      if (!validCycleIds.has(cycleId)) {
        errors.push(`cycleHistory[${stepId}] references invalid cycleId '${cycleId}'`);
      }
    });
  });

  // Check cycle order uniqueness
  const orders = iteration.cycles.map(c => c.order);
  const uniqueOrders = new Set(orders);
  if (orders.length !== uniqueOrders.size) {
    errors.push('Duplicate cycle orders detected');
  }

  return {
    valid: errors.length === 0,
    errors
  };
}
```

---

## State Transitions

### Cycle Lifecycle States

Cycles don't have explicit states, but their relationship to `currentCycle` defines implicit states:

```
┌─────────────┐
│   Created   │  ← New cycle added
└──────┬──────┘
       │
       ↓
┌─────────────┐
│   Active    │  ← currentCycle points to this cycle
└──────┬──────┘
       │
       ↓
┌─────────────┐
│  Inactive   │  ← User switched to different cycle
└──────┬──────┘
       │
       ↓
┌─────────────┐
│   Deleted   │  ← Cycle removed (minimum 1 enforced)
└─────────────┘
```

**State Transitions**:

1. **Add Cycle**:
   ```
   Transition: N/A → Active
   Trigger: User clicks "Add Cycle"
   Effect: New cycle created and immediately becomes currentCycle
   ```

2. **Switch Cycle**:
   ```
   Transition: Active → Inactive (for old cycle), Inactive → Active (for new cycle)
   Trigger: User selects different cycle from dropdown
   Effect: currentCycle updated, UI re-renders with new cycle's data
   ```

3. **Delete Cycle**:
   ```
   Transition: Active/Inactive → Deleted
   Trigger: User clicks delete and confirms
   Effect: Cycle removed from cycles array, all cycle-specific data purged
   Special: If deleting active cycle, auto-switch to adjacent cycle
   ```

4. **Rename Cycle**:
   ```
   State: Unchanged (Active or Inactive)
   Trigger: User edits cycle name inline
   Effect: cycle.name updated, no state transition
   ```

---

## Migration Strategy

### V1 to V2 Migration

**Problem**: Existing iterations use flat data structure without cycles array.

**Solution**: Transform flat structure to cycle-keyed structure during data load.

**Migration Function**:
```javascript
function migrateIterationToCycles(iteration) {
  // Skip if already migrated
  if (iteration.cycles && iteration.cycles.length > 0) {
    return iteration;
  }

  // Create timestamped first cycle
  const migrationDate = new Date().toISOString().split('T')[0];
  const firstCycle = {
    id: `cycle_${Date.now()}`,
    name: `Initial Cycle - Migrated ${migrationDate}`,
    createdAt: iteration.createdAt || new Date().toISOString(),
    order: 1
  };

  // Initialize cycles array
  iteration.cycles = [firstCycle];
  iteration.currentCycle = firstCycle.id;

  // Transform flat inputs to nested structure
  if (iteration.inputs && typeof iteration.inputs === 'object') {
    const oldInputs = { ...iteration.inputs };
    iteration.inputs = {};

    Object.entries(oldInputs).forEach(([stepId, value]) => {
      iteration.inputs[stepId] = {
        [firstCycle.id]: value
      };
    });
  } else {
    iteration.inputs = {};
  }

  // Transform flat notes to nested structure
  if (iteration.notes && typeof iteration.notes === 'object') {
    const oldNotes = { ...iteration.notes };
    iteration.notes = {};

    Object.entries(oldNotes).forEach(([stepId, value]) => {
      iteration.notes[stepId] = {
        [firstCycle.id]: value
      };
    });
  } else {
    iteration.notes = {};
  }

  // Transform flat completedSteps to nested structure
  if (iteration.completedSteps && typeof iteration.completedSteps === 'object') {
    const oldCompleted = { ...iteration.completedSteps };
    iteration.completedSteps = {};

    Object.entries(oldCompleted).forEach(([stepId, completed]) => {
      iteration.completedSteps[stepId] = {
        [firstCycle.id]: completed
      };
    });
  } else {
    iteration.completedSteps = {};
  }

  // Transform flat cycleHistory to nested structure
  if (iteration.cycleHistory && typeof iteration.cycleHistory === 'object') {
    const oldHistory = { ...iteration.cycleHistory };
    iteration.cycleHistory = {};

    Object.entries(oldHistory).forEach(([stepId, timestamp]) => {
      iteration.cycleHistory[stepId] = {
        [firstCycle.id]: timestamp
      };
    });
  } else {
    iteration.cycleHistory = {};
  }

  return iteration;
}
```

**Migration Timing**: Executed during `loadProjects()` on every page load until all data is migrated.

**Rollback**: Backup created before migration, retained for 24 hours in `localStorage` under key `spec_kit_backup`.

---

## Access Patterns

### Common Queries

**1. Get current cycle data for a step**:
```javascript
function getCurrentCycleInput(iteration, stepId) {
  return iteration.inputs[stepId]?.[iteration.currentCycle] || '';
}

function getCurrentCycleNote(iteration, stepId) {
  return iteration.notes[stepId]?.[iteration.currentCycle] || '';
}

function isStepCompletedInCurrentCycle(iteration, stepId) {
  return iteration.completedSteps[stepId]?.[iteration.currentCycle] || false;
}
```

**2. Get all cycles where a step is completed**:
```javascript
function getCompletedCyclesForStep(iteration, stepId) {
  const cycleData = iteration.completedSteps[stepId] || {};

  return Object.entries(cycleData)
    .filter(([cycleId, completed]) => completed)
    .map(([cycleId]) => iteration.cycles.find(c => c.id === cycleId))
    .filter(cycle => cycle !== undefined);
}
```

**3. Get cycle by ID**:
```javascript
function getCycleById(iteration, cycleId) {
  return iteration.cycles.find(c => c.id === cycleId);
}
```

**4. Get adjacent cycle (for auto-switch after deletion)**:
```javascript
function getAdjacentCycle(iteration, deletedCycleId) {
  const sortedCycles = [...iteration.cycles].sort((a, b) => a.order - b.order);
  const deletedIndex = sortedCycles.findIndex(c => c.id === deletedCycleId);

  // Prefer previous cycle
  if (deletedIndex > 0) {
    return sortedCycles[deletedIndex - 1];
  }

  // Fallback to next cycle (if first was deleted)
  return sortedCycles[deletedIndex + 1] || sortedCycles[0];
}
```

**5. Count completed steps in cycle**:
```javascript
function countCompletedStepsInCycle(iteration, cycleId) {
  const stepIds = Object.keys(iteration.completedSteps);

  return stepIds.filter(stepId => {
    return iteration.completedSteps[stepId]?.[cycleId] === true;
  }).length;
}
```

---

## Storage Considerations

### LocalStorage Size Estimation

**Single Cycle**:
- Metadata: ~150 bytes (id, name, createdAt, order)
- Per-step data (5 steps): ~500 bytes (inputs + notes + completedSteps + cycleHistory)
- Total per cycle: ~650 bytes

**Typical Iteration** (5 cycles):
- Cycle metadata: 5 × 150 = 750 bytes
- Step data: 5 cycles × 5 steps × 100 bytes = 2,500 bytes
- Total: ~3.25 KB per iteration

**Scalability**:
- LocalStorage limit: 5-10 MB (browser-dependent)
- 10 projects × 10 iterations × 5 cycles = ~325 KB
- Well within browser limits

### Data Cleanup

**Orphaned Data Removal**:
When a cycle is deleted, all associated data must be purged:

```javascript
function removeAllCycleData(iteration, cycleId) {
  // Remove cycle metadata
  iteration.cycles = iteration.cycles.filter(c => c.id !== cycleId);

  // Remove cycle-specific inputs
  Object.keys(iteration.inputs).forEach(stepId => {
    delete iteration.inputs[stepId][cycleId];
  });

  // Remove cycle-specific notes
  Object.keys(iteration.notes).forEach(stepId => {
    delete iteration.notes[stepId][cycleId];
  });

  // Remove cycle-specific completion status
  Object.keys(iteration.completedSteps).forEach(stepId => {
    delete iteration.completedSteps[stepId][cycleId];
  });

  // Remove cycle-specific history
  Object.keys(iteration.cycleHistory).forEach(stepId => {
    delete iteration.cycleHistory[stepId][cycleId];
  });
}
```

---

## Performance Considerations

### Access Complexity

| Operation | Complexity | Notes |
|-----------|------------|-------|
| Get current cycle data | O(1) | Direct object key lookup |
| Add new cycle | O(1) | Append to cycles array |
| Delete cycle | O(n) | Filter cycles array, delete keys from nested objects |
| Rename cycle | O(1) | Update single field |
| Switch cycle | O(1) | Update currentCycle reference |
| Find cycle by ID | O(n) | Linear search in cycles array (typically <20 cycles) |
| Count completed steps | O(s) | Iterate over steps (typically 5-8 steps) |

**Optimization Notes**:
- No nested loops in critical paths
- All data access uses direct object key lookup (O(1))
- Cycles array typically contains 3-5 elements (worst case: 20), linear operations are acceptable

---

## Testing Considerations

### Data Integrity Tests

**Test Cases**:
1. **Migration Test**: Load V1 iteration, verify transformation to V2 structure
2. **Referential Integrity Test**: Validate all cycleIds in nested data exist in cycles array
3. **Cycle Deletion Test**: Delete cycle, verify all associated data is removed
4. **Cycle Addition Test**: Add cycle, verify empty data structures initialized
5. **Cycle Switching Test**: Switch cycle, verify correct data loaded for new cycle

**Sample Test Data**:
```javascript
// V1 iteration (pre-migration)
const v1Iteration = {
  id: 'iter_123',
  name: 'Test Iteration',
  createdAt: '2025-10-16T10:00:00Z',
  inputs: { step1: 'value1' },
  notes: { step1: 'note1' },
  completedSteps: { step1: true },
  currentCycle: 'blue'  // Old color-based system
};

// Expected V2 iteration (post-migration)
const v2Iteration = {
  id: 'iter_123',
  name: 'Test Iteration',
  createdAt: '2025-10-16T10:00:00Z',
  cycles: [{
    id: 'cycle_1697845200000',
    name: 'Initial Cycle - Migrated 2025-10-16',
    createdAt: '2025-10-16T10:00:00Z',
    order: 1
  }],
  currentCycle: 'cycle_1697845200000',
  inputs: {
    step1: {
      cycle_1697845200000: 'value1'
    }
  },
  notes: {
    step1: {
      cycle_1697845200000: 'note1'
    }
  },
  completedSteps: {
    step1: {
      cycle_1697845200000: true
    }
  },
  cycleHistory: {}
};
```

---

## Summary

### Key Constraints

1. **Minimum Cycles**: Each iteration MUST have at least 1 cycle
2. **Unique IDs**: Cycle IDs MUST be unique within iteration
3. **Unique Orders**: Cycle orders MUST be unique within iteration
4. **Non-Empty Names**: Cycle names MUST NOT be empty after trim
5. **Referential Integrity**: All cycleIds in nested data MUST exist in cycles array

### Data Model Benefits

✅ **Data Isolation**: Each cycle has completely independent data
✅ **Backward Compatible**: V1 data automatically migrated to V2
✅ **Scalable**: Efficient O(1) access for common operations
✅ **Flexible**: Unlimited cycles per iteration (practical limit: 20)
✅ **Clean Deletion**: All cycle-specific data removed on delete
✅ **Audit Trail**: CreatedAt timestamps track cycle creation history

This data model supports all functional requirements (FR-001 to FR-015) defined in the feature specification.
