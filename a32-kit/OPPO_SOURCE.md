<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- lyu323 A32 4.19-port-kit (2026-11-24). NEW file; NOT upstream source. -->
# OPPO A32（PDVM00）官方内核源码获取

## 1. 两个精确对应 SM4250 的官方仓库（已核实存在）

| 仓库 | 用途 |
| --- | --- |
| https://github.com/oppo-source/android_kernel_oppo_sm4250 | 主内核源码 |
| https://github.com/oppo-source/android_kernel_modules_and_devicetree_oppo_sm4250 | **附加**模块 / 设备树源码（OPPO 编译必需） |

这两条是 `oppo-source` 官方组织下**与本机 SoC 直接对应**的仓库；GitHub 搜索
`org:oppo-source sm4250` 返回且仅返回这两个。

## 2. 分支必须核对

主仓库存在类似 `oppo/sm4250_s_12.1_f19` 的分支（对应 ColorOS 12.1 / F19、F17、A73、A74 等
SM4250 机型）。**PDVM00 是 Android 11 / ColorOS 11.1 / `PDVM00_11_C.29` / 内核 4.19.152**，
请进仓库 Branches 里找与 `C.29`、`11`、`4.19` 或 `PDVM00` 对应的分支/tag；
**不要直接拿 12.1 分支编给 11.1 的机器**，内核版本与驱动不匹配会不开机。

核对方式：下载后看根目录 `Makefile` 的 `VERSION/PATCHLEVEL/SUBLEVEL` 是否 `4.19.*`，
以及 `arch/arm64/configs/`（或 `vendor/` 子目录）里的 defconfig 名是否对应 bengal/sm4250。

## 3. 用 wget 下载，不要 git clone

社区移植指南明确提醒：**OPPO 内核源码请用 `wget` 下载而不是 git**（仓库体积大、历史深），
且**编译时需要额外克隆附加内核源码**（就是上表第二个仓库）。示例：

```bash
# 先在网页上确认分支名，再下 tarball（把 <BRANCH> 换成实际分支）
wget -O oppo-sm4250-kernel.tar.gz \
  https://codeload.github.com/oppo-source/android_kernel_oppo_sm4250/tar.gz/refs/heads/<BRANCH>
wget -O oppo-sm4250-modules.tar.gz \
  https://codeload.github.com/oppo-source/android_kernel_modules_and_devicetree_oppo_sm4250/tar.gz/refs/heads/<BRANCH>
tar xf oppo-sm4250-kernel.tar.gz
tar xf oppo-sm4250-modules.tar.gz
```

两个包按 OPPO 的编译脚本要求放到对应目录（通常是 `kernel/msm-4.19` 与
`vendor/oplus/kernel` 之类的布局，以仓库内 `AndroidKernel.mk` / `OplusKernelEnvConfig.mk` 为准）。

## 4. 原厂 boot.img（必须备份）

- 版本必须与你手机当前系统**完全一致**：`PDVM00_11_C.29`。
- 从**官方固件包**解包提取（`payload.bin` 用 `payload-dumper-go`，`.ofp` 用对应解包工具），
  不要拿别的机型/别的版本的 boot 来补。
- 记下它的**压缩格式**（gz / lz4 / 未压缩），重打包时必须一致。
- 刷之前先把这份原厂镜像放在电脑里，`fastboot flash boot <原厂>` 就是救砖通路。

## 5. 已核实：没有现成适配包

官方「非官方支持设备」列表里没有 A32/PDVM00/SM4250；GitHub 搜
`PDVM00 KernelSU`、`sm4250 KernelSU`、`OPPO A32 KernelSU`、`PDVM00 kernel` 全部 0 结果。
所以**没有现成可刷的 KSU boot 内核**，必须自己编；也**不要刷来路不明的 boot.img**。

## 6. 合规

OPPO 依 GPL 义务公开内核源码；你基于它编译并分发二进制时，同样要随附对应源码与许可证，
详见 `COMPLIANCE.md`。
