#!/bin/bash
# diy-part1.sh：feeds update 前执行（源码改动 / 添加 feed）

# q6_region 预留 16MB（256MB 内存机型防 OOM）
DTS=target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi
[ -f "$DTS" ] && sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x01000000>/' "$DTS" \
  || echo "警告: $DTS 不存在，跳过 q6_region 修改"
#sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x01000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-nowifi.dtsi

# 按需追加 feed
#echo 'src-git helloworld https://github.com/fw876/helloworld' >> feeds.conf.default
