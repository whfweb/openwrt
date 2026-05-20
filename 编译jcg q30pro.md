在 Ubuntu 22.04 (推荐) 或 20.04 的终端中，按顺序执行以下命令：

bash
# 1. 安装编译依赖
sudo apt update
sudo apt install build-essential clang flex g++ gawk gcc-multilib g++-multilib gettext git libncurses-dev libssl-dev python3-distutils python3-pyelftools rsync unzip zlib1g-dev file wget

# 2. 克隆你指定的 OpenWrt 官方源码
git clone https://github.com/openwrt/openwrt.git
cd openwrt

# 3. 更新软件包列表
./scripts/feeds update -a
./scripts/feeds install -a
步骤二：集成优化驱动并配置
这是提升 WiFi 性能最关键的一步。

1. 替换 WiFi 驱动
为了让你的设备在 5G 频段获得更高速度和稳定性，建议使用 MediaTek 开源驱动（MT76）的最新版本。执行：

bash
rm -rf package/kernel/mt76
git clone https://github.com/openwrt/mt76 package/kernel/mt76
注意：如果你的网络环境访问 GitHub 不稳定，可以等进入 make menuconfig 后，在 Kernel modules -> Wireless Drivers 中确保 <*> kmod-mt76 及其子选项为选中状态。

2. 运行配置菜单

bash
make menuconfig
请按下表进行配置：

菜单路径	选项	推荐选择值	说明
Target System	目标系统	MediaTek Ralink ARM	选择 CPU 架构
Subtarget	子目标	MT7981	选择芯片组
Target Profile	设备型号	JCG Q30 PRO	请务必找到并选中此项
LuCI → Collections	Web 界面	luci	勾选以生成 Web 管理界面
LuCI → Applications	额外应用	luci-app-ttyd (终端), luci-app-statistics (统计)	根据需要按 Y 键勾选
3. 编译固件
配置完成后，保存并退出菜单，然后开始编译。

bash
make -j$(nproc) V=s
-j$(nproc)：使用所有 CPU 核心加速编译，如果遇到错误，改为 make -j1 V=s 进行单线程编译以便查看完整错误日志。

V=s：输出详细的编译信息。

首次编译会非常漫长，大约需要数小时，这取决于你的网络和 CPU 性能。它会自动下载工具链、内核源码和所有软件包。

编译成功后，固件位于 bin/targets/mediatek/mt7981/ 目录下。你会看到两个重要文件：

...-initramfs-....bin：用于首次通过 U-Boot 刷入。

...-sysupgrade-....bin：用于在 OpenWrt 后台直接升级。
