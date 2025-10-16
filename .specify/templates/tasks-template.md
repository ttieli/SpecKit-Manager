---
description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: The examples below include test tasks. Tests are OPTIONAL - only include them if explicitly requested in the feature specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions
- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume single project - adjust based on plan.md structure

<!-- 
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.
  
  The /speckit.tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Endpoints from contracts/
  
  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment
  
  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create project structure per implementation plan
- [ ] T002 Initialize [language] project with [framework] dependencies
- [ ] T003 [P] Configure linting and formatting tools

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Foundational Infrastructure Tasks

Examples of foundational tasks (adjust based on your project):

- [ ] T004 Setup database schema and migrations framework
- [ ] T005 [P] Implement authentication/authorization framework
- [ ] T006 [P] Setup API routing and middleware structure
- [ ] T007 Create base models/entities that all stories depend on
- [ ] T008 Configure error handling and logging infrastructure
- [ ] T009 Setup environment configuration management

### Module Boundary Setup *(新增 / NEW - Constitution Principle VI)*

**Purpose**: Establish module boundaries and enforce modularity mandate

- [ ] T010 [P] [MODULE] Define module interfaces in plan.md Module Boundary Definition section
- [ ] T011 [P] [MODULE] Create module directory structure (if multi-file) or establish function naming conventions (if single-file)
- [ ] T012 [P] [MODULE] Setup module isolation tests (verify no circular dependencies)
- [ ] T013 [MODULE] Implement module dependency injection pattern (if applicable)
- [ ] T014 [MODULE] Add JSDoc/TypeDoc comments for all module interfaces

**Single-File Architecture Adaptation**:
- [ ] T010-SF [P] [MODULE] Define function group boundaries (auth*, data*, render*, validate*) in plan.md
- [ ] T011-SF [P] [MODULE] Add section comment headers in index.html for each function group
- [ ] T012-SF [MODULE] Setup test sections for each function group in test-automation.html

### Separation of Concerns Setup *(新增 / NEW - Constitution Principle VII)*

**Purpose**: Establish layer boundaries and enforce separation of concerns

- [ ] T015 [P] [LAYER:DATA] Define Data Access Layer interfaces in plan.md Layers of Concerns section
- [ ] T016 [P] [LAYER:BUSINESS] Define Business Logic Layer interfaces in plan.md Layers of Concerns section
- [ ] T017 [P] [LAYER:PRESENTATION] Define Presentation Layer interfaces in plan.md Layers of Concerns section
- [ ] T018 [LAYER:DATA] Create Data Access Layer directory/files or establish function naming conventions
- [ ] T019 [LAYER:BUSINESS] Create Business Logic Layer directory/files or establish function naming conventions
- [ ] T020 [LAYER:PRESENTATION] Create Presentation Layer directory/files or establish function naming conventions
- [ ] T021 [LAYER] Setup layer violation detection (ESLint rules or code review checklist)

**Single-File Architecture Adaptation**:
- [ ] T018-SF [P] [LAYER:DATA] Add "Data Access Layer" section comment in index.html with save*, load*, delete* functions
- [ ] T019-SF [P] [LAYER:BUSINESS] Add "Business Logic Layer" section comment in index.html with validate*, calculate* functions
- [ ] T020-SF [P] [LAYER:PRESENTATION] Add "Presentation Layer" section comment in index.html with render*, switch* functions
- [ ] T021-SF [LAYER] Add code review checklist in CONTRIBUTING.md for layer violation detection

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 (OPTIONAL - only if tests requested) ⚠️

**NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T010 [P] [US1] Contract test for [endpoint] in tests/contract/test_[name].py
- [ ] T011 [P] [US1] Integration test for [user journey] in tests/integration/test_[name].py

### Implementation for User Story 1

**Organized by Module and Layer** *(新增 / NEW - Constitution Principles VI & VII)*

#### Data Access Layer Tasks (LAYER:DATA)

- [ ] T022 [P] [US1] [MODULE:DataAccess] [LAYER:DATA] Implement saveEntity1() in src/data/storage.js
- [ ] T023 [P] [US1] [MODULE:DataAccess] [LAYER:DATA] Implement loadEntity1() in src/data/storage.js
- [ ] T024 [P] [US1] [MODULE:DataAccess] [LAYER:DATA] Implement deleteEntity1() in src/data/storage.js

#### Business Logic Layer Tasks (LAYER:BUSINESS)

- [ ] T025 [P] [US1] [MODULE:Validation] [LAYER:BUSINESS] Implement validateEntity1() in src/business/validators.js
- [ ] T026 [P] [US1] [MODULE:Processing] [LAYER:BUSINESS] Implement processEntity1() in src/business/processors.js
- [ ] T027 [US1] [MODULE:Business] [LAYER:BUSINESS] Add error handling for entity1 operations

#### Presentation Layer Tasks (LAYER:PRESENTATION)

- [ ] T028 [P] [US1] [MODULE:UI] [LAYER:PRESENTATION] Implement renderEntity1List() in src/ui/components.js
- [ ] T029 [P] [US1] [MODULE:UI] [LAYER:PRESENTATION] Implement renderEntity1Details() in src/ui/components.js
- [ ] T030 [US1] [MODULE:UI] [LAYER:PRESENTATION] Add loading states and error messages

#### Event Handler Tasks (Bridge Layer)

- [ ] T031 [US1] [MODULE:EventHandlers] Implement handleEntity1Create() orchestrating all layers
- [ ] T032 [US1] [MODULE:EventHandlers] Implement handleEntity1Delete() orchestrating all layers

**Traditional Organization** (use if not following new constitution principles):

