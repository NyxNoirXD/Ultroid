# Ultroid - UserBot
# Copyright (C) 2021-2025 TeamUltroid
# This file is a part of < https://github.com/TeamUltroid/Ultroid/ >
# Please read the GNU Affero General Public License in <https://www.github.com/TeamUltroid/Ultroid/blob/main/LICENSE/>.

ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-alpine

# Set the working directory early
WORKDIR /app

# Install all system dependencies in a single layer.

RUN apk add --no-cache \
    bash \
    build-base \
    curl \
    ffmpeg \
    git \
    libffi-dev \
    openssl-dev

# Clone the Ultroid repository
RUN git clone --depth 1 --branch alpine https://github.com/NyxNoirXD/Ultroid .

# Install all Python dependencies in a single RUN command to create a single layer.
# --no-cache-dir is used to keep the image size down.
RUN pip install --no-cache-dir -U pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir -r resources/startup/optional-requirements.txt \
    && pip install --no-cache-dir \
        telethon \
        gitpython \
        python-decouple \
        python-dotenv \
        telegraph \
        enhancer \
        requests \
        aiohttp \
        catbox-uploader \
        cloudscraper


# COPY .env .env

# Set the startup command
CMD ["/bin/bash", "-c", "\
    if [ -f .env ]; then set -o allexport; source .env; set +o allexport; fi && \
    if [ \"$SESSION1\" ]; then python3 multi_client.py; else python3 -m pyUltroid; fi \
"]
