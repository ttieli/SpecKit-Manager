# 项目宪法 (Project Constitution)

<!--
Sync Impact Report:
- Version change: 1.1.0 → 1.2.0
- Modified principles: None
- Added sections:
  ✅ Principle 6: Modularity Mandate (模块化设计强制原则)
  ✅ Principle 7: Separation of Concerns (关注点分离)
- Removed sections: None
- Key changes:
  ✅ Added Principle 6: Library-First approach with module isolation requirements
  ✅ Added Principle 7: Clear separation of concerns with folder structure enforcement
  ✅ Updated table of contents to include new principles
  ✅ Updated revision history
  ✅ Updated validation checklist
- Templates requiring updates:
  ✅ constitution.md (this file - fully updated)
  ⚠️ .specify/templates/spec-template.md (should reference modularity in requirements)
  ⚠️ .specify/templates/plan-template.md (should include module boundary checks)
  ⚠️ .specify/templates/tasks-template.md (should categorize by module/concern)
- Follow-up TODOs:
  1. Review existing codebase for modularity compliance
  2. Define module boundaries for current single-file architecture
  3. Plan migration path if modularity principle conflicts with current A-1 pattern
  4. Update template files to enforce new principles
-->

> **版本 (Version)**: 1.2.0
> **创建时间 (Created)**: 2025-10-15
> **最后修订 (Last Amended)**: 2025-10-15
> **适用项目 (Applies to)**: Spec Kit 项目管理面板

---

## 📋 目录 (Table of Contents)

