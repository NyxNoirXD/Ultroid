# Ultroid - UserBot
# Copyright (C) 2021-2025 TeamUltroid
# This file is a part of < https://github.com/TeamUltroid/Ultroid/ >
# Please read the GNU Affero General Public License in <https://www.github.com/TeamUltroid/Ultroid/blob/main/LICENSE/>.

FROM python:3.12-slim AS builder

# 1. Install build-time dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        build-essential \
        libffi-dev \
        libssl-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone Ultroid repository
RUN git clone --depth=1 https://github.com/TeamUltroid/Ultroid.git .

RUN pip install --no-cache-dir -U pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir -r resources/startup/optional-requirements.txt

FROM python:3.12-slim

# 3. Install only RUNTIME system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        git \
        bash \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# 4. Copy artifacts from the builder stage
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /app /app

# Startup command
CMD ["/bin/bash", "-c", "\
    if [ -f .env ]; then set -o allexport; source .env; set +o allexport; fi && \
    if [ \"$SESSION1\" ]; then python3 multi_client.py; else python3 -m pyUltroid; fi \
"]
