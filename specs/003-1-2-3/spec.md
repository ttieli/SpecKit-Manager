# Feature Specification: Enhanced Project Management and Command Library

**Feature Branch**: `003-1-2-3`
**Created**: 2025-10-16
**Status**: Draft
**Input**: User description: "根据以上内容，给我提供一个以下要求的优化：1）支持更详细的项目管理增删改功能 2）左侧项目列表提供更加详细的单个项目进度信息并支持跳转到项目页面；3）增加一个常见可复制命令保存和复制的页面，支持用户自己上传并提供用户自定义命令的快速复制功能"

## Clarifications

### Session 2025-10-16

- Q: Should the Command Library be global (shared by all projects) or project-specific (each project has its own command set)? → A: Global Command Library - Single shared command library for all projects. Commands are available across all projects for maximum reusability.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Enhanced Project CRUD Operations (Priority: P1)

As a project manager, I want to create, edit, rename, duplicate, and delete projects with full control so that I can manage my Spec Kit projects efficiently throughout their lifecycle.

**Why this priority**: Core project management operations are foundational to all other features. Without robust CRUD operations, users cannot effectively manage their project portfolio.

**Independent Test**: Can be fully tested by creating a new project, editing its name and description, duplicating it, and deleting it. Delivers immediate value by allowing users to organize and maintain their project list without worrying about data loss.

**Acceptance Scenarios**:

1. **Given** I am on the project overview page, **When** I click "Add Project" and fill in project name and description, **Then** a new project is created and appears in the project list with a unique ID
2. **Given** I have an existing project, **When** I click the edit icon and change the project name, **Then** the project name updates immediately in both the sidebar and project detail view
3. **Given** I have an existing project with iterations, **When** I click "Duplicate Project", **Then** a complete copy of the project with all iterations is created with a new unique ID and "(Copy)" appended to the name
4. **Given** I have an existing project, **When** I click delete and confirm the action, **Then** the project and all its iterations are permanently removed from storage
5. **Given** I attempt to delete a project, **When** I click delete, **Then** a confirmation dialog appears asking "Are you sure you want to delete [Project Name]? This action cannot be undone."
6. **Given** I am editing a project name, **When** I enter an empty string or only whitespace, **Then** the system shows validation error "Project name cannot be empty"
7. **Given** I am editing a project, **When** I add a project description field, **Then** the description persists and displays in the project detail view

---

### User Story 2 - Project Progress Dashboard in Sidebar (Priority: P2)

As a user reviewing my projects, I want to see detailed progress information directly in the sidebar project list so that I can quickly assess project status without opening each project individually.

**Why this priority**: After basic CRUD operations work (P1), users need at-a-glance visibility into project health to prioritize their work. This enhances productivity by reducing navigation time.

**Independent Test**: Can be tested by creating multiple projects with different numbers of iterations and completion states, then verifying the sidebar displays accurate progress indicators (iteration count, completion percentage, last updated timestamp). Users can identify which projects need attention without clicking into each one.

**Acceptance Scenarios**:

1. **Given** I have projects with iterations, **When** I view the sidebar project list, **Then** each project shows total iteration count (e.g., "5 iterations")
2. **Given** I have projects with completed and incomplete iterations, **When** I view the sidebar, **Then** each project shows completion percentage calculated as (completed iterations / total iterations × 100%)
3. **Given** I have projects last modified at different times, **When** I view the sidebar, **Then** each project shows "Last updated: [relative time]" (e.g., "2 hours ago", "3 days ago", "2024-10-15")
4. **Given** I click on a project in the sidebar, **When** the project has at least one iteration, **Then** the view jumps to that project's detail page and scrolls to the first iteration
5. **Given** I click on a project in the sidebar, **When** the project has no iterations, **Then** the view jumps to that project's detail page showing the empty state with "Add Iteration" prompt
6. **Given** I am viewing the sidebar, **When** a project has zero completed iterations, **Then** the progress indicator shows "0% complete" or displays a visual indicator (e.g., empty progress bar)
7. **Given** I am viewing the sidebar, **When** a project has all iterations completed, **Then** the progress indicator shows "100% complete" and displays a success visual indicator (e.g., green checkmark or filled progress bar)

