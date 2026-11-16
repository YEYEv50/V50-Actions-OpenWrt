#!/bin/bash
# diy-part1.sh（VIKINGYFY owrt 分支专用）：feeds update 前执行
#
# 注意：与 LibWrt 分支不同，这里【不做】q6_region 修改！
# VIKINGYFY 无 ECM，NSS 加速走 flowtable；ZN M2 无 WiFi 由 zn_m2 设备定义强制剔除 WiFi 栈。

# ZN M2 无 WiFi：给 zn_m2 设备定义加 minus 剔除（模板同仓库内 jdcloud_re-cs-07 写法）
IPQ60XX_MK=target/linux/qualcommax/image/ipq60xx.mk
if [ -f "$IPQ60XX_MK" ]; then
	perl -0pi -e 's/(define Device\/zn_m2\b.*?DEVICE_PACKAGES := )ipq-wifi-zn_m2/$1-ipq-wifi-zn_m2 -kmod-ath11k -kmod-ath11k-ahb -kmod-ath11k-pci -kmod-nss-wifi-drv -ath11k-firmware-ipq6018-ddwrt -wpad-openssl -automount/s' "$IPQ60XX_MK"
	grep -A8 "define Device/zn_m2" "$IPQ60XX_MK"
else
	echo "警告: $IPQ60XX_MK 不存在，跳过 zn_m2 修改"
fi

# 按需追加 feed
#echo 'src-git helloworld https://github.com/fw876/helloworld' >> feeds.conf.default
