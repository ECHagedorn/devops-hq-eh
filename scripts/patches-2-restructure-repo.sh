#!/bin/bash

set -e

cd "$(dirname "$0")/services/ai-agent"

echo "Restructuring ai-agent to match hquarter structure..."

# 1. Create app/ai_agent and move all ai_agent code there
mkdir -p app/ai_agent
mv ai_agent/*.py app/ai_agent/

# 2. Move main.py to app/
mv app/ai_agent/main.py app/

# 3. Remove old ai_agent dir if empty
rmdir ai_agent 2>/dev/null || true

# 4. Create requirements.txt (add your dependencies here)
cat > requirements.txt <<EOF
requests
beautifulsoup4
EOF

# 5. Update Dockerfile to match hquarter style
cat > Dockerfile <<EOF
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app /app/app

CMD ["python", "app/main.py"]
EOF

echo "Done! Structure is now:"
tree .
