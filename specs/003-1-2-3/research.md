# Research: Enhanced Project Management and Command Library
# 研究：增强的项目管理和命令库

**Feature**: 003-1-2-3
**Date**: 2025-10-16
**Status**: Complete

## Overview
## 概述

This research document consolidates technical decisions for implementing three major enhancements to the Spec Kit project management panel. Since the feature specification requested using "当前技术栈" (current technology stack), no new technologies or dependencies need to be evaluated. All implementation will use the existing vanilla JavaScript ES6+ single-file architecture.

本研究文档整合了为 Spec Kit 项目管理面板实施三大增强功能的技术决策。由于功能规格要求使用"当前技术栈"，无需评估新技术或依赖项。所有实现都将使用现有的原生 JavaScript ES6+ 单文件架构。

## Research Questions
## 研究问题

### Question 1: How to implement deep copy for project duplication?
### 问题 1：如何实现项目复制的深拷贝？

**Decision**: Use `JSON.parse(JSON.stringify(object))` for deep copying
**决策**：使用 `JSON.parse(JSON.stringify(object))` 进行深拷贝

**Rationale**:
- **理由**：
- Simple and works with plain objects (projects and iterations contain no circular references, functions, or special objects)
- 简单且适用于普通对象（项目和迭代不包含循环引用、函数或特殊对象）
- No external dependencies required
- 不需要外部依赖
- Sufficient for data structures used in Spec Kit (plain JSON objects)
- 足以满足 Spec Kit 中使用的数据结构（普通 JSON 对象）
- Performance acceptable for projects with up to 50 iterations
- 对于最多 50 次迭代的项目，性能可接受

**Alternatives Considered**:
**考虑的替代方案**：
1. ~~Structured Clone API~~ - Newer API, may have browser compatibility concerns with Safari 14
   ~~结构化克隆 API~~ - 较新的 API，Safari 14 可能存在浏览器兼容性问题
2. ~~Manual recursive copy~~ - More code, unnecessary complexity for plain objects
   ~~手动递归复制~~ - 代码更多，对于普通对象来说复杂度不必要
3. ~~Lodash cloneDeep~~ - Violates zero-dependency constraint
   ~~Lodash cloneDeep~~ - 违反零依赖约束

**Implementation Note**:
```javascript
function projectCRUDDuplicate(projectId) {
    const project = projects.find(p => p.id === projectId);
    if (!project) {
        return {success: false, error: 'Project not found'};
    }

    // Deep copy using JSON
    const copiedProject = JSON.parse(JSON.stringify(project));

    // Generate new IDs
    copiedProject.id = 'project_' + Date.now();
    copiedProject.name = projectCRUDGenerateUniqueName(project.name);
    copiedProject.createdAt = new Date().toISOString();
    copiedProject.updatedAt = new Date().toISOString();

    // Generate new IDs for all iterations
    copiedProject.iterations = copiedProject.iterations.map((iter, index) => ({
        ...iter,
        id: `${copiedProject.id}_iteration_${Date.now()}_${index}`
    }));

    projects.push(copiedProject);
    saveProjects();

    return {success: true, newProjectId: copiedProject.id};
}
```

---

### Question 2: How to implement clipboard copy functionality with fallback?
### 问题 2：如何实现带有后备方案的剪贴板复制功能？

**Decision**: Use Clipboard API with textarea fallback for older browsers
**决策**：使用剪贴板 API，为旧浏览器提供 textarea 后备方案

**Rationale**:
- **理由**：
- Clipboard API (`navigator.clipboard.writeText`) is supported in Chrome 90+, Firefox 88+, Safari 14+, Edge 90+
- 剪贴板 API（`navigator.clipboard.writeText`）在 Chrome 90+、Firefox 88+、Safari 14+、Edge 90+ 中受支持
- Provides async/await interface for clean error handling
- 提供 async/await 接口以实现清晰的错误处理
- Fallback using hidden textarea ensures compatibility if API unavailable
- 使用隐藏 textarea 的后备方案确保 API 不可用时的兼容性

**Alternatives Considered**:
**考虑的替代方案**：
1. ~~execCommand('copy')~~ - Deprecated, not recommended for new code
   ~~execCommand('copy')~~ - 已弃用，不建议用于新代码
