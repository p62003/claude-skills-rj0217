#!/usr/bin/env bash
# passive_recon.sh — 純被動觀察（任何訪客用瀏覽器都看得到的東西）
# 不送 payload、不試漏洞利用，對任何站執行都不越線
# Usage: passive_recon.sh <url>

set -euo pipefail
URL="${1:?Usage: $0 <url>}"
URL="${URL%/}"  # strip trailing slash

echo "=================================================="
echo " passive_recon.sh  target: $URL"
echo "=================================================="

echo ""
echo "=== 1. Response Headers ==="
curl -sIL "$URL" 2>/dev/null | head -40

echo ""
echo "=== 2. TLS ==="
curl -sv "$URL" 2>&1 \
  | grep -iE 'subject:|issuer:|SSL connection|TLS|verify' \
  | head -8

echo ""
echo "=== 3. Public discovery files ==="
for p in robots.txt sitemap.xml .well-known/security.txt security.txt humans.txt ads.txt .well-known/openid-configuration; do
  code=$(curl -sk -o /dev/null -w "%{http_code}" "$URL/$p")
  echo "  $code  /$p"
done

echo ""
echo "=== 4. Common sensitive paths (應該都 404) ==="
for p in .env .git/config .git/HEAD .DS_Store config.json package.json package-lock.json wp-config.php .aws/credentials; do
  code=$(curl -sk -o /dev/null -w "%{http_code}" "$URL/$p")
  if [ "$code" != "404" ] && [ "$code" != "403" ]; then
    echo "  ⚠️  $code  /$p  ← 非 404/403，需人工確認"
  else
    echo "  $code  /$p"
  fi
done

echo ""
echo "=== 5. robots.txt content ==="
curl -sk "$URL/robots.txt" 2>/dev/null | head -30 \
  || echo "  (no robots.txt)"

echo ""
echo "=== 6. security.txt content ==="
curl -sLk "$URL/.well-known/security.txt" 2>/dev/null | head -20 \
  || echo "  (no security.txt)"

echo ""
echo "=== 7. Security headers summary ==="
hdrs=$(curl -sIL "$URL" 2>/dev/null)
for h in 'content-security-policy' 'strict-transport-security' 'x-frame-options' 'x-content-type-options' 'referrer-policy' 'permissions-policy'; do
  line=$(echo "$hdrs" | grep -i "^$h:" | head -1)
  if [ -z "$line" ]; then
    echo "  ❌ $h: (missing)"
  else
    echo "  ✅ $(echo "$line" | tr -d '\r\n')"
  fi
done

echo ""
echo "=== 8. Info-leak headers (should be absent/minimized) ==="
for h in 'x-powered-by' 'server' 'x-aspnet-version'; do
  line=$(echo "$hdrs" | grep -i "^$h:" | head -1)
  [ -n "$line" ] && echo "  ⚠️  $(echo "$line" | tr -d '\r\n')"
done

echo ""
echo "=================================================="
echo " done. AI should now interpret the above."
echo "=================================================="
