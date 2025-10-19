# ==========================
# 🧩 Ultroid - UserBot
# Optimized Dockerfile
# ==========================
FROM python:3.12-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg git bash curl build-essential libffi-dev libssl-dev python3-dev && \
    rm -rf /var/lib/apt/lists/*

# Create app directory and a separate persistent data directory
RUN mkdir -p /app /data/Ultroid

# Set working directory to the persistent location
WORKDIR /data/Ultroid

# Clone Ultroid source directly into /app (read-only code)
RUN git clone --depth=1 https://github.com/TeamUltroid/Ultroid.git /app

# Install Python dependencies
RUN pip install -U pip setuptools wheel && \
    pip install -r /app/requirements.txt && \
    pip install -r /app/resources/startup/optional-requirements.txt && \
    pip install telethon gitpython python-decouple python-dotenv telegraph \
                enhancer requests aiohttp catbox-uploader cloudscraper

# Create a non-root user for security
RUN useradd -m ultroid && chown -R ultroid:ultroid /data /app
USER ultroid

# Copy files to /data/Ultroid only if not already present
ENTRYPOINT ["/bin/bash", "-c", "\
    if [ ! -d /data/Ultroid/pyUltroid ]; then \
        echo '📦 Copying Ultroid source to /data/Ultroid (first run)...'; \
        cp -r /app/. /data/Ultroid/; \
    fi && \
    cd /data/Ultroid && \
    if [ -f .env ]; then set -o allexport; source .env; set +o allexport; fi && \
    echo '🚀 Starting Ultroid from /data/Ultroid'; \
    exec python3 -m pyUltroid \
"]
