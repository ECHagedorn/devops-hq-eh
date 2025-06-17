FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y expect && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app
COPY setup.py .

RUN pip install -e .

CMD ["python", "app/main.py"]
