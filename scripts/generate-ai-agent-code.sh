#!/bin/bash

set -e

PROJECT_NAME="ai-agent-comelec"
mkdir -p $PROJECT_NAME/{ai_agent,k8s}

# --- Python Files ---
cat > $PROJECT_NAME/ai_agent/__init__.py <<EOF
# Package init
EOF

cat > $PROJECT_NAME/ai_agent/main.py <<EOF
from ai_agent.url_fetcher import fetch_url
from ai_agent.classifier import classify_page
from ai_agent.analyzer import analyze_page
from ai_agent.planner import plan_action
from ai_agent.executor import execute_plan
from ai_agent.utils import print_disclaimer
import sys

def main(url):
    response = fetch_url(url)
    if not response:
        print("❌ Failed to fetch URL.")
        return

    page_type = classify_page(response)
    intent = analyze_page(url, response)
    plan = plan_action(page_type, intent)
    result = execute_plan(plan)

    print("\\n🔍 Classification:", page_type)
    print("🧠 Intent:", intent)
    print("🗺️ Plan:", plan)
    print("�� Result:", result)

    print_disclaimer()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python main.py <url>")
        sys.exit(1)
    main(sys.argv[1])
EOF

cat > $PROJECT_NAME/ai_agent/url_fetcher.py <<EOF
import requests

def fetch_url(url):
    try:
        headers = {"User-Agent": "Mozilla/5.0"}
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        return response
    except requests.RequestException as e:
        print(f"Fetch error: {e}")
        return None
EOF

cat > $PROJECT_NAME/ai_agent/classifier.py <<EOF
def classify_page(response):
    content_type = response.headers.get("Content-Type", "").lower()
    body = response.text.lower()

    if "application/json" in content_type:
        return "json-api"
    elif "text/html" in content_type:
        if "react" in body or "<script" in body and "loading" in body:
            return "js-app"
        elif "<html" in body:
            return "static-html"
    return "unknown"
EOF

cat > $PROJECT_NAME/ai_agent/analyzer.py <<EOF
def analyze_page(url, response):
    url_lower = url.lower()
    text = response.text.lower()
    if "comelec" in url_lower and "er-result" in url_lower:
        return "election returns portal"
    if "coc-result" in url_lower:
        return "certificate of canvass portal"
    return "unknown site intent"
EOF

cat > $PROJECT_NAME/ai_agent/planner.py <<EOF
def plan_action(page_type, intent):
    if "election returns" in intent:
        return "crawl_er_api"
    elif "certificate of canvass" in intent:
        return "crawl_coc_api"
    elif page_type == "json-api":
        return "direct_parse"
    elif page_type == "static-html":
        return "scrape_with_bs4"
    elif page_type == "js-app":
        return "manual_api_discovery"
    return "no_action"
EOF

cat > $PROJECT_NAME/ai_agent/executor.py <<EOF
def execute_plan(plan):
    if plan == "crawl_er_api":
        return "Would call /api/regions → ... → /api/er-summary"
    if plan == "crawl_coc_api":
        return "Would call /api/regions → ... → /api/coc-summary"
    if plan == "direct_parse":
        return "Would parse JSON"
    if plan == "scrape_with_bs4":
        return "Would scrape with BeautifulSoup"
    if plan == "manual_api_discovery":
        return "Needs JS or browser emulation to discover API"
    return "No execution performed"
EOF

cat > $PROJECT_NAME/ai_agent/utils.py <<EOF
def print_disclaimer():
    print("\\n📜 DISCLAIMER:")
    print("This data was retrieved from the publicly accessible COMELEC 2025 election results portal:")
    print("→ https://2025electionresults.comelec.gov.ph")
    print("\\nThe information is provided as-is for educational, analytical, and civic transparency purposes.")
    print("It does not represent an official tally or endorsement by COMELEC or the Government of the Philippines.")
    print("Redistribution or publication of this data should clearly attribute COMELEC as the original source.")
    print("Please use responsibly and respect any official clarifications or updates from COMELEC.\\n")
EOF

# --- Dockerfile ---
cat > $PROJECT_NAME/Dockerfile <<EOF
FROM python:3.10-slim

WORKDIR /app
COPY ai_agent/ ai_agent/
COPY ai_agent/main.py .

RUN pip install requests

CMD ["python", "main.py", "https://2025electionresults.comelec.gov.ph/er-result"]
EOF

# --- Kubernetes Job YAML ---
cat > $PROJECT_NAME/k8s/job.yaml <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: ai-agent-comelec-job
spec:
  template:
    spec:
      containers:
      - name: ai-agent
        image: your-dockerhub-username/ai-agent-comelec:latest
        imagePullPolicy: IfNotPresent
      restartPolicy: Never
  backoffLimit: 1
EOF

echo "✅ Project scaffolded at: $PROJECT_NAME/"
echo "📦 To build: docker build -t your-dockerhub-username/ai-agent-comelec ."
echo "🚀 To deploy: kubectl apply -f k8s/job.yaml"

