# Trojan Panel 系统架构图

## 1. 整体架构图

```mermaid
graph TB
    subgraph "用户层"
        U1[用户浏览器]
    end
    
    subgraph "负载均衡层"
        N1[Nginx 反向代理]
    end
    
    subgraph "应用层"
        B1[trojan-panel-backend<br/>Web API 服务<br/>端口: 8081]
        U2[trojan-panel-ui<br/>前端界面<br/>端口: 8888]
    end
    
    subgraph "服务层"
        C1[trojan-panel-core<br/>代理管理服务<br/>端口: 8100]
    end
    
    subgraph "代理层"
        X1[Xray-core 进程]
        T1[Trojan-Go 进程]
        H1[Hysteria 进程]
        H2[Hysteria2 进程]
        N1[NaiveProxy 进程]
    end
    
    subgraph "数据层"
        M1[(MySQL 数据库)]
        R1[(Redis 缓存)]
        S1[(SQLite 本地缓存)]
    end
    
    %% 连接关系
    U1 -->|HTTPS:8888| N1
    N1 -->|静态文件| U2
    N1 -->|API 代理| B1
    
    B1 -->|gRPC:8100| C1
    B1 -->|数据操作| M1
    B1 -->|缓存操作| R1
    
    C1 -->|进程管理| X1
    C1 -->|进程管理| T1
    C1 -->|进程管理| H1
    C1 -->|进程管理| H2
    C1 -->|进程管理| N1
    C1 -->|数据读取| M1
    C1 -->|本地缓存| S1
    C1 -->|缓存操作| R1
    
    X1 -->|用户代理服务| U1
    T1 -->|用户代理服务| U1
    H1 -->|用户代理服务| U1
    H2 -->|用户代理服务| U1
    N1 -->|用户代理服务| U1
```

## 2. 组件间通信协议图

```mermaid
sequenceDiagram
    participant U as 用户浏览器
    participant N as Nginx
    participant B as Backend
    participant C as Core
    participant P as 代理进程
    participant D as 数据库
    
    Note over U,D: 用户登录流程
    U->>N: POST /api/auth/login (HTTPS)
    N->>B: 转发登录请求
    B->>D: 验证用户信息
    D-->>B: 返回用户数据
    B->>B: 生成 JWT Token
    B-->>N: 返回 Token
    N-->>U: 返回登录成功
    
    Note over U,D: 节点管理流程
    U->>N: POST /api/node/add (含 JWT)
    N->>B: 转发节点创建请求
    B->>B: 验证权限和数据
    B->>C: gRPC AddNode 调用
    C->>C: 配置验证和准备
    C->>P: 启动代理进程
    P-->>C: 进程启动结果
    C-->>B: gRPC 响应
    B->>D: 保存节点配置
    B-->>N: API 响应
    N-->>U: 返回操作结果
    
    Note over U,D: 流量统计流程
    Note over C,D: 定时任务触发
    C->>P: 查询流量统计
    P-->>C: 返回流量数据
    C->>D: 更新用户流量
    C->>R: 更新缓存
    
    Note over U,D: 用户获取流量数据
    U->>N: GET /api/dashboard/stats (含 JWT)
    N->>B: 转发请求
    B->>D: 查询统计数据
    D-->>B: 返回统计数据
    B-->>N: API 响应
    N-->>U: 返回数据
```

## 3. 数据流架构图

```mermaid
graph LR
    subgraph "数据写入流程"
        A[用户操作] --> B[Backend API]
        B --> C[权限验证]
        C --> D[业务逻辑处理]
        D --> E[MySQL 写入]
        D --> F[gRPC 调用 Core]
        F --> G[代理进程更新]
    end
    
    subgraph "数据读取流程"
        H[UI 请求] --> I[Backend API]
        I --> J[权限验证]
        J --> K[MySQL 查询]
        K --> L[Redis 缓存]
        L --> M[数据返回]
    end
    
    subgraph "定时任务流程"
        N[Core 定时器] --> O[代理进程查询]
        O --> P[流量数据收集]
        P --> Q[MySQL 更新]
        Q --> R[Redis 缓存更新]
    end
```

## 4. 部署架构图

```mermaid
graph TB
    subgraph "公网访问层"
        LB[负载均衡器]
    end
    
    subgraph "Web 服务层"
        N1[Nginx 1]
        N2[Nginx 2]
    end
    
    subgraph "应用服务层"
        B1[Backend 1<br/>8081]
        B2[Backend 2<br/>8081]
        U1[UI 静态文件]
    end
    
    subgraph "核心服务层"
        C1[Core 1<br/>8100]
        C2[Core 2<br/>8100]
        C3[Core 3<br/>8100]
    end
    
    subgraph "代理服务层"
        P1[代理进程组 1]
        P2[代理进程组 2]
        P3[代理进程组 3]
    end
    
    subgraph "数据存储层"
        M1[(MySQL 主)]
        M2[(MySQL 从)]
        R1[(Redis 集群)]
    end
    
    %% 连接关系
    LB --> N1
    LB --> N2
    
    N1 --> U1
    N1 --> B1
    N2 --> U1
    N2 --> B2
    
    B1 --> C1
    B1 --> C2
    B2 --> C2
    B2 --> C3
    
    B1 --> M1
    B1 --> R1
    B2 --> M1
    B2 --> R1
    
    C1 --> P1
    C2 --> P2
    C3 --> P3
    
    C1 --> M1
    C1 --> R1
    C2 --> M1
    C2 --> R1
    C3 --> M1
    C3 --> R1
    
    M1 --> M2
```

