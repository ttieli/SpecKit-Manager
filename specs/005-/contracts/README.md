# API Contracts: Cloud-First Synchronization

**Feature**: 005-cloud-first-sync
**Date**: 2025-10-16
**Purpose**: Define function interfaces for timestamp-based sync operations

## Overview

This document defines the function contracts (interfaces) for implementing cloud-first data synchronization. All functions follow the single-file architecture pattern with clear separation of concerns.

**Layer Organization**:
- **Data Access Layer**: `sync*`, `timestamp*` functions
- **Business Logic Layer**: `conflict*`, `validate*` functions
- **Presentation Layer**: `renderSyncStatus*` functions
- **Event Handler Layer**: `handle*` functions

---

## Data Access Layer

### `syncLoadProjectsCloudFirst()`

**Purpose**: Load projects with cloud-first conflict resolution

**Signature**:
```javascript
/**
 * Load projects using cloud-first strategy
 * Cloud timestamp >= local timestamp → use cloud data
 *
 * @returns {Promise<Array<Project>>} Array of projects with newest versions
 * @throws {Error} If Firebase is unreachable and no local cache exists
 */
async function syncLoadProjectsCloudFirst()
```

**Behavior**:
1. Load projects from Firebase (if online)
2. Load projects from localStorage
3. For each project ID:
   - Compare `cloudProject.lastModified` vs `localProject.lastModified`
   - If cloud timestamp >= local timestamp → use cloud version
   - If only exists locally → keep local version (pending sync)
   - If only exists in cloud → use cloud version (deleted locally? check timestamp)
4. Update localStorage cache with winning versions
5. Return merged project list

**Error Handling**:
- If Firebase unreachable: Use localStorage cache, set `isOnline = false`
- If both Firebase and localStorage empty: Return `[]` (empty array)
- If timestamp comparison fails: Log warning, default to cloud version

**Example Usage**:
```javascript
// On app init
async function init() {
    projects = await syncLoadProjectsCloudFirst();
    renderAllViews();
}
```

**Dependencies**: `loadProjectsFromFirebase()`, `localStorage.getItem()`

---

### `syncSaveProjectCloudFirst(project)`

**Purpose**: Save project with server timestamp

**Signature**:
```javascript
/**
 * Save project to localStorage and Firebase with server timestamp
 *
 * @param {Project} project - Project object to save
 * @returns {Promise<void>}
 * @throws {Error} If validation fails or localStorage is full
 */
async function syncSaveProjectCloudFirst(project)
```

**Behavior**:
1. Validate project data (call `validateProject(project)`)
2. If migration flag exists (`project.needsTimestampUpdate`):
   - Set `lastModified = firebase.database.ServerValue.TIMESTAMP`
   - Delete `needsTimestampUpdate` flag
3. Save to localStorage immediately (synchronous)
4. If online: Save to Firebase with server timestamp
5. If offline: Queue operation with `queueOfflineOperation()`

**Example Usage**:
```javascript
// After user edits project
project.name = "Updated Name";
await syncSaveProjectCloudFirst(project);
```

**Dependencies**: `validateProject()`, `saveProjectToFirebase()`, `queueOfflineOperation()`

---

### `timestampCompare(cloudTimestamp, localTimestamp)`

**Purpose**: Compare two timestamps to determine which is newer

**Signature**:
```javascript
/**
 * Compare timestamps for conflict resolution
 * Handles null/undefined as epoch 0 (oldest)
 *
 * @param {number|null|undefined} cloudTimestamp - Server timestamp from Firebase
 * @param {number|null|undefined} localTimestamp - Cached timestamp from localStorage
 * @returns {number} -1 if cloud older, 0 if equal, 1 if cloud newer
 */
function timestampCompare(cloudTimestamp, localTimestamp)
```

**Behavior**:
```javascript
const cloudTime = cloudTimestamp || 0;
const localTime = localTimestamp || 0;

if (cloudTime > localTime) return 1;   // Cloud is newer
if (cloudTime < localTime) return -1;  // Local is newer
return 0;                              // Same timestamp
```

