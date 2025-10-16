# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]  
**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]  
**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]  
**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]  
**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]
**Project Type**: [single/web/mobile - determines source structure]  
**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]  
**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]  
**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

[Gates determined based on constitution file]

## Project Structure

### Documentation (this feature)

```
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

## Module Boundary Definition *(新增 / NEW - Constitution Principle VI)*

<!--
  ACTION REQUIRED: Define clear boundaries for each module in this feature.
  Reference: Constitution Principle VI - Modularity Mandate

  Each module MUST answer:
  1. What functionality does this module provide?
  2. What are its inputs and outputs (interface)?
  3. What are its dependencies (internal and external)?
  4. How can it be tested independently?
-->

### Module 1: [Module Name]

**Purpose**: [One-sentence description of what this module does]

**Interface**:
```[language]
// Input parameters
function [moduleFunctionName](param1: Type, param2: Type): ReturnType

// Or for classes
class [ModuleName] {
    constructor(dependencies: Type)
    public method1(args): ReturnType
    public method2(args): ReturnType
}
```

**Dependencies**:
- **Internal**: [List other modules this depends on, or "None"]
- **External**: [List external libraries/services, or "None"]

**Independent Test Strategy**:
- [How to test this module in isolation]
- [Example: Mock dependencies, provide test fixtures, etc.]

**Location**: [File path, e.g., `src/modules/[module-name].js`]

---

### Module 2: [Module Name]

**Purpose**: [One-sentence description]

**Interface**:
```[language]
// Define clear API
```

**Dependencies**:
- **Internal**: [e.g., "Depends on Module 1"]
- **External**: [e.g., "Uses Firebase SDK"]

**Independent Test Strategy**:
- [Testing approach]

**Location**: [File path]

---

*[Add more modules as needed]*

### Module Dependency Graph

<!--
  Visualize module relationships to identify circular dependencies
-->

```
[Module 1] ──→ [Module 2]
             ↘
               [Module 3]

