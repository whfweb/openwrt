#!/bin/bash
###
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
##
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
########
# Modify default IP
# sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
# PATH=$(echo "$PATH" | sed -e 's/:\/mnt.*//g')
#!/bin/bash
###
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
##
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
########

echo "================================================"
echo "开始执行 diy-part2.sh"
echo "================================================"

# 修改默认 IP（如果需要）
# sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# 清理 PATH（针对 WSL 环境）
# PATH=$(echo "$PATH" | sed -e 's/:\/mnt.*//g')

# ==================== 关键部分：处理 luci-app-zerotier ====================
echo "检查 luci-app-zerotier 包..."

if [ -d "package/luci-app-zerotier" ]; then
    echo "✅ 找到 luci-app-zerotier 目录"
    
    # 1. 检查并修复 Makefile
    if [ ! -f "package/luci-app-zerotier/Makefile" ]; then
        echo "⚠️  没有 Makefile，创建基本版本..."
        cat > package/luci-app-zerotier/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Support for ZeroTier
LUCI_DEPENDS:=+zerotier
LUCI_PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-zerotier
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=ZeroTier LuCI Interface
  PKGARCH:=all
  DEPENDS:=+luci-base +zerotier
endef

define Package/luci-app-zerotier/description
  LuCI Support for ZeroTier.
endef

define Build/Prepare
	true
endef

define Build/Configure
	true
endef

define Build/Compile
	true
endef

define Package/luci-app-zerotier/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR $(PKG_BUILD_DIR)/luasrc/* $(1)/usr/lib/lua/luci/ 2>/dev/null || true
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view/zerotier
	cp -pR $(PKG_BUILD_DIR)/htdocs/* $(1)/www/luci-static/resources/view/zerotier/ 2>/dev/null || true
endef

$(eval $(call BuildPackage,luci-app-zerotier))
EOF
        echo "✅ Makefile 创建完成"
    else
        echo "✅ 已有 Makefile，检查内容..."
        # 确保 Makefile 有正确的 BuildPackage 调用
        if ! grep -q "BuildPackage.*luci-app-zerotier" package/luci-app-zerotier/Makefile; then
            echo "添加 BuildPackage 调用..."
            echo "" >> package/luci-app-zerotier/Makefile
            echo "\$(eval \$(call BuildPackage,luci-app-zerotier))" >> package/luci-app-zerotier/Makefile
        fi
    fi
    
    # 2. 检查包的实际内容
    echo "检查包结构："
    ls -la package/luci-app-zerotier/
    
    # 3. 创建到 feeds 的符号链接（确保 menuconfig 能识别）
    echo "创建符号链接到 feeds 目录..."
    mkdir -p feeds/luci/applications 2>/dev/null || true
    ln -sf ../../../package/luci-app-zerotier feeds/luci/applications/luci-app-zerotier 2>/dev/null || true
    
    # 4. 验证链接
    if [ -L "feeds/luci/applications/luci-app-zerotier" ]; then
        echo "✅ 符号链接创建成功"
    else
        echo "⚠️  符号链接创建失败，但继续执行"
    fi
    
else
    echo "❌ 错误：luci-app-zerotier 目录不存在！"
    echo "可能是 diy-part1.sh 中的克隆失败了"
    echo "创建空目录防止编译错误..."
    mkdir -p package/luci-app-zerotier
    # 创建最小化 Makefile
    cat > package/luci-app-zerotier/Makefile << 'EOF'
include $(TOPDIR)/rules.mk
LUCI_TITLE:=ZeroTier LuCI
LUCI_DEPENDS:=+zerotier
include $(INCLUDE_DIR)/package.mk
$(eval $(call BuildPackage,luci-app-zerotier))
EOF
fi

# ==================== 确保 zerotier 被选中 ====================
echo "检查 zerotier 配置..."
if [ -f ".config" ]; then
    # 确保 CONFIG_PACKAGE_zerotier 被选中
    if ! grep -q "CONFIG_PACKAGE_zerotier=y" .config; then
        echo "添加 zerotier 到配置..."
        echo "CONFIG_PACKAGE_zerotier=y" >> .config
    fi
    
    # 确保 CONFIG_PACKAGE_luci-app-zerotier 被选中
    if ! grep -q "CONFIG_PACKAGE_luci-app-zerotier=y" .config; then
        echo "添加 luci-app-zerotier 到配置..."
        echo "CONFIG_PACKAGE_luci-app-zerotier=y" >> .config
    fi
fi

# ==================== 可选：添加其他自定义配置 ====================
# 例如，如果你有自定义的 ssr.config 文件
if [ -f "$GITHUB_WORKSPACE/config/ssr.config" ]; then
    echo "加载自定义配置文件 ssr.config..."
    cat "$GITHUB_WORKSPACE/config/ssr.config" >> .config
fi

# ==================== 验证最终配置 ====================
echo "最终配置检查："
echo "1. 检查 zerotier 相关配置："
grep -i "zerotier" .config 2>/dev/null || echo "没有找到 zerotier 配置"

echo "2. 检查 package 目录："
ls -d package/*zerotier* 2>/dev/null || echo "没有找到 zerotier 包"

echo "================================================"
echo "diy-part2.sh 执行完成"
echo "================================================"
