# Spec Kit Project Constitution

> **Version**: 1.2.0
> **Ratified**: 2025-10-15
> **Last Amended**: 2025-10-15
> **Applies to**: Spec Kit 项目管理面板

## Core Principles

### I. Simplicity and Anti-Abstraction
Encourage simple, direct solutions. Complex abstractions are only allowed when simple approaches prove insufficient.

### II. Architectural Integrity
New features MUST follow architectural patterns defined in the constitution (single-file architecture, LocalStorage persistence, event-driven UI, functional programming).

### III. Clean and Modular Code
Enforce clear code structure following language/framework best practices. Functions max 50 lines, nesting max 3 levels, ES6+ syntax required.

### IV. Integration-First Testing
Prioritize integration tests reflecting user scenarios over isolated unit tests. E2E test priority with 100% critical path coverage.

### V. Bilingual Documentation
All project documents, specifications, plans, task lists, and AI responses MUST provide bilingual versions (Chinese/English) to ensure clarity for both audiences.

### VI. Modularity Mandate
All new feature components MUST be implemented as independent, reusable modules. Core logic code MUST NOT be placed directly in project root directory. Ensure all functionality has clear boundaries (Library-First Principle).

**Execution Standards**:
- ✅ MUST: Each new feature designed as independent module
- ✅ MUST: Modules have clear input/output interfaces
- ✅ MUST: Modules independently testable
- ✅ MUST: Module documentation clearly states purpose and boundaries
- ❌ MUST NOT: Place business logic directly in root directory files
- ❌ MUST NOT: Create "utility class" modules for organization only (no functional value)
- ❌ MUST NOT: Create circular dependencies between modules

**Current Project Adaptation** (single-file architecture):
- Function-level modularity: Split large features into small, focused functions
- Namespace isolation: Use function prefixes/comments to mark boundaries
- Logical grouping: Organize functions by domain (auth module, data module, UI module)
- Interface contracts: Use JSDoc comments to specify input/output contracts

### VII. Separation of Concerns
Enforce clear separation of concerns. For example, server-side logic, frontend components, and test files MUST be located in their designated isolated folders.

**Execution Standards**:
- ✅ MUST: Different concerns physically isolated
- ✅ MUST: Data logic, UI logic, business logic clearly layered
- ✅ MUST: Test code separated from implementation code
- ❌ MUST NOT: Directly manipulate data persistence in UI rendering functions
- ❌ MUST NOT: Directly manipulate DOM in data processing functions
- ❌ MUST NOT: Mix test code with production code

**Layers of Concerns**:
```
┌──────────────────────────────────┐
│  Presentation Layer              │  ← UI rendering, event binding, user interaction
├──────────────────────────────────┤
│  Business Logic Layer            │  ← Data validation, business rules, state management
├──────────────────────────────────┤
│  Data Access Layer               │  ← Data persistence, storage operations
└──────────────────────────────────┘
```

**Current Project Adaptation** (single-file architecture):
1. **Function Naming Conventions**:
   - Rendering functions: `render*`, `switch*`
   - Business logic functions: `validate*`, `calculate*`, `process*`
   - Data access functions: `save*`, `load*`, `delete*`
   - Event handler functions: `handle*`, `on*`

2. **Code Organization Order**:
   - Part 1: Constants and configuration
   - Part 2: Data access layer functions
   - Part 3: Business logic layer functions
   - Part 4: Presentation layer functions
   - Part 5: Event handler functions (bridge layer)

3. **Strict Calling Rules**:
   - Presentation layer can only call business logic layer
   - Business logic layer can only call data access layer
   - Data access layer cannot call other layers

## Architecture Constraints

### Data Model
```javascript
Project {
    id: string,              // 'project_' + timestamp
    name: string,
    createdAt: ISO8601,
    iterations: Iteration[]
}

Iteration {
    id: string,
    name: string,
    description: string,
    createdAt: ISO8601,
    completedSteps: Object,
    inputs: Object,
    notes: Object,
    currentCycle: string,
    cycleHistory: Object
}
```

### Key Constraints
1. Immutable data principle: All data updates must persist via `saveProjects()`
2. Rendering idempotency: Multiple calls to `render*` functions yield consistent results
3. Event delegation: Dynamic content uses `onclick` attribute binding
4. No external dependencies: Zero npm packages, zero frameworks, pure native implementation
5. Clear module boundaries: Each functional module has clear input/output interfaces (NEW)
6. Concern isolation: Data, business, presentation layers strictly separated (NEW)

