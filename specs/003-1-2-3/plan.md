# Implementation Plan: Enhanced Project Management and Command Library
# 实施计划：增强的项目管理和命令库

**Branch**: `003-1-2-3` | **Date**: 2025-10-16 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/003-1-2-3/spec.md`

## Summary
## 概要

This feature enhances the Spec Kit project management panel with three major improvements: (1) detailed project CRUD operations including edit, duplicate, delete with validation; (2) rich progress dashboard in the sidebar showing iteration count, completion percentage, and last updated timestamps with clickable navigation; (3) a dedicated Command Library tab for storing, organizing, and copying frequently-used commands with search/filter and drag-and-drop reordering capabilities.

本功能为 Spec Kit 项目管理面板提供三大增强：(1) 详细的项目增删改查操作,包括编辑、复制、删除及验证功能；(2) 侧边栏中的丰富进度仪表板,显示迭代计数、完成百分比和最后更新时间戳,支持点击导航；(3) 专用的命令库标签页,用于存储、组织和复制常用命令,支持搜索/筛选和拖放排序功能。

**Technical Approach**: All features will be implemented within the existing single-file architecture (index.html) using vanilla JavaScript ES6+, following the constitution's modularity and separation of concerns principles. No external frameworks or dependencies will be added.

**技术方法**：所有功能都将在现有的单文件架构（index.html）中使用原生 JavaScript ES6+ 实现,遵循宪法的模块化和关注点分离原则。不添加任何外部框架或依赖。

## Technical Context
## 技术上下文

**Language/Version**: JavaScript ES6+ (Vanilla JavaScript, no transpilation)
**Primary Dependencies**: None (zero external dependencies)
**Storage**: Dual-layer persistence
  - **Primary**: Browser LocalStorage (offline-first, 5MB limit)
  - **Secondary**: Firebase Realtime Database v12.4.0 (optional cloud sync)

**Testing**: Manual testing via test-automation.html (integration test scenarios)
**Target Platform**: Modern browsers (Chrome 90+, Firefox 88+, Safari 14+, Edge 90+)
**Project Type**: Single-file web application (index.html contains HTML, CSS, JavaScript)

**Performance Goals**:
- Page load: < 500ms (local file, no network)
- CRUD operations: < 30 seconds each
- Progress calculation: < 100ms per project
- Command copy: < 500ms with 95% success rate
- Search/filter: < 200ms for 100 commands
- Navigation scroll: < 300ms

**Constraints**:
- Single-file architecture (all code in index.html)
- No npm packages, no build tools, no frameworks
- HTML file size < 150KB (uncompressed)
- Offline-first design (LocalStorage primary, Firebase optional)
- No server-side logic (pure client-side)

**Scale/Scope**:
- Support up to 50 projects per user
- Support up to 50 iterations per project
- Support up to 100 commands in Command Library
- LocalStorage data < 5MB total

## Constitution Check
## 宪法检查

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*
*门禁：Phase 0 研究前必须通过。Phase 1 设计后重新检查。*

### Principle I: Simplicity and Anti-Abstraction ✅ PASS
- **Check**: No over-abstraction or unnecessary complexity
- **Status**: PASS - All features use direct, functional implementations without introducing abstractions like classes, design patterns, or helper libraries
- **Evidence**: Function-based modules (projectCRUD*, commandLibrary*, progressCalculation*) with clear, single-purpose functions

### Principle II: Architectural Integrity ✅ PASS
- **Check**: Follows existing architectural patterns (single-file, LocalStorage, event-driven, functional)
- **Status**: PASS - Maintains single-file architecture, dual-layer storage (LocalStorage + Firebase), event delegation via onclick attributes
- **Evidence**: No backend server, no external dependencies, pure client-side JavaScript

### Principle III: Clean and Modular Code ✅ PASS
- **Check**: Functions max 50 lines, nesting max 3 levels, ES6+ syntax
- **Status**: PASS - Implementation plan enforces function-level modularity with clear naming conventions
- **Evidence**: Module boundary definition specifies small, focused functions following naming conventions (save*, validate*, render*, etc.)

### Principle IV: Integration-First Testing ✅ PASS
- **Check**: Integration tests reflecting user scenarios prioritized
- **Status**: PASS - Spec defines 22 acceptance scenarios across 3 user stories for integration testing
- **Evidence**: test-automation.html will contain dedicated test sections for each function group

### Principle V: Bilingual Documentation ✅ PASS
- **Check**: Documents provide Chinese/English bilingual versions
- **Status**: PASS - This plan document includes bilingual section headers and key terms
- **Evidence**: All section titles in both Chinese and English

### Principle VI: Modularity Mandate ✅ PASS
- **Check**: Features implemented as independent modules with clear boundaries
- **Status**: PASS - 5 function groups defined (projectCRUD*, commandLibrary*, progressCalculation*, validate*, render*) with JSDoc interfaces
- **Evidence**: Module Boundary Definition section below specifies interfaces and dependencies

### Principle VII: Separation of Concerns ✅ PASS
- **Check**: Data, business, presentation layers strictly separated
- **Status**: PASS - Clear three-layer architecture with unidirectional communication flow
- **Evidence**: Layers of Concerns Design section below specifies responsibilities and prohibited patterns

### Overall Constitution Compliance: ✅ ALL GATES PASS
### 整体宪法合规性：✅ 所有门禁通过

**Decision**: Proceed to Phase 0 research. No violations require justification.
**决策**：进入 Phase 0 研究阶段。无需解释违规情况。

## Project Structure
## 项目结构

### Documentation (this feature)
### 文档（本功能）

```
specs/003-1-2-3/
├── spec.md              # Feature specification (功能规格)
├── plan.md              # This file - implementation plan (本文件 - 实施计划)
├── research.md          # Phase 0 output (Phase 0 输出)
├── data-model.md        # Phase 1 output - entity definitions (Phase 1 输出 - 实体定义)
├── quickstart.md        # Phase 1 output - developer guide (Phase 1 输出 - 开发者指南)
├── contracts/           # Phase 1 output - API contracts (Phase 1 输出 - API 契约)
│   ├── project-crud.md  # Project CRUD function signatures
│   ├── command-library.md # Command Library function signatures
│   └── progress-calculation.md # Progress calculation function signatures
├── checklists/          # Quality validation checklists (质量验证清单)
│   └── requirements.md  # Specification quality checklist
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)
### 源代码（仓库根目录）

