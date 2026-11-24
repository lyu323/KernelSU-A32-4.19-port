<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- lyu323 A32 4.19-port-kit (2026-11-24). NEW file; NOT upstream source. -->
# 现成适配包核查（2026-11-24）

结论：**没有**针对 OPPO A32 / PDVM00 的现成 KernelSU 内核或 boot 包，必须自己编。

| 核查项 | 结果 |
| --- | --- |
| 官方「非官方支持设备」列表 | 无 `OPPO` / `A32` / `PDVM00` / `SM4250` 条目 |
| GitHub 仓库搜索 `PDVM00 KernelSU` | 0 结果 |
| `sm4250 KernelSU` | 0 结果 |
| `OPPO A32 KernelSU` | 0 结果 |
| `PDVM00 kernel` | 0 结果 |
| 官方 v3.3.1 LKM 资产 | 16 个，全是 `android12-5.10` ~ `android17-6.18`，无 4.19 |
| 官方历史 51 个 Release | 无 4.19 / 非 GKI 通用 boot 镜像 |

但**有两个官方源码仓库**精确对应本机 SoC（这是好消息，源码不用自己找第三方）：

- https://github.com/oppo-source/android_kernel_oppo_sm4250
- https://github.com/oppo-source/android_kernel_modules_and_devicetree_oppo_sm4250

⚠️ 因此：网上任何声称「A32 / PDVM00 专用 KSU boot.img / 一键 root 包」的东西都值得怀疑，
**别拿来路不明的镜像刷**；按 `OPPO_SOURCE.md` + `PORT_PLAN.md` 自己从官方源码编才是可靠路径。
