# Ultroid - UserBot (Docker Production Ready)
FROM python:3.12-slim

# Set timezone and PATH
ENV TZ=Asia/Kolkata
ENV PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
# Install basic system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg \
    git \
    bash \
    curl \
    build-essential \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install neofetch manually
RUN curl -fsSL https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o /usr/local/bin/neofetch \
    && chmod +x /usr/local/bin/neofetch

# Set working directory
WORKDIR /app

# Clone Ultroid repository
RUN git clone --depth=1 https://github.com/TeamUltroid/Ultroid.git .

# Install Python dependencies
RUN pip install --no-cache-dir -U pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir -r resources/startup/optional-requirements.txt \
    && pip install --no-cache-dir \
        telethon gitpython python-decouple python-dotenv telegraph \
        enhancer requests aiohttp catbox-uploader cloudscraper

# COPY .env .env

# Startup
CMD ["/bin/bash", "-c", "\
    if [ -f .env ]; then set -o allexport; source .env; set +o allexport; fi && \
    if [ \"$SESSION1\" ]; then python3 multi_client.py; else python3 -m pyUltroid; fi \
"]