```
index.html               # Single-file application (ALL code here)
                        # Structure within index.html:
                        #   1. HTML structure
                        #   2. CSS styles
                        #   3. JavaScript modules:
                        #      - Firebase configuration
                        #      - Data Access Layer (save*, load*, delete*)
                        #      - Business Logic Layer (validate*, calculate*, process*)
                        #      - Presentation Layer (render*, switch*)
                        #      - Event Handlers (handle*, on*)

test-automation.html     # Manual integration tests (手动集成测试)
start-server.sh          # Local development server (本地开发服务器)
run-tests.sh             # Test runner script (测试运行脚本)
```

**Structure Decision**: Single-file architecture maintained. All new code will be added to index.html in designated sections following the constitutional code organization order: Constants → Data Access Layer → Business Logic Layer → Presentation Layer → Event Handlers.

**结构决策**：维持单文件架构。所有新代码将按照宪法代码组织顺序添加到 index.html 的指定部分：常量 → 数据访问层 → 业务逻辑层 → 展示层 → 事件处理器。

## Complexity Tracking
## 复杂度跟踪

*No constitutional violations detected. This section intentionally left empty.*
*未检测到宪法违规。本节故意留空。*

## Module Boundary Definition
## 模块边界定义
*(新增 / NEW - Constitution Principle VI)*

### Single-File Architecture Adaptation
### 单文件架构适配

For this single-file project, modules are implemented as **function groups** with strict naming conventions.
对于此单文件项目，模块通过**函数组**实现，采用严格的命名约定。

### Module 1: Project CRUD Module (projectCRUD*)
### 模块 1：项目增删改查模块

**Purpose**: Handle all project lifecycle operations (create, read, update, duplicate, delete)
**用途**：处理所有项目生命周期操作（创建、读取、更新、复制、删除）

