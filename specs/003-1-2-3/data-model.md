# Data Model: Enhanced Project Management and Command Library
# 数据模型：增强的项目管理和命令库

**Feature**: 003-1-2-3
**Date**: 2025-10-16
**Status**: Final

## Overview
## 概述

This document defines the data entities and their relationships for the Enhanced Project Management and Command Library feature. All entities are stored as plain JavaScript objects serialized to JSON in LocalStorage (primary) and Firebase Realtime Database (optional cloud sync).

本文档定义了增强的项目管理和命令库功能的数据实体及其关系。所有实体都存储为序列化为 JSON 的普通 JavaScript 对象，存储在 LocalStorage（主要）和 Firebase 实时数据库（可选云同步）中。

## Entity Definitions
## 实体定义

### 1. Project (Enhanced)
### 1. 项目（增强）

**Purpose**: Represents a Spec Kit project with extended metadata
**用途**：表示具有扩展元数据的 Spec Kit 项目

**Changes from existing model**:
**与现有模型的变化**：
- ✅ Added `description` field (optional)
- ✅ Added `updatedAt` field (required)
- ✅ Existing fields remain unchanged for backward compatibility

**Schema**:
```typescript
interface Project {
    id: string;              // Unique identifier (e.g., 'project_1697845200000')
    name: string;            // Project name (required, non-empty, max 100 chars)
    description?: string;    // NEW: Optional project description (max 500 chars)
    createdAt: string;       // ISO8601 timestamp (e.g., '2024-10-16T10:30:00.000Z')
    updatedAt: string;       // NEW: ISO8601 timestamp of last modification
    iterations: Iteration[]; // Array of iteration objects
}
```

**Field Constraints**:
| Field | Type | Required | Constraints | Default |
|-------|------|----------|-------------|---------|
| id | string | Yes | Format: `'project_' + timestamp`, must be unique | Auto-generated |
| name | string | Yes | Non-empty, max 100 chars, whitespace trimmed | None |
| description | string | No | Max 500 chars | Empty string `''` |
| createdAt | string | Yes | ISO8601 format | Auto-generated |
| updatedAt | string | Yes | ISO8601 format, >= createdAt | Auto-generated |
| iterations | Array | Yes | Can be empty array | `[]` |

**Validation Rules**:
**验证规则**：
1. `name` cannot be empty string or contain only whitespace
   `name` 不能为空字符串或仅包含空格
2. `name` must be unique within user's project list (case-sensitive)
   `name` 在用户的项目列表中必须唯一（区分大小写）
3. `description` is optional, empty string if not provided
   `description` 是可选的，如果未提供则为空字符串
4. `updatedAt` must be set whenever project or any iteration is modified
   每当修改项目或任何迭代时都必须设置 `updatedAt`
5. `id` format must match pattern: `/^project_\d+$/`
   `id` 格式必须匹配模式：`/^project_\d+$/`

**Example**:
```javascript
{
    id: 'project_1697845200000',
    name: 'E-commerce Platform Redesign',
    description: 'Redesigning the checkout flow to improve conversion rates',
    createdAt: '2024-10-16T10:30:00.000Z',
    updatedAt: '2024-10-16T14:45:00.000Z',
    iterations: [...]
}
```

---

### 2. Iteration (Unchanged)
### 2. 迭代（未更改）

**Purpose**: Represents a development cycle within a project
**用途**：表示项目中的开发周期

**Schema**:
```typescript
interface Iteration {
    id: string;              // Unique identifier
    name: string;            // Iteration name
    description: string;     // Iteration description
    createdAt: string;       // ISO8601 timestamp
    completedSteps: {        // Map of step completion status
        specify?: boolean;   // Spec created
        clarify?: boolean;   // Clarified
        plan?: boolean;      // Plan created
        tasks?: boolean;     // Tasks created
        implement?: boolean; // Implementation complete
    };
    inputs: {                // Step inputs
        [key: string]: any;  // Dynamic inputs per step
    };
    notes: {                 // Step notes
        [key: string]: string; // Notes per step
    };
    currentCycle: string;    // Current cycle color marker
    cycleHistory: {          // Historical cycle data
        [key: string]: any;
    };
}
```

**No changes required for this entity**. Existing iteration structure supports all required functionality.

**此实体无需更改**。现有迭代结构支持所有必需的功能。

---

