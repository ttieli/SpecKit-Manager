# 技术实现计划 (Plan)

> **规范**: 002-data-management-enhancements
> **创建时间**: 2025-10-15
> **技术栈**: 原生 JavaScript + HTML5 File API + LocalStorage
> **架构模式**: 单文件 HTML 应用（保持 A-1 模式）

---

## 📐 架构设计

### 整体架构约束

基于 Constitution 和用户需求，本次实现必须遵循：

✅ **单文件架构** - 所有代码保持在 `index.html` 中
✅ **项目目录左侧** - 调整布局，侧边栏显示项目列表（而非迭代列表）
✅ **LocalStorage 存储** - 无数据库，纯本地存储
✅ **静态部署** - 支持本地文件访问和 GitHub Pages 托管
✅ **零后端依赖** - 无需 Node.js、PHP 等服务器环境

### 新架构布局设计

```
┌─────────────────────────────────────────────────────┐
│  🚀 Spec Kit 项目管理面板                            │
│  规范驱动开发（SDD）完整工作流                        │
├─────────────────────────────────────────────────────┤
│  [💾 导出] [📂 导入] [🗑️ 清空] [➕ 新建项目]        │
├──────────────┬──────────────────────────────────────┤
│              │                                      │
│  📁 项目列表  │  📊 项目概览 / 迭代工作流              │
│              │                                      │
│  ▼ 项目 A    │  ┌────────────────────────────┐    │
│    • 迭代1   │  │  项目 A - 初始开发         │    │
│    • 迭代2   │  │  📊 进度: 14/27 (52%)     │    │
│              │  │  ⏱️ 创建于: 3 天前         │    │
│  ▼ 项目 B    │  └────────────────────────────┘    │
│    • 迭代1   │                                      │
│              │  ┌────────────────────────────┐    │
│  ▶ 项目 C    │  │  🎨 当前循环颜色           │    │
│              │  │  [灰] [蓝] [粉] [黄] ...   │    │
│              │  └────────────────────────────┘    │
│  [+ 新建]    │                                      │
│              │  ┌────────────────────────────┐    │
│              │  │  🎯 初始化阶段             │    │
│              │  │  [0] 项目初始化 ✓         │    │
│              │  └────────────────────────────┘    │
│              │                                      │
└──────────────┴──────────────────────────────────────┘
```

#### 关键变化

**当前布局** → **新布局**：
- ❌ 迭代侧边栏 → ✅ 项目侧边栏（左侧）
- ❌ 主区域只显示工作流 → ✅ 主区域可切换概览/工作流
- ❌ 标签页导航 → ✅ 树形侧边栏导航
- ➕ 新增数据管理工具栏

---

## 🗂️ 数据模型设计

### LocalStorage 数据结构（不变）

```javascript
// localStorage key: 'speckit_projects'
{
  "version": "1.0",
  "lastModified": "2025-10-15T10:30:00Z",
  "projects": [
    {
      "id": "project_1728987654321",
      "name": "示例项目",
      "createdAt": "2025-10-10T08:00:00Z",
      "expanded": true,  // 新增：侧边栏展开状态
      "iterations": [
        {
          "id": "iteration_1728987654322",
          "name": "初始开发",
          "description": "第一个迭代版本",
          "createdAt": "2025-10-10T08:00:00Z",
          "completedSteps": {
            "init-new": true,
            "constitution": true
          },
          "inputs": {
            "init-new": "my-project"
          },
          "notes": {
            "constitution": "遵循简洁性原则"
          },
          "currentCycle": "cycle-1",
          "cycleHistory": {
            "init-new": "init",
            "constitution": "cycle-1"
          }
        }
      ]
    }
  ]
}
```

### 导出 JSON Schema（新增）

```javascript
// 导出文件格式
{
  "schemaVersion": "1.0",
  "exportDate": "2025-10-15T10:30:00Z",
  "appVersion": "1.0.0",
  "totalProjects": 3,
  "totalIterations": 7,
  "projects": [ /* 项目数组，结构同 LocalStorage */ ]
}
```

**字段说明**：
- `schemaVersion`: 数据格式版本（用于未来兼容性）
- `exportDate`: 导出时间戳（ISO 8601）
- `appVersion`: 应用版本号（便于调试）
- `totalProjects/totalIterations`: 快速统计信息

---

## 🎨 UI 设计方案

### 1. 左侧项目树结构