**Interface**:
```javascript
/**
 * Edit project name and description
 * @param {string} projectId - Project ID
 * @param {string} newName - New project name (required, non-empty)
 * @param {string} newDescription - New project description (optional)
 * @returns {Object} - {success: boolean, error?: string}
 */
function projectCRUDEdit(projectId, newName, newDescription) {}

/**
 * Duplicate project with all iterations
 * @param {string} projectId - Source project ID
 * @returns {Object} - {success: boolean, newProjectId?: string, error?: string}
 */
function projectCRUDDuplicate(projectId) {}

/**
 * Delete project after confirmation
 * @param {string} projectId - Project ID to delete
 * @returns {Object} - {success: boolean, confirmed: boolean, error?: string}
 */
function projectCRUDDelete(projectId) {}

/**
 * Generate unique project name for duplicates
 * @param {string} baseName - Original project name
 * @returns {string} - Unique name (e.g., "Project (Copy)", "Project (Copy 2)")
 */
function projectCRUDGenerateUniqueName(baseName) {}
```

**Dependencies**:
- **Internal**: validateProjectName() (Business Logic Layer), saveProjects() (Data Access Layer)
- **External**: None

**Independent Test Strategy**:
- Mock projects array with test data
- Call projectCRUDEdit() with valid/invalid names, verify updates and error handling
- Call projectCRUDDuplicate() on project with iterations, verify deep copy
- Call projectCRUDDelete(), verify confirmation dialog and data removal
- Verify no direct DOM manipulation or storage calls within functions

**Location**: index.html, Business Logic Layer section (after validateProjectName, before render functions)

---

### Module 2: Command Library Module (commandLibrary*)
### 模块 2：命令库模块

**Purpose**: Manage command library CRUD operations, search, copy, and drag-drop reordering
**用途**：管理命令库的增删改查操作、搜索、复制和拖放排序

**Interface**:
```javascript
/**
 * Add new command to library
 * @param {string} label - Command label (required)
 * @param {string} text - Command text (required)
 * @param {string} category - Category (optional)
 * @returns {Object} - {success: boolean, commandId?: string, error?: string}
 */
function commandLibraryAdd(label, text, category = '') {}

/**
 * Edit existing command
 * @param {string} commandId - Command ID
 * @param {string} newLabel - New label
 * @param {string} newText - New text
 * @param {string} newCategory - New category
 * @returns {Object} - {success: boolean, error?: string}
 */
function commandLibraryEdit(commandId, newLabel, newText, newCategory) {}

/**
 * Delete command
 * @param {string} commandId - Command ID
 * @returns {Object} - {success: boolean, error?: string}
 */
function commandLibraryDelete(commandId) {}

/**
 * Copy command text to clipboard
 * @param {string} commandText - Text to copy
 * @returns {Promise<Object>} - {success: boolean, error?: string}
 */
async function commandLibraryCopy(commandText) {}

/**
 * Search/filter commands by term
 * @param {string} searchTerm - Search term
 * @returns {Array<Command>} - Filtered commands
 */
function commandLibrarySearch(searchTerm) {}

/**
 * Reorder command (drag-drop)
 * @param {string} commandId - Command ID
 * @param {number} newOrder - New order index
 * @returns {Object} - {success: boolean, error?: string}
 */
function commandLibraryReorder(commandId, newOrder) {}

/**
 * Seed default Spec Kit commands on first use
 * @returns {Array<Command>} - Default commands
 */
function commandLibrarySeedDefaults() {}
```

**Dependencies**:
- **Internal**: validateCommandText(), validateCommandLabel() (Business Logic), saveCommands(), loadCommands() (Data Access)
- **External**: Clipboard API (navigator.clipboard.writeText)

**Independent Test Strategy**:
- Mock commands array with test data
- Test CRUD operations with valid/invalid inputs
- Test search with various terms (label, text, category)
- Test copy functionality (may need manual verification for clipboard)
- Test reordering logic with different order values
- Verify seedDefaults() creates 8-12 default commands on empty state

**Location**: index.html, Business Logic Layer section (after validate functions, before render functions)

---

### Module 3: Progress Calculation Module (progressCalculation*)
### 模块 3：进度计算模块

**Purpose**: Calculate project progress metrics (iteration count, completion percentage, last updated time)
**用途**：计算项目进度指标（迭代计数、完成百分比、最后更新时间）

