# 任务分解 (Tasks)

> **规范**: 002-data-management-enhancements
> **创建时间**: 2025-10-15
> **开发模式**: TDD（测试驱动开发）
> **预计总工作量**: 8-12 小时

---

## 📋 任务总览

本次迭代共分解为 **15 个任务**，按照 TDD 原则，优先实现测试和核心功能。

### 任务分组

| 阶段 | 任务编号 | 任务数 | 预计时间 |
|-----|---------|-------|---------|
| **阶段 1: 布局重构** | T001-T002 | 2 | 2h |
| **阶段 2: 导出功能** | T003-T004 | 2 | 1.5h |
| **阶段 3: 导入功能** | T005-T008 | 4 | 3h |
| **阶段 4: 数据管理** | T009-T010 | 2 | 1h |
| **阶段 5: 统计和通知** | T011-T012 | 2 | 1.5h |
| **阶段 6: 样式优化** | T013 | 1 | 1h |
| **阶段 7: 测试和修复** | T014-T015 | 2 | 2h |

---

## 🔧 任务详细列表

### 📦 阶段 1: 布局重构

#### T001: 重构为左侧项目树布局
**优先级**: 🔴 高
**类型**: 重构
**预计时间**: 1.5h
**依赖**: 无
**可并行**: 否

**描述**:
将当前的顶部标签页布局改为左侧项目树 + 主内容区的布局。

**实现步骤**:
1. 修改整体布局结构：
   ```html
   <div class="main-layout">
     <div class="project-sidebar">
       <!-- 项目树 -->
     </div>
     <div class="main-content-area">
       <!-- 主内容区 -->
     </div>
   </div>
   ```

2. 移除现有的标签页导航 (`tabs-nav`)

3. 创建新的侧边栏结构：
   - 顶部工具栏（导出、导入、清空按钮）
   - 项目树容器
   - 底部新建项目按钮

4. 更新 CSS 网格布局：
   ```css
   .main-layout {
       display: grid;
       grid-template-columns: 280px 1fr;
       gap: 20px;
   }
   ```

5. 添加响应式断点（< 1024px 时侧边栏折叠）

**验收标准**:
- [ ] 页面显示左侧边栏和主内容区两栏布局
- [ ] 侧边栏宽度固定 280px
- [ ] 主内容区占据剩余空间
- [ ] 移动端侧边栏可折叠（< 1024px）
- [ ] 原有标签页导航已移除

---

#### T002: 实现项目树展开/折叠逻辑
**优先级**: 🔴 高
**类型**: 新功能
**预计时间**: 0.5h
**依赖**: T001
**可并行**: 否

**描述**:
实现项目节点的展开/折叠交互，点击项目名可切换迭代列表的显示/隐藏。

**实现步骤**:
1. 在项目数据中添加 `expanded` 字段：
   ```javascript
   project.expanded = true; // 默认展开
   ```

2. 实现展开/折叠函数：
   ```javascript
   function toggleProject(projectId) {
       const project = projects.find(p => p.id === projectId);
       if (!project) return;

       project.expanded = !project.expanded;
       saveProjects();
       renderProjectSidebar();
   }
   ```

3. 实现渲染项目树函数：
   ```javascript
   function renderProjectSidebar() {
       const tree = projects.map(project => {
           const stats = calculateProjectStats(project);
           const expandIcon = project.expanded ? '▼' : '▶';
           const expandedClass = project.expanded ? 'expanded' : 'collapsed';

           return `
               <div class="project-node ${expandedClass}">
                   <div class="project-header" onclick="toggleProject('${project.id}')">
                       <span class="expand-icon">${expandIcon}</span>
                       <span class="project-name">${project.name}</span>
                       <span class="project-stats">${stats.totalCompleted}/${stats.totalSteps}</span>
                   </div>
                   <div class="iteration-list">
                       ${renderIterationList(project)}
                   </div>
               </div>
           `;
       }).join('');

       document.getElementById('projectTree').innerHTML = tree;
   }
   ```

4. 实现迭代列表渲染：
   ```javascript
   function renderIterationList(project) {
       return project.iterations.map(iteration => {
           const completed = Object.values(iteration.completedSteps).filter(v => v).length;
           const activeClass = (selectedIterationId === iteration.id) ? 'active' : '';

           return `
               <div class="iteration-node ${activeClass}"
                    onclick="selectIteration('${project.id}', '${iteration.id}')">
                   <span class="iteration-name">${iteration.name}</span>
                   <span class="iteration-progress">${completed}/${commandSteps.length}</span>
               </div>
           `;
       }).join('');
   }
   ```

