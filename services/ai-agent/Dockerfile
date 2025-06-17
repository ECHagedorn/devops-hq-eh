FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app
COPY setup.py .

RUN pip install -e .

CMD ["python", "app/main.py"]