**Interface**:
```javascript
/**
 * Get total iteration count for project
 * @param {Object} project - Project object
 * @returns {number} - Iteration count
 */
function progressCalculationGetIterationCount(project) {}

/**
 * Calculate completion percentage
 * @param {Object} project - Project object
 * @returns {number} - Completion percentage (0-100)
 */
function progressCalculationGetCompletionPercentage(project) {}

/**
 * Get last updated timestamp
 * @param {Object} project - Project object
 * @returns {string} - ISO8601 timestamp or empty string
 */
function progressCalculationGetLastUpdated(project) {}

/**
 * Format timestamp as relative time
 * @param {string} isoTimestamp - ISO8601 timestamp
 * @returns {string} - Relative time (e.g., "2 hours ago") or absolute date
 */
function progressCalculationFormatRelativeTime(isoTimestamp) {}

/**
 * Check if iteration is complete
 * @param {Object} iteration - Iteration object
 * @returns {boolean} - True if all required steps completed
 */
function progressCalculationIsIterationComplete(iteration) {}
```

**Dependencies**:
- **Internal**: None (pure calculation functions)
- **External**: Date API (Date.now(), new Date())

**Independent Test Strategy**:
- Create test projects with various iteration counts and completion states
- Verify getIterationCount() returns correct count
- Verify getCompletionPercentage() handles edge cases:
  - 0 iterations (returns 0 or handles gracefully)
  - All complete (returns 100)
  - Partial complete (correct percentage, rounded)
- Verify formatRelativeTime() switches to absolute date after 30 days
- Verify isIterationComplete() checks all required steps in completedSteps

**Location**: index.html, Business Logic Layer section (after data access functions, before render functions)

---

### Module 4: Validation Module (validate*)
### 模块 4：验证模块

**Purpose**: Validate user inputs for projects and commands
**用途**：验证项目和命令的用户输入

**Interface**:
```javascript
/**
 * Validate project name
 * @param {string} name - Project name to validate
 * @returns {Object} - {valid: boolean, error?: string}
 */
function validateProjectName(name) {}

/**
 * Validate command label
 * @param {string} label - Command label to validate
 * @returns {Object} - {valid: boolean, error?: string}
 */
function validateCommandLabel(label) {}

/**
 * Validate command text
 * @param {string} text - Command text to validate
 * @returns {Object} - {valid: boolean, error?: string}
 */
function validateCommandText(text) {}
```

**Dependencies**:
- **Internal**: None (pure validation logic)
- **External**: None

**Independent Test Strategy**:
- Test validateProjectName() with:
  - Empty string (should fail)
  - Whitespace only (should fail)
  - Valid names (should pass)
  - Very long names (edge case)
- Test validateCommandLabel() with similar cases
- Test validateCommandText() with:
  - Empty string (should fail)
  - Valid command text (should pass)
- Verify functions return validation objects, not throw errors

**Location**: index.html, Business Logic Layer section (before other business logic functions)

---

### Module 5: Presentation Module (render*)
### 模块 5：展示模块

**Purpose**: Render UI components and update DOM based on application state
**用途**：渲染 UI 组件并根据应用状态更新 DOM

**Interface**:
```javascript
/**
 * Render project sidebar with progress indicators
 * @returns {void}
 */
function renderProjectSidebar() {}

/**
 * Render Command Library tab content
 * @returns {void}
 */
function renderCommandLibrary() {}

/**
 * Render project detail view
 * @param {string} projectId - Project ID to display
 * @returns {void}
 */
function renderProjectDetail(projectId) {}

/**
 * Show toast notification
 * @param {string} message - Message text
 * @param {string} type - 'success' | 'error' | 'warning' | 'info'
 * @returns {void}
 */
function showToast(message, type) {}
```

**Dependencies**:
- **Internal**: progressCalculationGetIterationCount(), progressCalculationGetCompletionPercentage(), progressCalculationFormatRelativeTime() (Business Logic)
- **External**: DOM API (document.getElementById, innerHTML, etc.)

**Independent Test Strategy**:
- Create test projects with various states
- Call renderProjectSidebar() and verify DOM updates:
  - Iteration counts displayed
  - Completion percentages displayed
  - Last updated timestamps displayed
  - Clickable project items
- Call renderCommandLibrary() and verify:
  - Commands grouped by category
  - Search input present
  - Copy buttons functional