**Example Usage**:
```javascript
const result = timestampCompare(cloudProject.lastModified, localProject.lastModified);
if (result >= 0) {
    // Use cloud version (cloud newer or tie)
    return cloudProject;
} else {
    // Use local version
    return localProject;
}
```

**Dependencies**: None (pure function)

---

### `timestampValidate(timestamp)`

**Purpose**: Validate timestamp value

**Signature**:
```javascript
/**
 * Validate timestamp is a reasonable value
 *
 * @param {any} timestamp - Value to validate
 * @returns {{valid: boolean, error?: string}} Validation result
 */
function timestampValidate(timestamp)
```

**Behavior**:
```javascript
if (typeof timestamp !== 'number') {
    return { valid: false, error: 'Timestamp must be a number' };
}

if (timestamp < 0) {
    return { valid: false, error: 'Timestamp cannot be negative' };
}

const now = Date.now();
const maxAllowed = now + (5 * 60 * 1000); // 5 minutes tolerance
if (timestamp > maxAllowed) {
    return { valid: false, error: 'Timestamp is too far in the future' };
}

return { valid: true };
```

**Example Usage**:
```javascript
const check = timestampValidate(project.lastModified);
if (!check.valid) {
    console.error(`Invalid timestamp: ${check.error}`);
    return;
}
```

**Dependencies**: None (pure function)

---

## Business Logic Layer

### `conflictResolveProjects(cloudProjects, localProjects)`

**Purpose**: Resolve conflicts between cloud and local project lists

**Signature**:
```javascript
/**
 * Merge cloud and local projects using timestamp-based resolution
 *
 * @param {Array<Project>} cloudProjects - Projects from Firebase
 * @param {Array<Project>} localProjects - Projects from localStorage
 * @returns {Array<Project>} Merged array with newest versions
 */
function conflictResolveProjects(cloudProjects, localProjects)
```

**Behavior**:
1. Create map of cloud projects by ID: `cloudMap = {id: project}`
2. Create map of local projects by ID: `localMap = {id: project}`
3. For each project ID in cloud OR local:
   - If exists in both: Compare timestamps, use newer
   - If only in cloud: Use cloud version
   - If only in local: Use local version (pending sync)
4. Return array of winning projects

**Pseudocode**:
```javascript
function conflictResolveProjects(cloudProjects, localProjects) {
    const cloudMap = new Map(cloudProjects.map(p => [p.id, p]));
    const localMap = new Map(localProjects.map(p => [p.id, p]));
    const allIds = new Set([...cloudMap.keys(), ...localMap.keys()]);

    const resolved = [];

    for (const id of allIds) {
        const cloudProj = cloudMap.get(id);
        const localProj = localMap.get(id);

        if (cloudProj && localProj) {
            // Both exist - compare timestamps
            const cmp = timestampCompare(cloudProj.lastModified, localProj.lastModified);
            resolved.push(cmp >= 0 ? cloudProj : localProj);
        } else if (cloudProj) {
            // Only in cloud
            resolved.push(cloudProj);
        } else {
            // Only in local (pending sync)
            resolved.push(localProj);
        }
    }

    return resolved;
}
```

**Example Usage**:
```javascript
const cloudProjects = await loadProjectsFromFirebase(userId);
const localProjects = JSON.parse(localStorage.getItem('speckit_projects') || '[]');
const mergedProjects = conflictResolveProjects(cloudProjects, localProjects);
```

**Dependencies**: `timestampCompare()`

---

### `conflictProcessOfflineQueue()`

**Purpose**: Process offline queue, discarding stale operations

**Signature**:
```javascript
/**
 * Retry offline operations, discard if cloud has newer data
 *
 * @returns {Promise<{processed: number, discarded: number}>} Stats
 */
async function conflictProcessOfflineQueue()
```

**Behavior**:
1. Load offline queue from localStorage
2. For each queue item:
   - Extract `projectId` from `path` field
   - Find project in current `projects` array
   - Compare `item.timestamp` vs `project.lastModified`
   - If project.lastModified > item.timestamp: Discard (stale)
   - Else: Retry operation, increment `retryCount`
