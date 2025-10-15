#!/bin/bash

# 启动本地 HTTP 服务器用于测试
# Start local HTTP server for testing

echo "🚀 启动本地 HTTP 服务器..."
echo "================================"
echo ""

# Check if Python 3 is available
if command -v python3 &> /dev/null; then
    echo "✅ 使用 Python 3 启动服务器"
    echo "📍 服务器地址: http://localhost:8000"
    echo ""
    echo "打开以下 URL 进行测试："
    echo "  - 主应用: http://localhost:8000/index.html"
    echo "  - 自动测试: http://localhost:8000/test-automation.html"
    echo ""
    echo "按 Ctrl+C 停止服务器"
    echo "================================"
    echo ""

    # Open test page in browser after 2 seconds
    (sleep 2 && open http://localhost:8000/test-automation.html) &

    # Start Python HTTP server
    python3 -m http.server 8000

elif command -v python &> /dev/null; then
    echo "✅ 使用 Python 2 启动服务器"
    echo "📍 服务器地址: http://localhost:8000"
    echo ""
    echo "打开以下 URL 进行测试："
    echo "  - 主应用: http://localhost:8000/index.html"
    echo "  - 自动测试: http://localhost:8000/test-automation.html"
    echo ""
    echo "按 Ctrl+C 停止服务器"
    echo "================================"
    echo ""

    # Open test page in browser after 2 seconds
    (sleep 2 && open http://localhost:8000/test-automation.html) &

    # Start Python HTTP server
    python -m SimpleHTTPServer 8000

else
    echo "❌ 未找到 Python"
    echo ""
    echo "请安装 Python 或使用以下替代方法："
    echo ""
    echo "方法 1: 使用 npx (如果已安装 Node.js)"
    echo "  npx http-server -p 8000"
    echo ""
    echo "方法 2: 使用 PHP (如果已安装)"
    echo "  php -S localhost:8000"
    echo ""
    echo "方法 3: 直接手动测试"
    echo "  打开 index.html 进行手动功能测试"
    exit 1
fi