---

### User Story 3 - Global Command Library with Copy Functionality (Priority: P3)

As a developer working with Spec Kit, I want a dedicated global command library page where I can store, organize, and quickly copy frequently-used commands that are accessible across all my projects so that I can reduce repetitive typing and streamline my workflow.

**Why this priority**: While valuable for power users, this is a productivity enhancement that doesn't block core project management workflows. It can be delivered after P1 and P2 are complete.

**Independent Test**: Can be fully tested by navigating to the Command Library tab, adding custom commands with labels and categories, organizing them, and using the one-click copy functionality. Delivers value by creating a personalized command repository that persists across sessions.

**Acceptance Scenarios**:

1. **Given** I am on the Command Library page, **When** I click "Add Command" and fill in command text and label, **Then** the command is saved and appears in the command list
2. **Given** I have added commands, **When** I click the copy icon next to a command, **Then** the command text is copied to clipboard and a confirmation tooltip appears saying "Copied!"
3. **Given** I am adding a command, **When** I optionally provide a category (e.g., "Git Commands", "Spec Kit Commands"), **Then** commands are grouped by category in the display
4. **Given** I have saved commands, **When** I edit a command's label or text, **Then** the changes persist immediately to storage
5. **Given** I have saved commands, **When** I delete a command, **Then** it is removed from the list and storage
6. **Given** I am on the Command Library page, **When** I use a search/filter input, **Then** the command list filters in real-time to show only commands matching the search term in label, text, or category
7. **Given** the Command Library is empty, **When** I first visit the page, **Then** a set of default Spec Kit commands are pre-populated (e.g., "/speckit.specify [description]", "/speckit.plan", "/speckit.tasks", "/speckit.implement")
8. **Given** I have multiple commands, **When** I drag and drop commands to reorder them, **Then** the custom order persists to storage

---

### Edge Cases

- What happens when a user tries to duplicate a project with a name that already exists? System should auto-append "(Copy N)" where N increments until the name is unique.
- What happens when a user deletes the currently active/displayed project? System should redirect to the overview page or the next available project.
- What happens when the sidebar becomes too long with many projects? System should provide scroll functionality within the sidebar while keeping the header fixed.
- What happens when a command text is too long to display in the Command Library? System should truncate command text exceeding 100 characters with ellipsis ("...") and show full text in a tooltip on hover.
- What happens when a user copies a command but the clipboard API is not available (older browsers)? System should show a fallback message or use a textarea-based copy method.
- What happens when calculation of completion percentage results in decimals (e.g., 1/3 iterations = 33.33%)? System should round to nearest integer (33%) or display one decimal place (33.3%).
- What happens when a project has zero iterations? Progress calculation should handle division by zero gracefully (show "No iterations" or "0/0" instead of crashing).
- What happens when relative time calculations show very old dates (e.g., "2 years ago")? System should switch to absolute date format after 30-day threshold using `toLocaleDateString('zh-CN', {year: 'numeric', month: '2-digit', day: '2-digit'})` format (e.g., >30 days shows "2024/10/15").

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to edit existing project names inline without navigating to a separate edit form
- **FR-002**: System MUST provide a project description field that persists and displays in project detail views
- **FR-003**: System MUST provide a "Duplicate Project" action that creates a complete deep copy of the project including all iterations, notes, and cycle history
- **FR-004**: System MUST show a confirmation dialog before permanently deleting a project
- **FR-005**: System MUST validate project names to prevent empty or whitespace-only names
- **FR-006**: System MUST display iteration count in the sidebar for each project (e.g., "5 iterations")
- **FR-007**: System MUST calculate and display completion percentage in the sidebar based on iteration completion status
- **FR-008**: System MUST display "Last updated" timestamp in the sidebar for each project using relative time formatting (e.g., "2 hours ago")
- **FR-009**: System MUST make each project in the sidebar clickable to navigate directly to that project's detail page
- **FR-010**: System MUST provide a new global "Command Library" tab in the main navigation accessible from any project
- **FR-011**: System MUST allow users to add custom commands with label, text, and optional category to the global library
- **FR-012**: System MUST provide one-click copy functionality for each command with visual confirmation
- **FR-013**: System MUST persist all global command library data to storage (localStorage and optionally Firebase) independent of project data
- **FR-014**: System MUST provide search/filter functionality to quickly find commands by label, text, or category
- **FR-015**: System MUST pre-populate the Command Library with default Spec Kit commands on first visit
- **FR-016**: System MUST support drag-and-drop reordering of commands with persistence

