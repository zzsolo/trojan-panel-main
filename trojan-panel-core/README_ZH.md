# 木马面板内核

木马面板内核

## 支持的节点类型

1. Xray
2. Trojan Go
3. Hysteria1/Hysteria2
4. NaiveProxy

默认数据处理：

1. 读取/写入 account 表中的 username, pass, hash, quota, download, upload, ip_limit, download_speed_limit, upload_speed_limit。
   pass, hash 需要哈希处理，quota, upload, download, download_speed_limit, upload_speed_limit 单位是 byte

主要逻辑：

1. API实时更新（数据库到应用）有效账户：account.quota < 0 or account.download +
   account.upload < account.quota
2. 定期更新 account.download、account.upload
3. account.quota=0, 该用户被禁用

## 创建数据库表语句示例

```sql
create table trojan_panel_db.account
(
    id                   bigint(10) unsigned auto_increment comment 'auto increment primary key'
        primary key,
    username             varchar(64) default '' not null comment 'login username',
    pass                 varchar(64) default '' not null comment 'login password',
    hash                 varchar(64) default '' not null comment 'hash of pass',
    quota                bigint      default 0  not null comment 'quota unit/byte',
    download             bigint unsigned default 0 not null comment 'download unit/byte',
    upload               bigint unsigned default 0 not null comment 'upload unit/byte',
    ip_limit             tinyint(2) unsigned default 3 not null comment 'limit the number of IP devices',
    download_speed_limit bigint unsigned default 0 not null comment 'download speed limit unit/byte',
    upload_speed_limit   bigint unsigned default 0 not null comment 'upload speed limit unit/byte',
);
```

## 版本关系

[发行说明](https://github.com/trojanpanel/install-script/blob/main/README_ARCHIVE_ZH.md#%E5%8F%91%E8%A1%8C%E8%AF%B4%E6%98%8E)

## 防止循环依赖

router->api->middleware->app->service/dao->core

## 构建

[compile.bat](compile.bat)

## 其他

Telegram Channel: https://t.me/jonssonyan_channel

You can subscribe to my channel on YouTube: https://www.youtube.com/@jonssonyan

## 致谢

- [trojan](https://github.com/trojan-gfw/trojan)
- [trojan-go](https://github.com/p4gefau1t/trojan-go)
- [Xray-core](https://github.com/XTLS/Xray-core)
- [hysteria](https://github.com/HyNetwork/hysteria)
- [naiveproxy](https://github.com/klzgrad/naiveproxy)