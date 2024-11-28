# 添加 `libcron` 包到 OpenWrt 源代码

以下步骤将指导您如何在 OpenWrt 源代码中添加 `libcron` 包，并进行编译。

## 步骤

1. 在 OpenWrt 源代码目录中执行以下命令：
   ```bash
   mkdir -p Package/libcron && wget -O Package/libcron/Makefile https://raw.githubusercontent.com/immortalwrt/packages/refs/heads/master/libs/libcron/Makefile

2.更新并安装 feeds：
```
./scripts/feeds update -a
./scripts/feeds install -a


