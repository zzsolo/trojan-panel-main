/*
 Navicat Premium Dump SQL

 Source Server         : trojan-panel
 Source Server Type    : MariaDB
 Source Server Version : 100703 (10.7.3-MariaDB-1:10.7.3+maria~focal)
 Source Host           : 150.230.204.166:9507
 Source Schema         : trojan_panel_db

 Target Server Type    : MariaDB
 Target Server Version : 100703 (10.7.3-MariaDB-1:10.7.3+maria~focal)
 File Encoding         : 65001

 Date: 02/08/2025 12:11:46
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for account
-- ----------------------------
DROP TABLE IF EXISTS `account`;
CREATE TABLE `account`  (
  `id` bigint(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '登录用户名',
  `pass` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '登录密码',
  `hash` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'pass的hash',
  `quota` bigint(20) NOT NULL DEFAULT 0 COMMENT '配额 单位/byte',
  `download` bigint(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT '下载 单位/byte',
  `upload` bigint(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT '上传 单位/byte',
  `ip_limit` tinyint(2) UNSIGNED NOT NULL DEFAULT 3 COMMENT '限制IP设备数',
  `upload_speed_limit` bigint(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT '上传限速 单位/byte',
  `download_speed_limit` bigint(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT '下载限速 单位/byte',
  `role_id` bigint(20) UNSIGNED NOT NULL DEFAULT 3 COMMENT '角色id 1/系统管理员 3/普通用户',
  `email` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '邮箱',
  `preset_expire` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '预设过期时长',
  `preset_quota` bigint(20) NOT NULL DEFAULT 0 COMMENT '预设配额',
  `last_login_time` bigint(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT '最后一次登录时间',
  `expire_time` bigint(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT '过期时间',
  `deleted` tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否禁用 0/正常 1/禁用',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '账户' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for black_list
-- ----------------------------
DROP TABLE IF EXISTS `black_list`;
CREATE TABLE `black_list`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'IP地址',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '黑名单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for casbin_rule
-- ----------------------------
DROP TABLE IF EXISTS `casbin_rule`;
CREATE TABLE `casbin_rule`  (
  `p_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `v0` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `v1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `v2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `v3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `v4` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `v5` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  INDEX `idx_casbin_rule`(`p_type`, `v0`, `v1`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for casbin_rule_backup
-- ----------------------------
DROP TABLE IF EXISTS `casbin_rule_backup`;
CREATE TABLE `casbin_rule_backup`  (
  `p_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `v0` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `v1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `v2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `v3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `v4` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `v5` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT ''
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for email_record
-- ----------------------------
DROP TABLE IF EXISTS `email_record`;
CREATE TABLE `email_record`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `to_email` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '收件人邮箱',
  `subject` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '主题',
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '内容',
  `state` tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态 0/未发送 1/发送成功 -1/发送失败',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '邮件发送记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for file_task
-- ----------------------------
DROP TABLE IF EXISTS `file_task`;
CREATE TABLE `file_task`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '文件名称',
  `path` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '文件路径',
  `type` tinyint(2) UNSIGNED NOT NULL DEFAULT 1 COMMENT '类型 1/用户导入 2/服务器导入 3/用户导出 4/服务器导出',
  `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态 -1/失败 0/等待 1/正在执行 2/成功',
  `err_msg` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '错误信息',
  `account_id` bigint(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT '账户id',
  `account_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '账户登录用户名',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '文件任务' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for node
-- ----------------------------
DROP TABLE IF EXISTS `node`;
CREATE TABLE `node`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `node_server_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '服务器id',
  `node_sub_id` bigint(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT '节点分表id',
  `node_type_id` bigint(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT '节点类型id',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '名称',
  `node_server_ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'IP地址',
  `node_server_grpc_port` int(10) UNSIGNED NOT NULL DEFAULT 8100 COMMENT 'gRPC端口',
  `domain` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '域名',
  `port` int(10) UNSIGNED NOT NULL DEFAULT 443 COMMENT '端口',
  `priority` int(11) NOT NULL DEFAULT 100 COMMENT '优先级',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 30 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '节点' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for node_hysteria
-- ----------------------------
DROP TABLE IF EXISTS `node_hysteria`;
CREATE TABLE `node_hysteria`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `protocol` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'udp' COMMENT '协议名称 udp/faketcp',
  `obfs` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '混淆密码',
  `up_mbps` int(10) NOT NULL DEFAULT 100 COMMENT '单客户端最大上传速度 单位:Mbps',
  `down_mbps` int(10) NOT NULL DEFAULT 100 COMMENT '单客户端最大下载速度 单位:Mbps',
  `server_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '用于验证服务端证书的 hostname',
  `insecure` tinyint(1) NOT NULL DEFAULT 0 COMMENT '忽略一切证书错误',
  `fast_open` tinyint(1) NOT NULL DEFAULT 0 COMMENT '启用 Fast Open (降低连接建立延迟)',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'Hysteria节点' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for node_hysteria2
-- ----------------------------
DROP TABLE IF EXISTS `node_hysteria2`;
CREATE TABLE `node_hysteria2`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `obfs_password` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '混淆密码',
  `up_mbps` int(10) NOT NULL DEFAULT 100 COMMENT '单客户端最大上传速度 单位:Mbps',
  `down_mbps` int(10) NOT NULL DEFAULT 100 COMMENT '单客户端最大下载速度 单位:Mbps',
  `server_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '用于验证服务端证书的 hostname',
  `insecure` tinyint(1) NOT NULL DEFAULT 0 COMMENT '忽略一切证书错误',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'Hysteria2节点' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for node_server
-- ----------------------------
DROP TABLE IF EXISTS `node_server`;
CREATE TABLE `node_server`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '服务器IP',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '服务器名称',
  `grpc_port` int(10) UNSIGNED NOT NULL DEFAULT 8100 COMMENT 'gRPC端口',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '服务器' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for node_trojan_go
-- ----------------------------
DROP TABLE IF EXISTS `node_trojan_go`;
CREATE TABLE `node_trojan_go`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `sni` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'sni',
  `mux_enable` tinyint(1) UNSIGNED NOT NULL DEFAULT 1 COMMENT '是否开启多路复用 0/关闭 1/开启',
  `websocket_enable` tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否开启websocket 0/否 1/是',
  `websocket_path` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'trojan-panel-websocket-path' COMMENT 'websocket路径',
  `websocket_host` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'websocket host',
  `ss_enable` tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否开启ss加密 0/否 1/是',
  `ss_method` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'AES-128-GCM' COMMENT 'ss加密方式',
  `ss_password` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'ss密码',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'TrojanGO节点' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for node_type
-- ----------------------------
DROP TABLE IF EXISTS `node_type`;
CREATE TABLE `node_type`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '名称',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '节点类型' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for node_xray
-- ----------------------------
DROP TABLE IF EXISTS `node_xray`;
CREATE TABLE `node_xray`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `protocol` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '协议名称',
  `xray_flow` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'Xray流控',
  `xray_ss_method` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'aes-256-gcm' COMMENT 'Xray Shadowsocks加密方式',
  `reality_pbk` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'reality的公钥',
  `settings` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'settings',
  `stream_settings` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'streamSettings',
  `tag` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'tag',
  `sniffing` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'sniffing',
  `allocate` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'allocate',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'Xray节点' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for role
-- ----------------------------
DROP TABLE IF EXISTS `role`;
CREATE TABLE `role`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `name` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '名称',
  `desc` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '描述',
  `parent_id` bigint(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT '父级id',
  `path` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '路径',
  `level` int(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT '等级',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `role_name_index`(`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for system
-- ----------------------------
DROP TABLE IF EXISTS `system`;
CREATE TABLE `system`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `name` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '系统名称',
  `account_config` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '用户设置',
  `email_config` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '系统邮箱设置',
  `template_config` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '模板设置',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '系统设置' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
