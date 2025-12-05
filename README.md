## 编译命令

1. 首先装好 Linux 系统，推荐 Debian 11 或 Ubuntu LTS


2. 安装编译依赖
   ```bash
   sudo apt update -y
   sudo apt full-upgrade -y
   sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
   bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
   git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev \
   libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool lrzsz \
   mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-pip libpython3-dev qemu-utils \
   rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev
   ```

3. 下载源代码，更新 feeds 并选择配置

   ```bash
git config --global http.sslverify false

git config --global https.sslverify false

git clone -b master  https://github.com/whfweb/openwrt.git
   
cd openwrt

sudo apt update
sudo apt install build-essential libncurses5-dev gawk git libssl-dev gettext zlib1g-dev swig unzip time rsync python3 python3-setuptools
   
   ./scripts/feeds update -a
   
   ./scripts/feeds install -a
   
   make menuconfig
   ```

4. 下载 dl 库，编译固件
（-j 后面是线程数，第一次编译推荐用单线程）

   ```bash
   make download -j8
   make V=s -j1
   ```


二次编译：

make clean     仅仅是清除之前编译的可执行文件及配置文件，比如bin路径下面的文件，config配置文件不会清除。
make distclean 清除所有生成的文件，连feeds也会干掉，只留下git clone完成时候的初始状态。
make -j$(($(nproc) + 1)) V=s

```bash
cd openwrt
git pull
./scripts/feeds update -a
./scripts/feeds install -a
make defconfig
make download -j8
make V=s -j$(nproc)
```

如果需要重新配置：

rm -rf ./tmp && rm -rf .config



make clean      
make distclean  

![OpenWrt logo](include/logo.png)

# 检查ubuntu子系统当前代理设置
echo $http_proxy
echo $https_proxy

# 如果没有设置，可以临时设置（端口9090是DevSidecar默认）
export http_proxy=http://127.0.0.1:9090
export https_proxy=http://127.0.0.1:9090

# 1. 清除当前终端会话的代理
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY

# 2. 验证已清除
echo "http_proxy=$http_proxy"
echo "https_proxy=$https_proxy"
# 应该显示空行
