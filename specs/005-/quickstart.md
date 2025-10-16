# Quick Start: Cloud-First Synchronization Implementation

**Feature**: 005-cloud-first-sync
**Date**: 2025-10-16
**Audience**: Developers implementing timestamp-based conflict resolution

## Overview

This guide walks you through implementing cloud-first data synchronization to replace the current merge-based strategy. The goal is to ensure deleted projects stay deleted across all browsers.

**Time Estimate**: 4-6 hours of development

**Prerequisites**:
- Familiarity with Firebase Realtime Database
- Understanding of async/await in JavaScript
- Access to index.html source code
- Test environment with multiple browsers

---

## Implementation Roadmap

### Phase 1: Data Model Updates (1 hour)

**Goal**: Add `lastModified` timestamp field to Project schema

**Steps**:

1. **Update `migrateProjectSchema()` function** (around line 2800):

```javascript
function migrateProjectSchema(project) {
    // Existing migrations...
    if (!project.description) project.description = '';
    if (!project.updatedAt) project.updatedAt = Date.parse(project.createdAt);

    // NEW: Add lastModified timestamp
    if (project.lastModified === undefined || project.lastModified === null) {
        project.lastModified = 0; // Epoch 0 = oldest possible
        project.needsTimestampUpdate = true; // Flag for next save
    }

    return project;
}
```

2. **Test migration locally**:

```javascript
// In browser console
localStorage.setItem('speckit_projects', JSON.stringify([
    {id: 'test_1', name: 'Test Project', createdAt: new Date().toISOString()}
]));
loadProjects(); // Should add lastModified: 0, needsTimestampUpdate: true
console.log(projects); // Verify migration worked
```

**Checkpoint**: Old projects now have `lastModified: 0` and `needsTimestampUpdate: true`.

---

### Phase 2: Timestamp Helper Functions (30 minutes)

**Goal**: Create utility functions for timestamp comparison and validation

**Location**: Add after existing helper functions (around line 4600)

```javascript
// ==================== TIMESTAMP UTILITIES (Feature 005-) ====================

/**
 * Compare two timestamps for conflict resolution
 * @param {number|null|undefined} cloudTimestamp - Server timestamp
 * @param {number|null|undefined} localTimestamp - Local cache timestamp
 * @returns {number} -1 if cloud older, 0 if equal, 1 if cloud newer
 */
function timestampCompare(cloudTimestamp, localTimestamp) {
    const cloudTime = cloudTimestamp || 0;
    const localTime = localTimestamp || 0;

    if (cloudTime > localTime) return 1;
    if (cloudTime < localTime) return -1;
    return 0;
}

/**
 * Validate timestamp value
 * @param {any} timestamp - Value to validate
 * @returns {{valid: boolean, error?: string}} Validation result
 */
function timestampValidate(timestamp) {
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
}
```

**Test helpers**:

```javascript
// In browser console
console.assert(timestampCompare(1000, 500) === 1, 'Cloud newer');
console.assert(timestampCompare(500, 1000) === -1, 'Local newer');
console.assert(timestampCompare(null, null) === 0, 'Null handling');
console.log('✅ Timestamp helpers working');
```

**Checkpoint**: Timestamp comparison functions available and tested.

---

### Phase 3: Update Save Operation (1 hour)

**Goal**: Ensure all saves include server timestamp

**Modify `saveProjectToFirebase()` function** (around line 3270):

```javascript
async function saveProjectToFirebase(userId, projectId, project) {
    try {
        const projectRef = window.firebase.ref(
            window.firebase.db,
            `users/${userId}/projects/${projectId}`
        );

        // Prepare data with server timestamp
        const dataToSave = { ...project };

        // NEW: Always set server timestamp on save
        dataToSave.lastModified = window.firebase.database.ServerValue.TIMESTAMP;

        // NEW: Remove migration flag if present
        if (dataToSave.needsTimestampUpdate) {
            delete dataToSave.needsTimestampUpdate;
        }

        if (isOnline && firebaseInitialized) {
            await window.firebase.set(projectRef, dataToSave);
            console.log(`✅ Project ${projectId} saved with timestamp`);
        } else {
            queueOfflineOperation('set', `users/${userId}/projects/${projectId}`, dataToSave);
            console.log(`📦 Project ${projectId} save queued`);
        }
    } catch (error) {
        console.error(`❌ Failed to save project ${projectId}:`, error);
        queueOfflineOperation('set', `users/${userId}/projects/${projectId}`, project);
        throw error;
    }
}
```