```html
<div class="project-sidebar">
  <!-- 工具栏 -->
  <div class="sidebar-toolbar">
    <button class="btn-export" onclick="exportAllProjects()">
      💾 导出
    </button>
    <button class="btn-import" onclick="openImportModal()">
      📂 导入
    </button>
    <button class="btn-clear" onclick="openClearModal()">
      🗑️ 清空
    </button>
  </div>

  <!-- 项目树 -->
  <div class="project-tree">
    <!-- 单个项目节点 -->
    <div class="project-node expanded">
      <div class="project-header" onclick="toggleProject('project_123')">
        <span class="expand-icon">▼</span>
        <span class="project-name">项目 A</span>
        <span class="project-stats">14/27</span>
      </div>

      <!-- 迭代列表（可展开/折叠） -->
      <div class="iteration-list">
        <div class="iteration-node active"
             onclick="selectIteration('project_123', 'iter_456')">
          <span class="iteration-name">初始开发</span>
          <span class="iteration-progress">9/9</span>
        </div>
        <div class="iteration-node"
             onclick="selectIteration('project_123', 'iter_789')">
          <span class="iteration-name">UI 增强</span>
          <span class="iteration-progress">5/9</span>
        </div>
      </div>
    </div>

    <!-- 折叠状态的项目 -->
    <div class="project-node collapsed">
      <div class="project-header" onclick="toggleProject('project_456')">
        <span class="expand-icon">▶</span>
        <span class="project-name">项目 B</span>
        <span class="project-stats">0/9</span>
      </div>
    </div>
  </div>

  <!-- 底部新建按钮 -->
  <div class="sidebar-footer">
    <button class="btn-add-project" onclick="openAddProjectModal()">
      ➕ 新建项目
    </button>
  </div>
</div>
```

**交互行为**：
- 点击项目名 → 展开/折叠迭代列表
- 点击迭代名 → 切换到该迭代的工作流视图
- 双击项目名 → 进入项目概览页（显示所有迭代的汇总）

### 2. 主内容区切换逻辑

```javascript
// 主区域显示模式
const VIEW_MODES = {
  OVERVIEW: 'overview',      // 显示所有项目概览卡片
  PROJECT: 'project',        // 显示单个项目的所有迭代
  ITERATION: 'iteration'     // 显示单个迭代的工作流
};

let currentView = VIEW_MODES.OVERVIEW;
let selectedProjectId = null;
let selectedIterationId = null;

// 切换视图
function switchView(mode, projectId, iterationId) {
  currentView = mode;
  selectedProjectId = projectId;
  selectedIterationId = iterationId;
  renderMainContent();
}
```

**视图示例**：

**概览模式** (初始默认)：
```
┌────────────────────────────────┐
│  项目 A                 [删除] │
│  📊 总进度: 14/27 (52%)        │
│  🔄 迭代数: 2                  │
│  ⏱️ 创建于: 3 天前             │
└────────────────────────────────┘
```

**项目模式** (点击侧边栏项目)：
```
项目 A - 概览

迭代 1: 初始开发          ✅ 9/9  (100%)
迭代 2: UI 增强           🔄 5/9  (56%)

[+ 新建迭代]
```

**迭代模式** (点击侧边栏迭代)：
```
项目 A > 初始开发

🎨 当前循环颜色
[灰色] [蓝色] ...

🎯 初始化阶段
[0] 项目初始化 ✓

🏛️ 架构约束阶段
[I] 定义架构 DNA ✓
...
```

### 3. 数据管理模态框设计

#### 导入模态框

```html
<div class="modal" id="importModal">
  <div class="modal-content">
    <h2>📂 导入项目数据</h2>

    <!-- 文件选择 -->
    <div class="file-upload-area">
      <input type="file" id="importFileInput"
             accept=".json"
             onchange="handleFileSelect(event)">
      <label for="importFileInput" class="upload-label">
        <div class="upload-icon">📁</div>
        <div>点击选择 JSON 文件</div>
        <div class="upload-hint">或拖拽文件到此区域</div>
      </label>
    </div>

    <!-- 文件信息预览 -->
    <div class="import-preview" id="importPreview" style="display:none;">
      <h3>文件信息</h3>
      <ul>
        <li>项目数量: <strong id="previewProjectCount">0</strong></li>
        <li>迭代总数: <strong id="previewIterationCount">0</strong></li>
        <li>导出时间: <strong id="previewExportDate">-</strong></li>
      </ul>
    </div>

    <!-- 导入模式选择 -->
    <div class="import-mode-selector" id="importModeSelector" style="display:none;">
      <h3>导入模式</h3>
      <label class="radio-option">
        <input type="radio" name="importMode" value="merge" checked>
        <span>📎 合并模式</span>
        <small>保留现有项目，添加新项目</small>
      </label>
      <label class="radio-option">
        <input type="radio" name="importMode" value="replace">
        <span>🔄 覆盖模式</span>
        <small class="warning">清空现有数据，完全替换</small>
      </label>
    </div>

    <!-- 操作按钮 -->
    <div class="modal-actions">
      <button class="btn-secondary" onclick="closeImportModal()">取消</button>
      <button class="btn-primary" id="confirmImportBtn"
              onclick="confirmImport()" disabled>
        确认导入
      </button>
    </div>
  </div>
</div>
```

#### 清空数据模态框

