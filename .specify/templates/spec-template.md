# Feature Specification: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`  
**Created**: [DATE]  
**Status**: Draft  
**Input**: User description: "$ARGUMENTS"

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently - e.g., "Can be fully tested by [specific action] and delivers [specific value]"]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 3 - [Brief Title] (Priority: P3)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- What happens when [boundary condition]?
- How does system handle [error scenario]?

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: System MUST [specific capability, e.g., "allow users to create accounts"]
- **FR-002**: System MUST [specific capability, e.g., "validate email addresses"]
- **FR-003**: Users MUST be able to [key interaction, e.g., "reset their password"]
- **FR-004**: System MUST [data requirement, e.g., "persist user preferences"]
- **FR-005**: System MUST [behavior, e.g., "log all security events"]

*Example of marking unclear requirements:*

- **FR-006**: System MUST authenticate users via [NEEDS CLARIFICATION: auth method not specified - email/password, SSO, OAuth?]
- **FR-007**: System MUST retain user data for [NEEDS CLARIFICATION: retention period not specified]

### Modularity Requirements *(新增 / NEW - Constitution Principle VI)*

<!--
  ACTION REQUIRED: For each new feature component, define modularity boundaries.
  Reference: Constitution Principle VI - Modularity Mandate
-->

- **MR-001**: Feature MUST be implemented as [number] independent module(s): [list module names]
- **MR-002**: Each module MUST have clear input/output interface defined in plan.md
- **MR-003**: Module dependencies: [list dependencies or state "None - fully independent"]
- **MR-004**: Module testing strategy: [how each module will be tested independently]

*Example - Good modularity definition:*

- **MR-001**: Feature MUST be implemented as 3 independent modules: UserAuthModule, DataPersistenceModule, UIRenderModule
- **MR-002**: Each module MUST have clear JSDoc interfaces defined in plan.md
- **MR-003**: Module dependencies: UIRenderModule depends on DataPersistenceModule; UserAuthModule is independent
- **MR-004**: Each module will have isolated test suite in tests/modules/[module-name]/

*Example - Single-file architecture adaptation:*

- **MR-001**: Feature MUST be implemented as 4 function groups (pseudo-modules): auth*, data*, render*, validate*
- **MR-002**: Function naming MUST follow conventions: auth* for authentication, data* for persistence, etc.
- **MR-003**: Function dependencies: render* functions can only call validate* and data* functions, not vice versa
- **MR-004**: Each function group will have dedicated test section in test-automation.html

### Separation of Concerns Requirements *(新增 / NEW - Constitution Principle VII)*

<!--
  ACTION REQUIRED: Define layer boundaries for data, business logic, and presentation.
  Reference: Constitution Principle VII - Separation of Concerns
-->

- **SC-001**: Feature touches these layers: [Data Access / Business Logic / Presentation / All]
- **SC-002**: Cross-layer communication MUST use: [interfaces/contracts defined in plan.md]
- **SC-003**: Prohibited patterns: [e.g., "Rendering functions MUST NOT directly call localStorage"]

*Example - Web application:*

- **SC-001**: Feature touches all three layers: Data (PostgreSQL), Business (validation service), Presentation (React components)
- **SC-002**: Cross-layer communication MUST use defined service interfaces in plan.md
- **SC-003**: Prohibited: React components directly calling database, business logic manipulating DOM

*Example - Single-file architecture:*

- **SC-001**: Feature touches all three layers: Data (saveProjects), Business (validateProject), Presentation (renderProjectList)
- **SC-002**: Layers communicate via function calls: Presentation → Business → Data (one-way only)
- **SC-003**: Prohibited: render* functions calling localStorage directly, save* functions calling document.getElementById

### Key Entities *(include if feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships to other entities]

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: [Measurable metric, e.g., "Users can complete account creation in under 2 minutes"]
- **SC-002**: [Measurable metric, e.g., "System handles 1000 concurrent users without degradation"]
- **SC-003**: [User satisfaction metric, e.g., "90% of users successfully complete primary task on first attempt"]
- **SC-004**: [Business metric, e.g., "Reduce support tickets related to [X] by 50%"]
