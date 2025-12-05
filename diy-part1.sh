#!/bin/bash
#######
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#sed -i '$a src-git lienol https://github.com/Lienol/openwrt-package' feeds.conf.default

# add theme
# # # # # cd package/lean  
# # # rm -rf luci-theme-argon  
# # git clone -b master https://github.com/jerrykuku/luci-theme-argon.git  

# git clone -b master https://github.com/r1172464137/luci-theme-edge.git
#!/bin/bash
# diy-part1.sh

echo "================================================"
echo "开始执行 diy-part1.sh"
echo "================================================"

# 克隆 luci-app-zerotier 到 package 目录
echo "克隆 luci-app-zerotier..."

cd package

# 先清理可能存在的旧目录
rm -rf luci-app-zerotier 2>/dev/null || true

# 尝试克隆，最多重试3次
CLONE_SUCCESS=false
for attempt in {1..3}; do
    echo "克隆尝试 $attempt/3..."
    if git clone --depth=1 https://github.com/rufengsuixing/luci-app-zerotier.git; then
        CLONE_SUCCESS=true
        echo "✅ 克隆成功"
        break
    else
        echo "❌ 尝试 $attempt 失败"
        if [ $attempt -lt 3 ]; then
            echo "等待 5 秒后重试..."
            sleep 5
        fi
    fi
done

# 如果克隆失败，至少创建目录
if [ "$CLONE_SUCCESS" = false ]; then
    echo "所有克隆尝试都失败了，创建空目录..."
    mkdir -p luci-app-zerotier
    echo "# 占位目录" > luci-app-zerotier/README.md
fi

cd ..

echo "================================================"
echo "diy-part2.sh 执行完成"
echo "================================================"
