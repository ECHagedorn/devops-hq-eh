FROM python:3.10-slim

WORKDIR /app
COPY ai_agent/ ai_agent/
COPY ai_agent/main.py .

RUN pip install requests

CMD ["python", "main.py", "https://2025electionresults.comelec.gov.ph/er-result"]
