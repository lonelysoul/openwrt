#!/bin/bash

# 设置变量
REPO_URL="https://github.com/openwrt/openwrt"
BRANCH="openwrt-23.05"
CONFIG_URL="https://raw.githubusercontent.com/lonelysoul/openwrt/main/.config"
SRC_DIR="openwrt"

# 保存当前目录
ORIGINAL_DIR=$(pwd)

# 依赖包列表
DEPENDENCIES=(
  ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev libssl-dev libtool lrzsz mkisofs msmtp ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev
)

# 更新包列表并安装依赖
sudo apt update && sudo apt install -y "${DEPENDENCIES[@]}"

# 检查命令是否成功执行
check_command_success() {
  if [ $? -ne 0 ]; then
    echo "Error: $1 failed. Exiting."
    exit 1
  fi
}

# 克隆源码
clone_repo() {
  if [ -d "$SRC_DIR" ]; then
    echo "目录 $SRC_DIR 已存在，跳过克隆步骤。"
  else
    git clone -b $BRANCH --single-branch --filter=blob:none $REPO_URL $SRC_DIR
    check_command_success "git clone"
    # 进入源码目录并执行 diy-part1.sh
    if [ -f "$SRC_DIR/diy-part1.sh" ]; then
      (cd $SRC_DIR && bash diy-part1.sh)
      check_command_success "diy-part1.sh"
    else
      echo "Warning: $SRC_DIR/diy-part1.sh not found, skipping."
    fi
  fi
}

# 更新和安装 feeds
update_and_install_feeds() {
  ./scripts/feeds update -a
  check_command_success "feeds update"

  ./scripts/feeds install -a
  check_command_success "feeds install"

  # 执行 diy-part2.sh
  if [ -f "diy-part2.sh" ]; then
    bash diy-part2.sh
    check_command_success "diy-part2.sh"
  else
    echo "Warning: diy-part2.sh not found, skipping."
  fi
}

# 下载并覆盖配置文件
download_config() {
  if [ -f ".config" ]; then
    echo ".config 文件已存在，将被覆盖。"
  fi
  wget -O .config $CONFIG_URL
  check_command_success "wget .config"
}

# 主要执行步骤
main() {
  clone_repo

  # 进入源码目录
  cd $SRC_DIR

  update_and_install_feeds

  download_config

  # 补全配置
  make defconfig
  check_command_success "make defconfig"
}

main

# 返回原目录
cd $ORIGINAL_DIR

# 提示完成
echo "初始化安装完成。"
