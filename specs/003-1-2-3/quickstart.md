# Quickstart: Enhanced Project Management and Command Library
# 快速入门：增强的项目管理和命令库

**Feature**: 003-1-2-3
**Date**: 2025-10-16
**For**: Developers implementing this feature

## Overview
## 概述

This quickstart guide provides a step-by-step implementation roadmap for the Enhanced Project Management and Command Library feature. Follow these steps to implement all three user stories in priority order.

本快速入门指南为增强的项目管理和命令库功能提供分步实施路线图。按照这些步骤按优先级顺序实施所有三个用户故事。

## Prerequisites
## 先决条件

Before starting implementation:
开始实施前：

1. ✅ Read [spec.md](./spec.md) - Understand user requirements
   阅读 [spec.md](./spec.md) - 了解用户需求
2. ✅ Read [plan.md](./plan.md) - Understand technical approach
   阅读 [plan.md](./plan.md) - 了解技术方法
3. ✅ Read [data-model.md](./data-model.md) - Understand data structures
   阅读 [data-model.md](./data-model.md) - 了解数据结构
4. ✅ Verify constitution compliance - All gates passed
   验证宪法合规性 - 所有门禁通过
5. ✅ Local dev environment ready - `./start-server.sh` running
   本地开发环境就绪 - `./start-server.sh` 运行中

## Implementation Workflow
## 实施工作流

### Phase 1: User Story 1 - Enhanced Project CRUD (Priority P1) 🎯

**Goal**: Implement edit, duplicate, delete operations for projects
**目标**：为项目实施编辑、复制、删除操作

#### Step 1.1: Add New Fields to Project Model
#### 步骤 1.1：为项目模型添加新字段

**Location**: index.html, Data Access Layer section
**位置**：index.html，数据访问层部分

1. Extend Project interface in loadProjects():
```javascript
function loadProjects() {
    const saved = localStorage.getItem('speckit_projects');
    if (saved) {
        projects = JSON.parse(saved).map(project => {
            // Migration: Add missing fields
            if (!project.description) project.description = '';
            if (!project.updatedAt) project.updatedAt = project.createdAt || new Date().toISOString();
            return project;
        });
    }
}
```

2. Update saveProjects() to include new fields (no changes needed, JSON.stringify handles all fields)

#### Step 1.2: Implement Validation Functions
#### 步骤 1.2：实施验证函数

**Location**: index.html, Business Logic Layer section (validation functions first)

```javascript
// Add these functions in Business Logic Layer
function validateProjectName(name) {
    if (!name || name.trim() === '') {
        return {valid: false, error: 'Project name cannot be empty'};
    }
    if (name.length > 100) {
        return {valid: false, error: 'Project name cannot exceed 100 characters'};
    }
    return {valid: true};
}
```

#### Step 1.3: Implement Project CRUD Functions
#### 步骤 1.3：实施项目 CRUD 函数

**Location**: index.html, Business Logic Layer section (after validation functions)

Implement in order:
按顺序实施：
1. `projectCRUDGenerateUniqueName()` - Used by duplicate function
2. `projectCRUDEdit()` - Edit project name/description
3. `projectCRUDDuplicate()` - Duplicate with iterations
4. `projectCRUDDelete()` - Delete with confirmation

See [research.md](./research.md) for implementation examples.

#### Step 1.4: Add UI Elements
#### 步骤 1.4：添加 UI 元素

**Location**: index.html, HTML section

Add buttons to project cards:
```html
<div class="project-actions">
    <button onclick="handleEditProject('${project.id}')">Edit</button>
    <button onclick="handleDuplicateProject('${project.id}')">Duplicate</button>
    <button onclick="handleDeleteProject('${project.id}')">Delete</button>
</div>
```

#### Step 1.5: Implement Event Handlers
#### 步骤 1.5：实施事件处理器

**Location**: index.html, Event Handlers section

```javascript
function handleEditProject(projectId) {
    const project = projects.find(p => p.id === projectId);
    const newName = prompt('Enter new project name:', project.name);
    const newDescription = prompt('Enter description (optional):', project.description);

    const validation = validateProjectName(newName);
    if (!validation.valid) {
        showToast(validation.error, 'error');
        return;
    }

    const result = projectCRUDEdit(projectId, newName, newDescription);
    if (result.success) {
        renderProjectSidebar();
        renderProjectDetail(projectId);
        showToast('Project updated', 'success');
    } else {
        showToast(result.error, 'error');
    }
}
```