**Test saving**:

```javascript
// Create test project
const testProject = {
    id: 'timestamp_test',
    name: 'Timestamp Test',
    createdAt: new Date().toISOString(),
    iterations: []
};

projects.push(testProject);
await saveProjectToFirebase(currentUser.uid, testProject.id, testProject);

// Check Firebase Console - should see lastModified as server timestamp
```

**Checkpoint**: New projects saved with Firebase server timestamps.

---

### Phase 4: Conflict Resolution Logic (2 hours)

**Goal**: Implement cloud-first conflict resolution

**Add new function `conflictResolveProjects()`** (around line 4700):

```javascript
/**
 * Merge cloud and local projects using timestamp-based resolution
 * Cloud timestamp >= local timestamp → use cloud data
 *
 * @param {Array<Project>} cloudProjects - Projects from Firebase
 * @param {Array<Project>} localProjects - Projects from localStorage
 * @returns {Array<Project>} Merged array with newest versions
 */
function conflictResolveProjects(cloudProjects, localProjects) {
    const cloudMap = new Map(cloudProjects.map(p => [p.id, p]));
    const localMap = new Map(localProjects.map(p => [p.id, p]));
    const allIds = new Set([...cloudMap.keys(), ...localMap.keys()]);

    const resolved = [];
    let cloudWins = 0;
    let localWins = 0;

    for (const id of allIds) {
        const cloudProj = cloudMap.get(id);
        const localProj = localMap.get(id);

        if (cloudProj && localProj) {
            // Both exist - compare timestamps
            const cmp = timestampCompare(cloudProj.lastModified, localProj.lastModified);

            if (cmp >= 0) {
                // Cloud is newer or equal (tie goes to cloud)
                resolved.push(cloudProj);
                cloudWins++;
            } else {
                // Local is newer (pending sync)
                resolved.push(localProj);
                localWins++;
            }
        } else if (cloudProj) {
            // Only in cloud (deleted locally? use cloud version)
            resolved.push(cloudProj);
            cloudWins++;
        } else {
            // Only in local (not yet synced)
            resolved.push(localProj);
            localWins++;
        }
    }

    console.log(`🔄 Conflict resolution: ${cloudWins} cloud wins, ${localWins} local wins`);
    return resolved;
}
```

**Replace `loadProjects()` function** (around line 4666):

```javascript
async function loadProjects() {
    try {
        // Load from both sources
        const localData = localStorage.getItem('speckit_projects');
        const localProjects = localData ? JSON.parse(localData) : [];

        let cloudProjects = [];
        if (currentUser && firebaseInitialized) {
            cloudProjects = await loadProjectsFromFirebase(currentUser.uid);
        }

        // NEW: Resolve conflicts using cloud-first strategy
        projects = conflictResolveProjects(cloudProjects, localProjects);

        // Apply migrations to all projects
        projects = projects.map(migrateProjectSchema);

        // Migrate iterations (existing code)
        projects.forEach(project => {
            project.iterations?.forEach((iteration, index) => {
                project.iterations[index] = migrateIterationToCycles(iteration);
            });
        });

        // Update local cache with merged results
        localStorage.setItem('speckit_projects', JSON.stringify(projects));

        console.log(`✅ Loaded ${projects.length} projects (cloud-first merge)`);
    } catch (error) {
        console.error('❌ Failed to load projects:', error);
        // Fallback: Use local cache only
        const saved = localStorage.getItem('speckit_projects');
        if (saved) {
            projects = JSON.parse(saved).map(migrateProjectSchema);
            console.log(`⚠️ Loaded ${projects.length} projects from local cache only`);
        }
    }
}
```

