# Ultroid - UserBot (Custom Slim Build)
# Copyright (C) 2021-2025 TeamUltroid
# https://github.com/TeamUltroid/Ultroid

FROM python:3.12-slim

# Set timezone and PATH
ENV TZ=Asia/Colombo
ENV PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl bash ffmpeg mediainfo build-essential libffi-dev libssl-dev tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# Install neofetch
RUN curl -fsSL https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o /usr/local/bin/neofetch \
    && chmod +x /usr/local/bin/neofetch

# Clone Ultroid repo
RUN git clone https://github.com/TeamUltroid/Ultroid /root/TeamUltroid

# Copy local installer.sh (if you have it)
COPY installer.sh /root/TeamUltroid/

# Set working directory
WORKDIR /root/TeamUltroid

# Run installer and ensure startup is executable
RUN bash installer.sh && chmod +x startup

# Start Ultroid
CMD ["bash", "startup"]