### Modularity Requirements *(新增 / NEW - Constitution Principle VI)*

- **MR-001**: Feature MUST be implemented as 5 independent function groups: projectCRUD*, commandLibrary*, progressCalculation*, validate*, render*
- **MR-002**: Function naming MUST follow conventions:
  - `projectCRUD*` for create, edit, duplicate, delete operations (e.g., `projectCRUDEdit()`, `projectCRUDDuplicate()`, `projectCRUDDelete()`)
  - `commandLibrary*` for command management (e.g., `commandLibraryAdd()`, `commandLibraryCopy()`, `commandLibrarySearch()`)
  - `progressCalculation*` for progress metrics (e.g., `progressCalculationGetIterationCount()`, `progressCalculationGetCompletionPercentage()`)
  - `validate*` for input validation (e.g., `validateProjectName()`, `validateCommandText()`)
  - `render*` for UI updates (e.g., `renderProjectSidebar()`, `renderCommandLibrary()`)
- **MR-003**: Function dependencies:
  - `render*` functions can call `progressCalculation*` and `validate*` functions
  - `projectCRUD*` functions can call `validate*` and `saveProjects()` (data layer)
  - `commandLibrary*` functions can call `validate*` and `saveCommands()` (data layer)
  - No circular dependencies allowed
- **MR-004**: Each function group will have dedicated test section in test-automation.html with independent test cases

**Note**: In single-file architecture (index.html), function groups replace traditional module files. Functions are grouped by naming prefix (validate*, render*, etc.) and organized by section comments.

### Separation of Concerns Requirements *(新增 / NEW - Constitution Principle VII)*

- **SC-001**: Feature touches all three layers:
  - **Data Access**: `saveProjects()`, `loadProjects()`, `saveCommands()`, `loadCommands()` (localStorage + Firebase)
  - **Business Logic**: `progressCalculationGetCompletionPercentage()`, `validateProjectName()`, `validateCommandText()`, `projectCRUDDuplicate()` (deep copy logic)
  - **Presentation**: `renderProjectSidebar()`, `renderCommandLibrary()`, `renderProjectDetail()`
- **SC-002**: Cross-layer communication MUST follow unidirectional flow:
  - Presentation → Business Logic → Data Access
  - Event handlers orchestrate: User Event → Validation → Data Save → UI Re-render
- **SC-003**: Prohibited patterns:
  - `render*` functions MUST NOT directly call `localStorage` or `firebase` APIs
  - `saveProjects()` and `saveCommands()` MUST NOT manipulate DOM
  - `progressCalculation*` functions MUST NOT perform data persistence
  - `validate*` functions MUST NOT render error messages directly (return validation result objects only)

### Key Entities *(include if feature involves data)*

- **Project**: Represents a Spec Kit project with attributes:
  - `id` (string): Unique identifier (e.g., 'project_1697845200000')
  - `name` (string): Project name (required, non-empty)
  - `description` (string): Optional project description (NEW)
  - `createdAt` (ISO8601 string): Creation timestamp
  - `updatedAt` (ISO8601 string): Last modification timestamp (NEW)
  - `iterations` (array): Array of Iteration objects

- **Iteration**: Represents a development cycle within a project (unchanged from existing model)
  - `id` (string): Unique identifier
  - `name` (string): Iteration name
  - `description` (string): Iteration description
  - `createdAt` (ISO8601 string): Creation timestamp
  - `completedSteps` (object): Map of step completion status
  - `inputs` (object): Step input data
  - `notes` (object): Step notes
  - `currentCycle` (string): Current cycle color marker
  - `cycleHistory` (object): Historical cycle data

