#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 删除 golang 语言包
# rm -rf feeds/packages/lang/golang
# git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

# rm -rf feeds/packages/net/v2ray-geodata
# git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
# git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# git clone https://github.com/QiuSimons/luci-app-daed package/dae

# wget https://raw.githubusercontent.com/lonelysoul/openwrt/refs/heads/main/xdp-sockets-diag.mk
# echo -e "\n\n" >> package/kernel/linux/modules/netsupport.mk && cat xdp-sockets-diag.mk >> package/kernel/linux/modules/netsupport.mk


# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate
