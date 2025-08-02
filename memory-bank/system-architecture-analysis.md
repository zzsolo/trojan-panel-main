# Trojan Panel 系统架构深度分析

## 系统概览

Trojan Panel 是一个多代理协议管理面板系统，采用微服务架构设计，由三个核心组件组成：

1. **trojan-panel-core**: 代理节点管理核心服务
2. **trojan-panel-backend**: Web API 管理后台  
3. **trojan-panel-ui**: 前端用户界面

## 组件详细分析

### 1. trojan-panel-core (核心服务)

#### 核心功能
- **多协议代理管理**: 支持 Xray-core、Trojan-Go、Hysteria、Hysteria2、NaiveProxy
- **节点生命周期管理**: 启动、停止、重启代理节点
- **用户管理**: 动态添加/删除代理用户
- **流量统计**: 实时统计用户上传下载流量
- **gRPC 服务**: 提供 RPC 接口给 backend 调用

#### 技术架构
- **框架**: Gin (HTTP) + gRPC (RPC)
- **数据库**: MySQL (主数据) + SQLite (本地缓存) + Redis (会话/锁)
- **进程管理**: 管理多个代理进程的运行状态
- **定时任务**: 用户同步、流量统计更新

#### 关键端口
- **HTTP API**: 8082 (可选，主要用于调试)
- **gRPC 服务**: 8100 (主要通信接口)
- **代理端口**: 动态分配 (用户配置)

#### gRPC API 接口
```protobuf
service ApiNodeService {
  rpc AddNode(NodeAddDto) returns (Response) {}
  rpc RemoveNode(NodeRemoveDto) returns (Response) {}
}

service ApiAccountService {
  rpc RemoveAccount(AccountRemoveDto) returns (Response) {}
}

service ApiStateService {
  rpc GetNodeState(NodeStateDto) returns (Response) {}
  rpc GetNodeServerState(NodeServerStateDto) returns (Response) {}
}
```

### 2. trojan-panel-backend (管理后台)

#### 核心功能
- **Web API 服务**: 提供完整的 RESTful API
- **用户认证**: JWT + Casbin RBAC 权限控制
- **业务逻辑**: 账户管理、节点管理、系统配置
- **gRPC 客户端**: 调用 core 服务的代理
- **定时任务**: 邮件发送、数据备份、系统监控

#### 技术架构
- **框架**: Gin (HTTP Web 框架)
- **认证**: JWT Token + Casbin RBAC
- **数据库**: MySQL + Redis
- **限流**: 令牌桶算法
- **日志**: Logrus 结构化日志

#### API 设计
- **认证相关**: `/api/auth/login`, `/api/auth/info`
- **账户管理**: `/api/account/*`
- **节点管理**: `/api/node/*`, `/api/node-server/*`
- **系统管理**: `/api/system/*`
- **仪表板**: `/api/dashboard/*`

#### 关键端口
- **Web API**: 8081 (主要服务端口)

### 3. trojan-panel-ui (前端界面)

#### 技术栈
- **框架**: Vue.js 2.x
- **UI 组件**: Element UI
- **构建工具**: Webpack
- **部署方式**: Nginx 静态文件服务

#### 功能模块
- **仪表板**: 系统概览、流量统计
- **账户管理**: 用户增删改查、流量监控
- **节点管理**: 代理节点配置管理
- **系统设置**: 参数配置、权限管理

#### 关键端口
- **Web 访问**: 8888 (HTTPS)

## 组件间通信协议

### 1. UI ↔ Backend (HTTP/HTTPS)

#### 通信方式
- **协议**: HTTP/HTTPS
- **认证**: JWT Token
- **数据格式**: JSON
- **代理配置**: Nginx 反向代理

#### 关键端点
```nginx
# UI 访问
location / {
    root   /tpdata/trojan-panel-ui/;
    index  index.html index.htm;
}

# API 代理
location /api {
    proxy_pass http://127.0.0.1:8081;
}
```

#### API 请求示例
```javascript
// 登录请求
POST /api/auth/login
{
  "username": "admin",
  "password": "password"
}

// 获取节点列表
GET /api/node/list
Headers: { "Authorization": "Bearer <token>" }
```

### 2. Backend ↔ Core (gRPC)

#### 通信方式
- **协议**: gRPC over HTTP/2
- **认证**: 自定义 Token 认证
- **数据格式**: Protocol Buffers
- **错误处理**: 重试机制 + 超时控制

#### gRPC 认证机制
```go
// Token 认证参数
type TokenValidateParam struct {
    Token string
}

func (t *TokenValidateParam) GetRequestMetadata(ctx context.Context, uri ...string) (map[string]string, error) {
    return map[string]string{"token": t.Token}, nil
}

func (t *TokenValidateParam) RequireTransportSecurity() bool {
    return false
}
```

#### 关键调用流程
```go
// 添加节点
func AddNode(token string, ip string, grpcPort uint, nodeAddDto *NodeAddDto) error {
    // 建立gRPC连接
    conn, ctx, clo, err := newGrpcInstance(token, ip, grpcPort, 4*time.Second)
    
    // 调用远程服务
    client := NewApiNodeServiceClient(conn)
    send, err := client.AddNode(ctx, nodeAddDto)
    
    // 处理响应
    if send.Success {
        return nil
    }
    return errors.New(send.Msg)
}
```

### 3. 数据存储架构

#### 数据库分布
- **MySQL**: 统一的主数据库，存储所有业务数据
- **Redis**: 缓存、会话、分布式锁
- **SQLite (Core)**: 本地节点配置缓存

#### 数据一致性
- **写操作**: Backend 直接操作 MySQL
- **读操作**: Core 从 MySQL 读取账户信息
- **缓存策略**: Redis 缓存热点数据

## 数据流分析

### 1. 用户管理流程

```
用户请求 (UI) 
    ↓
Backend API (HTTP/JSON)
    ↓
权限验证 (JWT + Casbin)
    ↓
数据库操作 (MySQL)
    ↓
gRPC 调用 (Core)
    ↓
代理进程更新 (Xray/Trojan-Go等)
    ↓
响应返回 (UI)
```

### 2. 节点管理流程

```
节点配置 (UI)
    ↓
Backend API 处理
    ↓
配置验证
    ↓
gRPC 调用 Core
    ↓
Core 进程管理
    ↓
代理进程启动/停止
    ↓
状态更新
    ↓
结果返回 UI
```

### 3. 流量统计流程

```
定时任务触发 (Core)
    ↓
查询代理进程 API
    ↓
收集流量数据
    ↓
更新数据库 (MySQL)
    ↓
Redis 缓存更新
    ↓
UI 轮询获取最新数据
```

## 部署架构

### 推荐部署方案

```
[用户浏览器]
       ↓ (HTTPS:8888)
[ Nginx 代理 ]
       ↓ (HTTP:8081)
[ Backend 服务 ]
       ↓ (gRPC:8100)
[ Core 服务 ]
       ↓
[ 代理进程 ]
```

### 端口分配
- **8888**: UI 访问端口 (HTTPS)
- **8081**: Backend API 端口 (HTTP)
- **8100**: Core gRPC 端口
- **动态端口**: 代理服务端口

### 数据库配置
- **MySQL**: 统一数据库实例
- **Redis**: 统一缓存实例
- **配置文件**: 各组件独立配置

## 安全机制

### 1. 认证授权
- **JWT**: 无状态认证
- **RBAC**: 基于角色的访问控制
- **Token 验证**: gRPC 调用认证

### 2. 数据安全
- **HTTPS**: 前端通信加密
- **密码加密**: 数据库存储加密
- **Token 管理**: 定期刷新机制

### 3. 访问控制
- **限流**: API 访问频率限制
- **IP 白名单**: gRPC 调用限制
- **日志审计**: 完整的操作日志

## 扩展性设计

### 1. 水平扩展
- **Backend**: 多实例负载均衡
- **Core**: 分布式节点管理
- **数据库**: 主从复制 + 分库分表

### 2. 插件化
- **代理协议**: 可扩展新的代理类型
- **认证方式**: 可插拔认证模块
- **存储后端**: 支持多种数据库

### 3. 监控告警
- **性能监控**: 系统资源使用情况
- **业务监控**: 用户流量、节点状态
- **错误告警**: 异常情况自动通知

## 总结

Trojan Panel 采用典型的微服务架构，通过清晰的职责分离和标准化的通信协议，实现了高可用、可扩展的代理管理平台。三个组件各司其职，通过 HTTP 和 gRPC 协议进行通信，形成了完整的管理闭环。

这种架构设计的优势：
1. **职责明确**: 每个组件专注于特定功能
2. **技术解耦**: 可以使用不同的技术栈
3. **独立部署**: 各组件可以独立升级和维护
4. **扩展性强**: 支持水平扩展和功能扩展