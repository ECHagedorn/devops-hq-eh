#!/bin/bash
set -e

echo "🔧 Patching executor.py for generic web agent behavior..."

cat > services/ai-agent/ai_agent/executor.py <<'EOF'
from bs4 import BeautifulSoup

def execute_plan(plan, response=None, url=None):
    if plan == "direct_parse":
        try:
            data = response.json()
            return f"Parsed JSON:\nTop-level keys: {list(data.keys())}"
        except Exception as e:
            return f"Failed to parse JSON: {str(e)}"

    if plan == "scrape_with_bs4":
        try:
            soup = BeautifulSoup(response.text, "html.parser")
            title = soup.title.string.strip() if soup.title else "No title"
            links = [a.get('href') for a in soup.find_all('a', href=True)]
            return f"HTML Title: {title}\nFound {len(links)} links"
        except Exception as e:
            return f"Failed to scrape HTML: {str(e)}"

    if plan == "manual_api_discovery":
        return "This appears to be a JavaScript-rendered site. Consider using a headless browser to inspect dynamic API activity."

    if plan in ["crawl_er_api", "crawl_coc_api"]:
        if "comelec.gov.ph" not in (url or ""):
            return "This action is COMELEC-specific and not applicable to this domain."
        return "Would crawl COMELEC's public API endpoints starting at /api/regions"

    return "No execution performed"
EOF

echo "✅ Patched executor.py"

echo "🔧 Patching utils.py to conditionally show disclaimer..."

cat > services/ai-agent/ai_agent/utils.py <<'EOF'
def print_disclaimer(url: str):
    if "comelec.gov.ph" in url:
        print("\n📜 DISCLAIMER:")
        print("This data was retrieved from the publicly accessible COMELEC 2025 election results portal:")
        print("→ https://2025electionresults.comelec.gov.ph")
        print("\nThe information is provided as-is for educational, analytical, and civic transparency purposes.")
        print("It does not represent an official tally or endorsement by COMELEC or the Government of the Philippines.")
        print("Redistribution or publication of this data should clearly attribute COMELEC as the original source.")
        print("Please use responsibly and respect any official clarifications or updates from COMELEC.\n")
EOF

echo "✅ Patched utils.py"

echo "🔧 Updating main.py to pass URL to disclaimer..."

# Safely replace print_disclaimer() with print_disclaimer(url)
sed -i 's/print_disclaimer()/print_disclaimer(url)/g' services/ai-agent/ai_agent/main.py

echo "✅ Patched main.py to pass URL to disclaimer"

echo "🎉 All patches applied. You can now rebuild your Docker image and redeploy."

