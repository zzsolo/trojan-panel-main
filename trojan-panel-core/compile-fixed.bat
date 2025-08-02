@echo off
REM Trojan Panel Core 配置文件保护修复编译脚本
REM 修复配置文件在重启时被意外删除的问题

echo ======================================
echo 🛡️ Trojan Panel Core 配置文件保护修复编译
echo ======================================

REM 检查Go环境
where go >nul 2>nul
if errorlevel 1 (
    echo ❌ 未找到Go编译器，请确保Go已安装并添加到PATH
    pause
    exit /b 1
)

echo ✅ Go环境检查通过
echo.

REM 设置编译参数
set CGO_ENABLED=0
set GOPROXY=https://goproxy.cn,direct
set GOSUMDB=off

REM 创建构建目录
if not exist build mkdir build

echo 🔧 开始编译修复版本...

REM 编译Linux amd64版本（服务器常用）
echo 📦 编译 Linux amd64...
set GOOS=linux
set GOARCH=amd64
go build -o build/trojan-panel-core-linux-amd64-fixed.exe -trimpath -ldflags "-s -w -buildid=" .
if errorlevel 1 (
    echo ❌ Linux amd64 编译失败
    pause
    exit /b 1
)
echo ✅ Linux amd64 编译完成

REM 编译Linux 386版本
echo 📦 编译 Linux 386...
set GOOS=linux
set GOARCH=386
go build -o build/trojan-panel-core-linux-386-fixed.exe -trimpath -ldflags "-s -w -buildid=" .
if errorlevel 1 (
    echo ❌ Linux 386 编译失败
    pause
    exit /b 1
)
echo ✅ Linux 386 编译完成

REM 编译Linux arm64版本
echo 📦 编译 Linux arm64...
set GOOS=linux
set GOARCH=arm64
go build -o build/trojan-panel-core-linux-arm64-fixed.exe -trimpath -ldflags "-s -w -buildid=" .
if errorlevel 1 (
    echo ❌ Linux arm64 编译失败
    pause
    exit /b 1
)
echo ✅ Linux arm64 编译完成

echo.
echo 🎉 所有修复版本编译完成！
echo 📁 输出目录: build\
dir build
echo.
echo 📋 编译结果:
echo   trojan-panel-core-linux-amd64-fixed.exe (x86_64)
echo   trojan-panel-core-linux-386-fixed.exe (i386)
echo   trojan-panel-core-linux-arm64-fixed.exe (ARM64)
echo.
echo ✅ 修复内容：配置文件在重启时不再被删除
echo.
pause