### 3. Command (NEW)
### 3. 命令（新增）

**Purpose**: Represents a saved command in the Command Library
**用途**：表示命令库中保存的命令

**Schema**:
```typescript
interface Command {
    id: string;              // Unique identifier (e.g., 'cmd_1697845200000')
    label: string;           // Human-readable command name (required, max 100 chars)
    text: string;            // Actual command text to copy (required, max 1000 chars)
    category: string;        // Optional category for grouping (max 50 chars)
    createdAt: string;       // ISO8601 timestamp
    order: number;           // Custom sort order (0-indexed, for drag-drop)
}
```

**Field Constraints**:
| Field | Type | Required | Constraints | Default |
|-------|------|----------|-------------|---------|
| id | string | Yes | Format: `'cmd_' + timestamp`, must be unique | Auto-generated |
| label | string | Yes | Non-empty, max 100 chars, whitespace trimmed | None |
| text | string | Yes | Non-empty, max 1000 chars | None |
| category | string | No | Max 50 chars | Empty string `''` |
| createdAt | string | Yes | ISO8601 format | Auto-generated |
| order | number | Yes | Non-negative integer | Auto-assigned |

**Validation Rules**:
**验证规则**：
1. `label` cannot be empty string or contain only whitespace
   `label` 不能为空字符串或仅包含空格
2. `text` cannot be empty string
   `text` 不能为空字符串
3. `category` is optional, empty string if not provided
   `category` 是可选的，如果未提供则为空字符串
4. `order` is auto-assigned sequentially on creation, updated on drag-drop
   `order` 在创建时自动按顺序分配，在拖放时更新
5. `id` format must match pattern: `/^cmd_\d+$/`
   `id` 格式必须匹配模式：`/^cmd_\d+$/`

**Category Examples**:
- "Spec Kit" - Spec Kit workflow commands
- "Git" - Git version control commands
- "Docker" - Docker container commands
- "NPM" - Node package manager commands
- "" (empty) - Uncategorized commands

**Example**:
```javascript
{
    id: 'cmd_1697845200000',
    label: 'Spec Kit: Create Feature Spec',
    text: '/speckit.specify Enhanced project management with CRUD operations',
    category: 'Spec Kit',
    createdAt: '2024-10-16T10:30:00.000Z',
    order: 0
}
```

---

## State Transitions
## 状态转换

### Project Lifecycle
### 项目生命周期

```
[Create] → NEW PROJECT (updatedAt = createdAt)
   ↓
[Edit Name/Description] → UPDATED (updatedAt = now)
   ↓
[Add/Edit/Delete Iteration] → UPDATED (updatedAt = now)
   ↓
[Duplicate] → NEW PROJECT (new ID, updatedAt = createdAt)
   ↓
[Delete] → REMOVED (permanent deletion)
```

### Iteration Completion Tracking
### 迭代完成跟踪

An iteration is considered **complete** when:
迭代被认为**完成**当：

```javascript
completedSteps.specify === true &&
completedSteps.plan === true &&
completedSteps.tasks === true &&
completedSteps.implement === true
```

**Note**: `clarify` step is optional and not required for completion.
**注意**：`clarify` 步骤是可选的，完成时不需要。

### Command Library State
### 命令库状态

```
[Empty State] → Auto-seed default commands (10 commands)
   ↓
[Add Command] → NEW COMMAND (order = max(order) + 1)
   ↓
[Edit Command] → UPDATED (order unchanged)
   ↓
[Reorder Command] → REORDERED (order = new position, other orders adjusted)
   ↓
[Delete Command] → REMOVED (orders compacted)
   ↓
[Search/Filter] → FILTERED VIEW (no state change)
```

---

## Storage Strategy
## 存储策略

### LocalStorage (Primary)
### LocalStorage（主要）

**Keys**:
- `speckit_projects`: Array of Project objects (enhanced with new fields)
- `speckit_commands`: Array of Command objects (new)
- `firebase_offline_queue`: Array of offline Firebase operations

**Size Limits**:
- Total LocalStorage: 5MB (browser limit)
- Estimated size per project: ~5-10KB (depends on iteration count)
- Estimated size per command: ~0.5-1KB
- Estimated max capacity: ~500 projects OR ~5000 commands (whichever reached first)

