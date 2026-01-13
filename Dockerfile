FROM eclipse-temurin:25-jdk
RUN apt-get update && \
    apt-get install -y curl unzip dos2unix && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /hytale/data
COPY hytale-downloader /usr/local/bin/hytale-downloader
RUN chmod +x /usr/local/bin/hytale-downloader
COPY scripts/update_and_start.sh /update_and_start.sh
RUN dos2unix /update_and_start.sh && \
    chmod +x /update_and_start.sh

EXPOSE 5520/udp
VOLUME /hytale/data

# Default Environment Variables
ENV RAM_MAX=4G
ENV RAM_MIN=2G

ENTRYPOINT ["/update_and_start.sh"]