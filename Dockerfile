FROM ubuntu:22.04

ARG RADARR_BRANCH="master"
ARG DEBIAN_FRONTEND=noninteractive

ENV RADARR_BRANCH="${RADARR_BRANCH}"
ENV XDG_CONFIG_HOME="/config/xdg"
ENV PUID=1001
ENV PGID=1001
ENV TZ=Europe/Amsterdam

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y ca-certificates tzdata curl jq sqlite3 xmlstarlet mediainfo gnupg2 apt-utils adduser coreutils && \
    # pick the newest libicu package available on this platform
    LIBICU="$(apt-cache pkgnames | grep -E '^libicu[0-9]+' | sort -V | tail -n1)" && \
    if [ -n "$LIBICU" ]; then apt-get install -y "$LIBICU"; fi && \
    mkdir -p /app/radarr/bin /config && \
    # install gosu for safe user switch at runtime
    curl -fsSL -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.14/gosu-armhf" && \
    chmod +x /usr/local/bin/gosu && gosu nobody true || true && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

RUN mkdir -p /app/radarr/bin && \
  RADARR_RELEASE=$(curl -sL "https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/changes?runtime=netcore&os=linux" | jq -r '.[0].version'); \
  curl -o /tmp/radarr.tar.gz -L "https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/updatefile?version=${RADARR_RELEASE}&os=linux&runtime=netcore&arch=arm" && \
  tar xzf /tmp/radarr.tar.gz -C /app/radarr/bin --strip-components=1 && \
  echo -e "UpdateMethod=docker\nBranch=${RADARR_BRANCH}" > /app/radarr/package_info && \
  rm -rf /tmp/*

COPY root/ /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 7878
VOLUME /config

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/app/radarr/bin/Radarr", "-nobrowser"]