2. ~~Always use textarea method~~ - Works but less modern, doesn't provide async error handling
   ~~始终使用 textarea 方法~~ - 有效但不够现代，不提供异步错误处理

**Implementation Note**:
```javascript
async function commandLibraryCopy(commandText) {
    try {
        // Try modern Clipboard API first
        if (navigator.clipboard && navigator.clipboard.writeText) {
            await navigator.clipboard.writeText(commandText);
            return {success: true};
        }

        // Fallback for older browsers
        const textarea = document.createElement('textarea');
        textarea.value = commandText;
        textarea.style.position = 'fixed';
        textarea.style.opacity = '0';
        document.body.appendChild(textarea);
        textarea.select();
        const success = document.execCommand('copy');
        document.body.removeChild(textarea);

        if (success) {
            return {success: true};
        } else {
            return {success: false, error: 'Copy failed'};
        }
    } catch (error) {
        return {success: false, error: error.message};
    }
}
```

---

### Question 3: How to calculate relative time ("2 hours ago") vs absolute date?
### 问题 3：如何计算相对时间（"2 小时前"）与绝对日期？

**Decision**: Use custom relative time formatter with 30-day threshold
**决策**：使用自定义相对时间格式化器，阈值为 30 天

**Rationale**:
- **理由**：
- Intl.RelativeTimeFormat requires manual calculation of time units anyway
- Intl.RelativeTimeFormat 无论如何都需要手动计算时间单位
- Custom implementation allows precise control over threshold (30 days) and format strings
- 自定义实现允许精确控制阈值（30 天）和格式字符串
- Simple implementation, no external dependencies
- 简单实现，无外部依赖
- Bilingual support (Chinese/English) built-in
- 内置双语支持（中文/英文）

**Alternatives Considered**:
**考虑的替代方案**：
1. ~~Moment.js~~ - Violates zero-dependency constraint, 67KB library
   ~~Moment.js~~ - 违反零依赖约束，67KB 库
2. ~~date-fns~~ - Modular but still external dependency
   ~~date-fns~~ - 模块化但仍是外部依赖
3. ~~Always show absolute dates~~ - Less user-friendly for recent updates
   ~~始终显示绝对日期~~ - 对于最近的更新不够用户友好

**Implementation Note**:
```javascript
function progressCalculationFormatRelativeTime(isoTimestamp) {
    if (!isoTimestamp) return 'Never';

    const now = Date.now();
    const timestamp = new Date(isoTimestamp).getTime();
    const diffMs = now - timestamp;
    const diffSeconds = Math.floor(diffMs / 1000);
    const diffMinutes = Math.floor(diffSeconds / 60);
    const diffHours = Math.floor(diffMinutes / 60);
    const diffDays = Math.floor(diffHours / 24);

    // After 30 days, switch to absolute date
    if (diffDays > 30) {
        return new Date(isoTimestamp).toLocaleDateString('zh-CN', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
        });
    }

    // Relative time formatting
    if (diffSeconds < 60) return '刚刚 (Just now)';
    if (diffMinutes < 60) return `${diffMinutes} 分钟前 (${diffMinutes} minutes ago)`;
    if (diffHours < 24) return `${diffHours} 小时前 (${diffHours} hours ago)`;
    return `${diffDays} 天前 (${diffDays} days ago)`;
}
```

---

### Question 4: How to determine iteration completion status?
### 问题 4：如何确定迭代完成状态？

**Decision**: Check if all required steps in completedSteps object are true
**决策**：检查 completedSteps 对象中的所有必需步骤是否为 true

**Rationale**:
- **理由**：
- Aligns with existing Spec Kit data model (iterations already have completedSteps)
- 与现有 Spec Kit 数据模型对齐（迭代已经有 completedSteps）
- Required steps defined by Spec Kit workflow: specify, clarify, plan, tasks, implement
- 必需步骤由 Spec Kit 工作流定义：specify、clarify、plan、tasks、implement
- Simple boolean check, no complex logic required
- 简单的布尔检查，不需要复杂的逻辑

**Alternatives Considered**:
**考虑的替代方案**：
1. ~~Check for presence of all workflow files~~ - Requires file system access, not applicable to browser environment
   ~~检查所有工作流文件的存在~~ - 需要文件系统访问，不适用于浏览器环境
2. ~~Use explicit "completed" flag~~ - Requires data model changes, doesn't reflect actual step completion
   ~~使用明确的"已完成"标志~~ - 需要数据模型更改，不反映实际步骤完成情况

