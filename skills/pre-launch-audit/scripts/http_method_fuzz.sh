#!/usr/bin/env bash
# http_method_fuzz.sh — HTTP 方法列舉
# 不送 payload，只看哪些方法回什麼狀態碼
# 用於 Phase 4，使用前應已取得用戶授權
# Usage: http_method_fuzz.sh <url-or-endpoint>

set -euo pipefail
URL="${1:?Usage: $0 <url-or-endpoint>}"

METHODS=(GET POST PUT DELETE PATCH TRACE HEAD OPTIONS)

echo "=================================================="
echo " http_method_fuzz.sh  target: $URL"
echo "=================================================="
echo ""

for m in "${METHODS[@]}"; do
  code=$(curl -sk -o /dev/null -w "%{http_code}" -X "$m" "$URL" 2>/dev/null)
  case "$code" in
    2*)  marker="✅" ;;
    3*)  marker="↪️" ;;
    401|403) marker="🔒" ;;
    404) marker="❌" ;;
    405) marker="⛔" ;;
    429) marker="⏱" ;;
    5*)  marker="💥" ;;
    *)   marker="❓" ;;
  esac
  printf "  %-8s %s  %s\n" "$m" "$code" "$marker"
done

echo ""
echo "Legend: ✅ 2xx OK  ↪️ 3xx redirect  🔒 401/403 blocked  ❌ 404  ⛔ 405 method not allowed  ⏱ 429 rate limit  💥 5xx server error"
echo ""
echo "=================================================="
echo " done. AI should interpret:"
echo "   - Unexpected 2xx on destructive methods (PUT/DELETE) = concerning"
echo "   - 405 on POST-only endpoint for other methods = correct"
echo "   - 200 on TRACE = possible info leak (XST-style)"
echo "=================================================="
