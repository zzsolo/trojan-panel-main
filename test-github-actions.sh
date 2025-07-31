#!/bin/bash

# 测试GitHub Actions配置是否正确
echo "测试GitHub Actions配置..."

# 检查GitHub Actions配置文件
if [ -f ".github/workflows/docker-build-push.yml" ]; then
    echo "✅ GitHub Actions配置文件存在"
    
    # 检查是否包含Node.js相关步骤
    if grep -q "node\|npm\|yarn" .github/workflows/docker-build-push.yml; then
        echo "❌ 发现Node.js相关步骤，需要移除"
    else
        echo "✅ 没有Node.js相关步骤"
    fi
    
    # 检查是否包含Go相关步骤
    if grep -q "go\|garble" .github/workflows/docker-build-push.yml; then
        echo "✅ 包含Go相关步骤"
    else
        echo "❌ 缺少Go相关步骤"
    fi
else
    echo "❌ GitHub Actions配置文件不存在"
fi

# 检查Go模块文件
if [ -f "go.mod" ]; then
    echo "✅ go.mod文件存在"
else
    echo "❌ go.mod文件不存在"
fi

# 检查Dockerfile
if [ -f "Dockerfile.optimized" ]; then
    echo "✅ Dockerfile.optimized存在"
else
    echo "❌ Dockerfile.optimized不存在"
fi

echo "测试完成"