**Serialization**:
```javascript
// Save
localStorage.setItem('speckit_projects', JSON.stringify(projects));
localStorage.setItem('speckit_commands', JSON.stringify(commands));

// Load
const projects = JSON.parse(localStorage.getItem('speckit_projects') || '[]');
const commands = JSON.parse(localStorage.getItem('speckit_commands') || '[]');
```

### Firebase Realtime Database (Secondary)
### Firebase 实时数据库（次要）

**Paths**:
- `/users/{userId}/projects/{projectId}`: Individual project object
- `/users/{userId}/commands/{commandId}`: Individual command object

**Sync Strategy**:
1. **Write**: Always save to LocalStorage first (immediate), then Firebase (async if user authenticated)
   **写入**：始终先保存到 LocalStorage（立即），然后 Firebase（如果用户已认证则异步）
2. **Read**: Load from LocalStorage on app init (fast), sync from Firebase in background if authenticated
   **读取**：应用初始化时从 LocalStorage 加载（快速），如果已认证则在后台从 Firebase 同步
3. **Conflict Resolution**: Firebase data takes precedence if user is authenticated and online
   **冲突解决**：如果用户已认证且在线，Firebase 数据优先

---

## Data Migration
## 数据迁移

### Backward Compatibility
### 向后兼容性

**Existing projects without new fields**:
**没有新字段的现有项目**：
```javascript
function migrateProjectSchema(project) {
    // Add missing fields with sensible defaults
    if (!project.description) {
        project.description = '';
    }
    if (!project.updatedAt) {
        // Use createdAt as fallback, or current time if createdAt missing
        project.updatedAt = project.createdAt || new Date().toISOString();
    }
    return project;
}

// Apply migration on load
function loadProjects() {
    const saved = localStorage.getItem('speckit_projects');
    if (saved) {
        projects = JSON.parse(saved).map(migrateProjectSchema);
        saveProjects(); // Save migrated data
    }
}
```

### Default Command Seeding
### 默认命令预设

**On first load of Command Library tab**:
**首次加载命令库标签页时**：
```javascript
function loadCommands() {
    const saved = localStorage.getItem('speckit_commands');
    if (saved) {
        commands = JSON.parse(saved);
    } else {
        // Seed defaults on first use
        commands = commandLibrarySeedDefaults();
        saveCommands();
    }
}
```

---

## Relationships
## 关系

### Project → Iterations (One-to-Many)
### 项目 → 迭代（一对多）

- One project contains multiple iterations (0 to N)
  一个项目包含多个迭代（0 到 N）
- Iterations are embedded within project object (no separate collection)
  迭代嵌入在项目对象中（无单独集合）
- Deleting project deletes all iterations (cascading delete)
  删除项目会删除所有迭代（级联删除）
- Duplicating project duplicates all iterations (deep copy)
  复制项目会复制所有迭代（深拷贝）

### Commands (Independent)
### 命令（独立）

- Commands have no relationships with projects or iterations
  命令与项目或迭代无关系
- Commands are user-specific (stored per authenticated user in Firebase)
  命令是用户特定的（在 Firebase 中按认证用户存储）
- Commands can be reordered independently via drag-drop
  命令可以通过拖放独立重新排序

---

## Validation Logic
## 验证逻辑

### Project Validation
### 项目验证

```javascript
function validateProjectName(name) {
    if (!name || typeof name !== 'string') {
        return {valid: false, error: 'Project name is required'};
    }

    const trimmed = name.trim();
    if (trimmed.length === 0) {
        return {valid: false, error: 'Project name cannot be empty'};
    }

    if (trimmed.length > 100) {
        return {valid: false, error: 'Project name cannot exceed 100 characters'};
    }

    return {valid: true};
}

function validateProjectDescription(description) {
    if (description && description.length > 500) {
        return {valid: false, error: 'Description cannot exceed 500 characters'};
    }
    return {valid: true};
}
```

### Command Validation
### 命令验证

```javascript
function validateCommandLabel(label) {
    if (!label || typeof label !== 'string') {
        return {valid: false, error: 'Command label is required'};
    }

    const trimmed = label.trim();
    if (trimmed.length === 0) {
        return {valid: false, error: 'Command label cannot be empty'};
    }

    if (trimmed.length > 100) {
        return {valid: false, error: 'Label cannot exceed 100 characters'};
    }

    return {valid: true};
}

function validateCommandText(text) {
    if (!text || typeof text !== 'string') {
        return {valid: false, error: 'Command text is required'};
    }

    if (text.trim().length === 0) {
        return {valid: false, error: 'Command text cannot be empty'};
    }

    if (text.length > 1000) {
        return {valid: false, error: 'Command text cannot exceed 1000 characters'};
    }

    return {valid: true};
}

function validateCommandCategory(category) {
    if (category && category.length > 50) {
        return {valid: false, error: 'Category cannot exceed 50 characters'};
    }
    return {valid: true};
}
```

