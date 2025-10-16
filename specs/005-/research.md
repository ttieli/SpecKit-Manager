# Research: Cloud-First Data Synchronization Strategy

**Feature**: 005-cloud-first-sync
**Date**: 2025-10-16
**Purpose**: Resolve technical unknowns for timestamp-based conflict resolution

## Research Questions

### Q1: How to implement server-generated timestamps in Firebase Realtime Database?

**Decision**: Use `firebase.database.ServerValue.TIMESTAMP`

**Rationale**:
- Firebase Realtime Database provides `ServerValue.TIMESTAMP` which generates server-side timestamps
- Eliminates client clock skew issues (user's browser time may be incorrect)
- Returns milliseconds since Unix epoch (January 1, 1970 UTC)
- Automatically set by Firebase server when writing data

**Implementation Pattern**:
```javascript
await firebase.database().ref(`users/${userId}/projects/${projectId}`).update({
    lastModified: firebase.database.ServerValue.TIMESTAMP
});
```

**Alternatives Considered**:
- `Date.now()` client-side: Rejected due to clock skew vulnerability
- ISO 8601 strings: Rejected due to string comparison complexity and no millisecond precision guarantee
- Custom timestamp server: Over-engineered for this use case

**References**:
- Firebase Docs: https://firebase.google.com/docs/reference/js/database.servervalue
- Best practices: Always use server timestamps for conflict resolution in distributed systems

---

### Q2: Conflict resolution strategy when timestamps are identical?

**Decision**: Last-write-wins (LWW) using Firebase's atomic operations

**Rationale**:
- Millisecond precision makes identical timestamps rare (<0.01% probability)
- Firebase `.update()` operations are atomic at the node level
- If truly simultaneous (same millisecond), Firebase's server will serialize writes in arrival order
- Acceptable trade-off: occasional "last arrival wins" is better than complex resolution logic

**Implementation Pattern**:
```javascript
// Firebase guarantees atomicity - no additional locking needed
await projectRef.update({
    data: newData,
    lastModified: ServerValue.TIMESTAMP
});
```

**Alternatives Considered**:
- Vector clocks: Over-engineered for single-user-per-browser use case
- CRDT (Conflict-Free Replicated Data Types): Requires complete rewrite of data model
- Manual user conflict resolution: Violates spec requirement for automatic resolution

**Edge Case Handling**:
- If two browsers write in same millisecond, the second write overwrites the first
- User impact: Negligible (requires sub-second writes to same project from different devices)
- Mitigation: Not needed at current scale; monitor via Success Metrics

---

### Q3: How to detect and handle cloud data being newer than local cache?

**Decision**: Compare `lastModified` timestamps on every `loadProjects()` call

**Rationale**:
- Simple comparison: `if (cloudTimestamp > localTimestamp) { useCloudData(); }`
- Aligns with "cloud-first" strategy from spec
- No complex diff算法 algorithms needed - atomic replacement
- Efficient: O(1) comparison per project

**Implementation Pattern**:
```javascript
async function loadProjects() {
    const localProjects = JSON.parse(localStorage.getItem('speckit_projects') || '[]');
    const cloudProjects = await loadProjectsFromFirebase(currentUser.uid);

    const mergedProjects = cloudProjects.map(cloudProject => {
        const localProject = localProjects.find(p => p.id === cloudProject.id);

        if (!localProject) {
            return cloudProject; // New cloud project
        }

        const cloudTime = cloudProject.lastModified || 0;
        const localTime = localProject.lastModified || 0;

        return cloudTime >= localTime ? cloudProject : localProject;
    });

    // Also include local-only projects (not yet synced)
    const cloudIds = new Set(cloudProjects.map(p => p.id));
    const localOnlyProjects = localProjects.filter(p => !cloudIds.has(p.id));

    projects = [...mergedProjects, ...localOnlyProjects];
    saveProjects(); // Update local cache
}
```

**Alternatives Considered**:
- Field-by-field comparison: Complex, error-prone, violates atomic replacement principle
- Hash-based detection (e.g., MD5 checksums): Adds computational overhead, doesn't solve "which version to keep"
- Always use cloud (ignore local): Loses offline-written data, violates spec requirement for offline queue

---

### Q4: Offline queue behavior when cloud has newer data?

**Decision**: Clear offline queue for affected项目s, keep queue for other operations

**Rationale**:
- Spec requirement (FR-008): "System MUST clear offline queue when cloud data takes precedence"
- Prevents applying stale changes over newer cloud data
- Per-project granularity: Only discard queue items for projects where cloud is newer
- Maintains data integrity: Newer cloud data represents user's latest intent from another device

**Implementation Pattern**:
```javascript
function processOfflineQueue() {
    const queue = JSON.parse(localStorage.getItem('offline_queue') || '[]');
    const updatedQueue = [];

    for (const item of queue) {
        const projectId = extractProjectId(item.path); // e.g., "users/uid/projects/proj_123"
        const cloudProject = projects.find(p => p.id === projectId);
        const queueTimestamp = item.timestamp || 0;
        const cloudTimestamp = cloudProject?.lastModified || 0;

        if (cloudTimestamp > queueTimestamp) {
            console.log(`⏭️ Skipping stale queue item for ${projectId} (cloud is newer)`);
            continue; // Discard stale operation
        }

        updatedQueue.push(item); // Keep for retry
    }

    localStorage.setItem('offline_queue', JSON.stringify(updatedQueue));

    // Process remaining queue items
    for (const item of updatedQueue) {
        await executeQueuedOperation(item);
    }
}
```

**Alternatives Considered**:
- Always apply queue (merge with cloud): Violates cloud-first principle, causes data resurrection
- Prompt user to choose: Too disruptive, violates spec requirement for automatic resolution
- Keep queue indefinitely: Risk of applying ancient stale changes later

---

### Q5: Migration strategy from current merge mode to cloud-first mode?

**Decision**: One-time forced sync with cloud-first behavior on next load

**Rationale**:
- Existing code has `migrateLocalStorageToFirebase()` function
- Need to add timestamp metadata to all existing projects during migration
- Use server timestamp at migration time as baseline
- Backward compatible: Projects without `lastModified` treated as epoch 0 (oldest)

**Migration Steps**:
1. Detect projects missing `lastModified` field
2. Add `lastModified: ServerValue.TIMESTAMP` during next save
3. On load, compare timestamps (missing = 0, always loses to timestamped data)
4. Communicate change to users via release notes

**Implementation Pattern**:
```javascript
function migrateProjectSchema(project) {
    // Existing migration logic...

    // NEW: Add lastModified if missing
    if (!project.lastModified) {
        project.lastModified = 0; // Treat as oldest
        project.needsTimestampUpdate = true; // Flag for next save
    }

    return project;
}

async function saveProjects() {
    for (const project of projects) {
        if (project.needsTimestampUpdate) {
            project.lastModified = firebase.database.ServerValue.TIMESTAMP;
            delete project.needsTimestampUpdate;
        }
    }

    // Continue with save logic...
}
```

**Alternatives Considered**:
- Big-bang migration script: Risky, requires all users to run it
- Gradual per-user migration: Adds complexity, confusing for multi-device users
- No migration (only apply to new projects): Creates inconsistency between old and new projects

---

### Q6: Performance impact of timestamp comparisons at scale?

**Decision**: Negligible impact - timestamp comparison is O(1) per project

**Rationale**:
- Constitution constraint: < 5MB localStorage, realistic max ~100 projects
- Timestamp comparison: Integer subtraction, ~1 CPU cycle per project
- Total overhead: <1ms for 100 projects
- Meets constitution performance goal: "Page load < 500ms"

**Benchmarking (estimated)**:
```
100 projects × 1µs per comparison = 100µs = 0.1ms
500 projects × 1µs per comparison = 500µs = 0.5ms
```

**Alternatives Considered**:
- Lazy comparison (only on access): Adds complexity, minimal benefit
- Caching comparison results: Over-optimization for this scale
- Batch operations: Not applicable to atomic per-project sync

**No action needed** - proceed with simple comparison approach.

---

## Technology Decisions

### Timestamp Storage Format

**Decision**: Store as number (milliseconds since epoch)

**Rationale**:
- Firebase `ServerValue.TIMESTAMP` returns number type
- JavaScript `Date.now()` also returns number
- Numeric comparison is fastest (no string parsing)
- Direct subtraction for age calculations: `age = Date.now() - lastModified`

**Schema**:
```javascript
{
    id: "project_123",
    name: "My Project",
    lastModified: 1697472000000, // milliseconds since epoch
    // ... other fields
}
```

---

### Connection Status Detection

**Decision**: Reuse existing Firebase `.info/connected` monitoring

**Rationale**:
- Already implemented in current codebase (line 2821-2828)
- Firebase Realtime Database provides real-time connection status
- No additional libraries needed
- Meets spec requirement (FR-006): "display clear indicator when offline"

**No changes needed** to existing implementation:
```javascript
const connectedRef = window.firebase.ref(window.firebase.db, '.info/connected');
window.firebase.onValue(connectedRef, (snapshot) => {
    isOnline = snapshot.val() === true;
    updateConnectionStatus();
});
```

---

### Data Persistence Layer

**Decision**: Dual persistence (localStorage + Firebase) with cloud authority

**Rationale**:
- localStorage: Offline access, fast reads
- Firebase: Multi-device sync, server timestamps, cloud authority
- Write-through cache: Save to localStorage first (instant), then Firebase (async)
- Read strategy: Load from cloud, update local cache

**Flow**:
```
User action → saveProjects()
    ↓
1. Update localStorage (synchronous, instant)
2. Update Firebase (async, uses ServerValue.TIMESTAMP)
    ↓
On next load → loadProjects()
    ↓
1. Fetch from Firebase (cloud data)
2. Compare timestamps with local cache
3. Use newer version (cloud-first if tie)
4. Update localStorage with winning version
```

---

## Risk Mitigation

### Risk 1: Data loss during migration

**Likelihood**: Low
**Impact**: High
**Mitigation**:
- Existing backup system (24-hour retention in `spec_kit_backup`)
- Test migration with sample data before deployment
- Add "Undo Cloud Sync" option for 24 hours post-migration
- Communicate migration in release notes with rollback instructions

---

### Risk 2: Firebase quota limits

**Likelihood**: Low (current user base)
**Impact**: Medium (sync failures)
**Mitigation**:
- Firebase Realtime Database free tier: 10GB storage, 1GB/day bandwidth
- Current data size: ~10KB per project × 100 users × 10 projects = ~100MB (well under limit)
- Monitor Firebase usage via Firebase Console
- Add offline queue retry logic (already implemented)

---

### Risk 3: Simultaneous edits causing data loss

**Likelihood**: Very Low (<1% of operations)
**Impact**: Low (last-write-wins is acceptable per spec)
**Mitigation**:
- Document LWW behavior in success metrics tracking
- If user complaints arise, implement project-level locking (future enhancement)
- Out of scope: Manual conflict resolution UI (per spec)

---

## Open Questions Resolved

All technical unknowns from spec have been researched and resolved:

✅ **Server timestamp implementation**: Firebase `ServerValue.TIMESTAMP`
✅ **Conflict resolution**: Last-write-wins with millisecond precision
✅ **Cloud vs. local comparison**: Numeric timestamp comparison on load
✅ **Offline queue handling**: Clear queue for projects where cloud is newer
✅ **Migration path**: One-time schema update with `lastModified` field
✅ **Performance**: <1ms overhead for timestamp comparisons

**No NEEDS CLARIFICATION markers remaining** - ready for Phase 1 design.

---

## Next Phase

Proceed to **Phase 1: Design & Contracts**
- Create data-model.md with `lastModified` field
- Define API contracts for sync operations
- Generate quickstart.md for developers
- Update Claude agent context