**Test conflict resolution**:

```javascript
// Scenario: Delete project in Browser A, check Browser B

// Browser A:
const projIndex = projects.findIndex(p => p.id === 'test_delete');
projects.splice(projIndex, 1);
await saveProjects(); // Pushes deletion to Firebase

// Browser B (simulate):
localStorage.setItem('speckit_projects', JSON.stringify([
    {id: 'test_delete', name: 'Should Be Deleted', lastModified: 100}
]));
await loadProjects(); // Should NOT include 'test_delete' (cloud has no record)

// Verify
console.assert(!projects.find(p => p.id === 'test_delete'), 'Deleted project should not reappear');
```

**Checkpoint**: Conflicts resolved with cloud-first strategy.

---

### Phase 5: Offline Queue Updates (1 hour)

**Goal**: Discard stale offline operations when cloud has newer data

**Update `processOfflineQueue()` function** (around line 3500):

```javascript
async function processOfflineQueue() {
    const queue = JSON.parse(localStorage.getItem('offline_queue') || '[]');

    if (queue.length === 0) {
        console.log('ℹ️ Offline queue is empty');
        return;
    }

    console.log(`📤 Processing ${queue.length} queued operations`);

    const updatedQueue = [];
    let processed = 0;
    let discarded = 0;

    for (const item of queue) {
        try {
            // NEW: Extract project ID from path
            const projectId = item.path.split('/').pop();
            const project = projects.find(p => p.id === projectId);

            // NEW: Check if cloud has newer data
            if (project && project.lastModified > (item.timestamp || 0)) {
                console.log(`⏭️ Discarding stale operation for ${projectId} (cloud is newer)`);
                discarded++;
                continue; // Skip this operation
            }

            // Execute operation
            const ref = window.firebase.ref(window.firebase.db, item.path);

            if (item.operation === 'set') {
                await window.firebase.set(ref, item.data);
            } else if (item.operation === 'update') {
                await window.firebase.update(ref, item.data);
            } else if (item.operation === 'delete') {
                await window.firebase.remove(ref);
            }

            console.log(`✅ Executed queued ${item.operation} for ${item.path}`);
            processed++;
        } catch (error) {
            console.error(`❌ Failed to execute queued operation:`, error);

            // NEW: Increment retry count
            item.retryCount = (item.retryCount || 0) + 1;

            if (item.retryCount < 5) {
                updatedQueue.push(item); // Retry later
            } else {
                console.error(`❌ Max retries exceeded, discarding operation`);
                discarded++;
            }
        }
    }

    // Save updated queue (with stale items removed)
    localStorage.setItem('offline_queue', JSON.stringify(updatedQueue));

    console.log(`📊 Queue processed: ${processed} succeeded, ${discarded} discarded, ${updatedQueue.length} remaining`);

    if (processed > 0) {
        showToast(`✅ 已同步 ${processed} 个离线更改`, 'success');
    }
}
```

**Update `queueOfflineOperation()` to add timestamp** (around line 3450):

```javascript
function queueOfflineOperation(operation, path, data) {
    const queue = JSON.parse(localStorage.getItem('offline_queue') || '[]');

    // NEW: Add timestamp and project ID
    queue.push({
        operation,
        path,
        data,
        timestamp: Date.now(),              // NEW
        projectId: path.split('/').pop(),   // NEW
        retryCount: 0                       // NEW
    });

    localStorage.setItem('offline_queue', JSON.stringify(queue));
    console.log(`📦 Queued ${operation} operation for ${path}`);
}
```

**Test offline queue**:

```javascript
// Scenario: Offline edit, then cloud update from another browser

// 1. Go offline
isOnline = false;

// 2. Edit project locally
const project = projects[0];
project.name = "Offline Edit";
await saveProjects(); // Should queue operation

// 3. Simulate cloud update from another browser
project.lastModified = Date.now() + 10000; // 10 seconds in future

// 4. Come back online
isOnline = true;
await processOfflineQueue(); // Should discard queued edit (stale)

// Verify
const queue = JSON.parse(localStorage.getItem('offline_queue') || '[]');
console.assert(queue.length === 0, 'Stale operation should be discarded');
```

