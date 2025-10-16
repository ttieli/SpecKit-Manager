# Tasks: Cloud-First Data Synchronization Strategy

**Input**: Design documents from `/specs/005-cloud-first-sync/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

**Organization**: Tasks grouped by user story for independent implementation and testing

**Tests**: Automated unit tests for pure functions (timestamp*, conflict*) + manual E2E tests for sync flows (per spec: E2E priority)

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story label (US1, US2, US3)
- All tasks include exact file paths

## Path Conventions
- **Single-file architecture**: `index.html` (249KB, <250KB limit)
- **Tests**: `test-automation.html`
- **Backup**: Created before save operations (24-hour retention)

---

## Phase 1: Setup & Verification

**Purpose**: Validate existing code structure and prepare for modifications

- [ ] T001 Verify index.html exists and is <250KB (current: 249KB)
- [ ] T002 Create backup of index.html at specs/005-/backup-index.html (rollback safety)
- [ ] T003 Verify existing Firebase integration is functional (test saveProjectToFirebase, loadProjectsFromFirebase)
- [ ] T004 Locate existing functions: migrateProjectSchema(), loadProjects(), saveProjects(), processOfflineQueue()

**Validation**:
- Backup exists, index.html functional, all target functions found

---

## Phase 2: Foundational Infrastructure

**Purpose**: Core infrastructure required by ALL user stories

### Module Boundary Setup (Constitution Principle VI)

- [ ] T005 [P] Add "Data Access Layer" section comment in index.html before existing data functions (~line 2800)
- [ ] T006 [P] Add "Business Logic Layer" section comment in index.html for new timestamp/conflict functions (~line 4600)
- [ ] T007 [P] Add "Presentation Layer" section comment in index.html for render functions (~line 5500)
- [ ] T008 Add cycle management test section in test-automation.html for sync tests

**Validation**:
- 4 section comments added with clear module boundaries

### Separation of Concerns Setup (Constitution Principle VII)

- [ ] T009 [P] Add layer validation checklist in plan.md: No render* calls localStorage
- [ ] T010 [P] Add layer validation checklist in plan.md: No business logic manipulates DOM
- [ ] T011 [P] Add layer validation checklist in plan.md: No data access implements conflict resolution
- [ ] T012 Document layer call chain in plan.md: Event Handler → Presentation → Business → Data

**Validation**:
- Layer boundaries documented, validation checklist created

### Data Migration Foundation

- [ ] T013 Verify migrateProjectSchema() exists and handles lastModified field in index.html (Data Access Layer ~line 2800)
  - Check: `grep -n "function migrateProjectSchema" index.html`
  - If missing: implement function to add `lastModified: 0` to old projects
  - If exists: verify it adds `lastModified: 0` and `needsTimestampUpdate: true` for projects missing this field
- [ ] T014 Update loadProjects() to call migration functions in correct order in index.html (~line 4666)
- [ ] T015 Update saveProjects() to create 24-hour backup before save in index.html (~line 4703)
- [ ] T016 Add DATA_VERSION = 2 constant if not exists in index.html (~line 100)

**Validation**:
- Migration runs on load, backup created before save, version constant added

---

## Phase 3: User Story 1 - Cloud Data Takes Precedence (P1)

**Goal**: Users can delete projects in Browser A and see deletion reflected in Browser B

**Independent Test**:
1. Login Browser A, delete Project X, save to cloud
2. Login Browser B with same account
3. Verify Project X does not appear

### Schema Migration (T017-T019)

- [ ] T017 [US1] Update migrateProjectSchema() to add lastModified: 0 and needsTimestampUpdate: true for old projects in index.html (~line 2800-2850)
- [ ] T018 [P] [US1] Add timestampValidate() function to validate timestamp is number, >0, not future in index.html (Business Logic Layer ~line 4600)
- [ ] T019 [US1] Test migration: Load old project, verify lastModified: 0 added

**Validation**:
- Old projects get lastModified: 0, needsTimestampUpdate: true
- timestampValidate() returns {valid, error} object

### Server Timestamp Integration (T020-T022)

- [ ] T020 [US1] Modify saveProjectToFirebase() to use firebase.database.ServerValue.TIMESTAMP in index.html (Data Access Layer ~line 3270)
- [ ] T021 [US1] Add logic to remove needsTimestampUpdate flag after setting timestamp in saveProjectToFirebase()
- [ ] T022 [US1] Test server timestamp: Save project, check Firebase Console for numeric timestamp

**Validation**:
- Firebase Console shows lastModified as number (milliseconds since epoch)
- needsTimestampUpdate flag removed after first save

### Timestamp Comparison (T023-T025)

- [ ] T023 [P] [US1] Implement timestampCompare(cloudTime, localTime) function returning -1/0/1 in index.html (Business Logic Layer ~line 4600)
- [ ] T024 [P] [US1] Add null/undefined handling: treat missing timestamp as 0 in timestampCompare()
- [ ] T025 [US1] Add unit tests for timestampCompare() in test-automation.html: (1000, 500) → 1, (500, 1000) → -1, (null, null) → 0

**Validation**:
- All unit tests pass
- Null handling works correctly

### Conflict Resolution Core (T026-T029)

- [ ] T026 [US1] Implement conflictResolveProjects(cloudProjects[], localProjects[]) in index.html (Business Logic Layer ~line 4700)
  - Create cloudMap and localMap by ID
  - For each ID: compare timestamps, use newer version (if timestamps equal, use cloud version as tie-breaker)
  - Return merged array
- [ ] T027 [US1] Modify loadProjects() to call conflictResolveProjects() instead of merge logic in index.html (~line 4666)
- [ ] T028 [US1] Update loadProjects() to save merged result back to localStorage after conflict resolution
- [ ] T029 [US1] Test cross-browser: Delete project in Browser A, reload Browser B, verify deletion reflected

**Validation**:
- Deleted projects stay deleted across browsers
- Newest version always wins (cloudTime >= localTime)
- Local-only projects preserved (not deleted)

---

## Phase 4: User Story 2 - Conflict Resolution via Timestamp (P1)

**Goal**: When local and cloud data conflict, newest timestamp wins

**Independent Test**:
1. Modify Project A in Browser 1 at T1 (name: "Version 1")
2. Modify Project A in Browser 2 at T2 (T2 > T1, name: "Version 2")
3. Force sync in Browser 1
4. Verify Browser 1 shows "Version 2" (T2 wins)

### Timestamp-Based Merge Logic (T030-T032)

- [ ] T030 [US2] Add validation in conflictResolveProjects(): if cloudTime > localTime, use cloud; if localTime > cloudTime, use local; if tie, use cloud
- [ ] T031 [US2] Add console logging in conflictResolveProjects() showing which version wins: "🔄 Conflict resolution: ${cloudWins} cloud wins, ${localWins} local wins"
- [ ] T032 [US2] Test conflict scenarios:
  - Cloud newer: cloudProject.lastModified = 2000, localProject.lastModified = 1000 → cloud wins
  - Local newer: cloudProject.lastModified = 1000, localProject.lastModified = 2000 → local wins
  - Tie: both 1000 → cloud wins

**Validation**:
- Conflict resolution logic correct
- Console logs show resolution stats
- All test scenarios pass

### Missing Timestamp Handling (T033-T034)

- [ ] T033 [P] [US2] Update conflictResolveProjects() to handle missing lastModified: treat as 0 (oldest)
- [ ] T034 [US2] Test missing timestamp scenarios:
  - Cloud has timestamp, local missing → cloud wins
  - Local has timestamp, cloud missing → local wins
  - Both missing → cloud wins (tie-breaker)

**Validation**:
- Missing timestamp treated as epoch 0
- Correct winner selected in all scenarios

---

## Phase 5: User Story 3 - Offline Changes Queue with Cloud Authority (P2)

**Goal**: Offline changes sync when online, but cloud timestamp wins if conflict

**Independent Test**:
1. Go offline (disable network)
2. Edit Project B locally
3. While offline, simulate cloud update in Firebase Console (set newer lastModified)
4. Come online
5. Verify cloud version wins, local changes discarded

### Offline Queue Timestamp Tracking (T035-T037)

- [ ] T035 [US3] Update queueOfflineOperation() to add timestamp: Date.now() and projectId to queue items in index.html (~line 3450)
- [ ] T036 [P] [US3] Update OfflineQueueItem structure to include: timestamp, retryCount, projectId fields
- [ ] T037 [US3] Test queue creation: Go offline, edit project, verify queue item has timestamp and projectId

**Validation**:
- Queue items have timestamp, retryCount, projectId
- timestamp is Date.now() at queue time

### Stale Operation Discard Logic (T038-T041)

- [ ] T038 [US3] Update processOfflineQueue() to extract projectId from item.path in index.html (~line 3500)
- [ ] T039 [US3] Add comparison in processOfflineQueue(): if project.lastModified > item.timestamp, discard operation
- [ ] T040 [US3] Add retry count increment: item.retryCount++, discard if retryCount >= 5
- [ ] T041 [US3] Add console logging: "⏭️ Discarding stale operation for ${projectId} (cloud is newer)"

**Validation**:
- Stale operations discarded (cloud timestamp > queue timestamp)
- Retry count incremented
- Max 5 retries before discard
- Console logs show discarded operations

### Offline Queue Processing (T042-T044)

- [ ] T042 [US3] Update processOfflineQueue() to return stats: {processed, discarded}
- [ ] T043 [US3] Add toast notification after queue processing: "✅ 已同步 ${processed} 个离线更改" if processed > 0
- [ ] T044 [US3] Test offline queue flow:
  - Go offline, edit Project C
  - Come online, cloud has no update → changes pushed successfully
  - Go offline, delete Project D
  - Come online, cloud has newer Project D → deletion discarded, cloud version kept

**Validation**:
- Queue processing returns {processed, discarded} stats
- Toast shows successful sync count
- Test scenarios pass: no conflict = sync, conflict = cloud wins

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: UI improvements, validation, testing

### Sync Status UI (T045-T047)

- [ ] T045 [P] Implement renderSyncStatus() to update #connectionStatus element with online/offline/syncing state in index.html (Presentation Layer ~line 5500)
- [ ] T046 [P] Add renderSyncDebugInfo(project) to show lastModified, needsTimestampUpdate in debug panel
- [ ] T047 Call renderSyncStatus() after sync operations: after saveProjects(), after processOfflineQueue()

**Validation**:
- Online status shows 🟢 "在线"
- Offline status shows 🔴 "离线"
- Syncing status shows 🟡 "同步中..."

### Event Handlers (T048-T049)

- [ ] T048 [P] Implement handleSyncNow() for manual sync button in index.html (Event Handler Layer ~line 6900)
- [ ] T049 Update handleConnectionChange(online) to call processOfflineQueue() when coming back online

**Validation**:
- Manual sync button triggers sync
- Auto-sync when connection restored

### Validation & Error Handling (T050-T052)

- [ ] T050 [P] Implement validateSyncMetadata(project) to check project has valid lastModified in index.html (Business Logic Layer ~line 4700)
- [ ] T051 Add error handling in conflictResolveProjects(): if timestamp validation fails, log warning and default to cloud version
- [ ] T052 Add error handling in processOfflineQueue(): if Firebase unreachable, keep items in queue for retry

**Validation**:
- Invalid timestamps logged as warnings
- Errors don't crash app
- Failed operations stay in queue

### Testing (T053-T057)

- [ ] T053 Add test case in test-automation.html: "[SYNC] Timestamp comparison" - test timestampCompare() with known inputs
- [ ] T054 Add test case in test-automation.html: "[SYNC] Conflict resolution (cloud wins)" - mock cloud/local with cloud newer
- [ ] T055 Add test case in test-automation.html: "[SYNC] Conflict resolution (local wins)" - mock cloud/local with local newer
- [ ] T056 Add test case in test-automation.html: "[SYNC] Missing timestamp handling" - test null/undefined timestamps
- [ ] T057 Add test case in test-automation.html: "[SYNC] Offline queue discard" - test stale operation discard logic

**Validation**:
- All 5 automated tests pass
- Test coverage for timestamp comparison, conflict resolution, offline queue

### Final Validation (T058-T060)

- [ ] T058 Verify file size: index.html <250KB after all changes
- [ ] T059 Verify function naming follows conventions: sync*, timestamp*, conflict*, render*, handle*
- [ ] T060 Verify layer separation: no data access in business logic, no business logic in presentation

**Validation**:
- File size within limit
- Naming conventions followed
- Layer boundaries respected

---

## Dependencies & Execution Order

### User Story Dependencies

```
US1 (Cloud Data Takes Precedence)
   ↓ provides timestamp comparison
