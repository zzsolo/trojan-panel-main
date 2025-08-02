# 编译过程记录

## 成功编译：trojan-panel-core

### 编译环境
- **Go版本**: 1.19 windows/amd64
- **操作系统**: Windows (MINGW64环境)
- **代理设置**: socks5://127.0.0.1:8888
- **Go代理**: https://goproxy.cn,direct

### 解决的问题

#### 1. 网络连接问题
**问题**: 无法连接到 golang.org 和 GitHub，依赖下载失败
```
go: mvdan.cc/garble@v0.10.1: verifying module: mvdan.cc/garble@v0.10.1: Get "https://proxy.golang.org/sumdb/sum.golang.org/supported": dial tcp [2607:f8b0:400a:80c::2011]:443: connectex: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond.
```

**解决方案**:
```bash
export GOPROXY=https://goproxy.cn,direct
export GOSUMDB=off
export ALL_PROXY=socks5://127.0.0.1:8888
export HTTP_PROXY=socks5://127.0.0.1:8888
export HTTPS_PROXY=socks5://127.0.0.1:8888
```

#### 2. Go环境变量问题
**问题**: Go命令不在系统PATH中
**解决方案**: 手动设置PATH
```bash
export PATH=/usr/local/go/bin:$PATH
```

#### 3. 依赖下载超时
**问题**: 大量依赖下载导致超时
**解决方案**: 使用timeout命令延长下载时间
```bash
timeout 10m go mod download
```

### 成功编译的命令
```bash
# Linux amd64
export CGO_ENABLED=0
export GOOS=linux
export GOARCH=amd64
go build -o trojan-panel-core-linux-amd64 -trimpath -ldflags "-s -w -buildid="

# Linux 386
export CGO_ENABLED=0
export GOOS=linux
export GOARCH=386
go build -o trojan-panel-core-linux-386 -trimpath -ldflags "-s -w -buildid="

# Linux arm64
export CGO_ENABLED=0
export GOOS=linux
export GOARCH=arm64
go build -o trojan-panel-core-linux-arm64 -trimpath -ldflags "-s -w -buildid="
```

### 编译结果
- **trojan-panel-core-linux-amd64**: 20,336,640 bytes
- **trojan-panel-core-linux-386**: 19,181,568 bytes  
- **trojan-panel-core-linux-arm64**: 19,529,728 bytes

## 成功编译：trojan-panel-backend

### 编译环境
- **Go版本**: 1.19 windows/amd64
- **操作系统**: Windows (MINGW64环境)
- **代理设置**: socks5://127.0.0.1:8888
- **Go代理**: https://goproxy.cn,direct

### 成功编译的命令
```bash
# Linux amd64
export CGO_ENABLED=0
export GOOS=linux
export GOARCH=amd64
go build -o trojan-panel-backend-linux-amd64 -trimpath -ldflags "-s -w -buildid="

# Linux 386
export CGO_ENABLED=0
export GOOS=linux
export GOARCH=386
go build -o trojan-panel-backend-linux-386 -trimpath -ldflags "-s -w -buildid="

# Linux arm64
export CGO_ENABLED=0
export GOOS=linux
export GOARCH=arm64
go build -o trojan-panel-backend-linux-arm64 -trimpath -ldflags "-s -w -buildid="
```

### 编译结果
- **trojan-panel-backend-linux-amd64**: 22,495,232 bytes
- **trojan-panel-backend-linux-386**: 21,585,920 bytes  
- **trojan-panel-backend-linux-arm64**: 21,823,488 bytes

## 遇到的问题：trojan-panel-backend

### 问题1: 目录结构混乱
**现象**: 在错误的目录层级操作，导致go.mod文件无法找到
**原因**: Git子模块问题导致目录结构异常
**状态**: 需要重新整理目录结构

### 问题2: garble版本不兼容
**现象**: 
```
Go version "go1.19" is too old; please upgrade to Go 1.20.x or newer
```
**解决方案**: 暂时跳过garble混淆，直接使用go build编译

## 待解决问题

### 1. trojan-panel-backend目录恢复
需要重新获取或恢复trojan-panel-backend源代码

### 2. 多架构编译完善
需要编译更多平台架构：
- Linux arm/v6, arm/v7
- Linux ppc64le, s390x
- Windows amd64
- Darwin amd64

### 3. 编译脚本优化
现有编译脚本需要根据实际环境调整

## 经验总结

### 网络配置是关键
在中国大陆环境下，必须配置：
1. Go代理：goproxy.cn
2. 系统代理：socks5://127.0.0.1:8888
3. 禁用GOSUMDB避免校验问题

### 环境变量管理
编译前必须设置：
```bash
export PATH=/usr/local/go/bin:$PATH
export GOPROXY=https://goproxy.cn,direct
export GOSUMDB=off
export ALL_PROXY=socks5://127.0.0.1:8888
```

### 编译参数标准化
使用统一的编译参数：
- CGO_ENABLED=0 (静态编译)
- -trimpath (去除路径信息)
- -ldflags "-s -w -buildid=" (优化和去调试信息)

### 超时处理
大型项目依赖下载需要足够时间，使用timeout命令避免意外中断。