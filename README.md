# V50-Actions-OpenWrt · VIKINGYFY 分支

使用 GitHub Actions 云编译 OpenWrt 固件，运行环境 `ubuntu-24.04`，按 **分支管理设备/源码**：每个分支存放各自的 `.config`、`feeds.conf.default` 与 DIY 脚本，workflow 保持通用。

## 本分支构建目标

| 项目 | 内容 |
|------|------|
| 设备 | ZN-M2（Qualcomm IPQ6000，qualcommax/ipq60xx） |
| 源码 | [VIKINGYFY/immortalwrt](https://github.com/VIKINGYFY/immortalwrt) `owrt`（ImmortalWrt fork） |
| 内核 | 6.18 |
| 包管理器 | APK |
| 硬件加速 | **PPE（qca-ppe）+ 内核 flowtable 硬件卸载**（`flow_offloading_hw`，debugfs 见 `/sys/kernel/debug/3a000000.ppe/`） |
| 特色插件 | luci-app-passwall、argon 系主题、smartdns、ddns-go、vlmcsd 等 |

## 本分支特有处理（diy-part1.sh 已内置）

- **剔除 qca-ppe-qos 三件套**：`qca-ppe-qos`、`luci-app-qca-ppe-qos`、`luci-i18n-qca-ppe-qos-zh-cn` 被硬编码在源码 `target/linux/qualcommax/Makefile` 的 DEFAULT_PACKAGES 中（设备默认包，仅删 `.config` 会被 defconfig 加回），脚本用 sed 从源码层面剔除并自带残留检查

## 实测验证（2026-11-17）

- 真实互联网流量下 conntrack 出现 `[HW_OFFLOAD]` 标记（PPE 硬件卸载专属），双向包计数持续增长
- PPE `active_flows` 4~6/2048，卸载生效期间路由器 CPU 接近 100% idle
- 对照：PC→路由器本机终止流（不可卸载路径）941 Mbps 时 CPU sirq 23~26%

## 已知事项

- APK 源码托管于 gitlab.alpinelinux.org，下载阶段偶发网络抖动导致 `package/system/apk failed to build`，重跑即可自愈
- 恢复路由器备份时，建议使用清理过 ECM/NSS 残留配置的备份（`etc/config/ecm`、`nss`、`skb_recycler`、`smp_affinity`、`etc/modules.conf` 的 ecm 模块参数），避免与本分支 PPE/flowtable 加速机制冲突
- 硬件加速生效需固件本体带 PPE 驱动 + `flow_offloading_hw=1` 开关两者齐备；验证命令：
  ```bash
  uci get firewall.@defaults[0].flow_offloading_hw   # 应返回 1
  grep -c HW_OFFLOAD /proc/net/nf_conntrack          # 上网后应 > 0
  ```

## 使用方法

1. 切换到目标设备的分支
2. 进入仓库 `Actions` 页 → 选择 `Build OpenWrt` → `Run workflow`
3. 可选勾选 `同时发布到 Releases`：编译成功后固件自动发布到 Releases（tag 格式 `openwrt-<分支>-<run#>`）
4. 未勾选时，固件上传到本次运行的 Artifacts 中下载

编译耗时约 2~4 小时，公开仓库的 Actions 分钟数不受限。

## 目录结构

```
├── .github/workflows/build-openwrt.yml   # 云编译主流程（ubuntu-24.04）
├── feeds.conf.default                    # feed 清单（编译时拷入源码目录）
├── .config                               # 编译种子配置（编译时拷入源码目录）
├── diy-part1.sh                          # feeds update 前执行：源码改动、添加 feed
└── diy-part2.sh                          # feeds install 后执行：替换主题/插件、补丁
```

## 编译流程

```
释放磁盘 → 安装依赖 → 克隆源码 → 载入 feeds.conf.default
→ diy-part1.sh → feeds update/install → diy-part2.sh
→ 载入 .config → make defconfig → make download → make
```