#### Step 1.6: Test User Story 1
#### 步骤 1.6：测试用户故事 1

Test all acceptance scenarios:
测试所有验收场景：
- [x] Create, edit, duplicate, delete projects
- [x] Validation errors show correctly
- [x] Confirmation dialog appears for delete
- [x] Data persists after page refresh

**Checkpoint**: User Story 1 complete, independently testable
**检查点**：用户故事 1 完成，可独立测试

---

### Phase 2: User Story 2 - Progress Dashboard (Priority P2)

**Goal**: Display iteration count, completion %, last updated in sidebar
**目标**：在侧边栏显示迭代计数、完成百分比、最后更新时间

#### Step 2.1: Implement Progress Calculation Functions
#### 步骤 2.1：实施进度计算函数

**Location**: index.html, Business Logic Layer section

Implement in order:
按顺序实施：
1. `progressCalculationIsIterationComplete()` - Check if iteration done
2. `progressCalculationGetIterationCount()` - Count iterations
3. `progressCalculationGetCompletionPercentage()` - Calculate %
4. `progressCalculationGetLastUpdated()` - Get timestamp
5. `progressCalculationFormatRelativeTime()` - Format time

See [research.md](./research.md) Question 3 for relative time formatter.

#### Step 2.2: Update renderProjectSidebar()
#### 步骤 2.2：更新 renderProjectSidebar()

**Location**: index.html, Presentation Layer section

```javascript
function renderProjectSidebar() {
    const sidebarContainer = document.getElementById('project-sidebar');
    const html = projects.map(project => {
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
                    <span class="progress-bar">
                        <span style="width: ${completionPercentage}%"></span>
                    </span>
                    <span>${completionPercentage}% complete</span>
                    <span class="last-updated">Last updated: ${lastUpdated}</span>
                </div>
            </div>
        `;
    }).join('');
    sidebarContainer.innerHTML = html;
}
```

#### Step 2.3: Add CSS for Progress Indicators
#### 步骤 2.3：为进度指示器添加 CSS

**Location**: index.html, CSS section

```css
.progress-info {
    display: flex;
    flex-direction: column;
    gap: 5px;
    font-size: 0.85rem;
    color: #666;
}

.progress-bar {
    width: 100%;
    height: 4px;
    background: #e0e0e0;
    border-radius: 2px;
    overflow: hidden;
}

