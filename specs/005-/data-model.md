# Data Model: Cloud-First Synchronization

**Feature**: 005-cloud-first-sync
**Date**: 2025-10-16
**Purpose**: Define data structures for timestamp-based conflict resolution

## Core Entities

### Project (Updated Schema)

**Changes**: Add `lastModified` server timestamp field

```javascript
{
    id: string,                  // 'project_' + timestamp (existing)
    name: string,                // Project name (existing)
    description: string,         // Project description (existing)
    createdAt: string,           // ISO8601 timestamp (existing)
    updatedAt: number,           // Milliseconds since epoch (existing, client-side)
    lastModified: number,        // NEW: Server timestamp (ms since epoch) - source of truth
    iterations: Iteration[],     // Array of iterations (existing)

    // Migration metadata (temporary)
    needsTimestampUpdate: boolean  // NEW: Flag for migration, deleted after first save
}
```

**Field Descriptions**:

- `lastModified` (NEW):
  - **Type**: Number (milliseconds since Unix epoch)
  - **Source**: Firebase `ServerValue.TIMESTAMP` (server-generated)
  - **Purpose**: Conflict resolution authority - determines which version is newer
  - **Null handling**: Missing/null treated as `0` (epoch, oldest possible)
  - **Comparison**: `cloudProject.lastModified >= localProject.lastModified` → use cloud
  - **Set on**: Every `saveProjectToFirebase()` call

- `updatedAt` (EXISTING):
  - **Deprecated**: Will be replaced by `lastModified` over time
  - **Current use**: Client-side timestamp, unreliable due to clock skew
  - **Migration**: Keep for backward compatibility, but ignore in comparisons

- `needsTimestampUpdate` (NEW, temporary):
  - **Type**: Boolean (optional)
  - **Purpose**: Flag old projects that need server timestamp on next save
  - **Lifecycle**: Set during `migrateProjectSchema()`, deleted in `saveProjects()`
  - **Example**: Migrated project from V1 schema gets this flag, next save adds `lastModified`

---

### SyncMetadata (NEW Entity)

**Purpose**: Track synchronization state per project

```javascript
{
    projectId: string,           // Reference to project.id
    cloudTimestamp: number,      // lastModified from Firebase (ms since epoch)
    localTimestamp: number,      // lastModified from localStorage (ms since epoch)
    syncStatus: string,          // 'synced' | 'pending' | 'conflict' | 'offline'
    lastSyncAt: number,          // When last sync attempt occurred (Date.now())
    conflictCount: number,       // Number of conflicts encountered (for debugging)

    // Offline queue metadata
    hasQueuedChanges: boolean,   // True if changes are in offline queue
    queuedOperations: number     // Count of pending operations for this project
}
```

**States**:

- `synced`: Cloud and local timestamps match, no pending changes
- `pending`: Local changes made but not yet pushed to cloud
- `conflict`: Cloud timestamp > local timestamp (cloud wins, discard local)
- `offline`: Cannot reach Firebase, changes queued

**Usage**:
- Not persisted long-term (computed on-the-fly during `loadProjects()`)
- Used for debugging and sync status UI
- Stored in memory during session: `const syncMetadata = new Map<projectId, SyncMetadata>()`

---

### OfflineQueueItem (EXISTING, Updated)

**Changes**: Add timestamp for staleness detection

```javascript
{
    operation: string,           // 'create' | 'update' | 'delete' (existing)
    path: string,                // Firebase path, e.g., 'users/uid/projects/proj_123' (existing)
    data: any,                   // Payload for create/update (existing)
    timestamp: number,           // NEW: When operation was queued (Date.now())
    retryCount: number,          // NEW: Number of retry attempts (for exponential backoff)
    projectId: string            // NEW: Extracted from path for quick lookup
}
```

**New Fields**:

- `timestamp`:
  - **Set on**: Queue creation (`queueOfflineOperation()`)
  - **Purpose**: Compare with cloud `lastModified` to detect stale operations
  - **Example**: If queue timestamp is 10:00 AM but cloud `lastModified` is 10:05 AM, discard queue item

- `retryCount`:
  - **Increments**: Each failed retry attempt
  - **Max retries**: 5 (then move to dead-letter queue or discard)
  - **Backoff**: Exponential (1s, 2s, 4s, 8s, 16s)

- `projectId`:
  - **Extracted from**: `path` field (e.g., `users/uid/projects/proj_123` → `proj_123`)
  - **Purpose**: Quick filtering of queue items during timestamp comparison

---

## Data Relationships

### Project ↔ Firebase

**Storage Locations**:

1. **Firebase Realtime Database**:
   - Path: `users/{userId}/projects/{projectId}`
   - Authority: Source of truth for conflict resolution
   - Timestamp: Server-generated `lastModified`

2. **LocalStorage**:
   - Key: `speckit_projects`
   - Value: JSON array of projects
   - Purpose: Offline cache, fast reads
   - Timestamp: `lastModified` copied from last successful Firebase sync