```html
<div class="modal" id="clearModal">
  <div class="modal-content modal-danger">
    <h2>⚠️ 清空所有数据</h2>
    <p class="warning-text">
      此操作将永久删除所有项目和迭代数据，且<strong>无法恢复</strong>！
    </p>

    <div class="confirmation-input">
      <label>请输入 <strong>确认删除</strong> 以继续：</label>
      <input type="text" id="clearConfirmText"
             placeholder="确认删除"
             oninput="validateClearConfirm()">
    </div>

    <div class="modal-actions">
      <button class="btn-secondary" onclick="closeClearModal()">取消</button>
      <button class="btn-danger" id="confirmClearBtn"
              onclick="confirmClearAll()" disabled>
        清空数据
      </button>
    </div>
  </div>
</div>
```

---

## 💻 技术实现方案

### 1. 导出功能实现

#### 导出所有项目

```javascript
function exportAllProjects() {
  // 1. 生成导出数据
  const exportData = {
    schemaVersion: "1.0",
    exportDate: new Date().toISOString(),
    appVersion: "1.0.0",
    totalProjects: projects.length,
    totalIterations: projects.reduce((sum, p) => sum + p.iterations.length, 0),
    projects: projects
  };

  // 2. 转换为 JSON 字符串（格式化输出）
  const jsonString = JSON.stringify(exportData, null, 2);

  // 3. 创建 Blob 对象
  const blob = new Blob([jsonString], { type: 'application/json' });

  // 4. 创建下载链接
  const url = URL.createObjectURL(blob);
  const timestamp = new Date().getTime();
  const filename = `speckit-backup-${timestamp}.json`;

  // 5. 触发下载
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();

  // 6. 清理
  document.body.removeChild(a);
  URL.revokeObjectURL(url);

  // 7. 显示成功提示
  showToast('✅ 数据已导出', 'success');
}
```

#### 导出单个项目

```javascript
function exportProject(projectId) {
  const project = projects.find(p => p.id === projectId);
  if (!project) return;

  const exportData = {
    schemaVersion: "1.0",
    exportDate: new Date().toISOString(),
    appVersion: "1.0.0",
    totalProjects: 1,
    totalIterations: project.iterations.length,
    projects: [project]
  };

  const jsonString = JSON.stringify(exportData, null, 2);
  const blob = new Blob([jsonString], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const filename = `speckit-${sanitizeFilename(project.name)}-${Date.now()}.json`;

  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);

  showToast(`✅ 已导出"${project.name}"`, 'success');
}

// 文件名安全化
function sanitizeFilename(name) {
  return name.replace(/[^a-z0-9\u4e00-\u9fa5]/gi, '-').toLowerCase();
}
```

### 2. 导入功能实现

#### 文件选择和预览

```javascript
function handleFileSelect(event) {
  const file = event.target.files[0];
  if (!file) return;

  // 检查文件大小（限制 10MB）
  if (file.size > 10 * 1024 * 1024) {
    showToast('❌ 文件过大（超过 10MB）', 'error');
    return;
  }

  // 检查文件类型
  if (!file.name.endsWith('.json')) {
    showToast('❌ 请选择 JSON 文件', 'error');
    return;
  }

  // 读取文件内容
  const reader = new FileReader();
  reader.onload = (e) => {
    try {
      const data = JSON.parse(e.target.result);

      // 验证数据格式
      const validation = validateImportData(data);
      if (!validation.valid) {
        showToast(`❌ ${validation.error}`, 'error');
        return;
      }

      // 显示预览信息
      showImportPreview(data);

      // 启用确认按钮
      document.getElementById('confirmImportBtn').disabled = false;

      // 保存待导入数据到全局变量
      window.pendingImportData = data;

    } catch (error) {
      showToast('❌ 文件格式错误，无法解析 JSON', 'error');
      console.error('Parse error:', error);
    }
  };

  reader.onerror = () => {
    showToast('❌ 文件读取失败', 'error');
  };

  reader.readAsText(file);
}

function showImportPreview(data) {
  document.getElementById('importPreview').style.display = 'block';
  document.getElementById('importModeSelector').style.display = 'block';

  document.getElementById('previewProjectCount').textContent = data.totalProjects || data.projects.length;
  document.getElementById('previewIterationCount').textContent = data.totalIterations ||
    data.projects.reduce((sum, p) => sum + p.iterations.length, 0);
  document.getElementById('previewExportDate').textContent =
    formatDateTime(data.exportDate);
}
```

#### 数据验证