## Performance Goals

### Response Time
- Page load: < 500ms (local file, no network requests)
- Tab switching: < 50ms
- Render project list: < 100ms (10 projects)
- LocalStorage read/write: < 10ms

### Resource Limits
- HTML file size: < 150KB (uncompressed)
- LocalStorage data: < 5MB (browser limit)
- DOM nodes: < 1000 (single page)

### Browser Compatibility
- Chrome 90+, Firefox 88+, Safari 14+, Edge 90+

## Terminology Standards

### Canonical Terms
| Term | Definition | Prohibited Aliases |
|------|------------|-------------------|
| Project | Top-level container with multiple iterations | ~~Workspace~~, ~~Repository~~ |
| Iteration | Development cycle with complete Spec Kit workflow | ~~Sprint~~, ~~Version~~, ~~Phase~~ |
| Cycle | Iteration loop marker distinguished by color | ~~Loop~~, ~~Round~~, ~~Stage~~ |
| Module | Functional unit with clear boundaries | ~~Component~~ (unless UI component), ~~Package~~ |
| Layer | Architectural layer (data/business/presentation) | ~~Tier~~, ~~Level~~ |
| Concern | Focus area in separation of concerns | ~~Aspect~~, ~~Responsibility~~ |

## Documentation Standards

### Document Structure

**Specification Documents**:
```markdown
# Feature Specification: [Feature Name]

> Version: x.y.z
> Created: YYYY-MM-DD
> Status: Draft | Approved | Implemented

## User Scenarios & Testing
## Requirements
## Success Criteria
## Assumptions
## Dependencies
## Constraints
## Out of Scope
```

**Planning Documents**:
```markdown
# Implementation Plan: [Feature Name]

## Technical Approach
## Architecture Decisions
## Module Boundary Definition  ← NEW
## Layers of Concerns Design  ← NEW
## Task Breakdown
## Risk Assessment
## Time Estimation
```

### Bilingual Rules Priority
1. **Mandatory Bilingual**: Document titles, section headers, table headers, core terms on first use
2. **Recommended Bilingual**: Success criteria, acceptance criteria, key step descriptions
3. **Optional Bilingual**: Detailed paragraphs, code comments, technical details

## Violation Handling

### Severity Levels

#### CRITICAL
- Violating architectural integrity (introducing backend, using class inheritance)
- Breaking data model constraints
- Introducing external frameworks/libraries
- **Violating modularity mandate (core logic in root directory)**
- **Violating separation of concerns (cross-layer direct calls, mixed responsibilities)**

**Action**: Immediate rejection, must refactor

#### WARNING
- Functions exceeding 50 lines
- Nesting depth exceeding 3 levels
- Missing necessary comments
- **Unclear module boundaries**
- **Non-standard concern layering**

**Action**: Flag during code review, request optimization

#### INFO
- Inconsistent naming
- Mixed comment languages (Chinese/English)
- Non-standard CSS ordering
- **Incomplete module documentation**
- **Function naming not following layer conventions**

**Action**: Suggest improvement, doesn't block merge

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.2.0 | 2025-10-15 | Added Principle VI: Modularity Mandate<br/>Added Principle VII: Separation of Concerns |
| 1.1.0 | 2025-10-15 | Added Principle V: Bilingual Documentation requirements |
| 1.0 | 2025-10-15 | Initial version with 5 core principles |

## Validation Checklist

Before executing `/speckit.plan` and `/speckit.implement`, AI agents must verify:

- [ ] New features follow simplicity principle (no over-abstraction)
- [ ] Adheres to existing architecture patterns (A-1 to A-4)
- [ ] Code is well-organized with proper naming conventions
- [ ] Uses canonical terminology without drift
- [ ] Integration test scenarios are defined
- [ ] Performance targets are within acceptable ranges
- [ ] Documentation includes required bilingual headers and terms
- [ ] **New features designed as independent modules with clear boundaries**
- [ ] **Separation of concerns correct, data/business/presentation layers strictly isolated**
- [ ] **Module interfaces clearly defined in plan.md**
- [ ] **Function naming follows layer conventions (render*/validate*/save* etc.)**

**Violating any CRITICAL constraint will automatically trigger re-planning.**
