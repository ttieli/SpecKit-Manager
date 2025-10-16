# Feature Specification: Cloud-First Data Synchronization Strategy

**Feature Branch**: `005-cloud-first-sync`
**Created**: 2025-10-16
**Status**: Draft
**Input**: User description: "当前融合模式会造成不同浏览器同用户访问，导致手动删了的项目信息还会回来，还是统一改为按照最新云端数据库修改的时间戳处理吧，确保云端可同步"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Cloud Data Takes Precedence (Priority: P1)

When a user logs in from multiple browsers or devices, they expect that deletions and changes made in one location are consistently reflected everywhere. Currently, the "merge mode" resurrects deleted projects because local data from different browsers conflicts with cloud data.

**Why this priority**: This is the core issue causing data inconsistency. Users lose trust when deleted projects mysteriously reappear, and this blocks effective multi-device workflows.

**Independent Test**: Can be fully tested by: (1) Login from Browser A, delete a project, save; (2) Login from Browser B with the same account; (3) Verify deleted project does not appear and delivers consistent data across devices.

**Acceptance Scenarios**:

1. **Given** user has deleted Project X in Browser A and changes are saved to cloud, **When** user opens Browser B with same account, **Then** Project X does not appear in project list
2. **Given** user edits Project Y metadata in Browser A at 10:00 AM, **When** user opens Browser B at 10:05 AM with stale local cache from 9:00 AM, **Then** Browser B displays the 10:00 AM cloud version, not the 9:00 AM local version
3. **Given** user is offline in Browser A and deletes Project Z locally, **When** user comes online and cloud sync occurs, **Then** Project Z deletion is pushed to cloud and reflected in all other devices

---

### User Story 2 - Conflict Resolution via Timestamp (Priority: P1)

When local data conflicts with cloud data (e.g., different browsers have different versions), the system should use the modification timestamp to determine which version is newer and authoritative.

**Why this priority**: Critical for data integrity. Without timestamp-based resolution, users cannot trust which version of their data is current.

**Independent Test**: Can be fully tested by: (1) Modify Project A in Browser 1 at T1; (2) Modify same Project A in Browser 2 at T2 where T2 > T1; (3) Force sync; (4) Verify both browsers show T2 version and delivers authoritative conflict resolution.

**Acceptance Scenarios**:

1. **Given** Project A was modified in Browser 1 at timestamp T1, **When** Project A is modified in Browser 2 at timestamp T2 (T2 > T1) and sync occurs, **Then** all devices show the T2 version
2. **Given** user has made local changes offline with timestamp T1, **When** user comes online and cloud has newer version with timestamp T2 (T2 > T1), **Then** local changes are discarded and cloud version (T2) is loaded
3. **Given** cloud database has Project X with lastModified timestamp, **When** browser loads with older local copy, **Then** system compares timestamps and replaces local data with cloud data if cloud is newer

---

### User Story 3 - Offline Changes Queue with Cloud Authority (Priority: P2)

When a user makes changes offline, those changes should be queued and synchronized when connection is restored, but if conflicts arise, cloud timestamp wins.

**Why this priority**: Supports offline-first workflows while maintaining cloud authority for conflict resolution.

**Independent Test**: Can be fully tested by: (1) Go offline; (2) Make changes to Project B; (3) Come online; (4) Verify changes sync to cloud if no conflicts, or cloud version wins if cloud was modified by another device and delivers resilient offline support.

**Acceptance Scenarios**:

1. **Given** user is offline and makes changes to Project B, **When** user comes online and cloud has no newer version, **Then** local changes are pushed to cloud successfully
2. **Given** user is offline and deletes Project C, **When** user comes online and cloud has a newer version of Project C (modified by another device), **Then** local deletion is discarded and cloud version is kept
3. **Given** offline queue has pending changes, **When** sync occurs and cloud data has newer timestamps, **Then** offline queue is cleared and cloud data takes precedence

---

### Edge Cases

- What happens when browser timestamps are skewed (e.g., local system time is incorrect)?
  - System should rely on cloud-generated timestamps (server time) rather than client timestamps to avoid clock skew issues
- How does system handle simultaneous edits from two browsers within the same second?
  - Use millisecond precision timestamps; if still identical, use a tiebreaker rule (e.g., last-write-wins based on Firebase server timestamp)
- What happens when Firebase is unreachable during sync attempt?
  - Changes remain in offline queue; user sees "offline" status indicator; retry sync when connection is restored
- How does system handle corrupted cloud data or missing timestamp metadata?
  - Treat missing timestamp as oldest possible (epoch 0); log error for investigation; attempt to reconstruct from available metadata

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST use cloud database modification timestamp as the single source of truth for conflict resolution
- **FR-002**: System MUST compare local data timestamp with cloud data timestamp on every load operation
- **FR-003**: System MUST replace local data with cloud data when cloud timestamp is newer (cloud-first strategy)
- **FR-004**: System MUST discard local changes when cloud has newer version with higher timestamp
- **FR-005**: System MUST persist cloud data to localStorage after successful sync for offline access
- **FR-006**: System MUST display clear indicator when operating in offline mode vs. online mode
- **FR-007**: System MUST use server-generated timestamps (Firebase server timestamp) to avoid client clock skew
- **FR-008**: System MUST clear offline queue when cloud data takes precedence due to newer timestamp
- **FR-009**: When user deletes a project, system MUST record deletion timestamp in cloud to propagate deletion to all devices
- **FR-010**: System MUST NOT merge local and cloud data (abandon merge strategy entirely)