US2 (Conflict Resolution via Timestamp)
   ↓ provides conflict resolution logic
US3 (Offline Changes Queue)
```

**Recommended MVP**: Implement US1 + US2 only (core sync functionality)
**P2 Feature**: US3 can be added in next iteration

### Parallel Execution Opportunities

**Within Phase 2 (Foundational)**:
- T005-T008 can run in parallel (different section comments)
- T009-T012 can run in parallel (documentation tasks)

**Within US1**:
- T018 (timestampValidate) parallel with T017 (schema migration)
- T023-T024 (timestampCompare) parallel with T020-T021 (server timestamp)

**Within Phase 6 (Polish)**:
- T045-T046 (UI functions) parallel with T048-T049 (event handlers)
- T050-T052 (validation) parallel with T053-T057 (tests)

---

## Implementation Strategy

### MVP Scope (First Iteration)

**Include**:
- Phase 1: Setup (T001-T004)
- Phase 2: Foundational (T005-T016)
- Phase 3: US1 (T017-T029) - Core cloud-first sync
- Phase 4: US2 (T030-T034) - Timestamp-based conflict resolution
- Phase 6: Partial (T050-T052, T058-T060) - Validation only

**Exclude** (next iteration):
- Phase 5: US3 (T035-T044) - Offline queue (P2 feature)
- Phase 6: UI (T045-T049) - Polish features
- Phase 6: Tests (T053-T057) - Optional automated tests

**MVP Validation**:
1. Delete project in Browser A → Browser B doesn't show it ✅
2. Edit project in Browser 1 → Browser 2 shows latest version ✅
3. No data resurrection bugs ✅

### Incremental Delivery Plan

**Week 1**: MVP (US1 + US2)
- Days 1-2: Phase 1 + Phase 2 (Setup + Foundational)
- Days 3-4: Phase 3 (US1 - Cloud precedence)
- Day 5: Phase 4 (US2 - Conflict resolution)

**Week 2**: P2 Features + Polish
- Days 1-2: Phase 5 (US3 - Offline queue)
- Days 3-4: Phase 6 (UI + Tests)
- Day 5: Final validation + deployment

---

## Task Summary

| Phase | Task Count | Estimated Time | Priority |
|-------|------------|----------------|----------|
| Phase 1: Setup | 4 tasks | 30 min | Required |
| Phase 2: Foundational | 12 tasks | 1.5 hours | Required |
| Phase 3: US1 (P1) | 13 tasks | 2 hours | MVP |
| Phase 4: US2 (P1) | 5 tasks | 1 hour | MVP |
| Phase 5: US3 (P2) | 10 tasks | 1.5 hours | Next iteration |
| Phase 6: Polish | 13 tasks | 1.5 hours | Optional |
| **Total** | **57 tasks** | **8 hours** | |

**MVP Tasks**: 34 tasks (Phase 1 + 2 + 3 + 4 + partial 6)
**P2 Tasks**: 23 tasks (Phase 5 + remaining Phase 6)

---

## Format Validation ✅

All tasks follow required format:
- ✅ Checkbox: `- [ ]`
- ✅ Task ID: Sequential (T001-T060)
- ✅ [P] marker: Where parallelizable
- ✅ [Story] label: US1, US2, US3 for user story tasks
- ✅ File paths: All tasks include exact paths (index.html line numbers)

---

## Next Steps

1. **Review tasks**: Ensure all user stories covered
2. **Execute MVP**: Run `/speckit.implement` to start Phase 1
3. **Track progress**: Mark tasks complete as you finish them
4. **Test frequently**: Validate each phase before proceeding

**Ready for implementation!** 🚀
