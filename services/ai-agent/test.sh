#!/usr/bin/env bash
set -e

URLS=(
  "https://www.sailmg.com/"
  "https://api.github.com"
  "https://app.netlify.com/"
  "https://jsonplaceholder.typicode.com/posts"
  "https://reqres.in/api/users"
)

if [ ${#URLS[@]} -gt 50 ]; then
  echo "❌ Too many URLs. Max is 50."
  exit 1
fi

echo "🔁 Running AI Agent with CLI-passed URLs..."

kubectl exec -it deploy/ai-agent -- python3 /app/app/main.py "${URLS[@]}"

echo -e "\n✅ Done"
