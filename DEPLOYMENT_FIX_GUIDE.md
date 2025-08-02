# Trojan Panel 部署问题分析和解决方案

## 问题诊断

通过对比分析 `jonssonyan/trojan-panel:latest` 和本地构建的镜像，发现了关键问题：

### 根本原因
**Linux二进制文件缺失** - Docker镜像中没有包含Linux版本的trojan-panel二进制文件

### 详细分析

1. **镜像内容对比**
   - `jonssonyan/trojan-panel:latest`: 包含完整的Linux二进制文件
   - 本地构建镜像: 缺少Linux二进制文件，只有Windows版本

2. **构建流程问题**
   - `auto-build.bat` 使用garble混淆编译，输出到build目录
   - build目录被混淆成十六进制文件夹结构
   - Dockerfile期望的 `build/trojan-panel-linux-amd64` 文件不存在

## 解决方案

### 方案1: 使用官方镜像（推荐）
```bash
# 直接使用官方镜像
docker run -d \
  --name trojan-panel \
  --restart=always \
  --network=host \
  -v /tpdata/trojan-panel/logs:/tpdata/trojan-panel/logs \
  -v /tpdata/trojan-panel/config:/tpdata/trojan-panel/config \
  -e mariadb_ip=127.0.0.1 \
  -e mariadb_port=9507 \
  -e mariadb_user=root \
  -e mariadb_pas=ZhengZhong1986 \
  -e database=trojan_panel_db \
  -e account_table=account \
  -e redis_host=127.0.0.1 \
  -e redis_port=6378 \
  -e redis_pass=ZhengZhong1986 \
  jonssonyan/trojan-panel:latest
```

### 方案2: 正确编译Linux版本
在有Go环境的Windows机器上执行：

```batch
@echo off
REM 设置Go环境变量
set CGO_ENABLED=0
set GOOS=linux
set GOARCH=amd64

REM 安装garble（如果未安装）
go install mvdan.cc/garble@v0.10.1

REM 编译Linux版本
garble -literals -tiny build -o build/trojan-panel-linux-amd64 -trimpath -ldflags "-s -w -buildid="

REM 构建Docker镜像
docker build -t jonssonyan/trojan-panel:latest .
```

### 方案3: 使用Docker多架构构建
```bash
# 使用现有的build.sh脚本
cd trojan-panel-backend
./build.sh
```

## 验证步骤

1. **检查镜像内容**
```bash
docker run --rm jonssonyan/trojan-panel:latest ls -la /tpdata/trojan-panel/
```

2. **验证backend服务**
```bash
docker run --rm jonssonyan/trojan-panel:latest pgrep -f trojan-panel
```

3. **测试容器运行**
```bash
docker run -d --name test trojan-panel:latest
sleep 5
docker logs test
docker rm -f test
```

## 预防措施

1. **构建流程标准化**
   - 确保在构建前清理build目录
   - 验证所有目标架构的二进制文件都已生成
   - 在构建镜像前进行内容检查

2. **质量检查**
   - 构建后检查镜像内容
   - 测试容器启动
   - 验证服务运行状态

## 紧急修复

当前可以立即使用 `jonssonyan/trojan-panel:latest` 官方镜像，该镜像包含完整的Linux二进制文件和服务。

```bash
# 立即部署修复版本
docker pull jonssonyan/trojan-panel:latest
docker stop trojan-panel
docker rm trojan-panel
docker run -d [上面的完整docker run命令]
```

## 部署验证

修复后验证以下服务：
- Backend服务运行在8080端口
- 数据库连接正常
- Redis连接正常
- 日志输出正常

---

**注意**: 建议使用方案1（官方镜像）作为临时解决方案，同时按照方案2或3重新构建本地镜像以确保长期可用性。