1. [核心原则 (Core Principles)](#-核心原则-core-principles)
   - [1. Simplicity and Anti-Abstraction (简洁性与反抽象)](#1-simplicity-and-anti-abstraction-简洁性与反抽象)
   - [2. Architectural Integrity (架构完整性)](#2-architectural-integrity-架构完整性)
   - [3. Clean and Modular Code (整洁和模块化代码)](#3-clean-and-modular-code-整洁和模块化代码)
   - [4. Integration-First Testing (集成优先测试)](#4-integration-first-testing-集成优先测试)
   - [5. Bilingual Documentation (双语文档)](#5-bilingual-documentation-双语文档)
   - [6. Modularity Mandate (模块化设计强制原则)](#6-modularity-mandate-模块化设计强制原则)
   - [7. Separation of Concerns (关注点分离)](#7-separation-of-concerns-关注点分离)
2. [架构约束 (Architecture Constraints)](#️-架构约束-architecture-constraints)
3. [性能目标 (Performance Goals)](#-性能目标-performance-goals)
4. [术语规范 (Terminology Standards)](#-术语规范-terminology-standards)
5. [文档规范 (Documentation Standards)](#-文档规范-documentation-standards)
6. [违规处理 (Violation Handling)](#-违规处理-violation-handling)
7. [修订历史 (Revision History)](#-修订历史-revision-history)
8. [检查清单 (Validation Checklist)](#-检查清单-validation-checklist)

---

## 🎯 核心原则 (Core Principles)

### 1. Simplicity and Anti-Abstraction (简洁性与反抽象)

**原则**: 鼓励简单直接的解决方案。只有当简单方案被证明不足时,才允许引入复杂抽象。

**执行标准**:
- ✅ **DO**: 使用原生 JavaScript 功能优先
- ✅ **DO**: 直接操作 DOM,避免不必要的框架依赖
- ✅ **DO**: 将功能保持在单文件中,除非文件超过 3000 行
- ❌ **DON'T**: 引入外部库来实现简单功能
- ❌ **DON'T**: 创建过度抽象的类层次结构
- ❌ **DON'T**: 使用设计模式除非有明确需求

**判定标准**:
- 任何超过 50 行的抽象函数必须在代码审查中说明必要性
- 新增依赖必须在 `plan.md` 中明确论证价值

**示例**:
```javascript
// ✅ GOOD: 简单直接
function saveProjects() {
    localStorage.setItem('speckit_projects', JSON.stringify(projects));
}

// ❌ BAD: 过度抽象
class StorageAdapter {
    constructor(strategy) { this.strategy = strategy; }
    save(key, value) { return this.strategy.persist(key, value); }
}
```

---

### 2. Architectural Integrity (架构完整性)

**原则**: 新增功能必须遵循宪法中定义的架构模式。

**当前架构模式**:
- **模式 A-1**: 单文件 HTML/CSS/JavaScript 架构
- **模式 A-2**: LocalStorage 作为唯一数据持久化层
- **模式 A-3**: 事件驱动的 UI 更新机制
- **模式 A-4**: 函数式编程优先,避免类和继承

**架构约束**:
1. **数据流**: 单向数据流 `User Action → Update Data → Save → Re-render`
2. **状态管理**: 全局变量 `projects` 作为唯一真实数据源
3. **渲染策略**: 声明式 HTML 模板字符串,避免命令式 DOM 操作
4. **模块化**: 按功能划分函数（CRUD、Render、Event Handlers）

**违规示例**:
```javascript
// ❌ CRITICAL: 违反模式 A-2（引入后端依赖）
function saveProjectsToBackend() {
    fetch('/api/projects', { method: 'POST', body: JSON.stringify(projects) });
}

// ❌ CRITICAL: 违反模式 A-4（引入类继承）
class Project extends BaseEntity {
    constructor() { super(); }
}
```

---

### 3. Clean and Modular Code (整洁和模块化代码)

**原则**: 强制代码结构清晰,遵循语言或框架的最新最佳实践。

**代码组织标准**:
```javascript
// 文件结构（index.html 内部）
// 1. 常量定义（commandSteps, phases）
// 2. 全局状态变量（projects, currentTab, currentProjectId）
// 3. 初始化函数（init, loadProjects）
// 4. CRUD 操作函数（addProject, deleteProject, saveProjects）
// 5. 渲染函数（render*, switch*）
// 6. 事件处理函数（copy*, save*, select*）
// 7. 工具函数（如果需要）
```

**命名规范**:
- **函数**: 驼峰命名,动词开头 (`renderOverview`, `saveInput`)
- **变量**: 驼峰命名,名词 (`currentProjectId`, `projects`)
- **常量**: 驼峰命名 (`commandSteps`, `phases`)
- **CSS 类**: 短横线命名 (`command-card`, `cycle-option`)

**代码质量要求**:
- 每个函数最多 50 行（渲染函数可例外至 100 行）
- 嵌套深度不超过 3 层
- 注释覆盖率：关键业务逻辑 20%,复杂算法 50%
- 使用 ES6+ 语法（箭头函数、模板字符串、解构赋值）

---

### 4. Integration-First Testing (集成优先测试)

**原则**: 优先编写反映用户场景的集成测试,而非孤立的单元测试。

**测试策略**:
1. **E2E 测试优先**: 模拟完整用户流程
2. **关键路径覆盖**: 100% 覆盖核心功能
3. **手动测试清单**: 每个 PR 必须通过检查清单

**必测场景**:
```
□ 场景 1: 新建项目 → 创建迭代 → 复制命令 → 标记完成
□ 场景 2: 切换循环颜色 → 命令颜色更新验证
□ 场景 3: 刷新页面 → LocalStorage 数据恢复
□ 场景 4: 删除项目 → 确认模态框 → 数据清理
□ 场景 5: 响应式布局测试（桌面、平板、手机）
```

**测试工具**:
- 手动测试：浏览器开发者工具 + 检查清单
- 自动化测试（未来）：Playwright 或 Cypress

**禁止的测试模式**:
```javascript
// ❌ BAD: 孤立的单元测试（脱离实际使用场景）
test('saveProjects calls localStorage.setItem', () => {
    const spy = jest.spyOn(localStorage, 'setItem');
    saveProjects();
    expect(spy).toHaveBeenCalled();
});

// ✅ GOOD: 集成测试（模拟真实用户操作）
test('user creates project and sees it in overview', async () => {
    await clickAddProjectButton();
    await fillProjectName('Test Project');
    await clickCreateButton();
    expect(overviewGrid).toContainProject('Test Project');
});
```

---

### 5. Bilingual Documentation (双语文档)

**原则 (Principle)**: 所有项目文档、规范、计划、任务列表和AI回复必须提供中英双语版本,确保中英文使用者都能清晰理解项目内容。

**执行标准 (Execution Standards)**:
- ✅ **DO**: 所有文档标题使用"中文 (English)"格式
- ✅ **DO**: 关键技术术语首次出现时标注双语对照
- ✅ **DO**: AI 最终确认消息提供中英文摘要
- ✅ **DO**: 表格和列表使用双语列头
- ❌ **DON'T**: 仅提供单一语言的规范文档
- ❌ **DON'T**: 在代码注释中混用中英文（选择一种）
- ❌ **DON'T**: 对简单变量名进行双语标注

**判定标准 (Criteria)**:
- Spec 文件的所有章节标题必须是双语格式
- Plan 文件的技术术语表必须包含中英对照
- Tasks 文件的任务描述可以是单语,但关键术语需双语
- AI 在完成阶段性工作时必须输出双语总结

**适用范围 (Scope)**:
1. **必须双语 (Must be bilingual)**:
   - 文档标题和章节标题
   - 核心原则和规范条款
   - 成功标准和验收条件
   - 术语表和定义
   - AI 最终确认消息

2. **可选双语 (Optional bilingual)**:
   - 代码注释（建议统一使用英文）
   - 变量和函数名（遵循驼峰命名,英文优先）
   - Git 提交消息（建议使用英文）
   - 详细的技术说明段落（可单语但关键术语需标注）

**示例 (Examples)**:
```markdown
✅ CORRECT: 双语标题
## 用户场景与测试 (User Scenarios & Testing)

✅ CORRECT: 关键术语双语标注
我们使用 **LocalStorage** (本地存储) 作为数据持久化层。

✅ CORRECT: 表格双语列头
| 术语 (Term) | 定义 (Definition) | 状态 (Status) |

❌ WRONG: 仅单一语言标题
## User Scenarios & Testing

❌ WRONG: 术语无双语说明
我们使用 LocalStorage 作为数据持久化层。（首次出现应标注中文）
```

**AI 输出格式要求 (AI Output Format Requirements)**:

当 AI 完成关键任务时,必须使用以下双语格式：

```
✅ 任务完成 (Task Completed)

**中文总结**: [简要描述完成的工作]
**English Summary**: [Brief description of completed work]

**关键变更 (Key Changes)**:
- [变更项 1 / Change 1]
- [变更项 2 / Change 2]

**后续步骤 (Next Steps)**: [可选]
```

---

### 6. Modularity Mandate (模块化设计强制原则)

**原则 (Principle)**: 所有新功能组件 MUST 以独立、可重用模块的形式实现,禁止将核心逻辑代码直接置于项目根目录。确保所有功能都有清晰的边界（Library-First Principle）。

**执行标准 (Execution Standards)**:
- ✅ **MUST DO**: 每个新功能必须设计为独立模块
- ✅ **MUST DO**: 模块必须有明确的输入输出接口
- ✅ **MUST DO**: 模块必须可以独立测试
- ✅ **MUST DO**: 模块必须有清晰的文档说明用途和边界
- ✅ **SHOULD DO**: 模块应该最小化外部依赖
- ❌ **MUST NOT**: 将业务逻辑直接写在根目录文件中
- ❌ **MUST NOT**: 创建仅用于组织代码的"工具类"模块（无实际功能价值）
- ❌ **MUST NOT**: 模块之间产生循环依赖

**判定标准 (Criteria)**:
- 每个模块必须能够回答："如果将此模块移除,哪些功能会失效？"
- 模块接口必须在 `plan.md` 中明确定义
- 模块必须包含独立的测试用例
- 新增模块必须在代码审查中证明其必要性和边界清晰性

**模块设计原则 (Module Design Principles)**:
1. **单一职责 (Single Responsibility)**: 每个模块只负责一个明确的功能领域
2. **接口隔离 (Interface Segregation)**: 模块接口应最小化,只暴露必要的功能
3. **依赖注入 (Dependency Injection)**: 模块不应硬编码依赖,而应通过参数传递
4. **自描述性 (Self-Documenting)**: 模块命名和接口应清晰表达其用途

**当前项目适配说明 (Current Project Adaptation)**:

由于本项目采用单文件架构（模式 A-1）,模块化原则的执行方式需要适配：

- **函数级模块化**: 将大型功能拆分为多个小型、专注的函数
- **命名空间隔离**: 使用函数前缀或注释明确标注功能边界
- **逻辑分组**: 按照功能领域组织函数（如认证模块、数据模块、UI模块）
- **接口契约**: 通过 JSDoc 注释明确函数的输入输出契约

**示例 (Examples)**:
```javascript
// ✅ CORRECT: 模块化函数设计（单文件架构适配）
/**
 * 项目数据持久化模块 (Project Data Persistence Module)
 * @module ProjectPersistence
 */

/**
 * 保存项目到 LocalStorage
 * @param {Array<Project>} projects - 项目数组
 * @returns {boolean} 保存成功返回 true
 */
function saveProjectsToStorage(projects) {
    try {
        localStorage.setItem('speckit_projects', JSON.stringify(projects));
        return true;
    } catch (error) {
        console.error('Failed to save projects:', error);
        return false;
    }
}

/**
 * 从 LocalStorage 加载项目
 * @returns {Array<Project>} 项目数组
 */
function loadProjectsFromStorage() {
    try {
        const data = localStorage.getItem('speckit_projects');
        return data ? JSON.parse(data) : [];
    } catch (error) {
        console.error('Failed to load projects:', error);
        return [];
    }
}

// ❌ WRONG: 逻辑混杂,边界不清晰
function handleProjectData() {
    // 混合了保存、加载、验证、UI更新等多个职责
    const data = localStorage.getItem('projects');
    if (data) {
        projects = JSON.parse(data);
        if (projects.length > 0) {
            renderProjects();
            showSuccessMessage();
        }
    }
    localStorage.setItem('projects', JSON.stringify(projects));
}
```

**违规处理 (Violation Handling)**:
- **CRITICAL**: 直接在根目录创建无模块边界的代码文件
- **CRITICAL**: 模块之间存在循环依赖
- **WARNING**: 模块职责不清晰,无法独立测试
- **INFO**: 模块命名不规范或缺少文档

---

### 7. Separation of Concerns (关注点分离)

**原则 (Principle)**: 强制执行清晰的关注点分离。例如,服务器端逻辑、前端组件和测试文件 MUST 位于其指定的隔离文件夹内。

**执行标准 (Execution Standards)**:
- ✅ **MUST DO**: 不同关注点的代码必须物理隔离
- ✅ **MUST DO**: 数据逻辑、UI逻辑、业务逻辑必须清晰分层
- ✅ **MUST DO**: 测试代码必须与实现代码分离
- ✅ **SHOULD DO**: 配置文件应集中管理
- ❌ **MUST NOT**: 在UI渲染函数中直接操作数据持久化
- ❌ **MUST NOT**: 在数据处理函数中直接操作DOM
- ❌ **MUST NOT**: 将测试代码与生产代码混合

**判定标准 (Criteria)**:
- 每个函数只能属于一个关注点层次
- 跨层调用必须通过明确的接口
- 关注点之间的依赖方向必须单向（避免循环）
- 代码审查时必须验证关注点分离的正确性

**关注点分层模型 (Layers of Concerns)**:

```
┌─────────────────────────────────────┐
│  展示层 (Presentation Layer)         │  ← UI渲染、事件绑定、用户交互
├─────────────────────────────────────┤
│  业务逻辑层 (Business Logic Layer)   │  ← 数据验证、业务规则、状态管理
├─────────────────────────────────────┤
│  数据访问层 (Data Access Layer)      │  ← 数据持久化、存储操作
└─────────────────────────────────────┘
```

**当前项目适配说明 (Current Project Adaptation)**:

由于本项目采用单文件架构（模式 A-1）,关注点分离通过以下方式实现：

1. **函数命名规范**:
   - 渲染函数前缀：`render*`, `switch*`
   - 业务逻辑函数前缀：`validate*`, `calculate*`, `process*`
   - 数据访问函数前缀：`save*`, `load*`, `delete*`
   - 事件处理函数前缀：`handle*`, `on*`

2. **代码组织顺序**:
   - 第一部分：常量和配置
   - 第二部分：数据访问层函数
   - 第三部分：业务逻辑层函数
   - 第四部分：展示层函数
   - 第五部分：事件处理函数（桥接层）

3. **严格的调用规则**:
   - 展示层只能调用业务逻辑层
   - 业务逻辑层只能调用数据访问层
   - 数据访问层不能调用其他层

**示例 (Examples)**:
```javascript
// ========== 数据访问层 (Data Access Layer) ==========

/**
 * 保存项目数据到持久化存储
 */
function saveProjects(projects) {
    localStorage.setItem('speckit_projects', JSON.stringify(projects));
}

/**
 * 从持久化存储加载项目数据
 */
function loadProjects() {
    const data = localStorage.getItem('speckit_projects');
    return data ? JSON.parse(data) : [];
}

// ========== 业务逻辑层 (Business Logic Layer) ==========

/**
 * 添加新项目（包含验证和数据处理）
 */
function addProject(name) {
    if (!name || name.trim().length === 0) {
        throw new Error('项目名称不能为空');
    }

    const newProject = {
        id: 'project_' + Date.now(),
        name: name.trim(),
        createdAt: new Date().toISOString(),
        iterations: []
    };

    projects.push(newProject);
    saveProjects(projects);  // 调用数据访问层

    return newProject;
}

// ========== 展示层 (Presentation Layer) ==========

/**
 * 渲染项目列表
 */
function renderProjectList() {
    const container = document.getElementById('projectList');

    const html = projects.map(project => `
        <div class="project-card" onclick="selectProject('${project.id}')">
            <h3>${project.name}</h3>
            <p>${project.iterations.length} 个迭代</p>
        </div>
    `).join('');

    container.innerHTML = html;
}

// ========== 事件处理层 (Event Handler Layer - Bridge) ==========

/**
 * 处理创建项目按钮点击事件
 */
function handleCreateProject() {
    const nameInput = document.getElementById('projectName');
    const name = nameInput.value;

    try {
        addProject(name);        // 调用业务逻辑层
        renderProjectList();     // 调用展示层
        nameInput.value = '';
        showSuccessMessage('项目创建成功');
    } catch (error) {
        showErrorMessage(error.message);
    }
}

// ❌ WRONG: 违反关注点分离
function badRenderProjectList() {
    // ❌ 在渲染函数中直接操作数据
    const data = localStorage.getItem('speckit_projects');
    projects = data ? JSON.parse(data) : [];

    // ❌ 在渲染函数中执行业务验证
    projects = projects.filter(p => p.name.length > 0);

    // ❌ 在渲染函数中执行持久化
    localStorage.setItem('speckit_projects', JSON.stringify(projects));

    // 然后才渲染 UI...
}
```

**文件夹结构要求 (Folder Structure Requirements)**:

当项目规模扩大需要拆分文件时,必须遵循以下结构：

```
project-root/
├── src/
│   ├── data/           # 数据访问层
│   ├── business/       # 业务逻辑层
│   ├── ui/             # 展示层
│   └── utils/          # 工具函数（跨层共享）
├── tests/              # 测试文件（完全独立）
├── config/             # 配置文件
└── docs/               # 文档文件
```

**违规处理 (Violation Handling)**:
- **CRITICAL**: 在渲染函数中直接调用数据持久化
- **CRITICAL**: 在数据访问层中直接操作 DOM
- **WARNING**: 跨层调用超过两层（如展示层直接调用数据访问层）
- **INFO**: 函数命名不符合关注点分层规范

---

## 🏗️ 架构约束 (Architecture Constraints)

### 数据模型

```javascript
// 项目数据结构（规范定义）
Project {
    id: string,              // 'project_' + timestamp
    name: string,            // 用户输入
    createdAt: ISO8601,      // 创建时间
    iterations: Iteration[]  // 迭代列表
}

Iteration {
    id: string,              // 'iteration_' + timestamp
    name: string,            // 迭代名称
    description: string,     // 可选描述
    createdAt: ISO8601,      // 创建时间
    completedSteps: Object,  // { stepId: boolean }
    inputs: Object,          // { stepId: string }
    notes: Object,           // { stepId: string }
    currentCycle: string,    // 'init' | 'cycle-1' | ... | 'cycle-6'
    cycleHistory: Object     // { stepId: cycleColor }
}
```

### 关键约束

1. **不可变数据原则**: 所有数据更新必须通过 `saveProjects()` 持久化
2. **渲染幂等性**: 多次调用 `render*` 函数结果一致
3. **事件委托**: 动态内容使用 `onclick` 属性绑定
4. **无外部依赖**: 零 npm 包,零框架,纯原生实现
5. **模块边界清晰**: 每个功能模块有明确的输入输出接口（新增）
6. **关注点隔离**: 数据、业务、展示层严格分离（新增）

---

## 📊 性能目标 (Performance Goals)

### 响应时间 (Response Time)
- **页面加载**: < 500ms（本地文件,无网络请求）
- **切换标签页**: < 50ms
- **渲染项目列表**: < 100ms（10 个项目）
- **LocalStorage 读写**: < 10ms

### 资源限制 (Resource Limits)
- **HTML 文件大小**: < 150KB（未压缩）
- **LocalStorage 数据**: < 5MB（浏览器限制）
- **DOM 节点数**: < 1000（单页面）

### 浏览器兼容性 (Browser Compatibility)
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

---

## 📚 术语规范 (Terminology Standards)

### Canonical Terminology (规范术语)

**原则**: 避免术语漂移（Terminology Drift）。在规范中对核心概念使用一致的命名。

**核心术语表**:

| 术语 (Term) | 定义 (Definition) | 禁止别名 |
|------------|------------------|---------|
| **Project** | 顶层容器,包含多个迭代 | ~~Workspace~~, ~~Repository~~ |
| **Iteration** | 开发周期,包含完整的 Spec Kit 工作流 | ~~Sprint~~, ~~Version~~, ~~Phase~~ |
| **Cycle** | 迭代内的循环标记,用颜色区分 | ~~Loop~~, ~~Round~~, ~~Stage~~ |
| **Command Card** | 单个 Spec Kit 步骤的 UI 卡片 | ~~Step Card~~, ~~Workflow Item~~ |
| **Workflow** | Spec Kit 的 9 个步骤流程 | ~~Pipeline~~, ~~Process~~ |
| **Phase** | 工作流的四个阶段（初始化、架构、开发、迭代） | ~~Stage~~, ~~Category~~ |
| **Step** | 单个命令操作（如 /speckit.specify） | ~~Task~~, ~~Action~~ |
| **Completed Steps** | 已完成的步骤标记 | ~~Done Tasks~~, ~~Finished Items~~ |
| **Module** | 具有清晰边界的功能单元 | ~~Component~~ (除非指UI组件), ~~Package~~ |
| **Layer** | 架构分层中的一层（数据层、业务层、展示层） | ~~Tier~~, ~~Level~~ |
| **Concern** | 关注点分离中的一个关注领域 | ~~Aspect~~, ~~Responsibility~~ |

**使用示例**:
```javascript
// ✅ CORRECT: 使用规范术语
function renderIterationWorkflow(project, iteration) {
    const cycleSelector = `<div class="cycle-selector">...`;
    iteration.completedSteps[stepId] = true;
}

// ❌ WRONG: 使用非规范术语
function renderSprintPipeline(workspace, version) {
    const loopPicker = `<div class="round-selector">...`;
    version.doneTasks[actionId] = true;
}
```

---

## 📝 文档规范 (Documentation Standards)

### 文档结构 (Document Structure)

所有项目文档必须遵循以下结构规范：

All project documents must follow this structural specification:

**规范文档 (Specification Documents)**:
```markdown
# 功能规范 (Feature Specification): [功能名称 / Feature Name]

> **版本 (Version)**: x.y.z
> **创建时间 (Created)**: YYYY-MM-DD
> **状态 (Status)**: Draft | Approved | Implemented

## 用户场景与测试 (User Scenarios & Testing)
## 需求 (Requirements)
## 成功标准 (Success Criteria)
## 假设 (Assumptions)
## 依赖 (Dependencies)
## 约束 (Constraints)
## 超出范围 (Out of Scope)
```

**计划文档 (Planning Documents)**:
```markdown
# 实现计划 (Implementation Plan): [功能名称 / Feature Name]

## 技术方案 (Technical Approach)
## 架构决策 (Architecture Decisions)
## 模块边界定义 (Module Boundary Definition)  ← 新增
## 关注点分层设计 (Layers of Concerns Design)  ← 新增
## 任务分解 (Task Breakdown)
## 风险评估 (Risk Assessment)
## 时间估算 (Time Estimation)
```

### 双语规则优先级 (Bilingual Rules Priority)

1. **强制双语 (Mandatory Bilingual)** - 必须使用双语格式：
   - 文档标题 (Document titles)
   - 章节标题 (Section headers)
   - 表格列头 (Table headers)
   - 核心术语首次出现 (Core terms on first use)

2. **推荐双语 (Recommended Bilingual)** - 建议使用双语：
   - 成功标准 (Success criteria)
   - 验收条件 (Acceptance criteria)
   - 关键步骤说明 (Key step descriptions)

3. **可选双语 (Optional Bilingual)** - 可以单语：
   - 详细段落正文 (Detailed paragraph content)
   - 代码示例注释 (Code example comments)
   - 技术实现细节 (Technical implementation details)

### 术语一致性 (Terminology Consistency)

在整个项目生命周期中,必须保持术语使用的一致性：

Throughout the project lifecycle, terminology usage must remain consistent:

- 使用宪法中定义的规范术语表 (Use canonical terms defined in constitution)
- 新术语首次使用时添加到术语表 (Add new terms to glossary on first use)
- 避免同义词混用 (Avoid mixing synonyms)
- AI 在输出中必须遵循术语规范 (AI must follow terminology standards in outputs)

---

## 🚨 违规处理 (Violation Handling)

### 严重级别

#### CRITICAL (关键)
- 违反架构完整性（引入后端、使用类继承）
- 破坏数据模型约束
- 引入外部框架/库
- **违反模块化强制原则（核心逻辑置于根目录）**
- **违反关注点分离（跨层直接调用、混合职责）**

**处理**: 立即拒绝,必须重构

#### WARNING (警告)
- 函数超过 50 行
- 嵌套深度超过 3 层
- 缺少必要注释
- **模块边界不清晰**
- **关注点分层不规范**

**处理**: 代码审查时标记,要求优化

#### INFO (信息)
- 命名不一致
- 注释语言混用（中英文）
- CSS 顺序不规范
- **模块文档不完整**
- **函数命名不符合分层规范**

**处理**: 建议改进,不阻塞合并

---

## 🔄 修订历史 (Revision History)

| 版本 (Version) | 日期 (Date) | 修改内容 (Changes) |
|---------------|------------|-------------------|
| 1.2.0 | 2025-10-15 | 新增第6条核心原则：模块化设计强制原则 (Added Principle 6: Modularity Mandate)<br/>新增第7条核心原则：关注点分离 (Added Principle 7: Separation of Concerns) |
| 1.1.0 | 2025-10-15 | 新增第5条核心原则：双语文档要求 (Added Principle 5: Bilingual Documentation requirements) |
| 1.0 | 2025-10-15 | 初始版本,定义五大核心原则 (Initial version with 5 core principles) |

---

## ✅ 检查清单 (Validation Checklist)

在执行 `/speckit.plan` 和 `/speckit.implement` 前,AI 代理必须验证：

Before executing `/speckit.plan` and `/speckit.implement`, AI agents must verify:

- [ ] 新功能符合简洁性原则（无过度抽象） / New features follow simplicity principle (no over-abstraction)
- [ ] 遵循现有架构模式（A-1 至 A-4） / Adheres to existing architecture patterns (A-1 to A-4)
- [ ] 代码组织清晰,命名规范 / Code is well-organized with proper naming conventions
- [ ] 使用规范术语,无术语漂移 / Uses canonical terminology without drift
- [ ] 集成测试场景已定义 / Integration test scenarios are defined
- [ ] 性能目标在可接受范围内 / Performance targets are within acceptable ranges
- [ ] 文档包含必要的双语标题和术语 / Documentation includes required bilingual headers and terms
- [ ] **新功能设计为独立模块,边界清晰** / **New features designed as independent modules with clear boundaries**
- [ ] **关注点分离正确,数据/业务/展示层严格隔离** / **Separation of concerns correct, data/business/presentation layers strictly isolated**
- [ ] **模块接口在 plan.md 中明确定义** / **Module interfaces clearly defined in plan.md**
- [ ] **函数命名符合分层规范（render*/validate*/save*等）** / **Function naming follows layer conventions (render*/validate*/save* etc.)**

**违反任何 CRITICAL 约束将自动触发重新规划。**

**Violating any CRITICAL constraint will automatically trigger re-planning.**