- Verify functions do not directly call localStorage or Firebase

**Location**: index.html, Presentation Layer section (after business logic functions, before event handlers)

---

### Module Dependency Graph
### 模块依赖关系图

```
Event Handlers (handle*, on*)
      ↓ calls
Presentation Module (render*)
      ↓ calls
Progress Calculation Module (progressCalculation*)
      ↓ calls
Validation Module (validate*)
      ↓ calls
Data Access Layer (save*, load*, delete*)

Project CRUD Module (projectCRUD*)
      ↓ calls
Validation Module (validate*)
      ↓ calls
Data Access Layer (save*, load*)

Command Library Module (commandLibrary*)
      ↓ calls
Validation Module (validate*)
      ↓ calls
Data Access Layer (saveCommands, loadCommands)

(No circular dependencies - all flows are unidirectional)
```

**Enforcement**: Function naming conventions strictly enforced during code review. JSDoc comments required for all public functions. No circular dependencies allowed.

**强制执行**：代码审查期间严格执行函数命名约定。所有公共函数都需要 JSDoc 注释。不允许循环依赖。

## Layers of Concerns Design
## 关注点分层设计
*(新增 / NEW - Constitution Principle VII)*

### Data Access Layer (数据访问层)

**Responsibilities**:
- Persist project data to LocalStorage (primary offline storage)
- Sync project data to Firebase Realtime Database (optional cloud sync)
- Persist command library data to LocalStorage
- Sync command library data to Firebase (if user authenticated)
- Handle offline queue for Firebase operations
- Migrate legacy localStorage data to Firebase

**Components**:
- **Functions**: `saveProjects()`, `loadProjects()`, `saveCommands()`, `loadCommands()`, `saveProjectToFirebase()`, `loadProjectsFromFirebase()`, `updateProjectInFirebase()`, `deleteProjectFromFirebase()`, `saveCommandsToFirebase()`, `loadCommandsFromFirebase()`
- **External Dependencies**: LocalStorage API, Firebase Realtime Database SDK v12.4.0
- **Data Contracts**:
  - LocalStorage keys: `speckit_projects`, `speckit_commands`, `firebase_offline_queue`
  - Firebase paths: `users/{userId}/projects/{projectId}`, `users/{userId}/commands/{commandId}`

**Prohibited**:
- ❌ MUST NOT manipulate DOM (no document.getElementById, no innerHTML updates)
- ❌ MUST NOT contain business logic (no validation, no calculation)
- ❌ MUST NOT be called by Presentation Layer directly (only via Business Logic or Event Handlers)

**Example Interface**:
```javascript
/**
 * Save all projects to LocalStorage
 * @returns {void}
 */
function saveProjects() {
    localStorage.setItem('speckit_projects', JSON.stringify(projects));
}

/**
 * Load projects from LocalStorage
 * @returns {Array<Project>}
 */
function loadProjects() {
    const saved = localStorage.getItem('speckit_projects');
    return saved ? JSON.parse(saved) : [];
}

/**
 * Save commands to LocalStorage
 * @returns {void}
 */
function saveCommands() {
    localStorage.setItem('speckit_commands', JSON.stringify(commands));
}

/**
 * Load commands from LocalStorage
 * @returns {Array<Command>}
 */
function loadCommands() {
    const saved = localStorage.getItem('speckit_commands');
    return saved ? JSON.parse(saved) : [];
}
```

---

### Business Logic Layer (业务逻辑层)

**Responsibilities**:
- Validate project names (non-empty, non-whitespace)
- Validate command labels and text (non-empty)
- Calculate iteration count for projects
- Calculate completion percentage (handle division by zero)
- Format relative time strings ("2 hours ago" vs "2024-10-15")
- Determine iteration completion status
- Generate unique duplicate project names
- Deep copy project objects (for duplication)
- Seed default command library entries
- Filter/search commands by term