```javascript
function validateImportData(data) {
  // Level 1: 基础结构验证
  if (!data || typeof data !== 'object') {
    return { valid: false, error: '数据格式错误' };
  }

  if (!Array.isArray(data.projects)) {
    return { valid: false, error: '缺少项目数组' };
  }

  if (data.projects.length === 0) {
    return { valid: false, error: '文件中没有项目数据' };
  }

  // Level 2: 项目结构验证
  for (let i = 0; i < data.projects.length; i++) {
    const project = data.projects[i];

    if (!project.id || !project.name) {
      return { valid: false, error: `项目 ${i+1} 缺少必需字段（id 或 name）` };
    }

    if (!Array.isArray(project.iterations)) {
      return { valid: false, error: `项目"${project.name}"缺少迭代数组` };
    }

    // Level 3: 迭代结构验证
    for (let j = 0; j < project.iterations.length; j++) {
      const iteration = project.iterations[j];

      if (!iteration.id || !iteration.name) {
        return {
          valid: false,
          error: `项目"${project.name}"的迭代 ${j+1} 缺少必需字段`
        };
      }
    }
  }

  return { valid: true };
}
```

#### 数据修复和导入

```javascript
function confirmImport() {
  const mode = document.querySelector('input[name="importMode"]:checked').value;
  const importData = window.pendingImportData;

  if (!importData) {
    showToast('❌ 无待导入数据', 'error');
    return;
  }

  try {
    // 修复数据（补全缺失字段）
    const repairedProjects = importData.projects.map(repairProjectData);

    if (mode === 'replace') {
      // 覆盖模式：清空现有数据
      if (!confirm('⚠️ 确定要清空现有数据并导入吗？此操作不可撤销！')) {
        return;
      }
      projects = repairedProjects;
    } else {
      // 合并模式：处理 ID 冲突
      repairedProjects.forEach(importedProject => {
        const existingIndex = projects.findIndex(p => p.id === importedProject.id);

        if (existingIndex >= 0) {
          // ID 冲突：重新生成 ID
          importedProject.id = 'project_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
          importedProject.name += ' (导入)';
        }

        projects.push(importedProject);
      });
    }

    // 保存到 LocalStorage
    saveProjects();

    // 关闭模态框
    closeImportModal();

    // 刷新界面
    renderProjectSidebar();
    renderMainContent();

    // 显示成功消息
    showToast(`✅ 已导入 ${repairedProjects.length} 个项目`, 'success');

  } catch (error) {
    showToast('❌ 导入失败：' + error.message, 'error');
    console.error('Import error:', error);
  }
}

function repairProjectData(project) {
  // 确保项目有必需字段
  project.createdAt = project.createdAt || new Date().toISOString();
  project.expanded = project.expanded !== undefined ? project.expanded : true;

  // 修复每个迭代
  project.iterations = project.iterations.map(iteration => {
    iteration.createdAt = iteration.createdAt || project.createdAt;
    iteration.completedSteps = iteration.completedSteps || {};
    iteration.inputs = iteration.inputs || {};
    iteration.notes = iteration.notes || {};
    iteration.currentCycle = iteration.currentCycle || 'init';
    iteration.cycleHistory = iteration.cycleHistory || {};
    return iteration;
  });

  return project;
}
```

### 3. 清空数据功能

```javascript
function openClearModal() {
  if (projects.length === 0) {
    showToast('ℹ️ 当前没有数据需要清空', 'info');
    return;
  }

  document.getElementById('clearModal').classList.add('active');
  document.getElementById('clearConfirmText').value = '';
  document.getElementById('confirmClearBtn').disabled = true;
}

function validateClearConfirm() {
  const input = document.getElementById('clearConfirmText').value;
  const btn = document.getElementById('confirmClearBtn');
  btn.disabled = (input !== '确认删除');
}

function confirmClearAll() {
  // 清空数据
  projects = [];
  saveProjects();

  // 关闭模态框
  closeClearModal();

  // 刷新界面
  renderProjectSidebar();
  renderMainContent();

  // 显示成功消息
  showToast('✅ 所有数据已清空', 'success');
}

function closeClearModal() {
  document.getElementById('clearModal').classList.remove('active');
}
```

### 4. 统计信息计算

```javascript
// 计算项目统计信息
function calculateProjectStats(project) {
  const totalIterations = project.iterations.length;
  let totalCompleted = 0;
  let totalSteps = 0;

  project.iterations.forEach(iteration => {
    const completed = Object.values(iteration.completedSteps).filter(v => v).length;
    totalCompleted += completed;
    totalSteps += commandSteps.length;
  });

  const percentage = totalSteps > 0 ? Math.round((totalCompleted / totalSteps) * 100) : 0;

  return {
    totalIterations,
    totalCompleted,
    totalSteps,
    percentage,
    createdAt: project.createdAt
  };
}

// 格式化相对时间
function formatRelativeTime(dateString) {
  const date = new Date(dateString);
  const now = new Date();
  const diffMs = now - date;
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

  if (diffDays === 0) return '今天';
  if (diffDays === 1) return '昨天';
  if (diffDays < 7) return `${diffDays} 天前`;
  if (diffDays < 30) return `${Math.floor(diffDays / 7)} 周前`;
  if (diffDays < 365) return `${Math.floor(diffDays / 30)} 个月前`;
  return `${Math.floor(diffDays / 365)} 年前`;
}

// 格式化日期时间
function formatDateTime(dateString) {
  if (!dateString) return '-';
  const date = new Date(dateString);
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  });
}
```

