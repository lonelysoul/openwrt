#!/bin/bash

# 设置变量
REPO_URL="https://github.com/openwrt/openwrt"  # OpenWrt 源码仓库地址
BRANCH="master"  # 使用的分支
CONFIG_URL="https://raw.githubusercontent.com/lonelysoul/openwrt/main/.config"  # 配置文件 URL
SRC_DIR="openwrt"  # 源码目录名称
DIY_PART1_URL="https://raw.githubusercontent.com/lonelysoul/openwrt/main/diy-part1.sh"  # diy-part1 脚本 URL
XDP_MK_URL="https://raw.githubusercontent.com/lonelysoul/openwrt/refs/heads/main/xdp-sockets-diag.mk"  # xdp-sockets-diag.mk 文件 URL

# 保存当前目录
ORIGINAL_DIR=$(pwd)

# 依赖包列表
DEPENDENCIES=(
  ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev libssl-dev libtool lrzsz mkisofs msmtp ninja-build p7zip p7zip-full patch pkgconf python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig texinfo uglifyjs unzip vim wget xmlto xxd zlib1g-dev clang-13
)

# 打印分隔符
print_step() {
  echo -e "\n=== $1 ===\n"
}

# 检查命令是否成功执行
check_command_success() {
  if [ $? -ne 0 ]; then
    echo "错误: $1 执行失败，退出程序。"
    exit 1
  fi
}

# 安装依赖
print_step "更新包列表并安装依赖"
sudo apt update && sudo apt install -y "${DEPENDENCIES[@]}"
check_command_success "依赖安装"

# 克隆源码
print_step "克隆 OpenWrt 源码仓库"
if [ -d "$SRC_DIR" ]; then
  echo "目录 $SRC_DIR 已存在，跳过克隆步骤。"
else
  git clone -b $BRANCH --single-branch --filter=blob:none $REPO_URL $SRC_DIR
  check_command_success "git clone"
fi

# 下载并执行 diy-part1.sh
print_step "执行 diy-part1.sh"
wget -O $SRC_DIR/diy-part1.sh $DIY_PART1_URL
check_command_success "wget diy-part1.sh"
chmod +x $SRC_DIR/diy-part1.sh
(cd $SRC_DIR && bash diy-part1.sh)
check_command_success "diy-part1.sh"

# 进入源码目录
cd $SRC_DIR || { echo "错误: 无法进入源码目录 $SRC_DIR"; exit 1; }

# 更新和安装 feeds
print_step "更新和安装 feeds"
./scripts/feeds update -a
check_command_success "feeds update"

./scripts/feeds install -a
check_command_success "feeds install"

# 原来的 diy-part2 内容开始
print_step "执行原来的 diy-part2 内容"

# 下载 luci-app-daed 插件
print_step "克隆 luci-app-daed 插件"
git clone https://github.com/QiuSimons/luci-app-daed package/dae
check_command_success "克隆 luci-app-daed"

# 下载 xdp-sockets-diag.mk 文件并附加到 netsupport.mk
print_step "下载 xdp-sockets-diag.mk 并追加到 netsupport.mk"
wget -O xdp-sockets-diag.mk $XDP_MK_URL
check_command_success "wget xdp-sockets-diag.mk"

if [ -f "package/kernel/linux/modules/netsupport.mk" ]; then
  echo -e "\n\n" >> package/kernel/linux/modules/netsupport.mk
  cat xdp-sockets-diag.mk >> package/kernel/linux/modules/netsupport.mk
  check_command_success "追加 xdp-sockets-diag.mk 到 netsupport.mk"
else
  echo "错误: 文件 package/kernel/linux/modules/netsupport.mk 未找到！"
  exit 1
fi

print_step "原来的 diy-part2 内容执行完成"

# 下载并覆盖配置文件
print_step "下载并覆盖配置文件 .config"
wget -O .config $CONFIG_URL
check_command_success "wget .config"

# 补全配置
print_step "补全配置"
make defconfig
check_command_success "make defconfig"

# 返回原目录
cd $ORIGINAL_DIR || { echo "错误: 无法返回初始目录 $ORIGINAL_DIR"; exit 1; }

# 提示完成
print_step "初始化安装完成"