**Sync Flow**:

```
┌─────────────────┐
│ User Action     │
│ (edit/delete)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ saveProjects()  │
│ 1. localStorage │ ← Instant update (synchronous)
│ 2. Firebase     │ ← Async with ServerValue.TIMESTAMP
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Firebase writes │
│ lastModified    │ ← Server sets timestamp
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Next load       │
│ loadProjects()  │
│ Compare times   │ ← cloudTime >= localTime → use cloud
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Update local    │
│ cache with      │
│ cloud data      │
└─────────────────┘
```

---

### OfflineQueue ↔ Projects

**Relationship**: Many-to-one (many queue items can reference one project)

**Clearing Logic**:

```javascript
function processOfflineQueue() {
    const queue = getOfflineQueue();
    const validQueue = [];

    for (const item of queue) {
        const project = projects.find(p => p.id === item.projectId);

        if (!project) {
            // Project deleted, discard queue item
            continue;
        }

        if (project.lastModified > item.timestamp) {
            // Cloud has newer data, discard stale operation
            console.log(`⏭️ Discarding stale operation for ${item.projectId}`);
            continue;
        }

        // Valid operation, keep for retry
        validQueue.push(item);
    }

    setOfflineQueue(validQueue);
}
```

---

## Validation Rules

### Timestamp Validation

```javascript
function validateTimestamp(timestamp) {
    // Rule 1: Must be a number
    if (typeof timestamp !== 'number') {
        return { valid: false, error: 'Timestamp must be a number' };
    }

    // Rule 2: Must be positive
    if (timestamp < 0) {
        return { valid: false, error: 'Timestamp cannot be negative' };
    }

    // Rule 3: Must not be in the future (allow 5-minute clock skew tolerance)
    const now = Date.now();
    const maxAllowed = now + (5 * 60 * 1000); // 5 minutes ahead
    if (timestamp > maxAllowed) {
        return { valid: false, error: 'Timestamp is too far in the future' };
    }

    // Rule 4: Must be after year 2020 (sanity check for epoch 0 bugs)
    const year2020 = new Date('2020-01-01').getTime();
    if (timestamp > 0 && timestamp < year2020) {
        console.warn(`⚠️ Suspicious timestamp: ${new Date(timestamp).toISOString()}`);
        // Don't fail - might be valid old data
    }

    return { valid: true };
}
```

### Project Validation (Updated)

```javascript
function validateProject(project) {
    const errors = [];

    // Existing validations...
    if (!project.id) errors.push('Missing id');
    if (!project.name) errors.push('Missing name');

    // NEW: Validate lastModified
    if (project.lastModified !== undefined) {
        const timestampCheck = validateTimestamp(project.lastModified);
        if (!timestampCheck.valid) {
            errors.push(`Invalid lastModified: ${timestampCheck.error}`);
        }
    }

    // NEW: Warn if both updatedAt and lastModified exist but differ significantly
    if (project.updatedAt && project.lastModified) {
        const diff = Math.abs(project.updatedAt - project.lastModified);
        if (diff > 60000) { // More than 1 minute difference
            console.warn(`⚠️ Project ${project.id} has inconsistent timestamps (diff: ${diff}ms)`);
        }
    }

    return { valid: errors.length === 0, errors };
}
```

---

## State Transitions

### Sync Status State Machine

```
                  ┌─────────┐
      ┌───────────│ synced  │◄──────────┐
      │           └─────────┘           │
      │                 │                │
      │ User edit       │ Network lost   │ Sync succeeds
      │                 │                │
      ▼                 ▼                │
┌─────────┐       ┌─────────┐     ┌─────────┐
│ pending │──────►│ offline │────►│ syncing │
└─────────┘       └─────────┘     └─────────┘
      │                 │                │
      │ Cloud newer     │ Retry failed   │ Cloud has newer
      │                 │                │
      ▼                 ▼                ▼
┌──────────┐      ┌──────────┐    ┌──────────┐
│ conflict │      │ offline  │    │ conflict │
└──────────┘      └──────────┘    └──────────┘
      │                                  │
      │ Discard local                    │ Discard local
      │                                  │
      └──────────────────────────────────┘
                       │
                       ▼
                 ┌─────────┐
                 │ synced  │
                 └─────────┘
```

**State Descriptions**:

- **synced**: Local and cloud timestamps match, no pending operations
- **pending**: Local changes made, waiting to push to cloud
- **offline**: Network unavailable, changes queued
- **syncing**: Actively pushing to Firebase
- **conflict**: Cloud has newer data, local changes discarded

---

## Migration Schema

### V1 → V2 Migration

**Detect**: Project missing `lastModified` field

**Transform**:

```javascript
function migrateProjectSchema(project) {
    // Existing migrations...
    if (!project.description) project.description = '';
    if (!project.updatedAt) project.updatedAt = Date.parse(project.createdAt);

    // NEW: Add lastModified if missing
    if (project.lastModified === undefined || project.lastModified === null) {
        project.lastModified = 0; // Epoch 0 = oldest possible
        project.needsTimestampUpdate = true; // Flag for next save
    }

    return project;
}
```