### 5. Toast 通知系统

```javascript
function showToast(message, type = 'info') {
  // 创建 Toast 元素
  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;
  toast.textContent = message;

  // 添加到页面
  document.body.appendChild(toast);

  // 触发动画
  setTimeout(() => toast.classList.add('show'), 10);

  // 3 秒后移除
  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => document.body.removeChild(toast), 300);
  }, 3000);
}
```

---

## 🎨 CSS 设计方案

### 1. 左侧项目树样式

```css
/* 侧边栏容器 */
.project-sidebar {
    width: 280px;
    background: white;
    border-right: 2px solid #e5e7eb;
    display: flex;
    flex-direction: column;
    height: calc(100vh - 200px);
    position: sticky;
    top: 20px;
}

/* 工具栏 */
.sidebar-toolbar {
    padding: 12px;
    border-bottom: 2px solid #e5e7eb;
    display: flex;
    gap: 8px;
}

.sidebar-toolbar button {
    flex: 1;
    padding: 8px;
    font-size: 0.75rem;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-export {
    background: linear-gradient(135deg, #10b981, #059669);
    color: white;
}

.btn-import {
    background: linear-gradient(135deg, #3b82f6, #2563eb);
    color: white;
}

.btn-clear {
    background: linear-gradient(135deg, #ef4444, #dc2626);
    color: white;
}

/* 项目树 */
.project-tree {
    flex: 1;
    overflow-y: auto;
    padding: 8px;
}

.project-node {
    margin-bottom: 4px;
}

.project-header {
    display: flex;
    align-items: center;
    padding: 10px 12px;
    background: #f8fafc;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s;
    gap: 8px;
}

.project-header:hover {
    background: #e5e7eb;
}

.project-node.expanded .project-header {
    background: linear-gradient(135deg, #dbeafe, #bfdbfe);
    color: #1e40af;
    font-weight: 600;
}

.expand-icon {
    font-size: 0.7rem;
    transition: transform 0.2s;
}

.project-node.collapsed .expand-icon {
    transform: rotate(-90deg);
}

.project-name {
    flex: 1;
    font-size: 0.9rem;
}

.project-stats {
    font-size: 0.75rem;
    background: white;
    padding: 2px 8px;
    border-radius: 12px;
    color: #64748b;
}

/* 迭代列表 */
.iteration-list {
    padding-left: 24px;
    margin-top: 4px;
}

.project-node.collapsed .iteration-list {
    display: none;
}

.iteration-node {
    display: flex;
    align-items: center;
    padding: 8px 12px;
    border-radius: 6px;
    cursor: pointer;
    transition: all 0.2s;
    margin-bottom: 2px;
}

.iteration-node:hover {
    background: #f1f5f9;
}

.iteration-node.active {
    background: linear-gradient(135deg, #2563eb, #1d4ed8);
    color: white;
    font-weight: 600;
}

.iteration-name {
    flex: 1;
    font-size: 0.85rem;
}

.iteration-progress {
    font-size: 0.7rem;
    opacity: 0.8;
}

/* 底部按钮 */
.sidebar-footer {
    padding: 12px;
    border-top: 2px solid #e5e7eb;
}

.btn-add-project {
    width: 100%;
    padding: 10px;
    background: linear-gradient(135deg, #f59e0b, #ea580c);
    color: white;
    border: none;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-add-project:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(245, 158, 11, 0.4);
}
```

### 2. 导入模态框样式