(No circular dependencies allowed)
```

### Single-File Architecture Adaptation *(if applicable)*

For projects using single-file architecture (e.g., current Spec Kit):

**Function Groups (Pseudo-Modules)**:

1. **Data Access Module**: `save*`, `load*`, `delete*` functions
   - Purpose: Handle all LocalStorage/Firebase operations
   - Interface: Accept data objects, return success/error
   - Dependencies: None
   - Test: Mock localStorage/Firebase

2. **Business Logic Module**: `validate*`, `calculate*`, `process*` functions
   - Purpose: Implement business rules and validation
   - Interface: Accept entities, return validated/processed results
   - Dependencies: Data Access Module only
   - Test: Provide test entities, verify logic

3. **Presentation Module**: `render*`, `switch*` functions
   - Purpose: Update DOM based on application state
   - Interface: Accept state objects, no return (side-effect: DOM update)
   - Dependencies: Business Logic Module only (not Data Access directly)
   - Test: Verify HTML output, no actual DOM manipulation needed

4. **Event Handler Module**: `handle*`, `on*` functions
   - Purpose: Bridge user actions to business logic
   - Interface: Event object in, no return (orchestrates other modules)
   - Dependencies: All modules (orchestration layer)
   - Test: Mock user events, verify correct module calls

**Enforcement**: Function naming conventions strictly enforced during code review.

## Layers of Concerns Design *(新增 / NEW - Constitution Principle VII)*

<!--
  ACTION REQUIRED: Define how this feature separates concerns across layers.
  Reference: Constitution Principle VII - Separation of Concerns

  Three layers:
  1. Data Access Layer - persistence, storage, external APIs
  2. Business Logic Layer - validation, calculations, business rules
  3. Presentation Layer - UI rendering, user interaction
-->

### Data Access Layer (数据访问层)

**Responsibilities**:
- [List what this layer does, e.g., "Persist projects to LocalStorage"]
- [e.g., "Fetch user data from Firebase"]

**Components**:
- **File/Functions**: [e.g., `src/data/storage.js` or `saveProjects()`, `loadProjects()`]
- **External Dependencies**: [e.g., "LocalStorage API", "Firebase Realtime Database"]
- **Data Contracts**: [Define data structures this layer works with]

**Prohibited**:
- ❌ MUST NOT manipulate DOM
- ❌ MUST NOT contain business logic (validation, calculations)
- ❌ MUST NOT be called by Presentation Layer directly

**Example Interface**:
```[language]
// Data Access Layer functions
function saveProjectData(projects: Project[]): Promise<boolean>
function loadProjectData(): Promise<Project[]>
function deleteProjectData(projectId: string): Promise<boolean>
```

---

### Business Logic Layer (业务逻辑层)

**Responsibilities**:
- [List business rules, e.g., "Validate project names are non-empty"]
- [e.g., "Calculate project completion percentage"]

**Components**:
- **File/Functions**: [e.g., `src/business/validators.js` or `validateProject()`, `calculateProgress()`]
- **Internal Dependencies**: Data Access Layer only
- **Business Rules**: [Document key rules this layer enforces]

**Prohibited**:
- ❌ MUST NOT manipulate DOM
- ❌ MUST NOT directly call storage APIs (use Data Access Layer)
- ❌ MUST NOT handle user events directly

**Example Interface**:
```[language]
// Business Logic Layer functions
function validateProject(project: Project): ValidationResult
function calculateProjectStats(project: Project): Stats
function processIteration(iteration: Iteration): ProcessedIteration
```

---

### Presentation Layer (展示层)

**Responsibilities**:
- [List UI responsibilities, e.g., "Render project list"]
- [e.g., "Display error messages to user"]

**Components**:
- **File/Functions**: [e.g., `src/ui/components.js` or `renderProjectList()`, `renderErrorMessage()`]
- **Internal Dependencies**: Business Logic Layer only (never Data Access)
- **UI Framework**: [e.g., "Vanilla JavaScript", "React", "Vue"]

**Prohibited**:
- ❌ MUST NOT call Data Access Layer directly
- ❌ MUST NOT contain business logic
- ❌ MUST NOT perform data validation (delegate to Business Logic)

**Example Interface**:
```[language]
// Presentation Layer functions
function renderProjectList(projects: Project[]): void
function renderProjectDetails(project: Project, stats: Stats): void
function showErrorMessage(message: string): void
```

---

### Layer Communication Rules

**Allowed Call Chains** (unidirectional):
```
Presentation Layer
      ↓ (calls)
Business Logic Layer
      ↓ (calls)
Data Access Layer
```

**Prohibited** (reverse calls):
```
Data Access Layer ─X→ Business Logic Layer
Data Access Layer ─X→ Presentation Layer
Business Logic Layer ─X→ Presentation Layer
```

**Event Handler Bridge** (orchestration):
```
User Event → Event Handler → {
    Business Logic Layer (validate)
    → Data Access Layer (save)
    → Presentation Layer (re-render)
}
```

### Single-File Architecture Adaptation *(if applicable)*

**Code Organization Order** (top to bottom in index.html):
1. Constants and Configuration
2. **Data Access Layer** functions (`save*`, `load*`, `delete*`)
3. **Business Logic Layer** functions (`validate*`, `calculate*`, `process*`)
4. **Presentation Layer** functions (`render*`, `switch*`)
5. **Event Handlers** (`handle*`, `on*`) - bridge layer

**Naming Convention Enforcement**:
- Data Access: `saveProjects()`, `loadProjects()`, `deleteProject()`
- Business Logic: `validateProjectName()`, `calculateProgress()`, `processIteration()`
- Presentation: `renderProjectList()`, `renderMainContent()`, `switchTab()`
- Event Handlers: `handleCreateProject()`, `handleDeleteClick()`, `onProjectSelect()`

**Code Review Checklist**:
- [ ] No `render*` functions call `localStorage` or `firebase` directly
- [ ] No `save*` functions call `document.getElementById()`
- [ ] No `validate*` functions manipulate DOM
- [ ] Event handlers properly orchestrate layers in correct order
