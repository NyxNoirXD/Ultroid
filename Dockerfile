# Ultroid - UserBot (Slim + Neofetch)
FROM python:3.12-slim

# Set timezone and PATH
ENV TZ=Asia/Kolkata
ENV PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl bash ffmpeg mediainfo build-essential libffi-dev libssl-dev tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# Install neofetch manually
RUN curl -fsSL https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o /usr/local/bin/neofetch \
    && chmod +x /usr/local/bin/neofetch

# Clone Ultroid repo
RUN git clone https://github.com/TeamUltroid/Ultroid /root/TeamUltroid

# Copy installer.sh (if you have a custom one)
COPY installer.sh /root/TeamUltroid/

# Set working directory
WORKDIR /root/TeamUltroid

# Ensure startup is executable
RUN chmod +x startup

CMD ["bash"]