```css
/* 文件上传区域 */
.file-upload-area {
    position: relative;
    margin-bottom: 20px;
}

.file-upload-area input[type="file"] {
    position: absolute;
    opacity: 0;
    width: 100%;
    height: 100%;
    cursor: pointer;
}

.upload-label {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 40px;
    border: 3px dashed #cbd5e0;
    border-radius: 12px;
    background: #f8fafc;
    cursor: pointer;
    transition: all 0.3s;
}

.upload-label:hover {
    border-color: #2563eb;
    background: #eff6ff;
}

.upload-icon {
    font-size: 3rem;
    margin-bottom: 10px;
}

.upload-hint {
    font-size: 0.8rem;
    color: #94a3b8;
    margin-top: 5px;
}

/* 导入预览 */
.import-preview {
    background: #f0fdf4;
    border: 2px solid #86efac;
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 20px;
}

.import-preview h3 {
    font-size: 0.9rem;
    color: #166534;
    margin-bottom: 10px;
}

.import-preview ul {
    list-style: none;
    padding: 0;
}

.import-preview li {
    padding: 6px 0;
    color: #15803d;
    font-size: 0.85rem;
}

/* 导入模式选择 */
.import-mode-selector {
    margin-bottom: 20px;
}

.import-mode-selector h3 {
    font-size: 0.9rem;
    margin-bottom: 12px;
    color: #1e293b;
}

.radio-option {
    display: block;
    padding: 12px;
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    margin-bottom: 10px;
    cursor: pointer;
    transition: all 0.2s;
}

.radio-option:hover {
    border-color: #3b82f6;
    background: #eff6ff;
}

.radio-option input[type="radio"] {
    margin-right: 10px;
}

.radio-option small {
    display: block;
    margin-left: 28px;
    color: #64748b;
    font-size: 0.75rem;
}

.radio-option small.warning {
    color: #dc2626;
}

/* 危险模态框 */
.modal-danger {
    border-top: 4px solid #dc2626;
}

.warning-text {
    background: #fef2f2;
    border-left: 4px solid #dc2626;
    padding: 12px;
    border-radius: 6px;
    color: #991b1b;
    margin-bottom: 20px;
}

.confirmation-input {
    margin-bottom: 20px;
}

.confirmation-input label {
    display: block;
    margin-bottom: 8px;
    font-size: 0.9rem;
    color: #1e293b;
}

.confirmation-input strong {
    color: #dc2626;
}

.confirmation-input input {
    width: 100%;
    padding: 10px;
    border: 2px solid #cbd5e0;
    border-radius: 6px;
    font-size: 0.9rem;
}

.btn-danger {
    background: linear-gradient(135deg, #dc2626, #b91c1c);
    color: white;
}

.btn-danger:hover:not(:disabled) {
    background: linear-gradient(135deg, #b91c1c, #991b1b);
}

.btn-danger:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}
```

### 3. Toast 通知样式

```css
.toast {
    position: fixed;
    bottom: 30px;
    right: 30px;
    padding: 16px 24px;
    border-radius: 8px;
    box-shadow: 0 8px 24px rgba(0,0,0,0.25);
    font-size: 0.9rem;
    font-weight: 600;
    color: white;
    opacity: 0;
    transform: translateY(20px);
    transition: all 0.3s;
    z-index: 10000;
}

.toast.show {
    opacity: 1;
    transform: translateY(0);
}

.toast-success {
    background: linear-gradient(135deg, #10b981, #059669);
}

.toast-error {
    background: linear-gradient(135deg, #ef4444, #dc2626);
}

.toast-info {
    background: linear-gradient(135deg, #3b82f6, #2563eb);
}

.toast-warning {
    background: linear-gradient(135deg, #f59e0b, #ea580c);
}
```

---

## 🚀 部署方案

### 本地使用

**方式 1：直接打开文件**
```bash
# 双击 index.html 文件即可在浏览器中打开
# 或在浏览器中按 Ctrl+O (Windows) / Cmd+O (Mac) 选择文件
```

**方式 2：使用 Python 简易服务器（可选）**
```bash
# 进入项目目录
cd /path/to/ClaudeCode_SpecKit_Automation_Web

# Python 3.x
python -m http.server 8080

# Python 2.x
python -m SimpleHTTPServer 8080

# 访问 http://localhost:8080
```

**方式 3：使用 Node.js http-server（可选）**
```bash
# 全局安装（仅需一次）
npm install -g http-server

# 启动服务器
http-server -p 8080

# 访问 http://localhost:8080
```

### GitHub Pages 部署

**步骤 1：创建 GitHub 仓库**
```bash
# 初始化 Git 仓库
git init

# 添加文件
git add index.html constitution.md README.md

# 提交
git commit -m "feat: 初始化 Spec Kit 项目管理面板"

# 关联远程仓库
git remote add origin https://github.com/yourusername/speckit-dashboard.git

# 推送到 GitHub
git push -u origin main
```

**步骤 2：启用 GitHub Pages**
1. 进入仓库的 Settings
2. 找到 Pages 选项
3. Source 选择 `main` 分支
4. 目录选择 `/` (root)
5. 点击 Save

**步骤 3：访问网站**
```
https://yourusername.github.io/speckit-dashboard/
```

### 文件结构（最终）

```
ClaudeCode_SpecKit_Automation_Web/
├── index.html                  # 主应用文件（单文件架构）
├── constitution.md             # 项目宪法
├── README.md                   # 项目说明文档
├── specs/
│   ├── 001-initial-implementation/
│   │   └── spec.md            # 初始实现规范
│   └── 002-data-management-enhancements/
│       ├── spec.md            # 数据管理增强规范
│       └── plan.md            # 本文档
└── .gitignore                 # Git 忽略文件（可选）
```

**.gitignore 内容**（可选）
```
.DS_Store
Thumbs.db
*.log
.vscode/
.idea/
```

---

## 📊 性能约束

### 响应时间目标