**On Next Save**:

```javascript
async function saveProjectToFirebase(userId, projectId, project) {
    const dataToSave = { ...project };

    // If migration flag is set, use server timestamp
    if (dataToSave.needsTimestampUpdate) {
        dataToSave.lastModified = firebase.database.ServerValue.TIMESTAMP;
        delete dataToSave.needsTimestampUpdate; // Clean up flag
    } else {
        // Normal save also updates timestamp
        dataToSave.lastModified = firebase.database.ServerValue.TIMESTAMP;
    }

    await firebase.database().ref(`users/${userId}/projects/${projectId}`).set(dataToSave);
}
```

---

## Indexing Strategy

### Firebase Indexes

**Not needed** - current queries are simple key-value lookups:

```javascript
// Query: Get all projects for a user
ref(`users/${userId}/projects`).get()

// Query: Get single project
ref(`users/${userId}/projects/${projectId}`).get()
```

**Future optimization** (if needed for >1000 projects per user):

```json
{
  "rules": {
    "users": {
      "$userId": {
        "projects": {
          ".indexOn": ["lastModified"]
        }
      }
    }
  }
}
```

This would enable efficient queries like:
```javascript
ref(`users/${userId}/projects`)
    .orderByChild('lastModified')
    .limitToLast(10)
    .get()
```

But **not needed** at current scale (constitution constraint: < 5MB localStorage).

---

## Example Data

### Before Sync (Local Cache)

```javascript
// localStorage: speckit_projects
[
    {
        "id": "project_123",
        "name": "Feature A",
        "lastModified": 1697472000000,  // 10:00 AM
        "needsTimestampUpdate": false
    }
]
```

### After Cloud Edit from Another Browser

```javascript
// Firebase: users/user_abc/projects/project_123
{
    "id": "project_123",
    "name": "Feature A (edited)",
    "lastModified": 1697475600000  // 11:00 AM (server timestamp)
}
```

### On Next Load

```javascript
// Comparison:
cloudTime = 1697475600000  // 11:00 AM
localTime = 1697472000000  // 10:00 AM

// Result: cloudTime > localTime → use cloud data
projects = [
    {
        "id": "project_123",
        "name": "Feature A (edited)",  // Cloud version wins
        "lastModified": 1697475600000
    }
]

// Update localStorage with cloud data
localStorage.setItem('speckit_projects', JSON.stringify(projects));
```

---

## Edge Cases

### Case 1: Missing timestamp (old data)

```javascript
cloudProject.lastModified = undefined
localProject.lastModified = 1697472000000

// Treat undefined as 0
cloudTime = 0
localTime = 1697472000000

// Result: localTime > cloudTime → use local data
// This ensures old data doesn't overwrite newer timestamped data
```

### Case 2: Both missing timestamps

```javascript
cloudProject.lastModified = undefined
localProject.lastModified = undefined

// Both are 0
cloudTime = 0
localTime = 0

// Result: cloudTime >= localTime → use cloud data (tie goes to cloud)
```

### Case 3: Future timestamp (clock skew)

```javascript
cloudProject.lastModified = Date.now() + 3600000  // 1 hour in future

// Validation catches this
validateTimestamp(cloudTime) // → Error: "Timestamp is too far in the future"

// Fallback: Use local data and log warning
console.error('⚠️ Cloud data has future timestamp, using local version');
```

---

## Performance Considerations

### Timestamp Comparison Overhead

**Operation**: `cloudTime >= localTime`
**Cost**: ~1 CPU cycle (integer comparison)
**Scale**: 100 projects × 1µs = 100µs = 0.1ms ✅ (within 500ms page load goal)

### Firebase Read Cost

**Current**: Load all projects on login
**Optimization** (future): Only load changed projects using Firebase listeners:

```javascript
ref(`users/${userId}/projects`)
    .orderByChild('lastModified')
    .startAt(lastKnownTimestamp)
    .on('child_added', handleNewProject);
```

**Not implemented now** - premature optimization (constitution principle: simplicity first).

---

## Summary

**New Fields**:
- `Project.lastModified` (number, server timestamp)
- `Project.needsTimestampUpdate` (boolean, migration flag)
- `OfflineQueueItem.timestamp` (number, queue creation time)
- `OfflineQueueItem.retryCount` (number, retry attempts)
- `OfflineQueueItem.projectId` (string, extracted from path)

**New Entity**:
- `SyncMetadata` (in-memory, not persisted)

**Validation Rules**:
- Timestamps must be positive numbers
- Timestamps cannot be >5 minutes in future
- Cloud timestamp >= local timestamp → use cloud

**Migration**:
- Missing `lastModified` → set to 0 (oldest)
- Flag with `needsTimestampUpdate` for next save
- Server timestamp set on next `saveProjectToFirebase()`

**Next**: Generate API contracts for sync operations
