#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# lyu323 A32 4.19-port-kit (2026-11-24). NEW file; NOT upstream source.
#
# 只读体检：检查 OPPO sm4250 内核源码树是否具备 kprobe 路线条件。
# 不修改文件、不编译、不刷机。用法：
#   bash scripts/check-a32-source.sh /path/to/oppo-sm4250-kernel
set -u
SRC="${1:-}"
if [ -z "$SRC" ] || [ ! -d "$SRC" ]; then
  echo "usage: bash scripts/check-a32-source.sh <kernel-source-dir>" >&2; exit 2
fi
cd "$SRC" || exit 2

echo "== OPPO A32 / SM4250 / 4.19 移植体检（只读） =="
echo "   dir: $(pwd)"; echo

echo "--- kernel version ---"
V=$(grep -m1 '^VERSION = ' Makefile 2>/dev/null | awk '{print $3}')
P=$(grep -m1 '^PATCHLEVEL = ' Makefile 2>/dev/null | awk '{print $3}')
S=$(grep -m1 '^SUBLEVEL = ' Makefile 2>/dev/null | awk '{print $3}')
echo "  Makefile: ${V:-?}.${P:-?}.${S:-?}"
if [ "${V:-0}" -eq 4 ] 2>/dev/null && [ "${P:-0}" -eq 19 ] 2>/dev/null; then
  echo "  => 4.19：在官方最低 4.14 回移植范围内，kprobe 自动集成为首选"
elif [ "${V:-0}" -eq 4 ] 2>/dev/null && [ "${P:-0}" -ge 14 ] 2>/dev/null; then
  echo "  => 4.14+：官方兼容范围，但仍需自行编译内核"
else
  echo "  => 版本与 4.19.152 不符：请核对是否选错分支（必须匹配 PDVM00_11_C.29）"
fi
echo

echo "--- tree layout ---"
for d in drivers common/drivers fs/exec.c fs/open.c fs/read_write.c fs/stat.c fs/namespace.c fs/devpts/inode.c drivers/input/input.c arch/arm64/configs; do
  [ -e "$d" ] && echo "  [ok]   $d" || echo "  [MISS] $d"
done
[ -d drivers/kernelsu ] && echo "  [ok]   drivers/kernelsu 已集成" || echo "  [--]   drivers/kernelsu 尚未建（跑 integrate-kprobe.sh）"
echo

echo "--- 关键符号（路线 B 才需要；路线 A 仅供参考） ---"
sym() { l="$1"; f="$2"; s="$3"; if [ -f "$f" ] && grep -q "$s" "$f" 2>/dev/null; then printf '  [yes] %-18s %-24s %s\n' "$l" "$s" "$f"; else printf '  [no ] %-18s %-24s %s\n' "$l" "$s" "$f"; fi; }
sym do_faccessat   fs/open.c        'do_faccessat'
sym vfs_statx      fs/stat.c        'vfs_statx'
sym vfs_fstatat    fs/stat.c        'vfs_fstatat'
sym vfs_read       fs/read_write.c  'vfs_read'
sym execve         fs/exec.c        'do_execveat_common'
sym devpts         fs/devpts/inode.c 'devpts_get_priv'
if [ -f fs/namespace.c ] && grep -Eq 'path_umount[[:space:]]*\(' fs/namespace.c 2>/dev/null; then
  echo '  [yes] path_umount      (function present)      fs/namespace.c'; HAS_UMOUNT=1
else
  echo '  [no ] path_umount      (needs backport)        fs/namespace.c'; HAS_UMOUNT=0
fi
echo

echo "--- config state ---"
CFG=""
for c in .config arch/arm64/configs/*_defconfig arch/arm64/configs/vendor/*_defconfig; do
  [ -f "$c" ] && CFG="$c" && break
done
if [ -n "$CFG" ]; then
  echo "  config: $CFG"
  for k in CONFIG_KSU CONFIG_KPROBES CONFIG_HAVE_KPROBES CONFIG_KPROBE_EVENTS CONFIG_MODULES CONFIG_EXT4_FS; do
    v=$(grep -m1 -E "^${k}=|^# ${k} is not set" "$CFG" 2>/dev/null || echo '(not set)')
    echo "    $k -> $v"
  done
else
  echo "  (未找到 .config / defconfig；先跑厂商 defconfig)"
fi
echo

echo "--- 结论 ---"
echo "  1. 首选路线 A：kprobe 自动集成，开 CONFIG_KSU + KPROBES + MODULES + EXT4_FS，内核源码零改动。"
echo "  2. 必做：fs/namespace.c 回移植 path_umount（4.19 < 5.9）；建议补 devpts 与 input.c。"
[ "$HAS_UMOUNT" -eq 0 ] && echo "     -> 当前源码缺 path_umount 函数，需回移植"
echo "  3. 4.19 有 do_faccessat / vfs_statx，若 kprobe 坏了改走路线 B，官方 4 个补丁可直接用，并关掉 KPROBES。"
echo "  4. 先原样编译能开机，再集成；fastboot boot 试刷不落盘，确认后才 flash。"
echo
echo "本脚本只读；不验证 OPPO 源码是否完整、不保证编译通过、不保证能开机。"
