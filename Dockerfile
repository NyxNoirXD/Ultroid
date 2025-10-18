# Ultroid - UserBot
FROM python:3.12-slim

# Working directory (image-local)
WORKDIR /root/TeamUltroid

# Install system dependencies + clone repo + prepare /data in one RUN
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg git bash curl build-essential libffi-dev libssl-dev mediainfo neofetch \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /data/Ultroid \
    && git clone --depth=1 https://github.com/NyxNoirXD/Ultroid.git /root/TeamUltroid

# Copy installer.sh
COPY installer.sh /installer.sh
RUN chmod +x /installer.sh

# Startup CMD
CMD ["/bin/bash", "-c", "\
    cp -r /root/TeamUltroid/. /data/Ultroid/ && \
    cd /data/Ultroid && \
    bash /installer.sh --dir=/data/Ultroid --no-root && \
    bash startup \
"]
