# Ultroid - UserBot (Docker Production Ready)
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

# Copy custom installer.sh if you have one
COPY installer.sh /root/TeamUltroid/

# Set working directory
WORKDIR /root/TeamUltroid

# Ensure startup is executable
RUN chmod +x startup

# Add entrypoint to run installer.sh on first start, then startup
RUN echo '#!/usr/bin/env bash\n\
if [ ! -f /.installed ]; then\n\
    echo "Running installer.sh..."\n\
    bash installer.sh --no-root\n\
    touch /.installed\n\
fi\n\
echo "Starting Ultroid..."\n\
exec bash startup' > /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

# Use entrypoint to handle first-run installer
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
