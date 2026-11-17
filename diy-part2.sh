#!/bin/bash
# diy-part2.sh（VIKINGYFY owrt PPE 分支专用）：feeds install 后执行

# 修改默认 LAN IP
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 修改主机名
sed -i "s/hostname='OWRT'/hostname='ZN-M2'/g" package/base-files/files/bin/config_generate

# 删除 feeds 自带主题（改用 jerrykuku 新版 luci-theme-argon，已内置 argon-config 功能）
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/luci/applications/luci-app-passwall2

# 独立插件（顶层 package/ 优先于 feed）
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth 1 https://github.com/eamonxg/luci-theme-aurora package/luci-theme-aurora
git clone --depth 1 https://github.com/eamonxg/luci-app-aurora-config package/luci-app-aurora-config
git clone --depth 1 https://github.com/chenmozhijin/luci-app-socat package/luci-app-socat
git clone --depth 1 https://github.com/bfmen/luci-app-wolplus package/luci-app-wolplus