## 5. 安全架构图

```mermaid
graph TB
    subgraph "认证层"
        JWT[JWT Token 认证]
        RBAC[Casbin RBAC 权限]
    end
    
    subgraph "通信层"
        HTTPS[HTTPS 加密]
        GRPC[gRPC Token 认证]
    end
    
    subgraph "应用层"
        RATE[API 限流]
        LOG[操作日志]
        VALID[数据验证]
    end
    
    subgraph "数据层"
        ENCRYPT[密码加密]
        BACKUP[数据备份]
        AUDIT[审计日志]
    end
    
    %% 安全流程
    USER[用户请求] --> HTTPS
    HTTPS --> JWT
    JWT --> RBAC
    RBAC --> RATE
    RATE --> VALID
    VALID --> LOG
    
    GRPC --> TOKEN[gRPC Token]
    TOKEN --> AUTH[权限验证]
    
    VALID --> ENCRYPT
    LOG --> AUDIT
    AUDIT --> BACKUP
```

## 6. 技术栈架构图

```mermaid
graph LR
    subgraph "前端技术栈"
        V[Vue.js 2.x]
        E[Element UI]
        W[Webpack]
        N[Nginx]
    end
    
    subgraph "后端技术栈"
        G[Gin]
        J[JWT]
        C[Casbin]
        R[Redis]
        M[MySQL]
    end
    
    subgraph "核心服务技术栈"
        GO[Go 1.19]
        GRPC[gRPC]
        SQL[SQLite]
        PROC[进程管理]
    end
    
    subgraph "代理技术栈"
        X[Xray-core]
        T[Trojan-Go]
        H[Hysteria]
        H2[Hysteria2]
        N2[NaiveProxy]
    end
    
    %% 技术关系
    V --> E
    V --> W
    W --> N
    
    G --> J
    G --> C
    G --> R
    G --> M
    
    GO --> GRPC
    GO --> SQL
    GO --> PROC
    
    PROC --> X
    PROC --> T
    PROC --> H
    PROC --> H2
    PROC --> N2
```

## 7. 接口架构图

```mermaid
graph TB
    subgraph "前端接口 (HTTP/JSON)"
        A1[POST /api/auth/login]
        A2[GET /api/auth/info]
        A3[GET /api/account/list]
        A4[POST /api/account/add]
        A5[PUT /api/account/update]
        A6[DELETE /api/account/delete]
        A7[GET /api/node/list]
        A8[POST /api/node/add]
        A9[DELETE /api/node/remove]
    end
    
    subgraph "后端接口 (HTTP/JSON)"
        B1[GET /api/dashboard/stats]
        B2[GET /api/system/info]
        B3[POST /api/system/config]
        B4[GET /api/node-server/list]
        B5[POST /api/node-server/add]
    end
    
    subgraph "gRPC 接口 (Protocol Buffers)"
        C1[ApiNodeService.AddNode]
        C2[ApiNodeService.RemoveNode]
        C3[ApiAccountService.RemoveAccount]
        C4[ApiStateService.GetNodeState]
        C5[ApiStateService.GetNodeServerState]
        C6[ApiNodeServerService.GetNodeServerInfo]
    end
    
    subgraph "代理进程 API"
        D1[Xray API]
        D2[Trojan-Go API]
        D3[Hysteria API]
        D4[Hysteria2 API]
        D5[NaiveProxy API]
    end
    
    %% 接口调用关系
    A1 --> B1
    A3 --> B1
    A7 --> B1
    
    A8 --> C1
    A9 --> C2
    A6 --> C3
    
    C1 --> D1
    C1 --> D2
    C1 --> D3
    C1 --> D4
    C1 --> D5
```

## 8. 配置架构图

```mermaid
graph TB
    subgraph "环境配置"
        ENV1[开发环境]
        ENV2[测试环境]
        ENV3[生产环境]
    end
    
    subgraph "组件配置"
        CONF1[Backend 配置<br/>config.ini]
        CONF2[Core 配置<br/>config.ini]
        CONF3[UI 配置<br/>nginx.conf]
    end
    
    subgraph "数据库配置"
        DB1[MySQL 连接配置]
        DB2[Redis 连接配置]
        DB3[SQLite 路径配置]
    end
    
    subgraph "代理配置"
        PROXY1[Xray 模板]
        PROXY2[Trojan-Go 模板]
        PROXY3[Hysteria 模板]
        PROXY4[Hysteria2 模板]
        PROXY5[NaiveProxy 模板]
    end
    
    %% 配置关系
    ENV1 --> CONF1
    ENV1 --> CONF2
    ENV1 --> CONF3
    
    ENV2 --> CONF1
    ENV2 --> CONF2
    ENV2 --> CONF3
    
    ENV3 --> CONF1
    ENV3 --> CONF2
    ENV3 --> CONF3
    
    CONF1 --> DB1
    CONF1 --> DB2
    
    CONF2 --> DB1
    CONF2 --> DB2
    CONF2 --> DB3
    
    CONF2 --> PROXY1
    CONF2 --> PROXY2
    CONF2 --> PROXY3
    CONF2 --> PROXY4
    CONF2 --> PROXY5
```

这些架构图完整展示了 Trojan Panel 系统的各个方面，包括组件关系、数据流、部署架构、安全机制等。通过这些图表，可以清晰地理解整个系统的工作原理和架构设计。