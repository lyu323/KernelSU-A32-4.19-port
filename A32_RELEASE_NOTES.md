<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- lyu323 A32 4.19-port-kit (2026-11-24). NEW file; NOT upstream source. -->
# Release `a32-kit-1` · OPPO A32 / 4.19 移植包

## 资产

| 文件 | 说明 |
| --- | --- |
| `KernelSU_v0.9.5_11872-release.apk` | **官方原版** v0.9.5 Manager，minSdk 26，Android 11 可装；非适配版、不给 root |
| `KernelSU-v0.9.5-source.zip` | 官方 v0.9.5 tag 完整源码（逐字节未改），commit `b766b985…` |
| `a32-kit.zip` | 设备专属移植包：PORT_PLAN / OPPO_SOURCE / DEVICES / 两个脚本 / 配置片段 / 合规文档 |
| `LICENSE` | GPL-3.0-or-later 全文 |
| `kernel-LICENSE` | GPL-2.0-only 全文 |
| `README-zh.md` | 中文交付说明 |

## 适用

OPPO A32（`PDVM00` / `OP4E35`）· ColorOS `V11.1` / Android 11 ·
高通 `SM4250`（骁龙 460）· 内核 `4.19.152-perf+` · `PDVM00_11_C.29`。

**4.19 在官方最低 4.14 回移植范围内，kprobe 自动集成为首选**；但仍属非 GKI，
官方不提供 boot 镜像，Manager 里的一键 LKM/GKI 对 4.19 不适用。
官方非官方支持设备列表与 GitHub 搜索均**无现成适配包**；OPPO 官方有精确对应 SM4250 的
两个内核源码仓库，见 `a32-kit/OPPO_SOURCE.md`。

## 不提供 / 风险

不含 `boot.img` / `.ko` / 一键 root；需要解锁 Bootloader、备份原厂镜像、自行编译内核；
刷错可能变砖。**未做真机验证**。Manager 单装只显示「未安装 / Unsupported」，这是正确状态。

## 合规

`kernel/**` = GPL-2.0-only，其余 = GPL-3.0-or-later，两份全文随包。
任何基于本仓库构建并对外分发的二进制，必须随附该次构建的对应源码与两份许可证；
私有仓库只适合自留产物，不能据此对外闭源分发。
