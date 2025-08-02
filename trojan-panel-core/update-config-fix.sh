#!/usr/bin/env bash
# Trojan Panel Core 配置保护修复脚本
# 修复配置文件在重启时被意外删除的问题

set -e

echo "🚀 Trojan Panel Core 配置文件保护修复开始..."

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查Docker环境
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose未安装，请先安装Docker Compose"
        exit 1
    fi
}

# 备份现有配置
backup_configs() {
    log_info "正在备份现有配置文件..."
    
    # 创建备份目录
    BACKUP_DIR="/tmp/trojan-panel-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # 备份所有配置文件
    if [ -d "/tpdata/trojan-panel-core" ]; then
        cp -r /tpdata/trojan-panel-core/bin "$BACKUP_DIR/" 2>/dev/null || true
        log_info "配置文件已备份到: $BACKUP_DIR"
    else
        log_warn "未找到现有配置目录，跳过备份"
    fi
}

# 构建修复版本
create_fixed_image() {
    log_info "正在构建配置文件保护修复版本..."
    
    # 创建临时Dockerfile
    cat > Dockerfile.fixed << 'EOF'
FROM jonssonyan/trojan-panel-core:latest

# 复制修复后的进程管理文件
COPY core/process/ /app/core/process/

# 设置文件权限
RUN chmod +x /app/trojan-panel-core

# 创建配置文件保护脚本
RUN cat > /app/protect-configs.sh << 'PROTECT'
#!/bin/bash
# 保护配置文件不被删除
chmod -R 644 /tpdata/trojan-panel-core/bin/*/config/
chattr +i /tpdata/trojan-panel-core/bin/*/config/config-*.json 2>/dev/null || true
PROTECT

RUN chmod +x /app/protect-configs.sh

# 添加启动钩子
RUN sed -i '/^exec/a\/app/protect-configs.sh' /entrypoint.sh || true
EOF

    # 构建镜像
    docker build -f Dockerfile.fixed -t trojan-panel-core:config-fixed .
    
    if [ $? -eq 0 ]; then
        log_info "修复版本镜像构建成功: trojan-panel-core:config-fixed"
    else
        log_error "镜像构建失败"
        exit 1
    fi
}

# 更新容器
update_container() {
    log_info "正在更新容器..."
    
    # 停止现有容器
    if docker ps | grep -q trojan-panel-core; then
        log_info "停止现有trojan-panel-core容器..."
        docker stop trojan-panel-core
        docker rm trojan-panel-core
    fi
    
    # 使用docker-compose更新（如果存在）
    if [ -f "docker-compose.yml" ]; then
        log_info "使用docker-compose更新..."
        sed -i.bak 's|jonssonyan/trojan-panel-core:latest|trojan-panel-core:config-fixed|g' docker-compose.yml
        docker-compose up -d trojan-panel-core
    else
        # 手动启动容器
        log_info "手动启动容器..."
        docker run -d \
            --name trojan-panel-core \
            --restart=always \
            -v /tpdata:/tpdata \
            -p 8081:8081 \
            trojan-panel-core:config-fixed
    fi
}

# 验证更新
verify_update() {
    log_info "验证更新结果..."
    
    # 等待容器启动
    sleep 10
    
    # 检查容器状态
    if docker ps | grep -q trojan-panel-core; then
        log_info "✅ 容器启动成功"
    else
        log_error "❌ 容器启动失败"
        docker logs trojan-panel-core
        exit 1
    fi
    
    # 检查配置文件目录
    log_info "检查配置文件完整性..."
    docker exec trojan-panel-core find /tpdata/trojan-panel-core/bin -name "config-*.json" -type f | head -5
    
    log_info "✅ 配置文件保护修复完成！"
}

# 主流程
main() {
    log_info "Trojan Panel Core 配置文件保护修复脚本"
    log_info "修复问题：重启时配置文件被意外删除"
    
    check_docker
    backup_configs
    create_fixed_image
    update_container
    verify_update
    
    log_info "🎉 修复完成！重启后配置文件将永久保留"
    log_info "📋 如需回滚，可以使用备份目录: $BACKUP_DIR"
}

# 执行主流程
main "$@"