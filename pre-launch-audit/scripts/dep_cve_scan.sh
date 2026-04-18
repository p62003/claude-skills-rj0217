#!/usr/bin/env bash
# dep_cve_scan.sh — 依賴層 CVE 掃描（Node.js）
# 包 npm audit，JSON 摘要版本數
# Usage: dep_cve_scan.sh [path-to-project]

set -euo pipefail
PROJECT="${1:-.}"

if [ ! -d "$PROJECT" ]; then
  echo "❌ path not found: $PROJECT"
  exit 1
fi

cd "$PROJECT"

if [ ! -f package.json ]; then
  echo "❌ no package.json in $PROJECT — this script is for Node.js projects"
  exit 1
fi

echo "=================================================="
echo " dep_cve_scan.sh  target: $(pwd)"
echo "=================================================="

echo ""
echo "=== npm audit (full text) ==="
npm audit --audit-level=low 2>&1 | head -100 || true

echo ""
echo "=== Severity summary (JSON parsed) ==="
npm audit --json 2>/dev/null | python3 - <<'PYEOF' 2>/dev/null || echo "  (JSON parse failed — use text output above)"
import json, sys
try:
    data = json.load(sys.stdin)
    meta = data.get('metadata', {})
    vulns = meta.get('vulnerabilities', {})
    total = vulns.get('total', 0)
    print(f"  Total vulnerabilities: {total}")
    for sev in ('critical', 'high', 'moderate', 'low', 'info'):
        n = vulns.get(sev, 0)
        marker = '🟥' if sev in ('critical', 'high') and n > 0 else ('🟨' if sev == 'moderate' and n > 0 else '  ')
        print(f"    {marker} {sev}: {n}")
    # List high/critical advisories
    advs = data.get('vulnerabilities', {})
    critical_list = []
    for pkg, info in advs.items():
        if info.get('severity') in ('critical', 'high'):
            critical_list.append(f"{pkg} [{info.get('severity')}] via {', '.join(info.get('via', [])[:2])}")
    if critical_list:
        print("\n  High/Critical packages:")
        for c in critical_list[:10]:
            print(f"    - {c}")
except Exception as e:
    print(f"  Parse error: {e}")
PYEOF

echo ""
echo "=== Actionable fixes ==="
echo "  - npm audit fix          # 自動升級 semver 兼容的版本"
echo "  - npm audit fix --force  # ⚠️ 含 breaking changes，逐件確認"
echo "  - GitHub Dependabot:     Settings → Security → Dependabot alerts"

echo ""
echo "=================================================="
echo " done. AI should distinguish:"
echo "   - direct deps CVE = 立即修"
echo "   - transitive deps CVE = 看是否 no fix available / 評估影響面"
echo "=================================================="
