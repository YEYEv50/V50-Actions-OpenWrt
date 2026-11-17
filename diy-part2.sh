#!/bin/bash
# diy-part2.sh（VIKINGYFY owrt 分支专用）：feeds install 后执行

# 修改默认 LAN IP
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 修改主机名
#sed -i 's/OpenWrt/V50/g' package/base-files/files/bin/config_generate

# 注意：NSS/PPE 硬件加速由 default-settings 里的 99-nss-hw-offload uci-defaults 首次开机自动开启
# （该文件已包含在 VIKINGYFY 源码树 package/emortal/default-settings/ 中，无需此处处理）

# 删除 feeds 自带主题（改用 jerrykuku 新版 luci-theme-argon，已内置 argon-config 功能）
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/luci/applications/luci-app-passwall2
#rm -rf feeds/packages/lang/golang

# 独立插件（顶层 package/ 优先于 feed）
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth 1 https://github.com/eamonxg/luci-theme-aurora package/luci-theme-aurora
git clone --depth 1 https://github.com/eamonxg/luci-app-aurora-config package/luci-app-aurora-config
git clone --depth 1 https://github.com/chenmozhijin/luci-app-socat package/luci-app-socat
git clone --depth 1 https://github.com/bfmen/luci-app-wolplus package/luci-app-wolplus

# 按需启用
#git clone https://github.com/sbwml/packages_lang_golang -b 27.x feeds/packages/lang/golang
#git clone https://github.com/immortalwrt/homeproxy package/luci-app-homeproxy
#git clone https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier
