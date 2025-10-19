# ------------------------------------------
# Ultroid - UserBot (Custom Build)
# ------------------------------------------

FROM python:3.13-slim

# Environment setup
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Colombo
ENV PATH="/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Timezone setup
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl bash ffmpeg build-essential libffi-dev libssl-dev python3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone Ultroid source
RUN git clone https://github.com/TeamUltroid/Ultroid /root/TeamUltroid

# Copy local installer script into container
COPY installer.sh /root/TeamUltroid/installer.sh

# Set working directory
WORKDIR /root/TeamUltroid

# Run the installer
RUN bash installer.sh

# Make sure startup script is executable
RUN chmod +x startup

# Default command — start Ultroid
CMD ["bash", "startup"]
