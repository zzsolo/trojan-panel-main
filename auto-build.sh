#!/bin/bash

# Trojan Panel 自动化编译和部署脚本
# 作者: zzsolo
# 功能: 编译Go代码、构建Docker镜像、推送到Docker Hub

set -e  # 遇到错误立即退出

# 颜色输出函数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查必要的工具
check_requirements() {
    log_info "检查必要的工具..."
    
    # 检查Go
    if ! command -v go &> /dev/null; then
        log_error "Go未安装，请先安装Go"
        exit 1
    fi
    
    # 检查Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    # 检查garble
    if ! command -v garble &> /dev/null; then
        log_warning "garble未安装，正在安装..."
        go install mvdan.cc/garble@v0.10.1
    fi
    
    log_success "所有必要工具检查通过"
}

# 编译Go代码
build_go() {
    log_info "开始编译Go代码..."
    
    # 设置Go环境变量
    export CGO_ENABLED=0
    export GOOS=linux
    export GOARCH=amd64
    
    # 清理旧的构建文件
    rm -f trojan-panel
    
    # 编译代码
    garble -literals -tiny build -o trojan-panel -trimpath -ldflags "-s -w -buildid="
    
    if [ $? -eq 0 ]; then
        log_success "Go代码编译成功"
        ls -la trojan-panel
    else
        log_error "Go代码编译失败"
        exit 1
    fi
}

# 构建Docker镜像
build_docker() {
    log_info "开始构建Docker镜像..."
    
    # 构建镜像
    docker build -f Dockerfile.optimized -t zzsolo/trojan-panel-main:latest .
    
    if [ $? -eq 0 ]; then
        log_success "Docker镜像构建成功"
        docker images | grep trojan-panel-main
    else
        log_error "Docker镜像构建失败"
        exit 1
    fi
}

# 推送到Docker Hub
push_to_docker() {
    log_info "推送到Docker Hub..."
    
    # 检查是否已登录Docker Hub
    if ! docker info | grep -q "Username"; then
        log_error "请先登录Docker Hub: docker login"
        exit 1
    fi
    
    # 推送镜像
    docker push zzsolo/trojan-panel-main:latest
    
    if [ $? -eq 0 ]; then
        log_success "镜像推送到Docker Hub成功"
    else
        log_error "镜像推送到Docker Hub失败"
        exit 1
    fi
}

# 创建标签并推送到GitHub
create_github_release() {
    log_info "创建GitHub Release..."
    
    # 检查git状态
    if [ -n "$(git status --porcelain)" ]; then
        log_warning "有未提交的更改，请先提交代码"
        return
    fi
    
    # 获取当前版本
    VERSION=$(date +%Y%m%d-%H%M%S)
    TAG="v$VERSION"
    
    # 创建标签
    git tag -a "$TAG" -m "Release $TAG"
    git push origin "$TAG"
    
    log_success "GitHub Release创建成功: $TAG"
}

# 清理工作
cleanup() {
    log_info "清理临时文件..."
    rm -f trojan-panel
    log_success "清理完成"
}

# 主函数
main() {
    log_info "开始Trojan Panel自动化编译和部署..."
    log_info "时间: $(date)"
    
    # 解析命令行参数
    BUILD_ONLY=false
    DOCKER_ONLY=false
    PUSH_ONLY=false
    SKIP_GITHUB=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --build-only)
                BUILD_ONLY=true
                shift
                ;;
            --docker-only)
                DOCKER_ONLY=true
                shift
                ;;
            --push-only)
                PUSH_ONLY=true
                shift
                ;;
            --skip-github)
                SKIP_GITHUB=true
                shift
                ;;
            --help)
                echo "用法: $0 [选项]"
                echo "选项:"
                echo "  --build-only     只编译Go代码"
                echo "  --docker-only    只构建Docker镜像"
                echo "  --push-only      只推送到Docker Hub"
                echo "  --skip-github    跳过GitHub Release"
                echo "  --help           显示帮助信息"
                exit 0
                ;;
            *)
                log_error "未知选项: $1"
                exit 1
                ;;
        esac
    done
    
    # 执行相应的步骤
    check_requirements
    
    if [ "$PUSH_ONLY" = true ]; then
        push_to_docker
    else
        if [ "$DOCKER_ONLY" = false ]; then
            build_go
        fi
        
        build_docker
        
        if [ "$BUILD_ONLY" = false ]; then
            push_to_docker
        fi
    fi
    
    if [ "$SKIP_GITHUB" = false ]; then
        create_github_release
    fi
    
    cleanup
    
    log_success "Trojan Panel自动化编译和部署完成！"
    log_info "时间: $(date)"
}

# 运行主函数
main "$@"