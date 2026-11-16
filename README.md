# V50-Actions-OpenWrt

使用 GitHub Actions 云编译 OpenWrt 固件。运行环境 `ubuntu-24.04`，按 **分支管理设备**：每个设备/源码版本一个 Git 分支，分支内存放各自的 `.config`、`feeds.conf.default` 与 DIY 脚本，workflow 保持通用。

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

## 添加新设备

1. 基于现有分支新建分支（分支名建议 `<设备>-<源码版本>`）
2. 替换分支内的 `.config`（本地 `make menuconfig` 导出，或先跑通 `make defconfig` 后用 `./scripts/diffconfig.sh` 生成精简种子）
3. 按需调整 `feeds.conf.default` 和两个 DIY 脚本
4. workflow 无需改动；若源码仓库/分支不同，修改 workflow 顶部 `env` 的 `REPO_URL` / `REPO_BRANCH`

## 注意事项

- workflow 固定 `ubuntu-24.04`，不要用 `ubuntu-latest`（其默认系统会滚动升级，产物不可复现）
- 依赖清单与 ImmortalWrt 官方 README 对齐，noble 已移除的包名（如 `libncursesw5-dev`）勿加回
- `diy-part1.sh` 中对 `feeds/` 目录的改动会被 `feeds update` 覆盖，修改 feed 内的包请在 `diy-part2.sh` 操作
- `.config` 请使用 LF 换行符，避免 `make defconfig` 解析异常