- [ ] T012 [P] [US1] Create [Entity1] model in src/models/[entity1].py
- [ ] T013 [P] [US1] Create [Entity2] model in src/models/[entity2].py
- [ ] T014 [US1] Implement [Service] in src/services/[service].py (depends on T012, T013)
- [ ] T015 [US1] Implement [endpoint/feature] in src/[location]/[file].py
- [ ] T016 [US1] Add validation and error handling
- [ ] T017 [US1] Add logging for user story 1 operations

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 (OPTIONAL - only if tests requested) ⚠️

- [ ] T018 [P] [US2] Contract test for [endpoint] in tests/contract/test_[name].py
- [ ] T019 [P] [US2] Integration test for [user journey] in tests/integration/test_[name].py

### Implementation for User Story 2

- [ ] T020 [P] [US2] Create [Entity] model in src/models/[entity].py
- [ ] T021 [US2] Implement [Service] in src/services/[service].py
- [ ] T022 [US2] Implement [endpoint/feature] in src/[location]/[file].py
- [ ] T023 [US2] Integrate with User Story 1 components (if needed)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 (OPTIONAL - only if tests requested) ⚠️

- [ ] T024 [P] [US3] Contract test for [endpoint] in tests/contract/test_[name].py
- [ ] T025 [P] [US3] Integration test for [user journey] in tests/integration/test_[name].py

### Implementation for User Story 3

- [ ] T026 [P] [US3] Create [Entity] model in src/models/[entity].py
- [ ] T027 [US3] Implement [Service] in src/services/[service].py
- [ ] T028 [US3] Implement [endpoint/feature] in src/[location]/[file].py

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates in docs/
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization across all stories
- [ ] TXXX [P] Additional unit tests (if requested) in tests/unit/
- [ ] TXXX Security hardening
- [ ] TXXX Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together (if tests requested):
Task: "Contract test for [endpoint] in tests/contract/test_[name].py"
Task: "Integration test for [user journey] in tests/integration/test_[name].py"

# Launch all models for User Story 1 together:
Task: "Create [Entity1] model in src/models/[entity1].py"
Task: "Create [Entity2] model in src/models/[entity2].py"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

### Task Label Format *(Updated)*

**Standard Labels**:
- **[P]** = Parallel task (different files, no dependencies)
- **[Story]** = User story identifier (e.g., [US1], [US2], [US3])

**New Constitution Labels** *(新增 / NEW - Constitution Principles VI & VII)*:
- **[MODULE:Name]** = Module identifier (e.g., [MODULE:DataAccess], [MODULE:Validation], [MODULE:UI])
- **[LAYER:Name]** = Layer identifier (e.g., [LAYER:DATA], [LAYER:BUSINESS], [LAYER:PRESENTATION])

**Full Example**:
```
- [ ] T022 [P] [US1] [MODULE:DataAccess] [LAYER:DATA] Implement saveEntity1() in src/data/storage.js
```

**Interpretation**:
- `T022` = Task ID
- `[P]` = Can run in parallel with other [P] tasks
- `[US1]` = Belongs to User Story 1
- `[MODULE:DataAccess]` = Part of Data Access module
- `[LAYER:DATA]` = Part of Data Access Layer
- Description: What to do and where

### Task Organization Strategies

**Strategy 1: By User Story** (Traditional - still valid)
- Group all tasks for each user story together
- Ensures each story can be completed independently
- Good for small teams or sequential development

**Strategy 2: By Module** (New - Constitution Principle VI)
- Group tasks by module across all user stories
- Enables module-focused development
- Good for teams with specialized module ownership
- Example: Complete all DataAccess module tasks, then all Validation module tasks

**Strategy 3: By Layer** (New - Constitution Principle VII)
- Group tasks by architectural layer across all user stories
- Ensures proper layer isolation
- Good for establishing layer boundaries early
- Example: Complete all Data Layer tasks, then Business Layer, then Presentation Layer

**Strategy 4: Hybrid** (Recommended for larger projects)
- Phase 1: Setup (all teams together)
- Phase 2: Foundational + Module/Layer setup (all teams together)
- Phase 3+: User stories in parallel, organized by module/layer within each story
- Balances independence with architectural rigor

### Best Practices

- **[P] tasks** = different files, no dependencies
- **[Story]** label maps task to specific user story for traceability
- **[MODULE]** label enables module boundary validation
- **[LAYER]** label enforces separation of concerns
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- **Module tasks within a story must not create circular dependencies**
- **Layer tasks must respect unidirectional communication (Data ← Business ← Presentation)**
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence, layer violations

### Module and Layer Validation Checklist

Before marking a task complete, verify:

**For [MODULE] tasks**:
- [ ] Module has clear, documented interface
- [ ] No circular dependencies with other modules
- [ ] Module can be tested independently
- [ ] Module follows single responsibility principle

**For [LAYER:DATA] tasks**:
- [ ] No DOM manipulation in data access code
- [ ] No business logic in data access functions
- [ ] Only called by business logic layer (never by presentation)

**For [LAYER:BUSINESS] tasks**:
- [ ] No DOM manipulation in business logic code
- [ ] No direct storage API calls (uses data access layer)
- [ ] Only called by presentation or event handlers

**For [LAYER:PRESENTATION] tasks**:
- [ ] No direct data access (uses business logic layer)
- [ ] No business validation logic in UI code
- [ ] Only renders based on data passed in

**For [MODULE:EventHandlers] tasks**:
- [ ] Properly orchestrates layers in correct order
- [ ] Handles errors from all layers gracefully
- [ ] Doesn't contain business logic (delegates to business layer)


