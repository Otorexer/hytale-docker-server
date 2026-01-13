FROM eclipse-temurin:25-jdk
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*
WORKDIR /hytale/data
# Copy downloader to a system path so it's always available
COPY hytale-downloader /usr/local/bin/hytale-downloader
RUN chmod +x /usr/local/bin/hytale-downloader
COPY scripts/update_and_start.sh /update_and_start.sh
RUN chmod +x /update_and_start.sh
EXPOSE 5520/udp
VOLUME /hytale/data
ENV RAM_MAX=4G
ENV RAM_MIN=2G
ENTRYPOINT ["/update_and_start.sh"]