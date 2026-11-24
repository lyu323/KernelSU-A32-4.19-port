#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# lyu323 A32 4.19-port-kit (2026-11-24). NEW file; NOT upstream source.
#
# 半自动集成（路线 A）：把本仓库自带的官方 v0.9.5 kernel/ 挂进 OPPO 内核源码树。
# 只建软链 + 改 Makefile/Kconfig，不改 fs 源码、不改 defconfig、不编译、不刷机。
# 用法：
#   bash scripts/integrate-kprobe.sh /path/to/oppo-sm4250-kernel
# 可选：KSU_SRC=/path/to/KernelSU/kernel 覆盖 KSU 源码位置。
set -eu
SRC="${1:-}"
if [ -z "$SRC" ] || [ ! -d "$SRC" ]; then
  echo "usage: bash scripts/integrate-kprobe.sh <kernel-source-dir>" >&2; exit 2
fi
KIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR="$(cd "$KIT_DIR/.." && pwd)"
KSU_SRC="${KSU_SRC:-$REPO_DIR/kernel}"
if [ ! -f "$KSU_SRC/Kconfig" ] || [ ! -f "$KSU_SRC/Makefile" ]; then
  echo "[ERROR] 找不到 KSU 源码：$KSU_SRC（应含 Kconfig 与 Makefile）" >&2; exit 3
fi

cd "$SRC"
if [ -d common/drivers ]; then DRV=common/drivers
elif [ -d drivers ]; then DRV=drivers
else echo "[ERROR] 未找到 drivers/ 或 common/drivers/" >&2; exit 4
fi
MF="$DRV/Makefile"; KC="$DRV/Kconfig"
[ -f "$MF" ] || { echo "[ERROR] 缺 $MF" >&2; exit 4; }
[ -f "$KC" ] || { echo "[ERROR] 缺 $KC" >&2; exit 4; }

echo "== 集成 KernelSU v0.9.5（路线 A / kprobe） =="
echo "   内核源码: $(pwd)"
echo "   KSU 源码: $KSU_SRC"
echo "   drivers : $DRV"

if [ -L "$DRV/kernelsu" ] || [ -e "$DRV/kernelsu" ]; then
  echo "  [skip] $DRV/kernelsu 已存在，未覆盖"
else
  ln -s "$(realpath --relative-to="$DRV" "$KSU_SRC")" "$DRV/kernelsu"
  echo "  [ok]   已建软链 $DRV/kernelsu -> $KSU_SRC"
fi

if grep -q 'kernelsu' "$MF" 2>/dev/null; then
  echo "  [skip] Makefile 已含 kernelsu"
else
  printf '\nobj-$(CONFIG_KSU) += kernelsu/\n' >> "$MF"
  echo "  [ok]   Makefile 追加 obj-\$(CONFIG_KSU) += kernelsu/"
fi

if grep -q 'drivers/kernelsu/Kconfig' "$KC" 2>/dev/null; then
  echo "  [skip] Kconfig 已 source kernelsu"
else
  # 不用 sed -i：受限目录里它 chmod 保留权限会失败；改为生成临时文件再原样写回
  TMP="$(mktemp)"
  awk '/^endmenu/ && !done { print "source \"drivers/kernelsu/Kconfig\""; done=1 } { print }' "$KC" > "$TMP"
  cat "$TMP" > "$KC"
  rm -f "$TMP"
  echo "  [ok]   Kconfig 插入 source \"drivers/kernelsu/Kconfig\""
fi

echo
echo "下一步（人工）："
echo "  1. 把 a32-kit/config/ksu-4.19-kprobe.cfg 合并进 defconfig，make menuconfig 核对依赖"
echo "     （CONFIG_KSU / KPROBES / MODULES / EXT4_FS，EXT4_FS 不开会看不到 CONFIG_KSU）"
echo "  2. 回移植 path_umount 到 fs/namespace.c；建议补 devpts 与 input.c 补丁"
echo "  3. 按 PORT_PLAN.md 编译、fastboot boot 试刷，确认后才 flash"
echo
echo "本脚本未修改任何 fs/ 源码、未改 defconfig、未编译、未刷机。"
