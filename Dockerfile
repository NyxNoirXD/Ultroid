# Ultroid - UserBot
# Copyright (C) 2021-2025 TeamUltroid
# This file is a part of < https://github.com/TeamUltroid/Ultroid/ >
# Please read the GNU Affero General Public License in <https://www.github.com/TeamUltroid/Ultroid/blob/main/LICENSE/>.

# --- Build Stage ---
# Use a specific version for reproducibility.
# Use a build-focused image that includes development tools.
FROM python:3.12-alpine AS builder

# Set the working directory
WORKDIR /app

# Install build-time dependencies
# build-base, libffi-dev, and openssl-dev are only needed to build the python packages
RUN apk add --no-cache git curl build-base libffi-dev openssl-dev

# Clone the repository first to leverage Docker layer caching
RUN git clone --depth=1 https://github.com/TeamUltroid/Ultroid.git .

# Create a virtual environment for clean dependency management
RUN python -m venv /opt/venv

# Activate the virtual environment for subsequent commands
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies into the virtual environment
# Combine pip installs into a single layer to reduce image size
RUN pip install --no-cache-dir -U pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir \
        telethon gitpython python-decouple python-dotenv telegraph \
        enhancer requests aiohttp catbox-uploader cloudscraper

# --- Final Stage ---
# Use a slim base image for the final product
FROM python:3.12-alpine

# Set the working directory
WORKDIR /app

# Install ONLY runtime dependencies
RUN apk add --no-cache ffmpeg bash

# Copy the virtual environment from the builder stage
COPY --from=builder /opt/venv /opt/venv

# Copy the application code from the builder stage
COPY --from=builder /app /app

# Activate the virtual environment for the final container
ENV PATH="/opt/venv/bin:$PATH"

# Set the startup command
CMD ["/bin/bash", "-c", "\
    if [ -f .env ]; then set -o allexport; source .env; set +o allexport; fi && \
    if [ \"$SESSION1\" ]; then python3 multi_client.py; else python3 -m pyUltroid; fi \
"]

