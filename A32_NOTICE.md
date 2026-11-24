<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- lyu323 A32 4.19-port-kit (2026-11-24). NEW file; NOT upstream source. -->
# ⚠️ 这个仓库是什么 / 不是什么

**是**：官方 KernelSU **v0.9.5** 完整源码（逐字节未改）+ 针对 **OPPO A32 / PDVM00 /
SM4250 / 内核 4.19.152 / Android 11** 的**设备专属移植包**：OPPO 官方两个 sm4250 源码仓库入口、
kprobe 自动集成步骤、4.19 回移植清单、只读体检脚本、半自动集成脚本、defconfig 片段、
GPL 双许可合规说明。外加一个 Android 11 能装的**官方原版 Manager 面板**。

**不是**：

- ❌ 装上就有 root 的「适配版 APK」
- ❌ 可刷入的 `boot.img` / `kernelsu.ko` / AnyKernel3 包
- ❌ 官方开箱即用的设备（那是 GKI 2.0 / 5.10+；本机 4.19 属非 GKI）

**好消息**：4.19 ≥ 官方最低回移植 4.14，**kprobe 自动集成**是官方推荐路线，源码零改动，
比 4.9 老内核容易很多；OPPO 官方也公开了**精确对应 SM4250** 的两个内核源码仓库。

入口：[README_A32.md](README_A32.md) ｜ [移植清单](a32-kit/PORT_PLAN.md) ｜
[OPPO 源码](a32-kit/OPPO_SOURCE.md) ｜ [合规](a32-kit/COMPLIANCE.md)