**Implementation Note**:
```javascript
function progressCalculationIsIterationComplete(iteration) {
    if (!iteration || !iteration.completedSteps) {
        return false;
    }

    // Define required steps for Spec Kit workflow
    const requiredSteps = ['specify', 'plan', 'tasks', 'implement'];

    // Check if all required steps are completed
    return requiredSteps.every(step =>
        iteration.completedSteps[step] === true
    );
}
```

---

### Question 5: How to handle duplicate project names efficiently?
### 问题 5：如何高效处理重复的项目名称？

**Decision**: Iterative check with counter suffix "(Copy N)"
**决策**：使用计数器后缀"(Copy N)"的迭代检查

**Rationale**:
- **理由**：
- Familiar UX pattern (used by macOS Finder, Windows Explorer, Google Drive)
- 熟悉的用户体验模式（被 macOS Finder、Windows Explorer、Google Drive 使用）
- Simple implementation with linear search (acceptable for < 50 projects)
- 简单的线性搜索实现（对于 < 50 个项目可接受）
- No risk of name collision
- 无名称冲突风险

**Alternatives Considered**:
**考虑的替代方案**：
1. ~~Append timestamp~~ - Less user-friendly, harder to identify duplicates visually
   ~~附加时间戳~~ - 不够用户友好，视觉上更难识别重复项
2. ~~Append random ID~~ - Not user-friendly, violates simplicity principle
   ~~附加随机 ID~~ - 不用户友好，违反简单性原则

**Implementation Note**:
```javascript
function projectCRUDGenerateUniqueName(baseName) {
    // Start with "Project Name (Copy)"
    let candidateName = `${baseName} (Copy)`;
    let counter = 2;

    // Check if name exists
    while (projects.some(p => p.name === candidateName)) {
        candidateName = `${baseName} (Copy ${counter})`;
        counter++;
    }

    return candidateName;
}
```

---

### Question 6: How to implement drag-and-drop reordering for commands?
### 问题 6：如何实现命令的拖放重新排序？

**Decision**: Use HTML5 Drag and Drop API with order field persistence
**决策**：使用 HTML5 拖放 API 并持久化 order 字段

**Rationale**:
- **理由**：
- Native browser API, no external dependencies
- 原生浏览器 API，无外部依赖
- Supported in all target browsers (Chrome 90+, Firefox 88+, Safari 14+, Edge 90+)
- 所有目标浏览器均支持（Chrome 90+、Firefox 88+、Safari 14+、Edge 90+）
- Provides visual feedback during drag operation
- 在拖动操作期间提供视觉反馈
- Simple to implement with `draggable` attribute and event listeners
- 使用 `draggable` 属性和事件监听器易于实现

**Alternatives Considered**:
**考虑的替代方案**：
1. ~~SortableJS library~~ - Violates zero-dependency constraint
   ~~SortableJS 库~~ - 违反零依赖约束
2. ~~Manual mouse event handling~~ - More complex, reinventing the wheel
   ~~手动鼠标事件处理~~ - 更复杂，重新发明轮子
3. ~~Up/Down buttons only~~ - Less intuitive UX for reordering multiple items
   ~~仅上/下按钮~~ - 对于重新排序多个项目的用户体验不够直观

**Implementation Note**:
```javascript
// In renderCommandLibrary(), add draggable attributes
const html = commands
    .sort((a, b) => a.order - b.order) // Sort by order field
    .map((command, index) => `
        <div class="command-item"
             draggable="true"
             ondragstart="handleDragStart(event, '${command.id}')"
             ondragover="handleDragOver(event)"
             ondrop="handleDrop(event, '${command.id}')">
            <span>${command.label}</span>
            <button onclick="handleCopyCommand('${command.id}')">Copy</button>
        </div>
    `).join('');

function handleDragStart(event, commandId) {
    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('text/plain', commandId);
}

function handleDragOver(event) {
    event.preventDefault(); // Allow drop
    event.dataTransfer.dropEffect = 'move';
}

function handleDrop(event, targetCommandId) {
    event.preventDefault();
    const sourceCommandId = event.dataTransfer.getData('text/plain');

    if (sourceCommandId === targetCommandId) return;

    // Reorder commands
    commandLibraryReorder(sourceCommandId, targetCommandId);
    renderCommandLibrary();
}
```