---

## Data Integrity Rules
## 数据完整性规则

### Referential Integrity
### 引用完整性

1. **Project IDs must be unique** within user's project list
   **项目 ID 必须唯一**在用户的项目列表中
2. **Iteration IDs must be unique** within parent project
   **迭代 ID 必须唯一**在父项目中
3. **Command IDs must be unique** within user's command library
   **命令 ID 必须唯一**在用户的命令库中

### Cascading Operations
### 级联操作

1. **Delete Project** → Delete all iterations (no orphaned iterations)
   **删除项目** → 删除所有迭代（无孤立迭代）
2. **Duplicate Project** → Duplicate all iterations with new IDs
   **复制项目** → 使用新 ID 复制所有迭代
3. **Edit Project** → Update `updatedAt` timestamp
   **编辑项目** → 更新 `updatedAt` 时间戳

### Timestamp Consistency
### 时间戳一致性

1. `createdAt` is set once on creation and never modified
   `createdAt` 在创建时设置一次，永不修改
2. `updatedAt` is updated on every edit/add/delete operation
   `updatedAt` 在每次编辑/添加/删除操作时更新
3. `updatedAt` >= `createdAt` (always true)
   `updatedAt` >= `createdAt`（始终为真）

---

## Query Patterns
## 查询模式

### Get Project by ID
### 按 ID 获取项目

```javascript
const project = projects.find(p => p.id === projectId);
```

### Get Projects Sorted by Last Updated
### 按最后更新排序获取项目

```javascript
const sortedProjects = [...projects].sort((a, b) =>
    new Date(b.updatedAt) - new Date(a.updatedAt)
);
```

### Calculate Iteration Count
### 计算迭代计数

```javascript
const iterationCount = project.iterations?.length || 0;
```

### Calculate Completion Percentage
### 计算完成百分比

```javascript
const completedCount = project.iterations.filter(iter =>
    progressCalculationIsIterationComplete(iter)
).length;
const percentage = project.iterations.length > 0
    ? Math.round((completedCount / project.iterations.length) * 100)
    : 0;
```

### Search Commands
### 搜索命令

```javascript
const searchTerm = 'git';
const filteredCommands = commands.filter(cmd =>
    cmd.label.toLowerCase().includes(searchTerm.toLowerCase()) ||
    cmd.text.toLowerCase().includes(searchTerm.toLowerCase()) ||
    cmd.category.toLowerCase().includes(searchTerm.toLowerCase())
);
```

### Get Commands by Category
### 按类别获取命令

```javascript
const categoryMap = commands.reduce((map, cmd) => {
    const category = cmd.category || 'Uncategorized';
    if (!map[category]) map[category] = [];
    map[category].push(cmd);
    return map;
}, {});

// Example: Get all "Spec Kit" commands
const specKitCommands = categoryMap['Spec Kit'] || [];
```

### Get Commands Sorted by Order
### 按顺序排序获取命令

```javascript
const sortedCommands = [...commands].sort((a, b) => a.order - b.order);
```

---

## Summary
## 总结

This data model extends the existing Spec Kit data structure with minimal changes to support three new feature sets:

1. **Enhanced Project Management**: Added `description` and `updatedAt` fields to Project entity
2. **Progress Dashboard**: Reused existing iteration structure with computed properties
3. **Command Library**: Introduced new Command entity with full CRUD support

All changes maintain backward compatibility with existing projects. Migration logic will automatically add missing fields with sensible defaults.

此数据模型通过最小更改扩展了现有的 Spec Kit 数据结构，以支持三个新功能集：

1. **增强的项目管理**：为 Project 实体添加了 `description` 和 `updatedAt` 字段
2. **进度仪表板**：重用现有迭代结构与计算属性
3. **命令库**：引入新的 Command 实体，支持完整的 CRUD

所有更改都保持与现有项目的向后兼容性。迁移逻辑将自动添加缺失字段，使用合理的默认值。
