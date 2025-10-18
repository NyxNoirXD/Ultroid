# Ultroid - UserBot
FROM python:3.11-slim

# Set working directory (image-local)
WORKDIR /root/TeamUltroid

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg git bash curl build-essential libffi-dev libssl-dev mediainfo \
    && rm -rf /var/lib/apt/lists/*

# Clone main Ultroid repo + addons/plugins at build time
RUN git clone --depth=1 https://github.com/NyxNoirXD/Ultroid.git /root/TeamUltroid && \
    git clone --depth=1 https://github.com/TeamUltroid/VcBot.git /root/TeamUltroid/vcbot && \
    git clone --depth=1 https://github.com/TeamUltroid/UltroidAddons.git /root/TeamUltroid/addons

# Install Python dependencies at build time
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r /root/TeamUltroid/requirements.txt && \
    pip install --no-cache-dir -r /root/TeamUltroid/resources/startup/optional-requirements.txt

# Copy installer.sh for runtime environment handling only
COPY installer.sh /installer.sh
RUN chmod +x /installer.sh

# Startup CMD: copy to /data, load .env, start bot
CMD ["/bin/bash", "-c", "\
    mkdir -p /data/Ultroid && \
    cp -r /root/TeamUltroid/. /data/Ultroid/ && \
    cd /data/Ultroid && \
    bash /installer.sh --dir=/data/Ultroid --no-root --skip-pip --skip-clone && \
    if [ \"$SESSION1\" ]; then python3 multi_client.py; else bash startup; fi \
"]
