FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

COPY app app

EXPOSE 80

CMD ["python", "app/webhook.py"]