# Ultroid - UserBot
# Copyright (C) 2021-2025 TeamUltroid
# This file is a part of < https://github.com/TeamUltroid/Ultroid/ >
# Please read the GNU Affero General Public License in <https://www.github.com/TeamUltroid/Ultroid/blob/main/LICENSE/>.

# Use a specific version of Python on Alpine for a small base image.
# Using ARG allows for easy updates in the future.
ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-alpine

# Set the working directory early
WORKDIR /app

# Install all system dependencies in a single layer.
# - build-base, libffi-dev, openssl-dev are for building Python packages.
# - ffmpeg, git, bash, curl are runtime dependencies for the application.
RUN apk add --no-cache \
    bash \
    build-base \
    curl \
    ffmpeg \
    git \
    libffi-dev \
    openssl-dev

# Clone the Ultroid repository
RUN git clone --depth=1 https://github.com/TeamUltroid/Ultroid.git .

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

# This line is for the user to uncomment and use if they have a local .env file.
# COPY .env .env

# Set the startup command
CMD ["/bin/bash", "-c", "\
    if [ -f .env ]; then set -o allexport; source .env; set +o allexport; fi && \
    if [ \"$SESSION1\" ]; then python3 multi_client.py; else python3 -m pyUltroid; fi \
"]
