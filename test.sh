#!/usr/bin/env bash
set -e

URLS=(
  "https://www.sailmg.com/"
  "https://api.github.com"
  "https://app.netlify.com/"
)

if [ ${#URLS[@]} -gt 10 ]; then
  echo "❌ Too many URLs. Limit is 10."
  exit 1
fi

echo "🔁 Running AI Agent on multiple URLs..."

for url in "${URLS[@]}"; do
  echo -e "\n🌐 Testing URL: $url"

  expect <<EOEXP
spawn kubectl exec -it deploy/ai-agent -- python3 /app/app/main.py
expect "🌐 URL>"
send "$url\r"
expect "🌐 URL>"
send "exit\r"
EOEXP

done

echo -e "\n✅ Done"
