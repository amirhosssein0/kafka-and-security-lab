# Flask App Dockerfile
FROM python:3.10-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt && \
    rm -rf ~/.cache/pip

# Copy application code
COPY app.py .

# Set environment variables
ENV FLASK_ENV=production

# Expose the port and run Flask
EXPOSE 5000
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]