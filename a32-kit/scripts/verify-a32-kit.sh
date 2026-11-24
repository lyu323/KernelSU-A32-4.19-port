#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# lyu323 A32 4.19-port-kit (2026-11-24). NEW file; NOT upstream source.
# 只读自检：kit 完整、许可证齐全、新增文件里无二进制/密钥/令牌。
set -u
R="${1:-.}"
echo "== a32-kit 自检 =="
ok=0; bad=0
need() { if [ -e "$R/$1" ]; then echo "  [ok]   $1"; ok=$((ok+1)); else echo "  [MISS] $1"; bad=$((bad+1)); fi }
need LICENSE; need kernel/LICENSE; need kernel/setup.sh
need a32-kit/README.md; need a32-kit/PORT_PLAN.md; need a32-kit/OPPO_SOURCE.md
need a32-kit/DEVICES.md; need a32-kit/COMPLIANCE.md; need a32-kit/NOTICE
need a32-kit/config/ksu-4.19-kprobe.cfg; need a32-kit/config/ksu-4.19-manual.cfg
need a32-kit/scripts/check-a32-source.sh; need a32-kit/scripts/integrate-kprobe.sh
need A32_NOTICE.md
echo
echo "--- 许可证全文长度 ---"; wc -c "$R/LICENSE" "$R/kernel/LICENSE" 2>/dev/null
echo "--- 新增文件里的二进制 / 私钥 / 令牌（应为空） ---"
echo "  (官方 v0.9.5 源码树自带 busybox/ksuinit/libmagiskboot.so 等，属上游原样内容)"
find "$R/a32-kit" -type f \( -name '*.apk' -o -name '*.img' -o -name '*.ko' -o -name '*.so' -o -name '*.jks' -o -name '*.keystore' \) -print
grep -rIlE 'ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|BEGIN (RSA |EC )?PRIVATE KEY' "$R/a32-kit" "$R"/*_NOTICE.md 2>/dev/null || true
echo
echo "result: ok=$ok miss=$bad"
echo "源码基线 = tiann/KernelSU v0.9.5 (b766b98513b5a7eb33bc1c4a76b5702bf1288f07)"
