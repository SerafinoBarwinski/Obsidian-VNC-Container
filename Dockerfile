FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV APP_DIR=/app

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    ca-certificates \
    jq \
    xfce4 \
    xfce4-terminal \
    tigervnc-standalone-server \
    tigervnc-common \
    novnc \
    websockify \
    x11-xserver-utils \
    dbus-x11 \
    libnss3 \
    libgtk-3-0 \
    libxss1 \
    libasound2 \
    libgbm1 \
    libfuse2 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app
WORKDIR /app

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 6080

CMD ["/entrypoint.sh"]