| 操作 | 目标时间 | 最大时间 |
|-----|---------|---------|
| 导出 10 个项目 | < 100ms | < 500ms |
| 导出 50 个项目 | < 500ms | < 1s |
| 导入 10 个项目（合并） | < 200ms | < 1s |
| 导入 50 个项目（覆盖） | < 500ms | < 2s |
| 切换项目展开/折叠 | < 16ms | < 50ms |
| 切换迭代视图 | < 50ms | < 100ms |
| 显示 Toast 通知 | 即时 | < 10ms |

### 内存和存储限制

| 项目 | 限制 |
|-----|------|
| LocalStorage 总大小 | < 5MB |
| 单个项目数据 | < 100KB |
| 导出 JSON 文件大小 | < 10MB |
| 最大项目数量 | 100 个 |
| 单项目最大迭代数 | 50 个 |

---

## 🧪 测试策略

### 手动测试清单

#### Phase 1: 基础功能测试

**T1: 导出功能**
```
前置条件：已有 3 个项目，每个项目 2 个迭代，部分步骤完成
步骤：
1. 点击"导出"按钮
2. 验证文件自动下载
3. 打开 JSON 文件查看内容
验证：
□ 文件名格式为 speckit-backup-{timestamp}.json
□ JSON 格式正确，可被解析
□ 包含所有 3 个项目
□ 包含所有 6 个迭代
□ completedSteps 数据正确
□ inputs 和 notes 内容完整
□ cycleHistory 记录准确
```

**T2: 导入功能（合并模式）**
```
前置条件：已有 2 个项目
步骤：
1. 准备包含 3 个项目的 JSON 文件
2. 点击"导入"按钮
3. 选择 JSON 文件
4. 查看预览信息
5. 选择"合并模式"
6. 点击"确认导入"
验证：
□ 预览信息显示正确（3 个项目）
□ 导入后总计 5 个项目
□ 原有 2 个项目数据未改变
□ 新增 3 个项目显示正确
□ 侧边栏刷新显示所有项目
```

**T3: 导入功能（覆盖模式）**
```
前置条件：已有 2 个项目
步骤：
1. 准备包含 3 个项目的 JSON 文件
2. 点击"导入"按钮
3. 选择 JSON 文件
4. 选择"覆盖模式"
5. 确认警告对话框
6. 点击"确认导入"
验证：
□ 显示警告提示
□ 导入后只有 3 个项目
□ 原有 2 个项目已清除
□ 新项目数据完整
```

**T4: 清空数据功能**
```
前置条件：已有 5 个项目
步骤：
1. 点击"清空"按钮
2. 在输入框输入"确认删除"
3. 点击"清空数据"按钮
验证：
□ 输入正确文本前按钮禁用
□ 输入正确文本后按钮启用
□ 确认后所有项目被清空
□ 侧边栏显示空状态
□ LocalStorage 数据已清除
```

**T5: 统计信息显示**
```
前置条件：创建 1 个项目，2 个迭代
步骤：
1. 迭代 1 完成 9/9 步骤
2. 迭代 2 完成 5/9 步骤
3. 查看侧边栏项目节点
验证：
□ 项目统计显示 14/18
□ 迭代 1 显示 9/9
□ 迭代 2 显示 5/9
□ 标记新步骤完成后统计立即更新
```

#### Phase 2: 边界情况测试

**T6: 格式错误处理**
```
步骤：
1. 尝试导入纯文本文件 → 应显示"文件格式错误"
2. 尝试导入缺少 projects 字段的 JSON → 应显示"缺少项目数组"
3. 尝试导入空项目数组 → 应显示"文件中没有项目数据"
4. 尝试导入包含无效项目的 JSON → 应显示具体错误位置
```

**T7: 大文件处理**
```
步骤：
1. 创建 100 个项目
2. 尝试导出 → 应在 1 秒内完成或显示进度提示
3. 尝试导入超过 10MB 的文件 → 应显示"文件过大"警告
```

**T8: ID 冲突处理**
```
步骤：
1. 创建项目 A（id: project_123）
2. 导出数据
3. 再次导入相同数据（合并模式）
验证：
□ 导入的项目 ID 被自动修改
□ 项目名称添加"(导入)"后缀
□ 两个项目并存，数据独立
```

#### Phase 3: UI/UX 测试

**T9: 侧边栏交互**
```
步骤：
1. 点击项目名展开/折叠迭代列表
2. 点击迭代名切换到工作流视图
3. 连续快速点击多个项目
验证：
□ 展开/折叠动画流畅
□ 迭代列表正确显示/隐藏
□ 主内容区切换无闪烁
□ 当前选中状态高亮显示
```

**T10: Toast 通知**
```
验证各种操作的 Toast 提示：
□ 导出成功 → "✅ 数据已导出"
□ 导入成功 → "✅ 已导入 X 个项目"
□ 清空成功 → "✅ 所有数据已清空"
□ 格式错误 → "❌ 文件格式错误..."
□ Toast 3 秒后自动消失
□ 多个 Toast 不重叠
```

