# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-ubuntu:arm32v7-focal-version-127ce7ef

ARG VERSION
ARG RADARR_RELEASE
ARG DEBIAN_FRONTEND=noninteractive

ENV RADARR_BRANCH="master"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN apt update; apt upgrade -y; apt install -y jq curl sqlite3 libicu66 xmlstarlet mediainfo
RUN mkdir -p /app/radarr/bin && \
  if [ -z ${RADARR_RELEASE+x} ]; then \
    RADARR_RELEASE=$(curl -sL "https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/changes?runtime=netcore&os=linux" \
    | jq -r '.[0].version'); \
  fi && \
  curl -o \
    /tmp/radarr.tar.gz -L \
    "https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/updatefile?version=5.28.0.10274&os=linux&runtime=netcore&arch=arm" && \
  tar xzf \
    /tmp/radarr.tar.gz -C \
    /app/radarr/bin --strip-components=1 && \
  echo -e "UpdateMethod=docker\nBranch=${RADARR_BRANCH}" > /app/radarr/package_info && \
  apt-get clean && \
  rm -rf \
    /app/radarr/bin/Radarr.Update \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY root/ /
EXPOSE 7878
VOLUME /config