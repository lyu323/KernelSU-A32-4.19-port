<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- lyu323 A32 4.19-port-kit (2026-11-24). NEW file; NOT upstream source. -->
# 合规说明（GPL 双许可）

## 许可证

| 范围 | 许可证 | 文件 |
| --- | --- | --- |
| `kernel/**` | **GPL-2.0-only** | `kernel/LICENSE`（18 092 B） |
| 其余（`userspace/`、`manager/`、`website/` …） | **GPL-3.0-or-later** | `LICENSE`（35 149 B） |

两份全文**逐字节未改**，随仓库与每个 Release 资产分发。

## 源码来源与改动

- 根目录源码 = 官方 `tiann/KernelSU` **v0.9.5 tag**，commit
  `b766b98513b5a7eb33bc1c4a76b5702bf1288f07`，**逐字节未改动**（从官方 codeload zip 展开）。
- **新增**文件仅：`a32-kit/**`、`A32_NOTICE.md`、`README_A32.md`、
  `A32_RELEASE_NOTES.md`、`.github/workflows/publish-a32-kit.yml`。
  每个都带 `SPDX-License-Identifier: GPL-3.0-or-later` 与日期声明。
- 新增内容是**设备专属移植准备材料**（文档 + 只读/半自动脚本 + 配置片段 + CI），
  **没有改动上游任何 `.c` / `.h` / `.kt` / Makefile**；`integrate-kprobe.sh` 只作用于
  **你自己提供的 OPPO 内核源码目录**，不修改本仓库上游源码。
- 官方 v0.9.5 源码树**自带**少量预编译工具（`userspace/ksud/bin/*/{busybox,ksuinit}`、
  `manager/app/src/main/jniLibs/*/libmagiskboot.so` 等），属上游原样内容，其源码同在仓库；
  本仓库没有添加任何新二进制。

## 分发义务（沿用你补充的合规背景）

> KernelSU 上游是 GPL 开源协议，任何修改后再分发的版本，都必须随包提供对应源码并保留许可证；
> 私有仓库只适合你自己留存构建产物，不能据此对外闭源分发。

1. 任何基于本仓库构建并对外分发的二进制（**你将来编出的 boot.img、`kernelsu.ko`、
   重编的 Manager APK**），必须随附**该次构建的对应源码**与两份许可证全文。
2. 修改 `kernel/**` 按 GPL-2.0 §2(a) 标注改动文件与日期；其余按 GPL-3.0 §5(a) 同样标注。
3. **私有仓库只适合自留产物，不能据此对外闭源分发**。本仓库是 public。
4. 这次分发的是**上游 GPL 源码本身**，必须完整公开、不能裁剪核心代码。
5. OPPO 依 GPL 公开的内核源码有它自己的许可；你编译并分发其衍生镜像时同样要遵守。

## 官方 Manager APK

Release 里的 `KernelSU_v0.9.5_11872-release.apk` 取自**官方 v0.9.5 Release**、未修改，
仅作 Android 11 可安装的管理面板参考；对应源码即本仓库 `manager/` 树（GPL-3.0-or-later），
两份许可证随包。它不是本仓库编译产物，不声称「适配 4.19」。

## 不提供

- 预编译 `boot.img` / `.ko` / AnyKernel3 包（官方也没有；未验证镜像不发给用户刷）
- 「适配版 / 一键 root」APK
- 绕过安全补丁、exploit 调参、刷机担保