**Checkpoint**: Offline queue respects cloud authority.

---

## Testing Checklist

### Manual Test Scenarios

#### Scenario 1: Cross-Browser Deletion

**Setup**: Two browsers (A and B) logged in as same user

**Steps**:
1. Browser A: Delete Project X
2. Browser A: Verify deletion synced to Firebase (check console for "☁️ All projects synced")
3. Browser B: Refresh page
4. Browser B: Verify Project X does not appear

**Expected**: ✅ Project stays deleted

---

#### Scenario 2: Timestamp Conflict Resolution

**Setup**: Two browsers with same project

**Steps**:
1. Browser A: Edit project name to "Version A" at 10:00:00
2. Browser B: Edit project name to "Version B" at 10:00:05 (5 seconds later)
3. Browser A: Refresh page

**Expected**: ✅ Browser A shows "Version B" (cloud timestamp wins)

---

#### Scenario 3: Offline Queue Discard

**Setup**: Browser in offline mode

**Steps**:
1. Go offline (disable network in DevTools)
2. Edit project locally (change name)
3. While still offline, simulate cloud update in Firebase Console (set newer `lastModified`)
4. Go online
5. Wait for queue processing

**Expected**: ✅ Local changes discarded, cloud version used

---

### Automated Tests

**Add to `test-automation.html`** (around line 800):

```javascript
// Cloud-First Sync Tests
{
    name: '[SYNC] Timestamp comparison',
    fn: async () => {
        assert(timestampCompare(1000, 500) === 1, 'Cloud newer');
        assert(timestampCompare(500, 1000) === -1, 'Local newer');
        assert(timestampCompare(1000, 1000) === 0, 'Equal');
        assert(timestampCompare(null, 500) === -1, 'Null handling');
    },
    category: 'sync'
},
{
    name: '[SYNC] Conflict resolution (cloud wins)',
    fn: async () => {
        const cloud = [{id: 'p1', name: 'Cloud', lastModified: 2000}];
        const local = [{id: 'p1', name: 'Local', lastModified: 1000}];
        const result = conflictResolveProjects(cloud, local);
        assert(result[0].name === 'Cloud', 'Cloud version should win');
    },
    category: 'sync'
},
{
    name: '[SYNC] Conflict resolution (local wins)',
    fn: async () => {
        const cloud = [{id: 'p1', name: 'Cloud', lastModified: 1000}];
        const local = [{id: 'p1', name: 'Local', lastModified: 2000}];
        const result = conflictResolveProjects(cloud, local);
        assert(result[0].name === 'Local', 'Local version should win');
    },
    category: 'sync'
}
```

---

## Debugging Tips

### Enable Debug Logging

```javascript
// Add to top of sync functions
const DEBUG_SYNC = true;

if (DEBUG_SYNC) {
    console.log('[SYNC DEBUG]', {
        cloudTimestamp: cloudProject?.lastModified,
        localTimestamp: localProject?.lastModified,
        winner: result >= 0 ? 'cloud' : 'local'
    });
}
```

### Inspect Sync Metadata

**Add debug panel to UI**:

```html
<div id="syncDebug" style="position: fixed; bottom: 0; right: 0; background: #f0f0f0; padding: 10px; font-size: 12px;">
    <h4>Sync Debug</h4>
    <div id="syncDebugContent"></div>
</div>
```

```javascript
function renderSyncDebugInfo() {
    const debugContent = projects.map(p => `
        <div>
            <strong>${p.name}</strong><br>
            Last Modified: ${p.lastModified ? new Date(p.lastModified).toLocaleString() : 'Never'}<br>
            Needs Update: ${p.needsTimestampUpdate ? '⚠️ Yes' : '✅ No'}
        </div>
        <hr>
    `).join('');

    document.getElementById('syncDebugContent').innerHTML = debugContent;
}

// Call after loadProjects()
renderSyncDebugInfo();
```