3. Save updated queue (with stale items removed)
4. Return stats: `{processed, discarded}`

**Pseudocode**:
```javascript
async function conflictProcessOfflineQueue() {
    const queue = JSON.parse(localStorage.getItem('offline_queue') || '[]');
    const validQueue = [];
    let processed = 0;
    let discarded = 0;

    for (const item of queue) {
        const project = projects.find(p => p.id === item.projectId);

        if (!project) {
            // Project deleted, discard operation
            discarded++;
            continue;
        }

        if (project.lastModified > item.timestamp) {
            // Cloud has newer data, discard stale operation
            console.log(`⏭️ Discarding stale operation for ${item.projectId}`);
            discarded++;
            continue;
        }

        // Valid operation - retry
        try {
            await executeQueuedOperation(item);
            processed++;
        } catch (error) {
            // Retry failed, keep in queue
            item.retryCount = (item.retryCount || 0) + 1;
            if (item.retryCount < 5) {
                validQueue.push(item);
            } else {
                console.error(`❌ Max retries exceeded for ${item.projectId}`);
                discarded++;
            }
        }
    }

    localStorage.setItem('offline_queue', JSON.stringify(validQueue));
    return { processed, discarded };
}
```

**Example Usage**:
```javascript
// When connection restored
window.addEventListener('online', async () => {
    const result = await conflictProcessOfflineQueue();
    console.log(`Processed ${result.processed}, discarded ${result.discarded}`);
});
```

**Dependencies**: `projects` global, `executeQueuedOperation()`

---

### `validateSyncMetadata(project)`

**Purpose**: Validate project has required sync metadata

**Signature**:
```javascript
/**
 * Check if project has valid lastModified timestamp
 *
 * @param {Project} project - Project to validate
 * @returns {{valid: boolean, errors: Array<string>}} Validation result
 */
function validateSyncMetadata(project)
```

**Behavior**:
```javascript
const errors = [];

if (!project.id) {
    errors.push('Missing project ID');
}

// Check lastModified exists and is valid
if (project.lastModified === undefined) {
    errors.push('Missing lastModified timestamp');
} else {
    const timestampCheck = timestampValidate(project.lastModified);
    if (!timestampCheck.valid) {
        errors.push(`Invalid lastModified: ${timestampCheck.error}`);
    }
}

// Warn if needsTimestampUpdate flag is still set
if (project.needsTimestampUpdate) {
    console.warn(`Project ${project.id} needs timestamp update on next save`);
}

return { valid: errors.length === 0, errors };
}
```

**Example Usage**:
```javascript
const validation = validateSyncMetadata(project);
if (!validation.valid) {
    console.error('Invalid sync metadata:', validation.errors);
    return;
}
```

**Dependencies**: `timestampValidate()`

---

## Presentation Layer

### `renderSyncStatus()`

**Purpose**: Render sync status indicator in UI

**Signature**:
```javascript
/**
 * Update sync status indicator (online/offline/syncing)
 *
 * @returns {void}
 */
function renderSyncStatus()
```

**Behavior**:
1. Read global `isOnline` variable
2. Count pending operations in offline queue
3. Update DOM element `#connectionStatus`:
   - If online + queue empty: 🟢 "在线"
   - If online + queue pending: 🟡 "同步中..."
   - If offline: 🔴 "离线"
4. Add tooltip with queue count

**Example HTML**:
```html
<div id="connectionStatus" class="status-indicator">
    <span class="status-dot">🟢</span>
    <span class="status-text">在线</span>
</div>
```

**Example Usage**:
```javascript
// Call after sync operations
await syncSaveProjectCloudFirst(project);
renderSyncStatus(); // Update UI
```

**Dependencies**: `isOnline` global, `localStorage.getItem('offline_queue')`

**Prohibited**:
- ❌ MUST NOT access Firebase directly (violation of separation of concerns)
- ❌ MUST NOT call `saveProjects()` or modify data

---

### `renderSyncDebugInfo(project)`

**Purpose**: Render sync metadata for debugging

**Signature**:
```javascript
/**
 * Display sync metadata for a project (debug panel)
 *
 * @param {Project} project - Project to inspect
 * @returns {string} HTML string with sync info
 */
function renderSyncDebugInfo(project)
```

**Behavior**:
```javascript
const lastModified = project.lastModified || 0;
const lastModifiedDate = lastModified > 0
    ? new Date(lastModified).toLocaleString()
    : 'Never';

const needsUpdate = project.needsTimestampUpdate ? '⚠️ Yes' : '✅ No';

return `
    <div class="sync-debug">
        <h4>Sync Metadata</h4>
        <table>
            <tr><td>Last Modified:</td><td>${lastModifiedDate}</td></tr>
            <tr><td>Timestamp:</td><td>${lastModified}</td></tr>
            <tr><td>Needs Update:</td><td>${needsUpdate}</td></tr>
        </table>
    </div>
`;
}
```

**Example Usage**:
```javascript
// In project detail view
const debugHtml = renderSyncDebugInfo(currentProject);
document.getElementById('debugPanel').innerHTML = debugHtml;
```

**Dependencies**: None

---

## Event Handler Layer

### `handleSyncNow()`

**Purpose**: Manual sync trigger (button click)

**Signature**:
```javascript
/**
 * Manually trigger sync operation
 *
 * @returns {Promise<void>}
 */
async function handleSyncNow()
```

**Behavior**:
1. Check if online: `if (!isOnline) { showToast('离线状态'); return; }`
2. Show syncing状态: `renderSyncStatus()`
3. Call `syncLoadProjectsCloudFirst()` to pull latest
4. Call `conflictProcessOfflineQueue()` to push pending
5. Update UI: `renderAllViews()`
6. Show success toast

**Example Usage**:
```html
<button onclick="handleSyncNow()">🔄 手动同步</button>
```

**Dependencies**: `syncLoadProjectsCloudFirst()`, `conflictProcessOfflineQueue()`, `renderSyncStatus()`

---

### `handleConnectionChange()`

**Purpose**: React to online/offline events

**Signature**:
```javascript
/**
 * Handle connection status change
 *
 * @param {boolean} online - New online status
 * @returns {Promise<void>}
 */
async function handleConnectionChange(online)
```

**Behavior**:
```javascript
async function handleConnectionChange(online) {
    isOnline = online;
    renderSyncStatus();

    if (online) {
        console.log('🟢 Back online');
        // Automatically sync when coming back online
        await syncLoadProjectsCloudFirst();
        await conflictProcessOfflineQueue();
        renderAllViews();
    } else {
        console.log('🔴 Gone offline');
        showToast('⚠️ 已离线，更改将在恢复连接后同步', 'warning');
    }
}
```

**Example Usage**:
```javascript
// Firebase connection listener (already exists)
const connectedRef = firebase.ref(firebase.db, '.info/connected');
firebase.onValue(connectedRef, (snapshot) => {
    const online = snapshot.val() === true;
    handleConnectionChange(online);
});
```

**Dependencies**: `syncLoadProjectsCloudFirst()`, `conflictProcessOfflineQueue()`, `renderSyncStatus()`, `renderAllViews()`

---

## Module Dependencies

```
Event Handler Layer
    ↓
Presentation Layer (renderSyncStatus, renderSyncDebugInfo)
    ↓
Business Logic Layer (conflictResolveProjects, conflictProcessOfflineQueue, validateSyncMetadata)
    ↓
Data Access Layer (syncLoadProjectsCloudFirst, syncSaveProjectCloudFirst, timestampCompare, timestampValidate)
    ↓
External APIs (Firebase, localStorage)
```

**Strict Rules** (Constitution Principle VII):
- ✅ Event handlers can call presentation functions
- ✅ Presentation functions can call business logic functions
- ✅ Business logic functions can call data access functions
- ❌ Data access functions MUST NOT call business logic or presentation
- ❌ Presentation functions MUST NOT call data access directly (bypass business logic)

---

## Testing Contracts

### Unit Test: `timestampCompare()`