### Modularity Requirements *(Constitution Principle VI)*

- **MR-001**: Feature MUST be implemented as 3 independent function groups: `sync*` (synchronization logic), `timestamp*` (timestamp comparison), `conflict*` (conflict resolution)
- **MR-002**: Function naming MUST follow conventions: `sync*` for sync operations, `timestamp*` for time comparison, `conflict*` for resolution logic
- **MR-003**: Function dependencies: `sync*` functions call `timestamp*` and `conflict*` helpers; helpers are independent
- **MR-004**: Each function group will have dedicated test section in test-automation.html

### Separation of Concerns Requirements *(Constitution Principle VII)*

- **SC-001**: Feature touches all three layers: Data (Firebase + localStorage), Business Logic (timestamp comparison, conflict resolution), Presentation (sync status indicator)
- **SC-002**: Layers communicate via function calls: Presentation → Business → Data (unidirectional flow)
- **SC-003**: Prohibited patterns:
  - Sync status UI MUST NOT directly access Firebase or localStorage
  - Timestamp comparison logic MUST NOT manipulate DOM elements
  - Data layer MUST NOT make conflict resolution decisions (delegate to business logic)

### Key Entities

- **Project**: Represents a Spec Kit project with metadata including `lastModified` timestamp (cloud-generated server timestamp)
- **SyncStatus**: Tracks current synchronization state (online, offline, syncing, conflict-resolved)
- **TimestampMetadata**: Contains `lastModified` (server timestamp), `localCachedAt` (client cache time), `source` (cloud|local)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can delete a project in one browser and see deletion reflected in all other browsers within 5 seconds of opening
- **SC-002**: When users modify a project in Browser A and then open Browser B, they see the latest version 100% of the time (no data resurrection)
- **SC-003**: System handles 10+ concurrent browser sessions for same user account without data conflicts
- **SC-004**: Offline changes are successfully queued and synced when online, with 0% data loss for non-conflicting changes
- **SC-005**: Conflict resolution completes in under 100ms (transparent to user)
- **SC-006**: User satisfaction: 95% of users report "deleted projects stay deleted" in post-deployment testing

## Assumptions

1. **Server timestamps**: Firebase provides reliable server-generated timestamps via `serverTimestamp()` API
2. **Clock skew tolerance**: Client-side timestamps are unreliable; system will migrate to server timestamps
3. **Network reliability**: Connection status detection via Firebase `.info/connected` is accurate
4. **Data retention**: Cloud database retains full project history with timestamps (no cleanup policy interfering)
5. **User behavior**: Users primarily work from 2-3 devices; edge case of 10+ simultaneous sessions is rare but must be supported
6. **Performance**: Timestamp comparison operations are O(1) and negligible overhead (<1ms per project)

## Dependencies

- **Firebase Realtime Database**: Provides `serverTimestamp()` for conflict-free time source
- **Existing `loadProjects()` function**: Will be modified to implement cloud-first strategy
- **Existing `saveProjects()` function**: Will be updated to always record server timestamp
- **Connection status monitoring**: Already implemented via Firebase `.info/connected`

## Out of Scope

- **Manual conflict resolution UI**: Users will not be presented with "choose version A or B" dialogs; timestamp always wins
- **Undo functionality**: No built-in way to recover overwritten local changes (future enhancement)
- **Audit trail**: Detailed history of all sync operations (future enhancement for debugging)
- **Partial sync**: Entire project list is synced atomically (no per-project sync control)

## Security & Privacy Considerations

- **Timestamp tampering**: Using server-generated timestamps prevents client-side manipulation
- **Data leakage**: Sync operations only occur for authenticated users; no cross-user data exposure
- **Rate limiting**: Firebase handles rate limiting; excessive sync attempts won't cause denial of service

## Backward Compatibility

- **Migration from merge mode**: Existing users with local data will see one-time sync where cloud data wins (if cloud timestamp is newer); communicate this change in release notes
- **Data loss mitigation**: Before deploying, ensure all users' latest data is in cloud by forcing a final merge-mode sync; document rollback procedure if issues arise

## Success Metrics (How We'll Measure)

- **Data consistency rate**: Percentage of sessions where project list matches cloud data (target: 100%)
- **Conflict resolution accuracy**: Percentage of conflicts resolved correctly by timestamp (target: 100%)
- **Sync latency**: Average time from "project deleted in Browser A" to "deletion visible in Browser B" (target: <5 seconds)
- **User complaints**: Number of support tickets about "deleted projects coming back" (target: 0 after deployment)
