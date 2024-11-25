#!/bin/bash

# 设置工作目录变量
WORK_DIR="./openwrt"  # OpenWrt 源码目录
BRANCH="master"  # 使用的分支

# 判断是否传入了 -c 参数（强制编译）
FORCE_COMPILE=false  # 默认为不强制编译
while getopts ":c" opt; do
  case ${opt} in
    c )
      FORCE_COMPILE=true  # 如果有 -c 参数，则设置为强制编译
      ;;
    \? )
      echo "无效的选项: $OPTARG" 1>&2  # 错误提示
      ;;
  esac
done

# 保存当前目录
ORIGINAL_DIR=$(pwd)

# 进入工作目录
cd "$WORK_DIR" || { echo "进入目录 $WORK_DIR 失败"; exit 1; }

# 拉取最新代码
git fetch origin $BRANCH  # 拉取远程仓库最新代码
LOCAL=$(git rev-parse HEAD)  # 获取本地代码版本
REMOTE=$(git rev-parse origin/$BRANCH)  # 获取远程仓库代码版本

# 检查本地和远程代码是否一致，或者是否强制编译
if [ "$LOCAL" != "$REMOTE" ] || [ "$FORCE_COMPILE" = true ]; then
    # 如果检测到强制编译参数或代码有更新
    if [ "$FORCE_COMPILE" = true ]; then
        echo "检测到强制编译选项，即使代码是最新的，也开始重新编译。"
    else
        echo "源码已更新，开始重新编译。"
    fi
    # 开始计时
    start=$(date +%s)
    # 拉取最新代码并重新编译
    if ! git pull origin $BRANCH; then
        echo "从 origin/$BRANCH 拉取最新代码失败。"
        exit 1
    fi
    if ! ./scripts/feeds update -a; then
        echo "更新 feeds 失败。"
        exit 1
    fi
    if ! ./scripts/feeds install -a; then
        echo "安装 feeds 失败。"
        exit 1
    fi
    if ! make -j$(nproc) download; then
        echo "下载 packages 失败。"
        exit 1
    fi
    if ! make -j$(nproc --ignore=1); then
        echo "编译失败。"
        exit 1
    fi
    # 结束计时
    end=$(date +%s)
    # 输出编译总耗时
    echo "总编译时间: $((end-start)) 秒"
    # 记录完成时间
    echo "$(date): 编译完成"
else
    # 如果本地代码与远程代码一致，且未传入强制编译参数
    echo "源码已是最新，无需重新编译。"
fi

# 返回原目录
cd "$ORIGINAL_DIR"
