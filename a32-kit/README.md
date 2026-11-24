<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- lyu323 A32 4.19-port-kit (2026-11-24). NEW file; NOT upstream source. -->
# OPPO A32（PDVM00）/ 内核 4.19.152 · KernelSU 移植包

> **一句话**：这台比 4.9 那台**近得多**——`4.19` 落在官方「最低支持 4.14」回移植范围内，
> **kprobe 自动集成**是官方推荐路线，不用手动改 4 个 fs 文件。
> 但它仍是**非 GKI 内核**，官方**不提供可刷的 boot.img**，所以本仓库依旧
> **不是「装上就 root 的适配版 APK」**。root 在内核侧，必须用 OPPO 官方内核源码编译。

## 设备卡（来自「关于手机 / 版本信息」截图）

| 项 | 值 |
| --- | --- |
| 机型 | OPPO A32 · `PDVM00`（`OP4E35`） |
| 系统 | ColorOS `V11.1` · Android **11** |
| SoC | 高通 **SM4250**（骁龙 460，11nm，八核 Kryo 240） |
| 内核 | **`4.19.152-perf+`** |
| 版本号 | `PDVM00_11_C.29` |
| 基带 | `Q_V1_P14,Q_V1_P14` |
| 内存 | 4.00 GB（+1.00 GB 扩展） |

## 为什么本次「更接近可用」

| 判断 | 结论 |
| --- | --- |
| 官方主线 v1.0+ 只支持 GKI 2.0（5.10+） | ❌ 本机 4.19，**不在开箱即用范围** |
| 官方非 GKI 最低回移植到 **4.14** | ✅ **4.19 ≥ 4.14，在官方兼容范围** |
| 官方推荐 4.19 的集成方式 | ✅ **kprobe 自动集成**（`CONFIG_KSU=y` + KPROBES），源码零改动 |
| 官方是否给非 GKI boot.img | ❌ 明确不给（碎片化），必须自编 |
| Manager 一键 LKM / GKI 安装 | ❌ 只适配 5.10+ GKI，本机不可用 |
| Android 11 能装哪个 Manager | ✅ **v0.9.5**（minSdk 26）；v3.x 是 minSdk 31，装不上 |

官方 FAQ 原文：*KernelSU is backported to kernel 4.14 now. For older kernels, you need to
backport it manually*；非 GKI 文档：*we don't have a universal way to build them; therefore,
we cannot provide a non-GKI boot.img*。

## 仓库内容

| 路径 | 内容 |
| --- | --- |
| `kernel/`、`userspace/`、`manager/` … | 官方 `tiann/KernelSU` **v0.9.5 tag 完整源码，逐字节未改** |
| `LICENSE` / `kernel/LICENSE` | GPL-3.0-or-later / GPL-2.0-only 全文 |
| `a32-kit/PORT_PLAN.md` | **设备专属**逐步骤：源码 → kprobe 集成 → 编译 → 试刷 |
| `a32-kit/OPPO_SOURCE.md` | OPPO 官方两个 sm4250 源码仓库、分支与 wget 获取方式 |
| `a32-kit/config/*.cfg` | kprobe 路线 / 手动回退路线的 defconfig 片段 |
| `a32-kit/scripts/check-a32-source.sh` | **只读**体检你手上的内核源码树 |
| `a32-kit/scripts/integrate-kprobe.sh` | **半自动**集成：建软链 + 改 Makefile/Kconfig（不编译、不刷机） |
| `a32-kit/DEVICES.md` | 已核实：无现成社区适配包，别刷来路不明 boot.img |
| `a32-kit/COMPLIANCE.md` / `NOTICE` | GPL 双许可与分发义务 |

## 三步走（真正拿到 root）

1. **拿源码 + 原厂 boot**：OPPO 官方开源组织有**精确对应本机 SoC** 的两个仓库
   （见 `OPPO_SOURCE.md`）；同时备份与 `PDVM00_11_C.29` **完全一致**的原厂 `boot.img`。
2. **先原样编译能开机**（不加任何修改）。这步过不了，后面都别做。
3. **集成 v0.9.5 + 编译 + 试刷**：按 `PORT_PLAN.md`，kprobe 路线开
   `CONFIG_KSU=y` / `KPROBES` / `MODULES` / `EXT4_FS`，回移植 `path_umount`，
   `fastboot boot` 不落盘试刷 → 确认开机且面板识别 → 才 `fastboot flash boot`。

⚠️ 需要**解锁 Bootloader**；刷错内核会变砖；**未做真机验证**，不担保能开机。

## 那个 Manager APK

Release 里的 `KernelSU_v0.9.5_11872-release.apk` 是**官方原版、未修改**的 v0.9.5 面板
（`me.weishu.kernelsu` / minSdk 26 / 官方证书）。Android 11 可安装，打开显示
「未安装 / Unsupported」是**正确状态**——没有内核侧 KSU 就不会有 root。
