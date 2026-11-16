#!/bin/bash
# diy-part2.sh（VIKINGYFY owrt 分支专用）：feeds install 后执行

# 修改默认 LAN IP
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 修改主机名
#sed -i 's/OpenWrt/V50/g' package/base-files/files/bin/config_generate

# 注意：NSS/PPE 硬件加速由 default-settings 里的 99-nss-hw-offload uci-defaults 首次开机自动开启
# （该文件已包含在 VIKINGYFY 源码树 package/emortal/default-settings/ 中，无需此处处理）

# 按需启用
#git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
#git clone --depth 1 https://github.com/sbwml/packages_lang_golang -b 27.x feeds/packages/lang/golang