---

### Question 7: What default commands should be seeded in Command Library?
### 问题 7：命令库应预设哪些默认命令？

**Decision**: Seed 10 essential Spec Kit commands on first use
**决策**：首次使用时预设 10 个基本 Spec Kit 命令

**Selected Default Commands**:
**选定的默认命令**：
1. `/speckit.specify [description]` - Create feature specification
2. `/speckit.clarify` - Clarify underspecified areas
3. `/speckit.plan` - Generate implementation plan
4. `/speckit.tasks` - Generate task list
5. `/speckit.implement` - Execute implementation
6. `/speckit.analyze` - Analyze consistency
7. `/speckit.constitution` - Update project constitution
8. `git status` - Check Git status
9. `git add . && git commit -m "message"` - Stage and commit changes
10. `git push origin main` - Push to remote repository

**Rationale**:
- **理由**：
- Covers full Spec Kit workflow (specify → plan → tasks → implement)
- 涵盖完整的 Spec Kit 工作流（specify → plan → tasks → implement）
- Includes most frequently used git commands
- 包括最常用的 git 命令
- Provides immediate value to new users
- 为新用户提供即时价值
- Users can delete unwanted defaults
- 用户可以删除不需要的默认值

**Implementation Note**:
```javascript
function commandLibrarySeedDefaults() {
    return [
        {id: 'cmd_1', label: 'Spec Kit: Specify', text: '/speckit.specify [description]', category: 'Spec Kit', order: 1, createdAt: new Date().toISOString()},
        {id: 'cmd_2', label: 'Spec Kit: Clarify', text: '/speckit.clarify', category: 'Spec Kit', order: 2, createdAt: new Date().toISOString()},
        {id: 'cmd_3', label: 'Spec Kit: Plan', text: '/speckit.plan', category: 'Spec Kit', order: 3, createdAt: new Date().toISOString()},
        {id: 'cmd_4', label: 'Spec Kit: Tasks', text: '/speckit.tasks', category: 'Spec Kit', order: 4, createdAt: new Date().toISOString()},
        {id: 'cmd_5', label: 'Spec Kit: Implement', text: '/speckit.implement', category: 'Spec Kit', order: 5, createdAt: new Date().toISOString()},
        {id: 'cmd_6', label: 'Spec Kit: Analyze', text: '/speckit.analyze', category: 'Spec Kit', order: 6, createdAt: new Date().toISOString()},
        {id: 'cmd_7', label: 'Spec Kit: Constitution', text: '/speckit.constitution', category: 'Spec Kit', order: 7, createdAt: new Date().toISOString()},
        {id: 'cmd_8', label: 'Git: Status', text: 'git status', category: 'Git', order: 8, createdAt: new Date().toISOString()},
        {id: 'cmd_9', label: 'Git: Commit', text: 'git add . && git commit -m "message"', category: 'Git', order: 9, createdAt: new Date().toISOString()},
        {id: 'cmd_10', label: 'Git: Push', text: 'git push origin main', category: 'Git', order: 10, createdAt: new Date().toISOString()}
    ];
}
```

---

## Best Practices
## 最佳实践

### Project CRUD Operations
### 项目增删改查操作

- **Validation First**: Always validate user input before performing operations
  **首先验证**：在执行操作前始终验证用户输入
- **Atomic Operations**: Each CRUD operation should be atomic (succeed or fail completely)
  **原子操作**：每个增删改查操作应该是原子的（完全成功或失败）
- **Confirmation for Destructive Actions**: Always require confirmation for delete operations
  **破坏性操作需确认**：删除操作始终需要确认
- **Update Timestamps**: Set `updatedAt` timestamp on all edit/duplicate operations
  **更新时间戳**：在所有编辑/复制操作中设置 `updatedAt` 时间戳
- **Preserve Data Integrity**: Deep copy must preserve all nested data structures
  **保持数据完整性**：深拷贝必须保留所有嵌套数据结构

### Progress Calculation
### 进度计算

- **Handle Edge Cases**: Always check for division by zero (projects with 0 iterations)
  **处理边界情况**：始终检查除以零（0 次迭代的项目）
- **Consistent Rounding**: Use Math.round() for percentage calculations
  **一致的舍入**：使用 Math.round() 进行百分比计算
