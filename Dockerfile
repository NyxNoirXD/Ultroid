# Ultroid - UserBot
FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg git bash curl build-essential libffi-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone Ultroid source
RUN git clone --depth=1 https://github.com/TeamUltroid/Ultroid.git .

# Install Python dependencies
RUN pip install --no-cache-dir -U pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir -r resources/startup/optional-requirements.txt \
    && pip install --no-cache-dir \
        telethon gitpython python-decouple python-dotenv telegraph \
        enhancer requests aiohttp catbox-uploader cloudscraper

# Create a separate folder for persistent data (to be mounted in Kubernetes)
RUN mkdir -p /data

# Startup command
CMD ["/bin/bash", "-c", "\
    mkdir -p /data/Ultroid && \
    cp -r /app/. /data/Ultroid/ && \
    cd /data/Ultroid && \
    if [ -f .env ]; then set -o allexport; source .env; set +o allexport; fi && \
    python3 -m pyUltroid \
"]
