# V50-Actions-OpenWrt · VIKINGYFY main NSS 分支

用于 ZN-M2 的 OpenWrt 云编译配置仓库。每个分支对应一套源码与设备配置，保存独立的 `.config`、`feeds.conf.default` 和 DIY 脚本；GitHub Actions 使用 `ubuntu-24.04` 编译。

## 构建目标

| 项目 | 内容 |
|------|------|
| 设备 | ZN-M2（Qualcomm IPQ6000，`qualcommax/ipq60xx`） |
| 源码 | [VIKINGYFY/immortalwrt](https://github.com/VIKINGYFY/immortalwrt) `main` |
| 内核 | 6.18 |
| 包管理器 | APK |
| 硬件加速 | NSS/ECM（conntrack 卸载）；fw4 flowtable 保持关闭 |
| 加密套件 | NSS crypto 与固件已启用 |
| 插件 | 以 `.config` 为准 |

> 本分支走 NSS/ECM，不是 PPE 分支；两者不可混用。

## 分支处理

- 调整 q6_region 预留内存，移除设备定义中的 WiFi 包
- 关闭 fw4 的 flowtable 硬件卸载，保留 ECM 独占加速
- 主题与插件按 `.config` 和 DIY 脚本安装

## 使用

1. 切换到本分支
2. 打开仓库 `Actions` 页面，选择 `Build OpenWrt`
3. 点击 `Run workflow`；需要发布时选择同时发布到 Releases
4. 编译产物在 Artifacts 或 Releases 中下载

## 文件

| 文件 | 用途 |
|------|------|
| `.config` | 编译种子配置 |
| `feeds.conf.default` | feed 清单 |
| `diy-part1.sh` | feeds 更新前执行：源码调整 |
| `diy-part2.sh` | feeds 安装后执行：插件、主题与补包 |
| `.github/workflows/build-openwrt.yml` | 编译与发布流程 |

构建顺序：释放磁盘 → 安装依赖 → 克隆源码 → 载入配置与 DIY 脚本 → `make defconfig` → `make download` → `make -j8`。