- **Performance**: Cache calculation results if called frequently within same render cycle
  **性能**：如果在同一渲染周期内频繁调用，缓存计算结果
- **Time Formatting**: Switch to absolute dates after 30 days for clarity
  **时间格式化**：30 天后切换到绝对日期以提高清晰度

### Command Library
### 命令库

- **Clipboard API Error Handling**: Always provide fallback for older browsers
  **剪贴板 API 错误处理**：始终为旧浏览器提供后备方案
- **Search Performance**: Use case-insensitive string matching with .toLowerCase()
  **搜索性能**：使用 .toLowerCase() 进行不区分大小写的字符串匹配
- **Category Grouping**: Group commands by exact category string match
  **类别分组**：按精确类别字符串匹配对命令进行分组
- **Drag-and-Drop UX**: Provide visual feedback (opacity, cursor) during drag operations
  **拖放用户体验**：在拖动操作期间提供视觉反馈（不透明度、光标）

## Technology Stack Summary
## 技术栈摘要

### Core Technologies (No Changes)
### 核心技术（无变化）

- **Language**: JavaScript ES6+ (Vanilla, no transpilation)
  **语言**：JavaScript ES6+（原生，无转译）
- **Storage**: Browser LocalStorage (primary) + Firebase Realtime Database v12.4.0 (optional sync)
  **存储**：浏览器 LocalStorage（主要）+ Firebase 实时数据库 v12.4.0（可选同步）
- **UI**: Vanilla JavaScript DOM manipulation, no framework
  **UI**：原生 JavaScript DOM 操作，无框架
- **Architecture**: Single-file (index.html) with functional programming patterns
  **架构**：单文件（index.html）采用函数式编程模式

### Browser APIs Used
### 使用的浏览器 API

- **Clipboard API**: `navigator.clipboard.writeText()` for copy functionality
  **剪贴板 API**：`navigator.clipboard.writeText()` 用于复制功能
- **LocalStorage API**: `localStorage.getItem/setItem()` for data persistence
  **LocalStorage API**：`localStorage.getItem/setItem()` 用于数据持久化
- **Date API**: `Date.now()`, `new Date()`, `toISOString()`, `toLocaleDateString()` for timestamps
  **日期 API**：`Date.now()`、`new Date()`、`toISOString()`、`toLocaleDateString()` 用于时间戳
- **HTML5 Drag and Drop API**: `draggable`, `ondragstart`, `ondragover`, `ondrop` events
  **HTML5 拖放 API**：`draggable`、`ondragstart`、`ondragover`、`ondrop` 事件
- **DOM API**: `document.getElementById()`, `innerHTML`, `createElement()`, etc.
  **DOM API**：`document.getElementById()`、`innerHTML`、`createElement()` 等

### Performance Characteristics
### 性能特征

- **Deep Copy (JSON.stringify)**: ~1-2ms for typical project (< 10 iterations)
  **深拷贝（JSON.stringify）**：典型项目（< 10 次迭代）约 1-2ms
- **Progress Calculation**: ~50-100μs per project (array filtering + arithmetic)
  **进度计算**：每个项目约 50-100μs（数组过滤 + 算术）
- **Relative Time Formatting**: ~10-20μs per timestamp (simple arithmetic)
  **相对时间格式化**：每个时间戳约 10-20μs（简单算术）
- **Command Search**: ~1-2ms for 100 commands (linear string matching)
  **命令搜索**：100 个命令约 1-2ms（线性字符串匹配）
- **Clipboard Copy**: ~50-100ms (async operation, includes user permission check)
  **剪贴板复制**：约 50-100ms（异步操作，包括用户权限检查）

## Conclusion
## 结论

All technical decisions have been made based on the existing technology stack ("当前技术栈"). No new dependencies or frameworks are required. All features can be implemented using vanilla JavaScript ES6+ with native browser APIs, maintaining the constitutional principles of simplicity, architectural integrity, and zero external dependencies.

所有技术决策都基于现有技术栈（"当前技术栈"）。不需要新的依赖项或框架。所有功能都可以使用原生 JavaScript ES6+ 和本地浏览器 API 实现，保持简单性、架构完整性和零外部依赖的宪法原则。

**Ready for Phase 1**: Data model design, contract generation, and quickstart documentation.
**准备进入 Phase 1**：数据模型设计、契约生成和快速入门文档。
