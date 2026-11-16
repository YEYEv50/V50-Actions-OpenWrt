# V50-Actions-OpenWrt · ZN-M2-25.12 分支

使用 GitHub Actions 云编译 OpenWrt 固件，运行环境 `ubuntu-24.04`，按 **分支管理设备/源码**：每个分支存放各自的 `.config`、`feeds.conf.default` 与 DIY 脚本，workflow 保持通用。

## 本分支构建目标

| 项目 | 内容 |
|------|------|
| 设备 | ZN-M2（Qualcomm IPQ6000，qualcommax/ipq60xx） |
| 源码 | [LiBwrt/LibWrt](https://github.com/LiBwrt/LibWrt) `25.12-nss` |
| 包管理器 | APK |
| 硬件加速 | **ECM/NSS 架构**（`/sys/kernel/debug/ecm/ecm_db/connection_count` 可查加速连接数） |
| 特色插件 | luci-app-passwall、argon 系主题、smartdns、ddns-go、vlmcsd 等 |

## 本分支特有处理

- `KERNEL_WERROR` 已预防性关闭：从 LibWrt 继承的该选项在源码更新内核后可能触发 `-Werror` 致命编译错误（LEDE 分支已实际翻车过一次，同样来自 LibWrt 继承）
- 首次构建（Run #2）成功；ECM/NSS 加速与 APK 包管理均为该源码分支的原生方案

## 已知事项

- APK 源码托管于 gitlab.alpinelinux.org，下载阶段偶发网络抖动导致 `package/system/apk failed to build`，重跑即可自愈；若频繁出现可参考 LEDE 分支切回 opkg
- 恢复本固件的备份到其他架构固件（如 PPE/flowtable）时，需清理 ECM/NSS 专属配置（`etc/config/ecm`、`nss`、`skb_recycler`、`smp_affinity` 及 `etc/modules.conf` 中的 ecm 模块参数），避免加速机制冲突

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
