#!/bin/bash

# Spec Kit 自动化测试启动脚本
# Run automated tests for Spec Kit MVP

echo "🧪 Spec Kit 自动化测试"
echo "===================="
echo ""
echo "正在打开测试页面..."
echo ""

# Detect OS and open test page
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open test-automation.html
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    xdg-open test-automation.html
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    # Windows (Git Bash or Cygwin)
    start test-automation.html
else
    echo "❌ 无法检测操作系统，请手动打开 test-automation.html"
    exit 1
fi

echo "✅ 测试页面已在浏览器中打开"
echo ""
echo "接下来："
echo "1. 点击 '▶️ 运行所有测试' 按钮"
echo "2. 等待 30-60 秒"
echo "3. 查看测试结果"
echo ""
echo "预期结果: ✅ 14/14 测试通过"
echo ""
