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

# ZN M2 无 WiFi：设备树叠加 nowifi 内存布局
# 基础定义（0102-wcss 补丁）给 WiFi Q6 预留 64MB@0x4ab00000，无 WiFi 时纯浪费；
# 压到 8MB 并把 etr/m3_dump/ramoops 错开到 0x4b3~0x4b5，释放约 56MB。绝不手动压 16MB（会与保留区重叠导致无法启动）。
M2_DTS=target/linux/qualcommax/dts/ipq6000-m2.dts
if [ -f "$M2_DTS" ]; then
	cat >> "$M2_DTS" << 'EOF'

/* nowifi 内存布局：禁用 WiFi，压缩 Q6 保留区 */
&wifi {
	status = "disabled";
};

&q6_region {
	reg = <0x0 0x4ab00000 0x0 0x800000>;
};

&q6_etr_region {
	reg = <0x0 0x4b300000 0x0 0x100000>;
};

&m3_dump_region {
	reg = <0x0 0x4b400000 0x0 0x100000>;
};

&ramoops_region {
	reg = <0x0 0x4b500000 0x0 0x100000>;
};
EOF
	tail -30 "$M2_DTS"
else
	echo "警告: $M2_DTS 不存在，跳过 nowifi 内存布局"
fi

# 按需追加 feed
#echo 'src-git helloworld https://github.com/fw876/helloworld' >> feeds.conf.default

# 剔除 qca-ppe-qos（硬编码在子目标 DEFAULT_PACKAGES，不从 .config 层面禁用会被 defconfig 加回）
PPE_QOS_MK=target/linux/qualcommax/Makefile
if [ -f "$PPE_QOS_MK" ]; then
	sed -i 's/qca-ppe-qos luci-app-qca-ppe-qos luci-i18n-qca-ppe-qos-zh-cn//' "$PPE_QOS_MK"
	grep -q "qca-ppe-qos" "$PPE_QOS_MK" && echo "警告: qca-ppe-qos 仍残留在 $PPE_QOS_MK" || echo "qca-ppe-qos 已从 DEFAULT_PACKAGES 剔除"
else
	echo "警告: $PPE_QOS_MK 不存在，跳过 qca-ppe-qos 剔除"
fi
