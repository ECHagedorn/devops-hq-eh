#!/usr/bin/env bash
set -e

URLS=(
  "https://www.sailmg.com/"
  "https://api.github.com"
  "https://app.netlify.com/"
)

echo "🔁 Running AI Agent on multiple URLs..."

for url in "${URLS[@]}"; do
  echo -e "\n🌐 Testing URL: $url"

  kubectl exec -i deploy/ai-agent -- expect <<EOF
spawn python3 /app/main.py
expect "🌐 URL>"
send "$url\r"
expect "🌐 URL>"
send "exit\r"
EOF

done

echo -e "\n✅ Done