- **Command**: Represents a saved command in the global Command Library (NEW)
  - `id` (string): Unique identifier (e.g., 'cmd_1697845200000')
  - `label` (string): Human-readable command name (required)
  - `text` (string): The actual command text to copy (required)
  - `category` (string): Optional category for grouping (e.g., "Git", "Spec Kit", "Docker")
  - `createdAt` (ISO8601 string): Creation timestamp
  - `order` (number): Custom sort order (for drag-and-drop persistence)
  - Note: Commands are global and NOT associated with specific projects (no `projectId` field)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can perform all project CRUD operations (create, edit, duplicate, delete) with < 30 seconds worst-case latency for any single operation
- **SC-002**: Project progress indicators (iteration count, completion %, last updated) display accurately in real-time with less than 100ms calculation time per project
- **SC-003**: 95% of command copy operations complete successfully with clipboard confirmation appearing within 500ms
- **SC-004**: Command Library search/filter returns results within 200ms for up to 100 stored commands
- **SC-005**: All project and command data persists correctly to storage with 100% data integrity (no data loss on page refresh)
- **SC-006**: Users can navigate from sidebar to project detail page in one click, with scroll-to-target completing within 300ms
- **SC-007**: Duplicate project operation creates an exact deep copy including all nested iteration data within 2 seconds for projects with up to 50 iterations
- **SC-008**: System handles edge cases gracefully (empty states, long text, division by zero) without crashes or console errors

## Assumptions

1. **Storage Layer**: Assumes existing `saveProjects()` and `loadProjects()` functions will be extended to support the new `description` and `updatedAt` fields. Command Library will use similar pattern with `saveCommands()` and `loadCommands()` functions.

2. **Project Structure**: Assumes the existing Project and Iteration data model is preserved, with additive changes only (new optional fields).

3. **Browser Compatibility**: Assumes modern browser support for Clipboard API (`navigator.clipboard.writeText()`). For older browsers, a fallback mechanism using hidden textarea will be provided.

4. **Relative Time Formatting**: Assumes relative time display (e.g., "2 hours ago") switches to absolute date format (e.g., "2024-10-15") after 30 days for readability.

5. **Default Commands**: Assumes a predefined set of 8-12 commonly used Spec Kit commands will be seeded into the Command Library on first use. Users can delete these if unwanted.

6. **Completion Calculation**: Assumes iteration completion is determined by checking if all required steps in `completedSteps` are marked `true`. The percentage is calculated as (completed iterations / total iterations × 100).

7. **Sidebar Scroll Behavior**: Assumes sidebar will use CSS `overflow-y: auto` to handle long project lists without affecting main content area.

8. **Duplicate Naming**: Assumes duplicate project names follow the pattern "Original Name (Copy)", "Original Name (Copy 2)", etc., incrementing the number until a unique name is found.

9. **Delete Confirmation**: Assumes delete confirmation dialog uses native `confirm()` for simplicity, consistent with existing UI patterns in the application.

10. **Category Organization**: Assumes Command Library categories are user-defined strings with no predefined taxonomy. System will group commands by exact category string match.

11. **Global Command Scope**: Command Library is global and shared across all projects. Commands added by the user are accessible from any project, enabling reusability of frequently-used commands (e.g., Spec Kit workflow commands, common git operations) without duplication per project.

## Dependencies

- Existing `saveProjects()` and `loadProjects()` functions must support new fields (`description`, `updatedAt`)
- Existing project data structure must be backward-compatible (old projects without new fields should still load)
- Clipboard API availability (graceful degradation for unsupported browsers)

## Constraints

- Must maintain single-file architecture (all code in index.html)
- Must not introduce external dependencies (no npm packages, no frameworks)
- Must maintain performance: page load < 500ms, all operations < 2s
- Must maintain data integrity: no data loss during operations
- HTML file size must remain < 150KB (uncompressed)
- Must work offline (LocalStorage as primary storage, Firebase as optional sync)

## Out of Scope

- Multi-user collaboration features (sharing projects between users)
- Project templates or starter kits
- Command Library import/export functionality (may be added in future iteration)
- Project archiving or soft-delete with recovery
- Undo/redo functionality for project edits
- Bulk operations (delete multiple projects at once, bulk command import)
- Command Library versioning or history
- Advanced search with regex or boolean operators
- Project tagging or multi-category classification
- Integration with external command-line tools or shell scripts