#### Phase 4: 跨平台测试

**T11: 浏览器兼容性**
```
在以下浏览器测试完整流程：
□ Chrome 90+ (Windows / Mac / Linux)
□ Firefox 88+ (Windows / Mac / Linux)
□ Safari 14+ (Mac / iOS)
□ Edge 90+ (Windows)
```

**T12: 响应式布局**
```
测试不同屏幕尺寸：
□ 桌面（1920x1080）
□ 笔记本（1366x768）
□ 平板（768x1024）
□ 手机（375x667）
验证：
□ 侧边栏在移动端自动隐藏或折叠
□ 按钮和输入框大小适配触摸
□ 模态框在小屏幕上可滚动
```

**T13: GitHub Pages 部署测试**
```
步骤：
1. 部署到 GitHub Pages
2. 访问在线 URL
3. 测试完整功能流程
验证：
□ 页面正常加载
□ 所有功能可用
□ LocalStorage 工作正常
□ 文件导出下载正常
□ 无控制台错误
```

---

## 🔒 与 Constitution 的一致性检查

### ✅ 简洁性与反抽象
- [x] 使用原生 File API（Blob、FileReader）
- [x] 无外部 JavaScript 库
- [x] 无框架依赖（React、Vue 等）
- [x] 函数平均长度 < 50 行
- [x] 嵌套深度 < 3 层

### ✅ 架构完整性
- [x] 保持单文件架构（模式 A-1）
- [x] LocalStorage 作为唯一数据层（模式 A-2）
- [x] 单向数据流（模式 A-3）
- [x] 函数式编程优先（模式 A-4）
- [x] 新增代码约 800 行（总计 ~2800 行，未超 3000 行限制）

### ✅ 整洁和模块化代码
- [x] 函数按功能分组（导出、导入、统计、UI）
- [x] 命名遵循驼峰规范
- [x] 关键业务逻辑有注释
- [x] 使用 ES6+ 语法（箭头函数、解构、模板字符串）

### ✅ 规范术语
- [x] 使用 Project、Iteration、Cycle 等标准术语
- [x] 避免 Workspace、Sprint、Loop 等别名
- [x] 函数命名清晰（exportAllProjects、importProjects）

### ✅ 集成优先测试
- [x] 定义 13 个端到端测试场景
- [x] 覆盖完整用户流程
- [x] 包含边界情况和错误处理
- [x] 无孤立的单元测试

---

## 📦 实现分解（下一步：Tasks）

本 Plan 完成后，将在 `/speckit.tasks` 阶段分解为以下任务组：

### 任务预览
```
T001: 调整布局为左侧项目树结构
T002: 实现项目展开/折叠逻辑
T003: 实现导出所有项目功能
T004: 实现导出单个项目功能
T005: 实现导入文件选择和预览
T006: 实现数据验证和修复逻辑
T007: 实现导入合并模式
T008: 实现导入覆盖模式
T009: 实现清空数据功能
T010: 实现统计信息计算
T011: 实现 Toast 通知系统
T012: 更新 CSS 样式（侧边栏、模态框）
T013: 手动测试和 Bug 修复
```

---

## 🎯 成功指标

本次实现成功的标准：

| 指标 | 目标 | 验证方法 |
|-----|------|---------|
| 功能完成度 | 100% | 所有 4 个用户故事的验收标准通过 |
| 性能达标率 | 100% | 所有操作在目标时间内完成 |
| 测试通过率 | 100% | 所有 13 个测试场景通过 |
| 浏览器兼容性 | 4 个主流浏览器 | Chrome、Firefox、Safari、Edge 均可用 |
| 代码质量 | 无 CRITICAL 违规 | Constitution 检查清单全部通过 |
| 文件大小 | < 150KB | 最终 index.html 大小 |

---

## 📝 风险评估

| 风险 | 概率 | 影响 | 缓解措施 |
|-----|------|------|---------|
| 导入大文件导致浏览器卡死 | 中 | 高 | 限制文件大小 < 10MB，显示加载提示 |
| JSON 格式错误导致数据丢失 | 中 | 高 | 先验证再写入，失败时保留原数据 |
| ID 冲突导致数据覆盖 | 低 | 中 | 合并模式下重新生成冲突 ID |
| 移动端文件选择器不兼容 | 低 | 中 | 测试 iOS Safari，提供替代方案 |
| LocalStorage 配额超限 | 低 | 中 | 导出前检查剩余空间，提示用户 |

---

## 🚀 下一步行动

**当前阶段**: ✅ Plan 完成

**下一阶段**: `/speckit.tasks`

在 Tasks 阶段将完成：
1. 将上述实现方案分解为可执行的任务
2. 确定任务执行顺序（TDD 优先）
3. 标记可并行任务
4. 估算每个任务的工作量

**预计总工作量**: 8-12 小时（含测试和修复）

---

**此计划已准备好进入 Tasks 分解阶段！**