**Components**:
- **Functions**: `validateProjectName()`, `validateCommandLabel()`, `validateCommandText()`, `progressCalculationGetIterationCount()`, `progressCalculationGetCompletionPercentage()`, `progressCalculationFormatRelativeTime()`, `progressCalculationIsIterationComplete()`, `progressCalculationGetLastUpdated()`, `projectCRUDGenerateUniqueName()`, `commandLibrarySearch()`, `commandLibrarySeedDefaults()`
- **Internal Dependencies**: Data Access Layer only (for reading/writing data after validation)
- **Business Rules**:
  - Project names cannot be empty or whitespace-only
  - Command labels and text cannot be empty
  - Completion percentage = (completed iterations / total iterations × 100), rounded to integer
  - Relative time switches to absolute date after 30 days
  - Iteration is complete when all required steps in completedSteps are true
  - Duplicate names append "(Copy)", "(Copy 2)", etc. until unique

**Prohibited**:
- ❌ MUST NOT manipulate DOM (no document.getElementById, no innerHTML)
- ❌ MUST NOT directly call storage APIs (use Data Access Layer functions)
- ❌ MUST NOT handle user events directly (that's Event Handler responsibility)

**Example Interface**:
```javascript
/**
 * Validate project name
 * @param {string} name - Project name
 * @returns {Object} - {valid: boolean, error?: string}
 */
function validateProjectName(name) {
    if (!name || name.trim() === '') {
        return {valid: false, error: 'Project name cannot be empty'};
    }
    return {valid: true};
}

/**
 * Calculate completion percentage
 * @param {Object} project - Project object
 * @returns {number} - Percentage (0-100)
 */
function progressCalculationGetCompletionPercentage(project) {
    if (!project.iterations || project.iterations.length === 0) {
        return 0; // Handle division by zero
    }

    const completed = project.iterations.filter(iter =>
        progressCalculationIsIterationComplete(iter)
    ).length;

    return Math.round((completed / project.iterations.length) * 100);
}
```

---

### Presentation Layer (展示层)

**Responsibilities**:
- Render project sidebar with progress indicators
- Render Command Library tab with commands grouped by category
- Render project detail views with edit/duplicate/delete buttons
- Display toast notifications for user feedback
- Update DOM based on application state changes
- Handle visual feedback (loading states, empty states, tooltips)
- Switch between tabs (Overview, Projects, Command Library)

**Components**:
- **Functions**: `renderProjectSidebar()`, `renderCommandLibrary()`, `renderProjectDetail()`, `showToast()`, `switchTab()`, `renderProjectList()`, `renderIterationList()`
- **Internal Dependencies**: Business Logic Layer only (calls progressCalculation* and validate* functions, never Data Access directly)
- **UI Framework**: Vanilla JavaScript (no framework)

**Prohibited**:
- ❌ MUST NOT call Data Access Layer directly (no localStorage.getItem, no firebase.set)
- ❌ MUST NOT contain business logic (no validation, no calculation, no data transformation)
- ❌ MUST NOT perform data validation (delegate to Business Logic validate* functions)

**Example Interface**:
```javascript
/**
 * Render project sidebar with progress indicators
 * @returns {void}
 */
function renderProjectSidebar() {
    const sidebarContainer = document.getElementById('project-sidebar');

    const html = projects.map(project => {
        // Call Business Logic Layer for metrics (not Data Access Layer)
        const iterationCount = progressCalculationGetIterationCount(project);
        const completionPercentage = progressCalculationGetCompletionPercentage(project);
        const lastUpdated = progressCalculationFormatRelativeTime(
            progressCalculationGetLastUpdated(project)
        );

        return `
            <div class="sidebar-project" onclick="handleProjectClick('${project.id}')">
                <h3>${project.name}</h3>
                <div class="progress-info">
                    <span>${iterationCount} iterations</span>
                    <span>${completionPercentage}% complete</span>
                    <span>Last updated: ${lastUpdated}</span>
                </div>
            </div>
        `;
    }).join('');

    sidebarContainer.innerHTML = html;
}
```

---

### Layer Communication Rules
### 层通信规则

**Allowed Call Chains** (unidirectional):
**允许的调用链**（单向）：
```
Presentation Layer (render*)
      ↓ calls
Business Logic Layer (validate*, calculate*, process*)
      ↓ calls
Data Access Layer (save*, load*, delete*)
```

**Prohibited** (reverse calls):
**禁止**（反向调用）：
```
Data Access Layer ─X→ Business Logic Layer
Data Access Layer ─X→ Presentation Layer
Business Logic Layer ─X→ Presentation Layer
```

**Event Handler Bridge** (orchestration):
**事件处理器桥接**（编排）：
```
User Event (button click, form submit)
      ↓
Event Handler (handle*, on*)
      ↓ orchestrates
{
    1. Call Business Logic Layer (validate input)
    2. Call Data Access Layer (save/load data) if validation passes
    3. Call Presentation Layer (re-render UI with new state)
}
```

**Example Event Handler**:
```javascript
/**
 * Handle edit project button click
 * @param {string} projectId - Project ID
 */
function handleEditProject(projectId) {
    const newName = prompt('Enter new project name:');
    const newDescription = prompt('Enter new description (optional):');

    // Step 1: Validate (Business Logic Layer)
    const validation = validateProjectName(newName);
    if (!validation.valid) {
        showToast(validation.error, 'error');
        return;
    }

    // Step 2: Update data (Business Logic + Data Access Layer)
    const result = projectCRUDEdit(projectId, newName, newDescription);
    if (!result.success) {
        showToast(result.error, 'error');
        return;
    }

    // Step 3: Re-render UI (Presentation Layer)
    renderProjectSidebar();
    renderProjectDetail(projectId);
    showToast('Project updated successfully', 'success');
}
```

### Code Organization Order in index.html
### index.html 中的代码组织顺序

```html
<script>
    // ===========================
    // Part 1: Constants and Configuration
    // ===========================
    const firebaseConfig = {...};
    let projects = [];
    let commands = [];
    let currentUser = null;

    // ===========================
    // Part 2: Data Access Layer
    // ===========================
    function saveProjects() {...}
    function loadProjects() {...}
    function saveCommands() {...}
    function loadCommands() {...}
    function saveProjectToFirebase(userId, projectId, projectData) {...}
    function loadProjectsFromFirebase(userId) {...}

    // ===========================
    // Part 3: Business Logic Layer
    // ===========================
    // Validation functions
    function validateProjectName(name) {...}
    function validateCommandLabel(label) {...}
    function validateCommandText(text) {...}

    // Progress calculation functions
    function progressCalculationGetIterationCount(project) {...}
    function progressCalculationGetCompletionPercentage(project) {...}
    function progressCalculationFormatRelativeTime(timestamp) {...}

    // Project CRUD functions
    function projectCRUDEdit(projectId, newName, newDescription) {...}
    function projectCRUDDuplicate(projectId) {...}
    function projectCRUDDelete(projectId) {...}
    function projectCRUDGenerateUniqueName(baseName) {...}

    // Command Library functions
    function commandLibraryAdd(label, text, category) {...}
    function commandLibraryEdit(commandId, newLabel, newText, newCategory) {...}
    function commandLibraryDelete(commandId) {...}
    async function commandLibraryCopy(commandText) {...}
    function commandLibrarySearch(searchTerm) {...}
    function commandLibrarySeedDefaults() {...}

    // ===========================
    // Part 4: Presentation Layer
    // ===========================
    function renderProjectSidebar() {...}
    function renderCommandLibrary() {...}
    function renderProjectDetail(projectId) {...}
    function showToast(message, type) {...}
    function switchTab(tabName) {...}

    // ===========================
    // Part 5: Event Handlers
    // ===========================
    function handleEditProject(projectId) {...}
    function handleDuplicateProject(projectId) {...}
    function handleDeleteProject(projectId) {...}
    function handleAddCommand() {...}
    function handleCopyCommand(commandId) {...}
    function handleSearchCommands(searchTerm) {...}
    function handleProjectClick(projectId) {...}

    // ===========================
    // Part 6: Initialization
    // ===========================
    async function initializeApp() {
        await initializeFirebase();
        loadProjects();
        loadCommands();
        renderProjectSidebar();
    }

    initializeApp();
</script>
```

**Code Review Checklist**:
**代码审查清单**：
- [ ] No `render*` functions call `localStorage` or `firebase` directly
- [ ] No `save*` functions call `document.getElementById()`
- [ ] No `validate*` functions manipulate DOM
- [ ] Event handlers properly orchestrate layers in correct order (validate → save → render)
- [ ] All functions follow naming conventions (render*, validate*, save*, handle*)
- [ ] Function length < 50 lines, nesting depth < 3 levels
- [ ] JSDoc comments present for all public functions