**验收标准**:
- [ ] 点击项目名可展开/折叠迭代列表
- [ ] 展开图标切换（▼ ↔ ▶）
- [ ] 折叠状态保存到 LocalStorage
- [ ] 刷新页面后展开状态保留
- [ ] 展开/折叠动画流畅（< 300ms）

---

### 💾 阶段 2: 导出功能

#### T003: 实现导出所有项目功能
**优先级**: 🔴 高
**类型**: 新功能
**预计时间**: 1h
**依赖**: 无
**可并行**: [P] 可与 T001-T002 并行开发

**描述**:
实现导出所有项目数据为 JSON 文件的功能。

**实现步骤**:
1. 创建导出数据生成函数：
   ```javascript
   function generateExportData() {
       return {
           schemaVersion: "1.0",
           exportDate: new Date().toISOString(),
           appVersion: "1.0.0",
           totalProjects: projects.length,
           totalIterations: projects.reduce((sum, p) => sum + p.iterations.length, 0),
           projects: projects
       };
   }
   ```

2. 实现导出所有项目函数：
   ```javascript
   function exportAllProjects() {
       // 检查项目数量
       if (projects.length === 0) {
           showToast('ℹ️ 当前没有项目可导出', 'info');
           return;
       }

       // 警告大量项目
       if (projects.length > 50) {
           if (!confirm(`您有 ${projects.length} 个项目，导出可能较慢。是否继续？`)) {
               return;
           }
       }

       // 生成导出数据
       const exportData = generateExportData();
       const jsonString = JSON.stringify(exportData, null, 2);

       // 创建 Blob 和下载链接
       const blob = new Blob([jsonString], { type: 'application/json' });
       const url = URL.createObjectURL(blob);
       const timestamp = Date.now();
       const filename = `speckit-backup-${timestamp}.json`;

       // 触发下载
       const a = document.createElement('a');
       a.href = url;
       a.download = filename;
       document.body.appendChild(a);
       a.click();
       document.body.removeChild(a);
       URL.revokeObjectURL(url);

       // 显示成功提示
       showToast('✅ 数据已导出', 'success');
   }
   ```

3. 在侧边栏工具栏添加导出按钮：
   ```html
   <button class="btn-export" onclick="exportAllProjects()">
       💾 导出
   </button>
   ```

**验收标准**:
- [ ] 点击"导出"按钮自动下载 JSON 文件
- [ ] 文件名格式为 `speckit-backup-{timestamp}.json`
- [ ] JSON 文件格式正确，可被解析
- [ ] 包含所有项目和迭代数据
- [ ] completedSteps、inputs、notes、cycleHistory 数据完整
- [ ] 空项目时显示提示信息
- [ ] 超过 50 个项目时显示确认对话框
- [ ] 导出成功后显示 Toast 提示

**测试命令**:
```javascript
// 在浏览器控制台测试
exportAllProjects();
// 检查下载的 JSON 文件内容
```

---

#### T004: 实现导出单个项目功能
**优先级**: 🟡 中
**类型**: 新功能
**预计时间**: 0.5h
**依赖**: T003
**可并行**: 否

**描述**:
在项目节点添加右键菜单或操作按钮，支持导出单个项目。

**实现步骤**:
1. 实现导出单个项目函数：
   ```javascript
   function exportProject(projectId) {
       const project = projects.find(p => p.id === projectId);
       if (!project) {
           showToast('❌ 项目不存在', 'error');
           return;
       }

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

   function sanitizeFilename(name) {
       return name.replace(/[^a-z0-9\u4e00-\u9fa5]/gi, '-').toLowerCase();
   }
   ```

2. 在项目节点添加操作按钮：
   ```html
   <div class="project-header">
       <!-- ... -->
       <div class="project-actions">
           <button class="btn-export-project"
                   onclick="event.stopPropagation(); exportProject('${project.id}')"
                   title="导出此项目">
               📤
           </button>
       </div>
   </div>
   ```

**验收标准**:
- [ ] 项目节点显示导出按钮
- [ ] 点击导出按钮只导出该项目
- [ ] 文件名包含项目名称（安全化处理）
- [ ] 不触发项目展开/折叠事件
- [ ] 导出成功后显示 Toast 提示

---

### 📥 阶段 3: 导入功能

#### T005: 实现文件选择和预览功能
**优先级**: 🔴 高
**类型**: 新功能
**预计时间**: 1h
**依赖**: 无
**可并行**: [P] 可与 T003-T004 并行开发

**描述**:
创建导入模态框，实现文件选择和预览信息显示。

