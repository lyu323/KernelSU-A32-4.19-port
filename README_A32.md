<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- lyu323 A32 4.19-port-kit (2026-11-24). NEW file; NOT upstream source. -->
# 快速入口（中文）

| 我想… | 去这里 |
| --- | --- |
| 知道为什么没有现成 APK、这台比 4.9 好在哪 | [a32-kit/README.md](a32-kit/README.md) |
| 拿 OPPO 官方内核源码 | [a32-kit/OPPO_SOURCE.md](a32-kit/OPPO_SOURCE.md) |
| 看 4.19 完整集成步骤 | [a32-kit/PORT_PLAN.md](a32-kit/PORT_PLAN.md) |
| 体检我手上的源码树 | `bash a32-kit/scripts/check-a32-source.sh <内核源码目录>` |
| 半自动集成（建软链/改 Makefile/Kconfig） | `bash a32-kit/scripts/integrate-kprobe.sh <内核源码目录>` |
| 看 defconfig 片段 | [a32-kit/config/](a32-kit/config/) |
| 确认有没有现成适配包 | [a32-kit/DEVICES.md](a32-kit/DEVICES.md) |
| 下载官方 v0.9.5 Manager 面板 | 本仓库 Release `a32-kit-1` |

**一句话**：仓库给的是「官方源码 + 设备专属施工图」，不是「成品」。
要成品，需要你提供与 `PDVM00_11_C.29` 匹配的原厂 `boot.img`、已解锁的 Bootloader，
按施工图编译并自行试刷；风险自担。

源码基线：`tiann/KernelSU` **v0.9.5** · commit `b766b98513b5a7eb33bc1c4a76b5702bf1288f07`
