#!/usr/bin/env bash
# bundle_scan.sh — 下載 public JS chunks 搜常見秘密 pattern
# 被動：chunks 是瀏覽器訪問時本來就下載的資源
# Usage: bundle_scan.sh <url>

set -euo pipefail
URL="${1:?Usage: $0 <url>}"
URL="${URL%/}"

SCAN_DIR=$(mktemp -d)
trap 'rm -rf "$SCAN_DIR"' EXIT

echo "=================================================="
echo " bundle_scan.sh  target: $URL"
echo "=================================================="

echo ""
echo "=== Detecting JS chunks ==="
# Support Next.js conventions (with/without basePath prefix)
chunks=$(curl -sk "$URL" 2>/dev/null \
  | grep -oE '(/root|/basePath)?/_next/static/chunks/[^"]+\.js' \
  | sort -u | head -25)
n=$(echo "$chunks" | grep -c . || echo 0)
echo "  found $n Next.js chunks"

if [ "$n" -eq 0 ]; then
  # Try generic /_app/ or /assets/ or /static/
  chunks=$(curl -sk "$URL" 2>/dev/null \
    | grep -oE '/(assets|static|_app)/[^"]+\.js' \
    | sort -u | head -25)
  n=$(echo "$chunks" | grep -c . || echo 0)
  echo "  found $n generic chunks (fallback)"
fi

if [ "$n" -eq 0 ]; then
  echo "  ⚠️  No JS chunks detected. Script assumes Next.js or standard /assets|/static|/_app paths."
  exit 0
fi

for c in $chunks; do
  curl -sk "$URL$c" -o "$SCAN_DIR/$(basename "$c")" 2>/dev/null || true
done
echo "  downloaded $(ls "$SCAN_DIR" | wc -l) chunks to temp dir"

echo ""
echo "=== Secret pattern matching ==="
PATTERNS=(
  # Generic cloud / SaaS
  'AKIA'                  # AWS access key
  'AIza'                  # Google API key
  'ya29\.'                # Google OAuth
  'sk_live_'              # Stripe live
  'sk_test_'              # Stripe test
  'xoxb-'                 # Slack bot token
  'xoxp-'                 # Slack user token
  'ghp_'                  # GitHub classic PAT
  'github_pat_'           # GitHub fine-grained PAT
  'glpat-'                # GitLab PAT
  # Anthropic / OpenAI
  'sk-ant-'               # Anthropic API key
  'sk-proj-'              # OpenAI project key
  # Database / service
  'service_role'
  'SUPABASE_SERVICE'
  'mongodb\+srv://'
  'postgres://.*:.*@'
  # Cryptographic
  'BEGIN RSA'
  'BEGIN OPENSSH'
  'BEGIN PRIVATE'
  'private_key'
  # Custom project patterns
  'CHANNEL_SECRET'
  'ADMIN_PASSWORD'
  'TELEGRAM_BOT_TOKEN'
  'JWT_SECRET'
)
found_any=0
for pat in "${PATTERNS[@]}"; do
  hits=$(grep -rlE "$pat" "$SCAN_DIR/" 2>/dev/null | wc -l)
  if [ "$hits" -gt 0 ]; then
    echo "  🟥 '$pat': $hits file(s)"
    found_any=1
  fi
done
[ "$found_any" -eq 0 ] && echo "  ✅ No known secret patterns detected in $(ls "$SCAN_DIR" | wc -l) chunks"

echo ""
echo "=== Long suspicious string count (false-positive prone, manual review needed) ==="
long_strs=$(grep -rhoE '["\047][A-Za-z0-9_/+=-]{40,}["\047]' "$SCAN_DIR/" 2>/dev/null | wc -l)
echo "  $long_strs strings ≥40 chars found (most are hashes/JWT public parts/module IDs — not secrets by themselves)"

echo ""
echo "=================================================="
echo " done. AI should now interpret results + decide if manual investigation needed."
echo "=================================================="
