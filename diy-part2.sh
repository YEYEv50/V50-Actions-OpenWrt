#!/bin/bash
# diy-part2.sh：feeds install 后执行（覆盖层 / 补丁 / 替换 feed 包）

# 修改默认 IP
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 修改主机名
#sed -i 's/OpenWrt/V50/g' package/base-files/files/bin/config_generate

# 删除 feeds 自带主题（改用 jerrykuku 新版 luci-theme-argon，已内置 argon-config 功能）
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/applications/luci-app-passwall
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