```javascript
// Test case 1: Cloud newer
assert(timestampCompare(1000, 500) === 1);

// Test case 2: Local newer
assert(timestampCompare(500, 1000) === -1);

// Test case 3: Equal
assert(timestampCompare(1000, 1000) === 0);

// Test case 4: Null handling
assert(timestampCompare(null, 500) === -1); // null = 0, older than 500
assert(timestampCompare(1000, null) === 1);  // 1000 > 0
assert(timestampCompare(null, null) === 0);  // both 0
```

### Integration Test: `conflictResolveProjects()`

```javascript
const cloudProjects = [
    { id: 'proj_1', name: 'Cloud Version', lastModified: 2000 }
];

const localProjects = [
    { id: 'proj_1', name: 'Local Version', lastModified: 1000 },
    { id: 'proj_2', name: 'Local Only', lastModified: 1500 }
];

const result = conflictResolveProjects(cloudProjects, localProjects);

// Expected result
assert(result.length === 2);
assert(result[0].name === 'Cloud Version'); // Cloud wins (2000 > 1000)
assert(result[1].name === 'Local Only');    // Local kept (not in cloud)
```

### End-to-End Test: Cloud-First Sync Flow

**Scenario**: User deletes project in Browser A, opens Browser B

```javascript
// Browser A
await deleteProject('proj_123');
await syncSaveProjectCloudFirst(projects); // Push deletion to cloud

// Browser B (different machine)
projects = await syncLoadProjectsCloudFirst(); // Pull from cloud

// Assertion
assert(!projects.find(p => p.id === 'proj_123')); // Deleted project not present
```

---

## Error Handling Contracts

### Firebase Errors

```javascript
try {
    await syncSaveProjectCloudFirst(project);
} catch (error) {
    if (error.code === 'PERMISSION_DENIED') {
        showToast('权限不足，请重新登录', 'error');
        logout();
    } else if (error.code === 'NETWORK_ERROR') {
        queueOfflineOperation('update', path, data);
        showToast('网络错误，已加入离线队列', 'warning');
    } else {
        console.error('Unexpected error:', error);
        showToast('保存失败，请重试', 'error');
    }
}
```

### Timestamp Validation Errors

```javascript
const validation = timestampValidate(project.lastModified);
if (!validation.valid) {
    console.error(`Timestamp validation failed: ${validation.error}`);
    // Fallback: Use current time
    project.lastModified = Date.now();
    console.warn('Fallback: Using current client timestamp');
}
```

---

## Performance Contracts

### Response Time SLAs

| Function | Max Time | Typical | Measurement |
|----------|----------|---------|-------------|
| `timestampCompare()` | 1ms | <0.001ms | CPU cycles |
| `conflictResolveProjects()` | 50ms | ~10ms | 100 projects |
| `syncLoadProjectsCloudFirst()` | 1000ms | ~200ms | Network + parse |
| `conflictProcessOfflineQueue()` | 2000ms | ~500ms | Retry 10 items |

### Memory Usage

| Structure | Size | Max Count | Total |
|-----------|------|-----------|-------|
| Project | ~1KB | 100 | 100KB |
| OfflineQueueItem | ~0.5KB | 50 | 25KB |
| SyncMetadata (in-memory) | ~0.1KB | 100 | 10KB |

**Total**: ~135KB (well under 5MB localStorage limit)

---

## Summary

**Functions Added**: 11 total
- Data Access: 4 (`syncLoadProjectsCloudFirst`, `syncSaveProjectCloudFirst`, `timestampCompare`, `timestampValidate`)
- Business Logic: 3 (`conflictResolveProjects`, `conflictProcessOfflineQueue`, `validateSyncMetadata`)
- Presentation: 2 (`renderSyncStatus`, `renderSyncDebugInfo`)
- Event Handlers: 2 (`handleSyncNow`, `handleConnectionChange`)

**Naming Conventions**: ✅ All follow constitution standards
- `sync*`: Data access operations
- `timestamp*`: Time comparison helpers
- `conflict*`: Conflict resolution logic
- `validate*`: Validation functions
- `render*`: UI rendering
- `handle*`: Event handlers

**Next**: Create quickstart.md developer guide