### Check Firebase Timestamps

```javascript
// In Firebase Console > Realtime Database
// Navigate to: users/{userId}/projects/{projectId}
// Check lastModified field - should be a number like 1697472000000
```

---

## Common Pitfalls

### ❌ Pitfall 1: Using client-side `Date.now()` instead of server timestamp

**Wrong**:
```javascript
project.lastModified = Date.now(); // Client time, unreliable
```

**Correct**:
```javascript
project.lastModified = firebase.database.ServerValue.TIMESTAMP; // Server time
```

---

### ❌ Pitfall 2: Forgetting to update localStorage after conflict resolution

**Wrong**:
```javascript
projects = conflictResolveProjects(cloud, local);
// Missing: localStorage.setItem(...)
```

**Correct**:
```javascript
projects = conflictResolveProjects(cloud, local);
localStorage.setItem('speckit_projects', JSON.stringify(projects)); // Update cache
```

---

### ❌ Pitfall 3: Not handling null timestamps

**Wrong**:
```javascript
if (cloudProject.lastModified > localProject.lastModified) { /* ... */ }
// Fails if either is null/undefined
```

**Correct**:
```javascript
const cloudTime = cloudProject.lastModified || 0;
const localTime = localProject.lastModified || 0;
if (cloudTime > localTime) { /* ... */ }
```

---

## Performance Optimization

### Lazy Timestamp Comparison

**For large project lists (>100 projects)**:

```javascript
// Instead of resolving all at once, resolve on-demand
const projectCache = new Map();

function getProject(id) {
    if (!projectCache.has(id)) {
        const cloudProj = cloudProjects.find(p => p.id === id);
        const localProj = localProjects.find(p => p.id === id);
        projectCache.set(id, resolveConflict(cloudProj, localProj));
    }
    return projectCache.get(id);
}
```

**Note**: Only needed if performance issues observed. Current implementation is sufficient for <100 projects.

---

## Rollback Plan

**If issues arise in production**:

1. **Revert to merge mode**:
   ```javascript
   // In loadProjects(), comment out new logic:
   // projects = conflictResolveProjects(cloudProjects, localProjects);

   // Restore old logic:
   projects = [...cloudProjects, ...localProjects.filter(l => !cloudProjects.find(c => c.id === l.id))];
   ```

2. **Force re-sync all users**:
   ```javascript
   // Clear local cache, force cloud reload
   localStorage.removeItem('speckit_projects');
   localStorage.removeItem('offline_queue');
   await loadProjects(); // Will load fresh from cloud
   ```

3. **Export user data** (before rollback):
   ```javascript
   const backup = JSON.parse(localStorage.getItem('speckit_projects'));
   const blob = new Blob([JSON.stringify(backup, null, 2)], {type: 'application/json'});
   const url = URL.createObjectURL(blob);
   const a = document.createElement('a');
   a.href = url;
   a.download = `backup_${Date.now()}.json`;
   a.click();
   ```

---

## Success Metrics

**Monitor these after deployment**:

1. **Data consistency rate**: 100% of users see same projects across browsers
2. **Conflict resolution accuracy**: 100% of conflicts resolved correctly
3. **Sync latency**: Deletions visible in <5 seconds
4. **User complaints**: 0 tickets about "deleted projects coming back"

**Track via**:
- Firebase Analytics (custom events for sync operations)
- Console logs (search for "🔄 Conflict resolution" messages)
- User support tickets (filter by keywords: "deleted", "reappear", "sync")

---

## Next Steps

After successful implementation:

1. **Run automated tests**: `test-automation.html` sync category
2. **Perform manual testing**: All 3 scenarios above
3. **Monitor production**: Check success metrics for 1 week
4. **Gather feedback**: Ask early users about sync behavior
5. **Iterate**: Implement optimizations based on real usage patterns

**Questions?** Refer to:
- [Feature Spec](../spec.md) for requirements
- [Data Model](../data-model.md) for schema details
- [API Contracts](../contracts/README.md) for function signatures

---

**Good luck with the implementation!** 🚀
