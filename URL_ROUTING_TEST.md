# URL路由功能测试指南

## 功能概述

此更新为SpecKit Manager添加了基于URL的项目路由功能，允许用户通过URL直接访问特定项目和迭代。

## 实现的功能

### 1. URL格式

- **项目页面**: `#/project/PROJECT_ID`
- **迭代页面**: `#/project/PROJECT_ID/iteration/ITERATION_ID`
- **首页**: `#/` 或无hash

### 2. 核心功能

1. **URL导航**: 用户可以通过URL直接访问特定项目或迭代
2. **浏览器历史**: 支持浏览器的前进/后退按钮
3. **书签支持**: 可以将特定项目/迭代添加到浏览器书签
4. **URL分享**: 可以分享URL给其他人直接访问特定项目
5. **自动URL更新**: 当用户选择项目/迭代时，URL自动更新

### 3. 修改的函数

#### 新增函数:
- `getProjectURLState()`: 解析URL hash中的项目状态
- `setProjectURL(projectId, iterationId, skipHashChange)`: 设置URL hash
- `handleHashChange()`: 处理URL hash变化
- `selectProjectFromURL(projectId, iterationId)`: 从URL恢复项目选择

#### 修改的现有函数:
- `init()`: 启动时从URL恢复状态
- `selectProject(projectId)`: 选择项目时更新URL
- `selectIteration(projectId, iterationId)`: 选择迭代时更新URL
- `handleProjectClick(projectId)`: 点击项目时更新URL
- `addProject()`: 创建新项目时更新URL
- `addIteration()`: 创建新迭代时更新URL
- `deleteProject(projectId)`: 删除项目时更新URL
- `deleteIteration(projectId, iterationId)`: 删除迭代时更新URL

#### 新增事件监听器:
- `window.addEventListener('hashchange', handleHashChange)`: 监听URL变化

## 测试步骤

### 测试1: 基本URL导航

1. 在浏览器中打开 `index.html`
2. 创建至少2个项目，每个项目包含2个迭代
3. 选择一个项目，观察URL是否变为 `#/project/PROJECT_ID`
4. 选择一个迭代，观察URL是否变为 `#/project/PROJECT_ID/iteration/ITERATION_ID`
5. 刷新页面，验证是否保持在相同的项目/迭代

### 测试2: 浏览器历史

1. 选择项目A的迭代1
2. 选择项目A的迭代2
3. 选择项目B的迭代1
4. 点击浏览器后退按钮，验证是否返回到项目A的迭代2
5. 再次点击后退，验证是否返回到项目A的迭代1
6. 点击前进按钮，验证是否前进到项目A的迭代2

### 测试3: 直接URL访问

1. 选择一个项目/迭代
2. 复制浏览器地址栏中的完整URL
3. 打开新标签页
4. 粘贴URL并访问
5. 验证是否直接打开了对应的项目/迭代

### 测试4: 书签功能

1. 选择一个特定的项目/迭代
2. 将页面添加到书签
3. 选择其他项目/迭代
4. 点击刚才创建的书签
5. 验证是否返回到书签保存的项目/迭代

### 测试5: 创建和删除

1. **创建项目**: 创建新项目，验证URL是否自动更新为新项目
2. **创建迭代**: 在项目中创建新迭代，验证URL是否更新
3. **删除迭代**: 删除当前选中的迭代，验证URL是否更新到其他迭代
4. **删除项目**: 删除当前选中的项目，验证URL是否更新到其他项目

### 测试6: 无效URL处理

1. 手动修改URL为一个不存在的项目ID: `#/project/invalid_id`
2. 按回车访问
3. 验证是否显示"项目未找到"提示
4. 验证URL是否被清除或重定向到首页

### 测试7: 手动URL编辑

1. 选择一个项目/迭代
2. 在浏览器地址栏手动修改URL到另一个有效的项目/迭代
3. 按回车
4. 验证是否正确导航到新的项目/迭代

## 预期结果

- ✅ 所有URL变化都应正确反映在地址栏
- ✅ 刷新页面后应保持在相同的项目/迭代
- ✅ 浏览器前进/后退按钮应正常工作
- ✅ 直接访问URL应打开对应的项目/迭代
- ✅ 无效的URL应显示友好的错误提示
- ✅ 创建/删除操作后URL应自动更新

## 注意事项

1. **本地存储**: URL路由功能依赖于localStorage中的项目数据
2. **项目ID**: 每个项目都有唯一的ID（格式: `project_TIMESTAMP`）
3. **迭代ID**: 每个迭代都有唯一的ID（格式: `iteration_TIMESTAMP`）
4. **循环避免**: 使用 `skipHashChange` 标志避免无限循环
5. **向后兼容**: 如果URL中没有hash，应用会正常显示默认项目

## 技术实现细节

### URL格式设计

采用hash-based路由（而非History API）的原因：
- 不需要服务器端配置
- 兼容静态文件托管
- 简单可靠
- 支持所有现代浏览器

### 状态同步

URL变化的触发点：
1. 用户点击项目/迭代
2. 用户创建新项目/迭代
3. 用户删除项目/迭代（当前选中的）
4. 浏览器前进/后退
5. 用户手动编辑URL

### 错误处理

- 无效的项目ID → 显示toast提示并清除URL
- 无效的迭代ID → 回退到只显示项目
- 空URL → 显示首页/默认项目

## 兼容性

- 支持所有现代浏览器（Chrome, Firefox, Safari, Edge）
- 向后兼容：没有URL hash时使用默认行为
- 不影响现有的localStorage功能
- 不影响Firebase同步功能