.progress-bar span {
    display: block;
    height: 100%;
    background: linear-gradient(90deg, #10b981, #059669);
    transition: width 0.3s ease;
}

.last-updated {
    font-size: 0.75rem;
    color: #999;
}
```

#### Step 2.4: Implement handleProjectClick()
#### 步骤 2.4：实施 handleProjectClick()

**Location**: index.html, Event Handlers section

```javascript
function handleProjectClick(projectId) {
    // Switch to project tab
    switchTab('projects');

    // Scroll to project detail
    const projectElement = document.getElementById(`project-${projectId}`);
    if (projectElement) {
        projectElement.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}
```

#### Step 2.5: Test User Story 2
#### 步骤 2.5：测试用户故事 2

- [x] Progress indicators display correctly
- [x] Click on sidebar project navigates correctly
- [x] Relative time updates ("2 hours ago", etc.)
- [x] Edge cases handled (0 iterations, all complete)

**Checkpoint**: User Story 2 complete, works independently
**检查点**：用户故事 2 完成，可独立工作

---

### Phase 3: User Story 3 - Command Library (Priority P3)

**Goal**: Add dedicated tab for storing and copying commands
**目标**：添加专用标签页用于存储和复制命令

#### Step 3.1: Implement Data Access Functions
#### 步骤 3.1：实施数据访问函数

**Location**: index.html, Data Access Layer section

```javascript
function saveCommands() {
    localStorage.setItem('speckit_commands', JSON.stringify(commands));
}

function loadCommands() {
    const saved = localStorage.getItem('speckit_commands');
    if (saved) {
        commands = JSON.parse(saved);
    } else {
        commands = commandLibrarySeedDefaults();
        saveCommands();
    }
}
```

#### Step 3.2: Implement Command Library Functions
#### 步骤 3.2：实施命令库函数

**Location**: index.html, Business Logic Layer section

Implement in order:
按顺序实施：
1. `commandLibrarySeedDefaults()` - Seed defaults
2. `commandLibraryAdd()` - Add command
3. `commandLibraryEdit()` - Edit command
4. `commandLibraryDelete()` - Delete command
5. `commandLibraryCopy()` - Copy to clipboard (see research.md Question 2)
6. `commandLibrarySearch()` - Filter commands
7. `commandLibraryReorder()` - Drag-drop reorder

#### Step 3.3: Add Command Library Tab
#### 步骤 3.3：添加命令库标签页

**Location**: index.html, HTML section

```html
<div class="tabs-nav">
    <!-- Existing tabs -->
    <button class="tab-btn" onclick="switchTab('commands')">Command Library</button>
</div>

<div id="commands-tab" class="tab-content">
    <div class="commands-header">
        <input type="text" id="command-search" placeholder="Search commands..."
               oninput="handleSearchCommands(this.value)">
        <button onclick="handleAddCommand()">Add Command</button>
    </div>
    <div id="command-list"></div>
</div>
```

#### Step 3.4: Implement renderCommandLibrary()
#### 步骤 3.4：实施 renderCommandLibrary()

**Location**: index.html, Presentation Layer section

```javascript
function renderCommandLibrary() {
    const container = document.getElementById('command-list');

    // Group by category
    const categoryMap = commands.reduce((map, cmd) => {
        const category = cmd.category || 'Uncategorized';
        if (!map[category]) map[category] = [];
        map[category].push(cmd);
        return map;
    }, {});

    const html = Object.entries(categoryMap).map(([category, cmds]) => `
        <div class="command-category">
            <h3>${category}</h3>
            ${cmds.sort((a, b) => a.order - b.order).map(cmd => `
                <div class="command-item" draggable="true"
                     ondragstart="handleDragStart(event, '${cmd.id}')"
                     ondrop="handleDrop(event, '${cmd.id}')">
                    <div class="command-info">
                        <strong>${cmd.label}</strong>
                        <code>${cmd.text}</code>
                    </div>
                    <div class="command-actions">
                        <button onclick="handleCopyCommand('${cmd.id}')">Copy</button>
                        <button onclick="handleEditCommand('${cmd.id}')">Edit</button>
                        <button onclick="handleDeleteCommand('${cmd.id}')">Delete</button>
                    </div>
                </div>
            `).join('')}
        </div>
    `).join('');

    container.innerHTML = html;
}
```

#### Step 3.5: Implement Event Handlers
#### 步骤 3.5：实施事件处理器

**Location**: index.html, Event Handlers section

Key handlers:
关键处理器：
- `handleAddCommand()` - Add new command dialog
- `handleCopyCommand()` - Copy command text to clipboard
- `handleSearchCommands()` - Filter commands in real-time
- `handleDragStart()`, `handleDrop()` - Drag-drop reordering

#### Step 3.6: Test User Story 3
#### 步骤 3.6：测试用户故事 3

- [x] Default commands seeded on first load
- [x] Add, edit, delete commands work
- [x] Copy to clipboard works (with fallback)
- [x] Search filters correctly
- [x] Drag-drop reordering persists

**Checkpoint**: User Story 3 complete, all features functional
**检查点**：用户故事 3 完成，所有功能正常

---

## Final Integration & Testing
## 最终集成与测试

### Step 4.1: Update initializeApp()
### 步骤 4.1：更新 initializeApp()

```javascript
async function initializeApp() {
    await initializeFirebase();
    loadProjects(); // Loads and migrates projects
    loadCommands(); // Loads or seeds commands
    renderProjectSidebar();

    // If on commands tab, render it
    if (getCurrentTab() === 'commands') {
        renderCommandLibrary();
    }
}
```

### Step 4.2: Cross-Feature Testing
### 步骤 4.2：跨功能测试

Test interactions between features:
测试功能之间的交互：
- [x] Edit project updates `updatedAt`, reflected in sidebar
- [x] Duplicate project creates new entry in sidebar
- [x] Delete project removes from sidebar
- [x] Commands persist across page refresh
- [x] All features work offline (LocalStorage)
- [x] Firebase sync works if authenticated

### Step 4.3: Performance Validation
### 步骤 4.3：性能验证

Verify performance targets:
验证性能目标：
- [x] Page load < 500ms
- [x] CRUD operations < 30 seconds
- [x] Progress calculation < 100ms per project
- [x] Command copy < 500ms
- [x] Search/filter < 200ms for 100 commands

### Step 4.4: Edge Case Testing
### 步骤 4.4：边界情况测试

Test all edge cases from spec.md:
测试 spec.md 中的所有边界情况：
- [x] Duplicate with existing name (auto-appends Copy N)
- [x] Delete currently active project (redirects)
- [x] Long project lists (scroll behavior)
- [x] Long command text (truncate with tooltip)
- [x] Clipboard API unavailable (fallback works)
- [x] Division by zero (0 iterations handled)

---

## Code Review Checklist
## 代码审查清单

Before marking implementation complete:
在标记实施完成前：

### Constitution Compliance
### 宪法合规性

- [ ] No external dependencies added
  未添加外部依赖
- [ ] Single-file architecture maintained
  维持单文件架构
- [ ] Functions max 50 lines, nesting max 3 levels
  函数最多 50 行，嵌套最多 3 层
- [ ] All functions have JSDoc comments
  所有函数都有 JSDoc 注释
- [ ] Naming conventions followed (save*, validate*, render*, handle*)
  遵循命名约定（save*、validate*、render*、handle*）

### Layer Separation
### 层分离

- [ ] No `render*` functions call `localStorage` or `firebase` directly
  `render*` 函数不直接调用 `localStorage` 或 `firebase`
- [ ] No `save*` functions call `document.getElementById()`
  `save*` 函数不调用 `document.getElementById()`
- [ ] No `validate*` functions manipulate DOM
  `validate*` 函数不操作 DOM
- [ ] Event handlers orchestrate layers correctly (validate → save → render)
  事件处理器正确编排层（validate → save → render）

### Testing
### 测试

- [ ] All 22 acceptance scenarios pass
  所有 22 个验收场景通过
- [ ] All 8 edge cases handled gracefully
  所有 8 个边界情况优雅处理
- [ ] Performance targets met
  性能目标达成
- [ ] No console errors
  无控制台错误

---

## Troubleshooting
## 故障排除

### Common Issues
### 常见问题

**Issue**: Duplicate project doesn't copy iterations
**问题**：复制项目不复制迭代
**Solution**: Verify JSON.parse(JSON.stringify()) deep copy works
**解决方案**：验证 JSON.parse(JSON.stringify()) 深拷贝工作正常

**Issue**: Progress percentage shows NaN
**问题**：进度百分比显示 NaN
**Solution**: Check division by zero handling (0 iterations case)
**解决方案**：检查除以零处理（0 次迭代情况）

**Issue**: Clipboard copy doesn't work
**问题**：剪贴板复制不工作
**Solution**: Test fallback method, check HTTPS requirement for Clipboard API
**解决方案**：测试后备方法，检查剪贴板 API 的 HTTPS 要求

**Issue**: Drag-drop reorder doesn't persist
**问题**：拖放重新排序不持久化
**Solution**: Ensure saveCommands() called after reorder
**解决方案**：确保重新排序后调用 saveCommands()

---

## Next Steps
## 下一步

After implementation complete:
实施完成后：

1. Run `/speckit.tasks` to generate detailed task breakdown
   运行 `/speckit.tasks` 生成详细任务分解
2. Run `/speckit.implement` to execute implementation with AI assistance
   运行 `/speckit.implement` 使用 AI 辅助执行实施
3. Run `/speckit.analyze` to validate cross-artifact consistency
   运行 `/speckit.analyze` 验证跨工件一致性

---

## Summary
## 总结

This quickstart provides a pragmatic implementation roadmap focusing on:
本快速入门提供务实的实施路线图，重点关注：

1. **Incremental Delivery**: P1 → P2 → P3 (each story independently testable)
   **增量交付**：P1 → P2 → P3（每个故事可独立测试）
2. **Layer-by-Layer**: Data → Business → Presentation → Event Handlers
   **逐层实施**：数据 → 业务 → 展示 → 事件处理
3. **Test-Driven**: Test each story before moving to next
   **测试驱动**：在进入下一个故事前测试每个故事
4. **Constitution-Compliant**: All constraints satisfied
   **宪法合规**：满足所有约束

Follow this guide to ensure smooth, systematic implementation.
遵循本指南确保顺利、系统化的实施。
