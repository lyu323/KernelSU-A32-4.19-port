<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- lyu323 A32 4.19-port-kit (2026-11-24). NEW file; NOT upstream source. -->
# PDVM00 / 4.19.152 · KernelSU v0.9.5 集成逐步骤

> 依据：官方 [非 GKI 集成文档（已归档）](https://kernelsu.org/zh_CN/guide/how-to-integrate-for-non-gki.html)、
> [FAQ](https://kernelsu.org/zh_CN/guide/faq.html)、v0.9.5 `kernel/setup.sh`。
> **4.19 ≥ 官方最低 4.14**，kprobe 路线是官方推荐；但仍属非 GKI，官方不给 boot.img。

## 0. 前置（缺一不可）

- OPPO 两个官方 sm4250 源码仓库（见 `OPPO_SOURCE.md`），分支与 `PDVM00_11_C.29` 匹配
- 原厂 `boot.img`（同版本、同压缩格式）、救砖刷回通路
- **已解锁 Bootloader**、fastboot、对应 Clang/交叉工具链、`mkbootimg`
- 先「原样编译一次并能正常开机」——**这是第一道验收**，过不了就别集成

## 1. 路线 A（首选）：kprobe 自动集成，内核源码零改动

### 1.1 把 KSU 加进内核树

在内核源码根目录执行（**参数是 `v0.9.5`，不是 main**）：

```bash
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/v0.9.5/kernel/setup.sh" | bash -s v0.9.5
```

或离线用本仓库自带的 wrapper（不联网、不 clone，直接用本仓库根目录的 `kernel/`）：

```bash
bash a32-kit/scripts/integrate-kprobe.sh /path/to/oppo-sm4250-kernel
```

脚本只做三件事：建 `drivers/kernelsu` 软链、往 `drivers/Makefile` 追加
`obj-$(CONFIG_KSU) += kernelsu/`、往 `drivers/Kconfig` 插 `source "drivers/kernelsu/Kconfig"`。
**不碰任何 fs 文件、不编译、不刷机。**

### 1.2 defconfig（参考 `config/ksu-4.19-kprobe.cfg`）

```
CONFIG_KSU=y
CONFIG_KPROBES=y
CONFIG_HAVE_KPROBES=y
CONFIG_KPROBE_EVENTS=y
CONFIG_MODULES=y
CONFIG_EXT4_FS=y
```

两个容易漏的硬依赖：

- 官方 Kconfig 是 `depends on KPROBES && EXT4_FS`，**`CONFIG_EXT4_FS` 没开时 menuconfig 里
  根本看不到 `CONFIG_KSU`**；
- `KPROBES` 起不来时先查 `CONFIG_MODULES`，再用 `make menuconfig` 搜依赖逐个补。

defconfig 可能在 `arch/arm64/configs/` 或 `arch/arm64/configs/vendor/`，两处都查。

### 1.3 4.19 必做的回移植与可选补丁

| 文件 | 作用 | 4.19 必要性 |
| --- | --- | --- |
| `fs/namespace.c` ← 回移植 `path_umount` | 「卸载模块」功能 | **必需**（内核 < 5.9；参考官方归档文档末尾补丁 / PR #1464） |
| `fs/devpts/inode.c` → `devpts_get_priv` | 修 root 后 `pm` 命令失效 | **建议** |
| `drivers/input/input.c` | KernelSU 安全模式组合键 | **建议** |

kprobe 路线**不要**手动改 `fs/exec.c`、`fs/open.c`、`fs/read_write.c`、`fs/stat.c`。

### 1.4 编译 / 试刷 / 落盘

```bash
# 编译（工具链与 OPPO 构建脚本保持一致）
make ARCH=arm64 <你的_defconfig>
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- -j$(nproc)

# 用原厂 ramdisk 重打包；压缩格式必须与原厂一致
mkbootimg --kernel <Image.gz|Image.lz4> --ramdisk <原厂ramdisk> -o boot-ksu.img

# 关键：先不落盘试刷
fastboot boot boot-ksu.img

# 确认开机、Manager 识别、`su` 可用，才落盘
fastboot flash boot boot-ksu.img && fastboot reboot
```

## 2. 路线 B（kprobe 坏了才用）：手动挂 4 个 hook

**先验证是不是 kprobe 的锅**：注释 `kernel/ksu.c` 里 `ksu_sucompat_init()` 与
`ksu_ksud_init()`，若这样能正常开机 → kprobe 在 OPPO 这颗内核上不可靠，改走手动。

手动路线与 4.9 那台不同，**4.19 反而更简单**：

| hook | 4.19 上的符号 | 说明 |
| --- | --- | --- |
| `fs/open.c` | `do_faccessat` | 4.17+ 已有，**官方补丁可直接用**（4.9 才需要改挂 faccessat 系统调用） |
| `fs/exec.c` | `do_execveat_common` / `__do_execve_file` | 按实际签名插 `ksu_handle_execveat*`，注意变量声明不能穿插语句 |
| `fs/read_write.c` | `vfs_read` | 官方补丁 |
| `fs/stat.c` | `vfs_statx` | 4.19 已有；**若实际内核没有才**回退 `vfs_fstatat` |

配置（`config/ksu-4.19-manual.cfg`）：`CONFIG_KSU=y` + `MODULES` + `EXT4_FS`，
**必须关掉 `CONFIG_KPROBES`**（否则开机按音量下会误触 KSU 安全模式）。
`path_umount` 回移植、devpts、input.c 三样照样要做。

> 补充：KernelSU **Next** 的 4.19 手动路线把 read hook 挂在 `SYSCALL_DEFINE3(read)`
> 而非 `vfs_read`（其 issue #1133）。本仓库基于**官方 v0.9.5**，按上表走；
> 若你改用 KSU Next，以它自己的文档为准。

## 3. 验收与排错

| 症状 | 原因 | 处理 |
| --- | --- | --- |
| menuconfig 找不到 `CONFIG_KSU` | 没跑 setup.sh / `EXT4_FS` 或 `KPROBES` 没开 | 查软链、`drivers/Kconfig`、依赖 |
| 卡 logo / bootloop | kprobe 坏或 hook 插错 | 刷回原厂 boot → 注释两个 init 验证 → 改手动路线 |
| 开机误入安全模式 | 手动路线却没关 KPROBES | 关闭后重编 |
| `pm` 命令异常 | 缺 devpts hook | 补 `fs/devpts/inode.c` |
| 卸载模块不生效 | 缺 `path_umount` 回移植 | 补 `fs/namespace.c` |
| 面板 `Unsupported` | 内核没集成或没刷入新内核 | 确认当前启动的是你编的内核 |
| 刷完不开机 | 压缩格式/ramdisk/分支不匹配 | 用原厂 `fastboot flash boot` 救回 |

## 4. 本仓库不提供 / 不做

- ❌ 预编译 `boot.img`、`kernelsu.ko`、AnyKernel3 包（官方也没有，且未验证镜像给人刷会变砖）
- ❌ 「适配版」Manager APK（root 不在 APK 里）
- ❌ 自动编译出可刷镜像的 CI（OPPO 源码分支/附加仓库/工具链需人工核对，且无真机验证）
- ❌ 绕过安全补丁、exploit 调参、刷机担保

`check-a32-source.sh` 与 `integrate-kprobe.sh` 都只作用于你给的内核源码目录，
**不碰手机、不刷分区**。
