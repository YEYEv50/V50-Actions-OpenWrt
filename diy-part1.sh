#!/bin/bash
# diy-part1.sh（VIKINGYFY main NSS 分支专用）：feeds update 前执行

# ZN M2 无 WiFi：剔除设备和源码默认 WiFi 包
IPQ60XX_MK=target/linux/qualcommax/image/ipq60xx.mk
if [ -f "$IPQ60XX_MK" ]; then
	perl -0pi -e 's/(define Device\/zn_m2\b.*?DEVICE_PACKAGES := )ipq-wifi-zn_m2/$1-ipq-wifi-zn_m2 -kmod-ath11k -kmod-ath11k-ahb -kmod-ath11k-pci -kmod-nss-wifi-drv -ath11k-firmware-ipq6018-ddwrt -wpad-openssl -automount/s' "$IPQ60XX_MK"
	grep -A8 "define Device/zn_m2" "$IPQ60XX_MK"
else
	echo "警告: $IPQ60XX_MK 不存在，跳过 zn_m2 修改"
fi

# ZN M2 无 WiFi：设备树叠加 nowifi 内存布局
# 基础定义给 WiFi Q6 预留 64MB@0x4ab00000；无 WiFi 时压到 8MB，
# etr/m3_dump/ramoops 错开到 0x4b3~0x4b5，释放约 56MB。
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
