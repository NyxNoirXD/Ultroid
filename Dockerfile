# Ultroid - UserBot
# Copyright (C) 2021-2025 TeamUltroid
# This file is a part of < https://github.com/TeamUltroid/Ultroid/ >
# PLease read the GNU Affero General Public License in <https://www.github.com/TeamUltroid/Ultroid/blob/main/LICENSE/>.

FROM python:3.12-slim

# Set timezone
ENV TZ=Asia/Colombo
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl bash ffmpeg neofetch build-essential libffi-dev libssl-dev tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# Clone Ultroid repo
RUN git clone https://github.com/TeamUltroid/Ultroid /root/TeamUltroid

# Copy installer.sh into the repo root (if you have it locally)
COPY installer.sh /root/TeamUltroid/

# Run installer
WORKDIR /root/TeamUltroid
RUN bash installer.sh && chmod +x startup

# Default command to start Ultroid
CMD ["bash", "startup"]
