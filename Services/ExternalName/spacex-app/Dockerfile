FROM python:3.10-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt && \
    rm -rf ~/.cache/pip 

# Copy application files
COPY app.py .
COPY templates/ ./templates/
COPY static/ ./static/


ENV FLASK_ENV=production
ENV SPACEX_API_HOST=api.spacexdata.com


# Expose Flask port
EXPOSE 5000

# Run Flask app
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]