**实现步骤**:
1. 创建导入模态框 HTML：
   ```html
   <div class="modal" id="importModal">
       <div class="modal-content">
           <h2>📂 导入项目数据</h2>

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

           <div class="import-preview" id="importPreview" style="display:none;">
               <h3>文件信息</h3>
               <ul>
                   <li>项目数量: <strong id="previewProjectCount">0</strong></li>
                   <li>迭代总数: <strong id="previewIterationCount">0</strong></li>
                   <li>导出时间: <strong id="previewExportDate">-</strong></li>
               </ul>
           </div>

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

2. 实现打开/关闭模态框：
   ```javascript
   function openImportModal() {
       document.getElementById('importModal').classList.add('active');
       resetImportModal();
   }

   function closeImportModal() {
       document.getElementById('importModal').classList.remove('active');
       resetImportModal();
   }

   function resetImportModal() {
       document.getElementById('importFileInput').value = '';
       document.getElementById('importPreview').style.display = 'none';
       document.getElementById('importModeSelector').style.display = 'none';
       document.getElementById('confirmImportBtn').disabled = true;
       window.pendingImportData = null;
   }
   ```

3. 实现文件选择处理：
   ```javascript
   function handleFileSelect(event) {
       const file = event.target.files[0];
       if (!file) return;

       // 检查文件大小（10MB 限制）
       if (file.size > 10 * 1024 * 1024) {
           showToast('❌ 文件过大（超过 10MB）', 'error');
           return;
       }

       // 检查文件类型
       if (!file.name.endsWith('.json')) {
           showToast('❌ 请选择 JSON 文件', 'error');
           return;
       }

       // 读取文件
       const reader = new FileReader();
       reader.onload = (e) => {
           try {
               const data = JSON.parse(e.target.result);
               handleFileLoaded(data);
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

   function handleFileLoaded(data) {
       // 验证数据（将在 T006 实现）
       const validation = validateImportData(data);
       if (!validation.valid) {
           showToast(`❌ ${validation.error}`, 'error');
           return;
       }

       // 显示预览
       showImportPreview(data);

       // 启用确认按钮
       document.getElementById('confirmImportBtn').disabled = false;

       // 保存待导入数据
       window.pendingImportData = data;
   }

   function showImportPreview(data) {
       document.getElementById('importPreview').style.display = 'block';
       document.getElementById('importModeSelector').style.display = 'block';

       const projectCount = data.totalProjects || data.projects.length;
       const iterationCount = data.totalIterations ||
           data.projects.reduce((sum, p) => sum + p.iterations.length, 0);

       document.getElementById('previewProjectCount').textContent = projectCount;
       document.getElementById('previewIterationCount').textContent = iterationCount;
       document.getElementById('previewExportDate').textContent =
           formatDateTime(data.exportDate);
   }
   ```

4. 添加导入按钮到侧边栏：
   ```html
   <button class="btn-import" onclick="openImportModal()">
       📂 导入
   </button>
   ```

**验收标准**:
- [ ] 点击"导入"按钮打开模态框
- [ ] 点击文件上传区域或拖拽文件可选择文件
- [ ] 只接受 .json 文件
- [ ] 文件大小超过 10MB 时显示错误提示
- [ ] 非 JSON 格式显示错误提示
- [ ] 成功加载文件后显示预览信息（项目数、迭代数、导出时间）
- [ ] 显示导入模式选择（合并/覆盖）
- [ ] "确认导入"按钮在未选择文件时禁用
- [ ] 点击"取消"关闭模态框并重置状态

---

#### T006: 实现数据验证逻辑
**优先级**: 🔴 高
**类型**: 新功能
**预计时间**: 1h
**依赖**: T005
**可并行**: 否

**描述**:
实现三层数据验证逻辑：基础格式验证、数据结构验证、数据修复。

**实现步骤**:
1. 实现基础格式验证：
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
           const result = validateProjectStructure(data.projects[i], i);
           if (!result.valid) {
               return result;
           }
       }

       return { valid: true };
   }
   ```

2. 实现项目结构验证：
   ```javascript
   function validateProjectStructure(project, index) {
       if (!project.id || !project.name) {
           return {
               valid: false,
               error: `项目 ${index + 1} 缺少必需字段（id 或 name）`
           };
       }

       if (!Array.isArray(project.iterations)) {
           return {
               valid: false,
               error: `项目"${project.name}"缺少迭代数组`
           };
       }

       if (project.iterations.length === 0) {
           return {
               valid: false,
               error: `项目"${project.name}"必须至少有一个迭代`
           };
       }

       // Level 3: 迭代结构验证
       for (let j = 0; j < project.iterations.length; j++) {
           const result = validateIterationStructure(
               project.iterations[j],
               project.name,
               j
           );
           if (!result.valid) {
               return result;
           }
       }

       return { valid: true };
   }
   ```

3. 实现迭代结构验证：
   ```javascript
   function validateIterationStructure(iteration, projectName, index) {
       if (!iteration.id || !iteration.name) {
           return {
               valid: false,
               error: `项目"${projectName}"的迭代 ${index + 1} 缺少必需字段（id 或 name）`
           };
       }

       return { valid: true };
   }
   ```

4. 实现数据修复函数：
   ```javascript
   function repairProjectData(project) {
       // 补全项目字段
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
           iteration.description = iteration.description || '';

           return iteration;
       });

       return project;
   }
   ```

**验收标准**:
- [ ] 导入纯文本文件 → 显示"数据格式错误"
- [ ] 导入缺少 projects 字段的 JSON → 显示"缺少项目数组"
- [ ] 导入空项目数组 → 显示"文件中没有项目数据"
- [ ] 导入缺少 id 字段的项目 → 显示具体错误位置
- [ ] 导入缺少 iterations 的项目 → 显示具体项目名称
- [ ] 导入缺少可选字段的数据 → 自动补全默认值
- [ ] 验证失败时不修改现有数据

**测试命令**:
```javascript
// 测试各种错误格式
validateImportData({});  // 缺少 projects
validateImportData({ projects: [] });  // 空数组
validateImportData({ projects: [{ name: 'Test' }] });  // 缺少 id
```

---

#### T007: 实现导入合并模式
**优先级**: 🔴 高
**类型**: 新功能
**预计时间**: 0.5h
**依赖**: T006
**可并行**: 否

**描述**:
实现导入合并模式，保留现有项目，添加新项目，处理 ID 冲突。

**实现步骤**:
1. 实现合并导入逻辑：
   ```javascript
   function importMergeMode(importData) {
       // 修复数据
       const repairedProjects = importData.projects.map(repairProjectData);

       // 处理每个导入的项目
       repairedProjects.forEach(importedProject => {
           const existingIndex = projects.findIndex(p => p.id === importedProject.id);

           if (existingIndex >= 0) {
               // ID 冲突：重新生成 ID
               importedProject.id = generateUniqueProjectId();
               importedProject.name += ' (导入)';

               // 为所有迭代也重新生成 ID
               importedProject.iterations.forEach(iteration => {
                   iteration.id = generateUniqueIterationId();
               });
           }

           // 添加到项目列表
           projects.push(importedProject);
       });

       return repairedProjects.length;
   }

   function generateUniqueProjectId() {
       return 'project_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
   }

   function generateUniqueIterationId() {
       return 'iteration_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
   }
   ```

**验收标准**:
- [ ] 导入后项目总数 = 原有数量 + 导入数量
- [ ] 原有项目数据不变
- [ ] ID 冲突的项目自动重命名（添加"(导入)"后缀）
- [ ] ID 冲突的项目生成新的唯一 ID
- [ ] 所有迭代 ID 也重新生成（避免冲突）

---

#### T008: 实现导入覆盖模式
**优先级**: 🔴 高
**类型**: 新功能
**预计时间**: 0.5h
**依赖**: T006
**可并行**: 否

**描述**:
实现导入覆盖模式，清空现有数据并完全替换，包含二次确认。

**实现步骤**:
1. 实现覆盖导入逻辑：
   ```javascript
   function importReplaceMode(importData) {
       // 显示警告确认
       const confirmText = `⚠️ 确定要清空所有现有数据并导入吗？

当前有 ${projects.length} 个项目将被删除！
此操作不可撤销！

点击"确定"继续，点击"取消"返回。`;

       if (!confirm(confirmText)) {
           return null;
       }

       // 修复数据
       const repairedProjects = importData.projects.map(repairProjectData);

       // 完全替换
       projects = repairedProjects;

       return repairedProjects.length;
   }
   ```

2. 实现确认导入主函数：
   ```javascript
   function confirmImport() {
       const mode = document.querySelector('input[name="importMode"]:checked').value;
       const importData = window.pendingImportData;

       if (!importData) {
           showToast('❌ 无待导入数据', 'error');
           return;
       }

       try {
           let importedCount;

           if (mode === 'replace') {
               importedCount = importReplaceMode(importData);
               if (importedCount === null) {
                   // 用户取消操作
                   return;
               }
           } else {
               importedCount = importMergeMode(importData);
           }

           // 保存到 LocalStorage
           saveProjects();

           // 关闭模态框
           closeImportModal();

           // 刷新界面
           renderProjectSidebar();
           renderMainContent();

           // 显示成功消息
           const modeText = mode === 'replace' ? '覆盖导入' : '合并导入';
           showToast(`✅ ${modeText}成功：${importedCount} 个项目`, 'success');

       } catch (error) {
           showToast('❌ 导入失败：' + error.message, 'error');
           console.error('Import error:', error);
       }
   }
   ```

**验收标准**:
- [ ] 选择覆盖模式时显示警告确认对话框
- [ ] 确认对话框显示当前项目数量
- [ ] 点击"取消"不执行导入
- [ ] 点击"确定"清空现有数据
- [ ] 导入后只显示新导入的项目
- [ ] 导入成功后显示 Toast 提示

---

### 🗑️ 阶段 4: 数据管理

#### T009: 实现清空数据功能
**优先级**: 🟡 中
**类型**: 新功能
**预计时间**: 0.5h
**依赖**: 无
**可并行**: [P] 可与其他任务并行

**描述**:
实现清空所有数据功能，包含输入确认文本的二次验证。

**实现步骤**:
1. 创建清空数据模态框：
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

2. 实现清空数据逻辑：
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

   function closeClearModal() {
       document.getElementById('clearModal').classList.remove('active');
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
   ```

3. 添加清空按钮到侧边栏：
   ```html
   <button class="btn-clear" onclick="openClearModal()">
       🗑️ 清空
   </button>
   ```

**验收标准**:
- [ ] 点击"清空"按钮打开确认模态框
- [ ] 模态框显示警告文案（红色主题）
- [ ] 输入"确认删除"前按钮禁用
- [ ] 输入正确文本后按钮启用
- [ ] 点击"清空数据"清除所有项目
- [ ] LocalStorage 数据被清空
- [ ] 界面刷新显示空状态
- [ ] 显示成功 Toast 提示
- [ ] 空项目列表时点击清空显示提示

---

#### T010: 实现项目统计信息计算
**优先级**: 🟡 中
**类型**: 新功能
**预计时间**: 0.5h
**依赖**: 无
**可并行**: [P] 可与其他任务并行

**描述**:
实现项目和迭代的统计信息计算函数。

**实现步骤**:
1. 实现项目统计计算：
   ```javascript
   function calculateProjectStats(project) {
       const totalIterations = project.iterations.length;
       let totalCompleted = 0;
       let totalSteps = 0;

       project.iterations.forEach(iteration => {
           const completed = Object.values(iteration.completedSteps)
               .filter(v => v).length;
           totalCompleted += completed;
           totalSteps += commandSteps.length;
       });

       const percentage = totalSteps > 0
           ? Math.round((totalCompleted / totalSteps) * 100)
           : 0;

       return {
           totalIterations,
           totalCompleted,
           totalSteps,
           percentage,
           createdAt: project.createdAt
       };
   }
   ```

2. 实现迭代统计计算：
   ```javascript
   function calculateIterationStats(iteration) {
       const totalSteps = commandSteps.length;
       const completedSteps = Object.values(iteration.completedSteps)
           .filter(v => v).length;
       const percentage = Math.round((completedSteps / totalSteps) * 100);

       // 按循环颜色分组
       const cycleGroups = {};
       Object.entries(iteration.cycleHistory).forEach(([stepId, cycle]) => {
           if (iteration.completedSteps[stepId]) {
               cycleGroups[cycle] = (cycleGroups[cycle] || 0) + 1;
           }
       });

       return {
           totalSteps,
           completedSteps,
           percentage,
           cycleGroups
       };
   }
   ```

3. 实现时间格式化函数：
   ```javascript
   function formatRelativeTime(dateString) {
       if (!dateString) return '-';

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

4. 在侧边栏项目节点显示统计信息：
   ```javascript
   // 在 renderProjectSidebar 中使用
   const stats = calculateProjectStats(project);
   // 显示：14/27 (52%)
   ```

**验收标准**:
- [ ] 侧边栏项目节点显示完成步骤数 / 总步骤数
- [ ] 统计信息实时更新（标记步骤完成后）
- [ ] 百分比计算准确（四舍五入）
- [ ] 相对时间格式友好（今天、昨天、X天前）
- [ ] 日期时间格式符合中文习惯

---

### 📢 阶段 5: 统计和通知

#### T011: 实现 Toast 通知系统
**优先级**: 🔴 高
**类型**: 新功能
**预计时间**: 0.5h
**依赖**: 无
**可并行**: [P] 可与其他任务并行

**描述**:
实现全局 Toast 通知系统，用于显示操作反馈。

**实现步骤**:
1. 实现 Toast 通知函数：
   ```javascript
   function showToast(message, type = 'info') {
       // 创建 Toast 元素
       const toast = document.createElement('div');
       toast.className = `toast toast-${type}`;
       toast.textContent = message;

       // 添加到页面
       document.body.appendChild(toast);

       // 触发显示动画
       setTimeout(() => toast.classList.add('show'), 10);

       // 3 秒后隐藏并移除
       setTimeout(() => {
           toast.classList.remove('show');
           setTimeout(() => {
               if (toast.parentNode) {
                   document.body.removeChild(toast);
               }
           }, 300);
       }, 3000);
   }
   ```

2. 添加 Toast CSS 样式：
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
       transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
       z-index: 10000;
       max-width: 400px;
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

3. 在所有操作中添加 Toast 提示：
   - 导出成功/失败
   - 导入成功/失败
   - 清空成功
   - 验证错误
   - 文件大小错误

**验收标准**:
- [ ] Toast 从右下角滑入
- [ ] 显示 3 秒后自动消失
- [ ] 支持 4 种类型（success、error、info、warning）
- [ ] 多个 Toast 不重叠（自动堆叠）
- [ ] 移除动画流畅
- [ ] 移动端显示位置合适

**测试命令**:
```javascript
// 测试各种类型的 Toast
showToast('✅ 操作成功', 'success');
showToast('❌ 操作失败', 'error');
showToast('ℹ️ 提示信息', 'info');
showToast('⚠️ 警告信息', 'warning');
```

---

#### T012: 更新主内容区渲染逻辑
**优先级**: 🟡 中
**类型**: 重构
**预计时间**: 1h
**依赖**: T001, T002
**可并行**: 否

**描述**:
更新主内容区的渲染逻辑，支持三种视图模式（概览/项目/迭代）。

**实现步骤**:
1. 定义视图模式常量：
   ```javascript
   const VIEW_MODES = {
       OVERVIEW: 'overview',      // 所有项目概览
       PROJECT: 'project',        // 单个项目详情
       ITERATION: 'iteration'     // 单个迭代工作流
   };

   let currentView = VIEW_MODES.OVERVIEW;
   let selectedProjectId = null;
   let selectedIterationId = null;
   ```

2. 实现视图切换函数：
   ```javascript
   function switchView(mode, projectId = null, iterationId = null) {
       currentView = mode;
       selectedProjectId = projectId;
       selectedIterationId = iterationId;
       renderMainContent();
   }

   function selectIteration(projectId, iterationId) {
       switchView(VIEW_MODES.ITERATION, projectId, iterationId);
   }
   ```

3. 实现主内容区渲染：
   ```javascript
   function renderMainContent() {
       const container = document.getElementById('mainContentArea');

       switch (currentView) {
           case VIEW_MODES.OVERVIEW:
               container.innerHTML = renderOverviewMode();
               break;
           case VIEW_MODES.PROJECT:
               container.innerHTML = renderProjectMode(selectedProjectId);
               break;
           case VIEW_MODES.ITERATION:
               container.innerHTML = renderIterationMode(selectedProjectId, selectedIterationId);
               break;
       }
   }

   function renderOverviewMode() {
       if (projects.length === 0) {
           return `
               <div class="empty-state">
                   <div class="empty-state-icon">📦</div>
                   <div class="empty-state-text">
                       <h2>暂无项目</h2>
                       <p>点击左侧"新建项目"开始使用 Spec Kit</p>
                   </div>
               </div>
           `;
       }

       const cards = projects.map(project => {
           const stats = calculateProjectStats(project);
           return `
               <div class="project-overview-card">
                   <div class="project-header">
                       <div class="project-name">${project.name}</div>
                       <button class="delete-project-btn"
                               onclick="deleteProject('${project.id}')">
                           删除
                       </button>
                   </div>
                   <div class="project-stats-summary">
                       <div class="stat-item">
                           <span class="stat-label">📊 总进度</span>
                           <span class="stat-value">${stats.totalCompleted}/${stats.totalSteps} (${stats.percentage}%)</span>
                       </div>
                       <div class="stat-item">
                           <span class="stat-label">🔄 迭代数</span>
                           <span class="stat-value">${stats.totalIterations}</span>
                       </div>
                       <div class="stat-item">
                           <span class="stat-label">⏱️ 创建于</span>
                           <span class="stat-value">${formatRelativeTime(stats.createdAt)}</span>
                       </div>
                   </div>
               </div>
           `;
       }).join('');

       return `
           <div class="overview-grid">
               ${cards}
           </div>
       `;
   }

   function renderIterationMode(projectId, iterationId) {
       const project = projects.find(p => p.id === projectId);
       if (!project) return '<div>项目不存在</div>';

       const iteration = project.iterations.find(i => i.id === iterationId);
       if (!iteration) return '<div>迭代不存在</div>';

       // 渲染迭代工作流（保持原有逻辑）
       return renderIterationWorkflow(project, iteration);
   }
   ```

**验收标准**:
- [ ] 初始加载显示概览模式
- [ ] 概览模式显示所有项目卡片
- [ ] 点击侧边栏迭代切换到迭代模式
- [ ] 迭代模式显示完整工作流
- [ ] 空项目时显示空状态引导
- [ ] 视图切换无闪烁
- [ ] 主内容区可滚动

---

### 🎨 阶段 6: 样式优化

#### T013: 添加新组件 CSS 样式
**优先级**: 🟡 中
**类型**: 样式
**预计时间**: 1h
**依赖**: T001-T012
**可并行**: 否

**描述**:
添加所有新增组件的 CSS 样式，确保视觉一致性。

**实现步骤**:
1. 添加侧边栏样式（已在 plan.md 中定义）
2. 添加工具栏按钮样式
3. 添加导入模态框样式
4. 添加清空模态框样式
5. 添加 Toast 通知样式
6. 添加统计信息样式
7. 添加响应式断点样式

**关键 CSS 组件**:
- `.project-sidebar` - 侧边栏容器
- `.project-tree` - 项目树
- `.project-node` - 项目节点
- `.iteration-node` - 迭代节点
- `.file-upload-area` - 文件上传区
- `.import-preview` - 导入预览
- `.radio-option` - 单选选项
- `.modal-danger` - 危险模态框
- `.toast` - 通知提示
- `.project-stats-summary` - 统计信息

**验收标准**:
- [ ] 所有组件样式与现有设计一致
- [ ] 颜色使用项目主题色
- [ ] 按钮悬停效果流畅
- [ ] 动画时长合理（200-300ms）
- [ ] 阴影和圆角符合设计规范
- [ ] 移动端布局合适（< 768px）
- [ ] 深色背景上文字可读性好

---

### 🧪 阶段 7: 测试和修复

#### T014: 执行手动测试清单
**优先级**: 🔴 高
**类型**: 测试
**预计时间**: 1.5h
**依赖**: T001-T013
**可并行**: 否

**描述**:
按照 plan.md 中定义的 13 个测试场景执行完整测试。

**测试场景**:
1. **T1**: 导出功能测试
2. **T2**: 导入功能测试（合并模式）
3. **T3**: 导入功能测试（覆盖模式）
4. **T4**: 清空数据功能测试
5. **T5**: 统计信息显示测试
6. **T6**: 格式错误处理测试
7. **T7**: 大文件处理测试
8. **T8**: ID 冲突处理测试
9. **T9**: 侧边栏交互测试
10. **T10**: Toast 通知测试
11. **T11**: 浏览器兼容性测试
12. **T12**: 响应式布局测试
13. **T13**: GitHub Pages 部署测试

**测试记录**:
创建测试记录文档：`specs/002-data-management-enhancements/test-report.md`

记录格式：
```markdown
## T1: 导出功能测试
- [ ] 测试步骤 1
- [ ] 测试步骤 2
- [x] 测试步骤 3 ✅
- [ ] 发现问题：xxx
```

**验收标准**:
- [ ] 所有 13 个测试场景通过
- [ ] 记录所有发现的 Bug
- [ ] 性能指标达标
- [ ] 跨浏览器测试通过
- [ ] 移动端体验良好

---

#### T015: Bug 修复和优化
**优先级**: 🔴 高
**类型**: 修复
**预计时间**: 0.5h
**依赖**: T014
**可并行**: 否

**描述**:
修复测试阶段发现的所有 Bug，优化用户体验。

**常见问题预测**:
1. **文件上传后预览不显示** → 检查事件绑定
2. **导入后界面未刷新** → 确保调用 render 函数
3. **Toast 消息重叠** → 调整 z-index 和定位
4. **移动端侧边栏遮挡内容** → 添加折叠逻辑
5. **大文件导入卡顿** → 添加加载提示

**修复流程**:
1. 在测试报告中标记 Bug
2. 逐个修复并验证
3. 回归测试相关场景
4. 更新测试报告状态

**验收标准**:
- [ ] 所有 CRITICAL Bug 已修复
- [ ] 所有 WARNING Bug 已修复或记录为已知问题
- [ ] 回归测试通过
- [ ] 代码符合 Constitution 标准

---

## 📊 任务依赖关系图

```
T001 (布局重构) ─────────────────┐
                                 ↓
T002 (展开折叠) ─────────────────┤
                                 ↓
T003 (导出所有) ─┐               ↓
                 ↓               ↓
T004 (导出单个) ─┘               ↓
                                 ↓
T005 (文件预览) ─┐               ↓
                 ↓               ↓
T006 (数据验证) ─┤               ↓
                 ↓               ↓
T007 (合并导入) ─┤               ↓
                 ↓               ↓
T008 (覆盖导入) ─┘               ↓
                                 ↓
T009 (清空数据) ─────────────────┤
                                 ↓
T010 (统计计算) ─────────────────┤
                                 ↓
T011 (Toast通知) ─────────────────┤
                                 ↓
T012 (主区渲染) ─────────────────┤
                                 ↓
T013 (CSS样式) ──────────────────┤
                                 ↓
T014 (手动测试) ─────────────────┤
                                 ↓
T015 (Bug修复) ──────────────────┘
```

**可并行任务**:
- T003-T004 可与 T001-T002 并行
- T005-T008 可与 T003-T004 并行
- T009-T011 可相互并行

---

## ⏱️ 开发时间估算

### 按阶段估算

| 阶段 | 时间 | 备注 |
|-----|------|------|
| 阶段 1: 布局重构 | 2h | 涉及大量 HTML/CSS 改动 |
| 阶段 2: 导出功能 | 1.5h | 相对简单，原生 API |
| 阶段 3: 导入功能 | 3h | 包含验证逻辑，较复杂 |
| 阶段 4: 数据管理 | 1h | 清空和统计功能 |
| 阶段 5: 统计通知 | 1.5h | Toast 和渲染逻辑 |
| 阶段 6: 样式优化 | 1h | CSS 编写 |
| 阶段 7: 测试修复 | 2h | 完整测试流程 |
| **总计** | **12h** | 约 1.5 个工作日 |

### 按优先级估算

| 优先级 | 任务数 | 时间 |
|-------|--------|------|
| 🔴 高 | 10 | 9h |
| 🟡 中 | 5 | 3h |
| **总计** | **15** | **12h** |

---

## ✅ Definition of Done (DoD)

每个任务完成的标准：

### 代码质量
- [ ] 函数长度 < 50 行（渲染函数可例外至 100 行）
- [ ] 嵌套深度 < 3 层
- [ ] 关键逻辑有注释
- [ ] 变量命名清晰

### 功能完整性
- [ ] 所有验收标准通过
- [ ] 无控制台错误
- [ ] 边界情况处理
- [ ] 错误提示友好

### 用户体验
- [ ] 操作响应 < 100ms
- [ ] 动画流畅
- [ ] Toast 提示及时
- [ ] 移动端可用

### Constitution 一致性
- [ ] 符合简洁性原则
- [ ] 符合架构完整性
- [ ] 使用规范术语
- [ ] 无 CRITICAL 违规

---

## 🚀 实施建议

### 推荐实施顺序

**Day 1 (上午 4h)**:
1. T001: 布局重构 (1.5h)
2. T002: 展开折叠 (0.5h)
3. T003: 导出所有 (1h)
4. T011: Toast 通知 (0.5h)
5. 测试导出功能

**Day 1 (下午 4h)**:
6. T005: 文件预览 (1h)
7. T006: 数据验证 (1h)
8. T007: 合并导入 (0.5h)
9. T008: 覆盖导入 (0.5h)
10. 测试导入功能

**Day 2 (上午 4h)**:
11. T009: 清空数据 (0.5h)
12. T010: 统计计算 (0.5h)
13. T012: 主区渲染 (1h)
14. T013: CSS 样式 (1h)
15. T004: 导出单个 (0.5h)

**Day 2 (下午 2h)**:
16. T014: 手动测试 (1.5h)
17. T015: Bug 修复 (0.5h)

### 开发提示

1. **频繁保存**: 每完成一个小功能就保存 `index.html`
2. **浏览器测试**: 在 Chrome 开发者工具中实时测试
3. **数据备份**: 测试前导出现有数据
4. **版本控制**: 每完成一个任务提交一次 Git
5. **文档更新**: 同步更新 `README.md`

---

## 📝 下一步行动

**当前阶段**: ✅ Tasks 完成

**下一阶段**: `/speckit.implement`

在 Implement 阶段将：
1. 按照上述任务列表逐个实现
2. 遵循 TDD 原则（测试驱动开发）
3. 每完成一个任务标记完成状态
4. 发现问题及时记录和修复

**预计开始时间**: 立即开始
**预计完成时间**: 1.5 个工作日后

---

**此任务列表已准备好进入实施阶段！**
